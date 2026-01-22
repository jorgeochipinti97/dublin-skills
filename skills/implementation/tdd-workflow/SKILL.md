---
name: tdd-workflow
description: Guide test-driven development workflow with red-green-refactor cycle. Use when implementing features, writing tests, or improving code quality. Outputs test cases from acceptance criteria, unit tests, integration tests, and refactoring patterns.
---

# TDD Workflow

Write tests first, then make them pass, then improve the code.

## The Cycle

```
    ┌─────────────┐
    │             │
    │    RED      │  1. Write a failing test
    │             │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │             │
    │   GREEN     │  2. Write minimal code to pass
    │             │
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │             │
    │  REFACTOR   │  3. Improve without changing behavior
    │             │
    └──────┬──────┘
           │
           └──────────► Repeat
```

## From User Story to Tests

### Input: Acceptance Criteria
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
      // Arrange
      const dto = { email: 'test@example.com', password: 'SecurePass123!' };
      
      // Act
      await useCase.execute(dto);
      
      // Assert
      expect(mockEmailService.sendWelcome).toHaveBeenCalledWith('test@example.com');
    });

    it('should allow the user to log in after registration', async () => {
      // Integration test
    });
  });

  describe('Registration with existing email', () => {
    it('should fail when email already exists', async () => {
      // Arrange
      mockUserRepo.findByEmail.mockResolvedValue(existingUser);
      const dto = { email: 'existing@example.com', password: 'SecurePass123!' };
      
      // Act & Assert
      await expect(useCase.execute(dto)).rejects.toThrow(UserAlreadyExistsError);
    });

    it('should return correct error message', async () => {
      // Arrange
      mockUserRepo.findByEmail.mockResolvedValue(existingUser);
      const dto = { email: 'existing@example.com', password: 'SecurePass123!' };
      
      // Act & Assert
      await expect(useCase.execute(dto)).rejects.toThrow('Email already registered');
    });
  });
});
```

## Test Anatomy: AAA Pattern

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

| Type | Purpose | Example |
|------|---------|---------|
| **Stub** | Returns predefined values | `mockRepo.findById.mockResolvedValue(user)` |
| **Mock** | Verifies interactions | `expect(mockRepo.save).toHaveBeenCalledWith(user)` |
| **Spy** | Wraps real implementation | `jest.spyOn(service, 'method')` |
| **Fake** | Working implementation (simplified) | In-memory repository |

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

## Test Pyramid

```
                    ┌───────┐
                   │  E2E  │         Few, slow, expensive
                  │ Tests  │
                 └─────────┘
                ┌─────────────┐
               │ Integration  │      Some, medium speed
              │    Tests      │
             └─────────────────┘
            ┌─────────────────────┐
           │      Unit Tests      │   Many, fast, cheap
          └───────────────────────┘
```

| Layer | What to Test | Tools |
|-------|--------------|-------|
| Unit | Domain logic, Use cases | Jest |
| Integration | Repositories, External services | Jest + TestContainers |
| E2E | Full user flows | Playwright, Supertest |

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
// FAIL: Password is not being hashed

// 3. Now implement the feature
```

## Green Phase: Minimal Implementation

```typescript
// Write the MINIMUM code to pass the test
// Don't over-engineer, don't add extra features

class CreateUserUseCase {
  async execute(dto: CreateUserDto): Promise<User> {
    const hashedPassword = await this.hasher.hash(dto.password);  // ← Added
    const user = User.create({
      email: Email.create(dto.email),
      password: hashedPassword,  // ← Changed
    });
    await this.userRepo.save(user);
    return user;
  }
}

// Run test - it MUST pass (green)
// PASS
```

## Refactor Phase: Improve Code

```typescript
// Now improve without changing behavior
// Tests must stay green

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

// Run tests again - must still pass
```

## Common Testing Patterns

### Testing Exceptions
```typescript
it('should throw when email is invalid', async () => {
  const dto = { email: 'not-an-email', password: 'test123' };
  
  await expect(useCase.execute(dto))
    .rejects
    .toThrow(InvalidEmailError);
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

## Anti-Patterns

- ❌ Writing tests after implementation
- ❌ Testing implementation details instead of behavior
- ❌ Tests that depend on each other
- ❌ Mocking everything (test the real thing when possible)
- ❌ Skipping refactor phase
- ❌ Tests without assertions
- ❌ Too many assertions per test
