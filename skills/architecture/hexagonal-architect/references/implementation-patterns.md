# Hexagonal Architecture — Implementation Patterns

## Architecture Diagram

```
            ┌─────────────────────────────────────────┐
            │              ADAPTERS                   │
            │  ┌─────────┐           ┌─────────┐     │
            │  │  REST   │           │ GraphQL │     │
            │  │   API   │           │   API   │     │
            │  └────┬────┘           └────┬────┘     │
            │       │                     │          │
            │       ▼                     ▼          │
            │  ┌─────────────────────────────────┐   │
            │  │         INPUT PORTS             │   │
            │  │      (Use Case Interfaces)      │   │
            │  └─────────────┬───────────────────┘   │
            │                │                       │
            │                ▼                       │
            │  ┌─────────────────────────────────┐   │
            │  │           DOMAIN                │   │
            │  │   (Entities, Business Logic)    │   │
            │  └─────────────┬───────────────────┘   │
            │                │                       │
            │                ▼                       │
            │  ┌─────────────────────────────────┐   │
            │  │        OUTPUT PORTS             │   │
            │  │    (Repository Interfaces)      │   │
            │  └─────────────┬───────────────────┘   │
            │                │                       │
            │       ┌───────┴───────┐               │
            │       ▼               ▼               │
            │  ┌─────────┐     ┌─────────┐         │
            │  │ Postgres│     │  Redis  │         │
            │  │ Adapter │     │ Adapter │         │
            │  └─────────┘     └─────────┘         │
            └─────────────────────────────────────────┘

Dependency Rule: Dependencies point INWARD.
Domain knows nothing about adapters.
```

## Port (Interface)

```typescript
// application/ports/output/user-repository.port.ts
export interface UserRepositoryPort {
  save(user: User): Promise<void>;
  findById(id: UserId): Promise<User | null>;
  findByEmail(email: Email): Promise<User | null>;
}

// Symbol for dependency injection
export const USER_REPOSITORY = Symbol('USER_REPOSITORY');
```

## Use Case

```typescript
// application/use-cases/create-user.use-case.ts
@Injectable()
export class CreateUserUseCase implements CreateUserPort {
  constructor(
    @Inject(USER_REPOSITORY)
    private readonly userRepo: UserRepositoryPort,
    private readonly eventBus: EventBus,
  ) {}

  async execute(dto: CreateUserDto): Promise<User> {
    // 1. Validate & create domain entity
    const email = Email.create(dto.email);  // Throws if invalid
    const user = User.create({ email, name: dto.name });
    
    // 2. Check business rules
    const existing = await this.userRepo.findByEmail(email);
    if (existing) {
      throw new UserAlreadyExistsError(email);
    }
    
    // 3. Persist
    await this.userRepo.save(user);
    
    // 4. Publish domain events
    this.eventBus.publishAll(user.pullDomainEvents());
    
    return user;
  }
}
```

## Adapter (Repository)

```typescript
// infrastructure/adapters/output/persistence/user.repository.ts
@Injectable()
export class UserRepository implements UserRepositoryPort {
  constructor(
    @InjectRepository(UserSchema)
    private readonly ormRepo: Repository<UserSchema>,
  ) {}

  async save(user: User): Promise<void> {
    const schema = UserMapper.toSchema(user);
    await this.ormRepo.save(schema);
  }

  async findById(id: UserId): Promise<User | null> {
    const schema = await this.ormRepo.findOne({ where: { id: id.value } });
    return schema ? UserMapper.toDomain(schema) : null;
  }
}
```

## NestJS Module Wiring

```typescript
// user.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([UserSchema])],
  controllers: [UserController],
  providers: [
    // Use Cases
    CreateUserUseCase,
    
    // Adapters bound to Ports
    {
      provide: USER_REPOSITORY,
      useClass: UserRepository,
    },
  ],
})
export class UserModule {}
```

## Dependency Injection — Right vs Wrong

```typescript
// CORRECT: Use case depends on PORT (interface)
constructor(
  @Inject(USER_REPOSITORY)
  private readonly userRepo: UserRepositoryPort,  // Interface
) {}

// WRONG: Use case depends on ADAPTER (implementation)
constructor(
  private readonly userRepo: UserRepository,  // Concrete class
) {}
```

## Testing Example

```typescript
// Testing use case with mocked port
describe('CreateUserUseCase', () => {
  let useCase: CreateUserUseCase;
  let mockUserRepo: jest.Mocked<UserRepositoryPort>;

  beforeEach(() => {
    mockUserRepo = {
      save: jest.fn(),
      findByEmail: jest.fn().mockResolvedValue(null),
    };
    useCase = new CreateUserUseCase(mockUserRepo, mockEventBus);
  });

  it('creates user when email is unique', async () => {
    const user = await useCase.execute({ email: 'test@test.com', name: 'Test' });
    expect(mockUserRepo.save).toHaveBeenCalledWith(expect.any(User));
  });
});
```
