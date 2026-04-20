# testing-strategy

## Activation Prompts

```
Set up the test pyramid for this project
```

```
What should I unit test vs integration test vs E2E?
```

```
Audit this project's test coverage — what's missing
```

```
Add testcontainers for real Postgres integration tests
```

```
Set up Playwright for critical user journeys
```

```
Write contract tests between [service A] and [service B]
```

```
Fix flaky tests
```

## Example Use Cases

- Day-0 test infrastructure (Vitest + Testing Library + Playwright)
- Integration test with real Postgres via testcontainers
- Component test with Testing Library + MSW
- E2E test with Playwright for signup/checkout
- Pact contract tests between frontend and backend
- Test data factories with faker
- Diagnosing why tests are flaky (timing, shared state, order)

## Pairs With

- `tdd-workflow` (the red-green-refactor cycle)
- `hexagonal-architect` (what to test at each layer)
- `error-handling` (testing the error paths)
