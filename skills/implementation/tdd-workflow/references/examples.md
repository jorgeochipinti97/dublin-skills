# TDD Workflow — Code Examples

## From User Story to Tests

### Input: Acceptance Criteria (Gherkin)

```gherkin
Feature: User Registration

Scenario: Successful registration
  Given a new user with email "test@example.com"
  When they register with password "SecurePass123!"
  Then a user account should be created
  And a welcome email should be sent
  And the user should be able to log in

Scenario: Registration with existing email
  Given a user exists with email "existing@example.com"
  When a new user tries to register with "existing@example.com"
  Then registration should fail
  And error message should be "Email already registered"
```

### Output: Test Cases

```typescript
describe('User Registration', () => {
  describe('Successful registration', () => {
    it('should create a user account', async () => {
      // Arrange
      const dto = { email: 'test@example.com', password: 'SecurePass123!' };
      
      // Act
      const result = await useCase.execute(dto);
      
      // Assert
      expect(result.id).toBeDefined();
      expect(mockUserRepo.save).toHaveBeenCalled();
    });

    it('should send a welcome email', async () => {
      const dto = { email: 'test@example.com', password: 'SecurePass123!' };
      await useCase.execute(dto);
      expect(mockEmailService.sendWelcome).toHaveBeenCalledWith('test@example.com');
    });
  });

  describe('Registration with existing email', () => {
    it('should fail when email already exists', async () => {
      mockUserRepo.findByEmail.mockResolvedValue(existingUser);
      const dto = { email: 'existing@example.com', password: 'SecurePass123!' };
      await expect(useCase.execute(dto)).rejects.toThrow(UserAlreadyExistsError);
    });

    it('should return correct error message', async () => {
      mockUserRepo.findByEmail.mockResolvedValue(existingUser);
      const dto = { email: 'existing@example.com', password: 'SecurePass123!' };
      await expect(useCase.execute(dto)).rejects.toThrow('Email already registered');
    });
  });
});
```

## AAA Pattern Template

```typescript
it('should [expected behavior] when [condition]', () => {
  // Arrange - Setup test data and mocks
  const input = createTestInput();
  mockDependency.method.mockReturnValue(expectedValue);

  // Act - Execute the code under test
  const result = systemUnderTest.execute(input);

  // Assert - Verify the outcome
  expect(result).toEqual(expectedOutput);
  expect(mockDependency.method).toHaveBeenCalledWith(expectedArgs);
});
```

## Test Doubles

```typescript
// Stub - just returns data
const stubUserRepo = {
  findById: jest.fn().mockResolvedValue(testUser),
};

// Mock - we verify it was called
const mockEmailService = {
  send: jest.fn(),
};
expect(mockEmailService.send).toHaveBeenCalledWith(email);

// Fake - real behavior, simplified
class FakeUserRepository implements UserRepositoryPort {
  private users: Map<string, User> = new Map();
  
  async save(user: User): Promise<void> {
    this.users.set(user.id.value, user);
  }
  
  async findById(id: UserId): Promise<User | null> {
    return this.users.get(id.value) || null;
  }
}
```

## Red Phase: Write Failing Test First

```typescript
// 1. Write the test BEFORE the implementation
it('should hash password before saving', async () => {
  const dto = { email: 'test@test.com', password: 'plain123' };
  
  await useCase.execute(dto);
  
  const savedUser = mockUserRepo.save.mock.calls[0][0];
  expect(savedUser.password.value).not.toBe('plain123');
  expect(savedUser.password.isHashed).toBe(true);
});

// 2. Run test - it MUST fail (red)
// 3. Now implement the feature
```

## Green Phase: Minimal Implementation

```typescript
class CreateUserUseCase {
  async execute(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await this.hasher.hash(dto.password);
    const user = User.create({
      email: Email.create(dto.email),
      password: hashedPassword,
    });
    await this.userRepo.save(user);
    return user;
  }
}
// Run test - MUST pass (green)
```

## Refactor Phase: Improve Code

```typescript
// Before refactor
class CreateUserUseCase {
  async execute(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await this.hasher.hash(dto.password);
    const user = User.create({
      email: Email.create(dto.email),
      password: hashedPassword,
    });
    await this.userRepo.save(user);
    return user;
  }
}

// After refactor - extract value object creation
class CreateUserUseCase {
  async execute(dto: CreateUserDto): Promise<User> {
    const user = await User.createWithHashedPassword(
      dto.email,
      dto.password,
      this.hasher
    );
    await this.userRepo.save(user);
    return user;
  }
}
// Tests must still pass
```

## Common Testing Patterns

### Testing Exceptions
```typescript
it('should throw when email is invalid', async () => {
  const dto = { email: 'not-an-email', password: 'test123' };
  await expect(useCase.execute(dto)).rejects.toThrow(InvalidEmailError);
});
```

### Testing Async Code
```typescript
it('should wait for all operations', async () => {
  const dto = validDto();
  await useCase.execute(dto);
  expect(mockRepo.save).toHaveBeenCalled();
  expect(mockEmail.send).toHaveBeenCalled();
});
```

### Testing Events
```typescript
it('should emit UserCreated event', async () => {
  const dto = validDto();
  const user = await useCase.execute(dto);
  const events = user.pullDomainEvents();
  expect(events).toContainEqual(
    expect.objectContaining({ type: 'UserCreated' })
  );
});
```
