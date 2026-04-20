---
name: testing-strategy
description: Decide WHAT to test, at WHAT layer, and WITH which tooling. Use when setting up a test pyramid for a new project, auditing test coverage, deciding between unit vs integration vs E2E, designing test data strategy, fixing flaky tests, or writing contract tests between services. Covers Vitest/Jest, Playwright, Testing Library, contract testing (Pact), and testing patterns by hexagonal layer. Complements tdd-workflow (the red-green-refactor cycle).
---

# Testing Strategy

`tdd-workflow` tells you HOW to write tests (the cycle). This skill tells you **WHAT** to test, at **WHICH** layer, and WHY.

## The Pyramid (not a law, a default)

```
       /\
      /E2\         Few. Expensive. Brittle. Test critical user journeys only.
     /----\
    /Integ.\       Some. Test contracts across boundaries (DB, HTTP, queues).
   /--------\
  / Unit     \     Many. Fast. Pure logic, domain rules, utilities.
 /____________\
```

**Rules of thumb:**
- **70% unit** — pure, fast, no I/O
- **20% integration** — across module boundaries, real DB (test container)
- **10% E2E** — full stack, real browser, real API

If you have more E2E than unit, your test suite is slow and flaky. If you have 99% unit and no integration, you're not catching bugs in the seams where they actually happen.

## What to Test by Layer (Hexagonal)

| Layer | Test type | Tools | What to assert |
|---|---|---|---|
| **Domain** (entities, value objects, services) | Pure unit | Vitest | Business rules, invariants, edge cases. No mocks. |
| **Application** (use cases) | Unit with fakes | Vitest + in-memory repo | Orchestration logic, side effects via port interfaces |
| **Infrastructure adapters** (repositories, clients) | Integration | Vitest + testcontainers | Real DB / real HTTP. One adapter = one integration test file. |
| **HTTP controllers** | Integration | Vitest + Supertest | Status codes, validation, serialization. Thin, since logic is in use cases. |
| **Frontend components** | Component | Testing Library | Behavior from user POV, not implementation |
| **Full stack** | E2E | Playwright | 5-10 golden paths (signup, checkout, core feature) |

## Unit Tests — What Actually Belongs

✅ **Unit-test:**
- Pure functions, utilities, calculations
- Domain entities and value objects (every invariant)
- Use cases (with in-memory fakes for ports)
- Reducers, derivations, validators
- Parsing/serialization

❌ **Don't unit-test:**
- Framework code (don't test React or NestJS)
- Getters/setters, trivial DTOs
- Implementation details (private methods, internal state)
- Third-party libraries (you don't own them)

## Integration Tests — The Seams

This is where bugs live. Unit tests pass, E2E is green, but the repository query is wrong or the HTTP client can't parse the response.

- **Database adapters**: use **testcontainers** for real Postgres. Mock DB = lie.
- **HTTP clients**: use **MSW** (Mock Service Worker) to stub the external API at the network layer
- **Queues**: run real Redis/RabbitMQ in a container
- **One file per adapter**: `user-repository.integration.test.ts`

```ts
// example: real Postgres via testcontainers
beforeAll(async () => {
  container = await new PostgreSqlContainer().start();
  db = createDb(container.getConnectionUri());
  await migrate(db);
});

test("findByEmail returns user with sessions", async () => {
  await db.insert(users).values({ email: "a@b.com", ... });
  const user = await repo.findByEmail("a@b.com");
  expect(user).toMatchObject({ email: "a@b.com" });
});
```

## Component Tests (Frontend)

**Rule:** test what a user would do, not what the component renders internally.

```tsx
// ❌ Implementation detail
expect(wrapper.find(".submit-btn").prop("disabled")).toBe(true);

// ✅ User-facing behavior
await user.type(screen.getByLabelText(/email/i), "invalid");
await user.click(screen.getByRole("button", { name: /submit/i }));
expect(screen.getByRole("alert")).toHaveTextContent(/valid email/i);
```

**Tools:**
- **Vitest + Testing Library** for component tests
- **@testing-library/user-event** for realistic interactions
- **MSW** for API mocking
- **Storybook + play functions** for visual + interaction tests in one place

## E2E Tests — What to Actually Cover

**Cover only critical paths.** E2E is expensive.

Mandatory:
- Signup → onboarding → first action
- Login → core feature → logout
- Checkout / payment flow
- Any regulated/money path (subscription, refund)

Avoid:
- Testing every form field in E2E (use component tests)
- Testing auth error states in E2E (use integration)
- Testing loading spinners (use component)

**Tool: Playwright** (not Cypress — Playwright is faster, multi-browser, better parallelism).

```ts
// playwright/tests/signup.spec.ts
test("user can sign up and land on dashboard", async ({ page }) => {
  await page.goto("/signup");
  await page.getByLabel("Email").fill(`test-${Date.now()}@example.com`);
  await page.getByLabel("Password").fill("SuperSecret123!");
  await page.getByLabel("Name").fill("Test User");
  await page.getByRole("button", { name: "Create account" }).click();
  await expect(page).toHaveURL(/\/dashboard/);
});
```

## Test Doubles Taxonomy

| Double | What it does | When |
|---|---|---|
| **Dummy** | Passed but unused (filler arg) | Satisfy types |
| **Stub** | Returns canned response | "Given this input, return Y" |
| **Fake** | Working impl, simpler than real (in-memory DB) | Unit tests of use cases |
| **Mock** | Verifies interactions (was this called?) | Asserting side effects (email sent, event published) |
| **Spy** | Wraps real, records calls | Rare, usually a Mock is cleaner |

**Rule:** Prefer **fakes > stubs > mocks**. Mocks couple tests to implementation. Fakes test behavior.

## Contract Tests (microservices)

If you have multiple services, unit + integration isn't enough — you need **contract tests**.

- Provider (service offering API) generates a contract
- Consumer (service using API) verifies against the contract
- Tool: **Pact** (mature), or OpenAPI-based contract testing

Without contract tests: classic "each service is green, integration is broken" scenario.

## Test Data Strategy

- **Factories over fixtures** — define `makeUser({ email?: ... })` helpers
- **Randomize what doesn't matter** — use `faker` for emails, names
- **Freeze what matters** — always pass explicit values for fields under test
- **Unique per test** — avoid cross-test leakage (suffix emails with `Date.now()` or nanoid)

```ts
export function makeUser(overrides: Partial<User> = {}): User {
  return {
    id: crypto.randomUUID(),
    email: `user-${crypto.randomUUID()}@example.com`,
    name: faker.person.fullName(),
    createdAt: new Date(),
    ...overrides,
  };
}
```

## Flaky Tests — The Rules

1. **A flaky test is a broken test.** Fix or delete, never retry-and-hope.
2. Most flakiness sources: timing (sleeps), shared state, order dependence, real network.
3. **Never use `sleep()`** in tests. Use `waitFor`, `toBeVisible`, event-based waits.
4. **Clean DB between tests** (truncate or transaction rollback).
5. **Tests must pass independently** — random order, parallel, first run, second run.

## Coverage — A Tool, Not a Goal

- Coverage % doesn't measure quality. 100% coverage with no assertions = garbage tests.
- **Aim for ~80% line coverage** on domain + use cases. Don't chase 100%.
- **Branch coverage** matters more than line coverage.
- **Mutation testing** (Stryker) is the real quality measure — but expensive to run.

## Test Naming

```
describe("CreateOrderUseCase", () => {
  it("creates an order with pending status", () => {});
  it("rejects when cart is empty", () => {});
  it("emits OrderCreated event", () => {});
});
```

Not: `it("works")`, `it("test 1")`, `it("should create")`.

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| 100% unit, 0% integration | Misses seam bugs | Add integration for every adapter |
| Mocking the DB | Lies — mock ≠ real | Testcontainers |
| Mocking the thing under test | Testing the mock, not the code | Only mock dependencies |
| Snapshot tests for everything | Noise, people approve broken snapshots | Use only for stable, serializable outputs |
| Shared mutable test state | Order-dependent, flaky | Fresh state per test |
| `await sleep(1000)` | Flaky, slow | `waitFor`, event-based |
| E2E for form validation | Slow, brittle | Component test |
| Asserting log output | Coupled to format | Assert behavior, not logs |
| No test for the happy path | Only edge cases tested | Always have a happy path per feature |

## Output Standards

- When recommending tests: say WHICH layer, WHY there, and what assertions
- Prefer fakes and in-memory implementations over mocks
- Every new feature gets: 1 happy path test + 2-3 edge case tests (minimum)
- E2E tests named for the user journey, not the page

## Reference Files

- `references/patterns.md` — Vitest + Testing Library setup, testcontainers Postgres example, MSW setup, Playwright config, in-memory repository fake template, factory helpers, Pact contract test example
