---
name: tdd-workflow
description: Guide test-driven development workflow with red-green-refactor cycle. Use when implementing features, writing tests, or improving code quality. Outputs test cases from acceptance criteria, unit tests, integration tests, and refactoring patterns.
---

# TDD Workflow

Write tests first, then make them pass, then improve the code.

## The Cycle

1. **RED** — Write a failing test that defines expected behavior
2. **GREEN** — Write the MINIMUM code to make the test pass
3. **REFACTOR** — Improve code quality without changing behavior. Tests must stay green
4. **Repeat**

## From User Story to Tests

Convert acceptance criteria (Given/When/Then) into test cases:
- Each "Then" clause becomes at least one assertion
- Each "Scenario" becomes a `describe` block
- Use AAA pattern: Arrange → Act → Assert

Load `references/examples.md` for complete Gherkin → test code examples.

## Test Doubles

| Type | Purpose | When to Use |
|------|---------|-------------|
| **Stub** | Returns predefined values | Isolate from dependencies |
| **Mock** | Verifies interactions | Ensure side effects happened |
| **Spy** | Wraps real implementation | Monitor without replacing |
| **Fake** | Simplified real implementation | In-memory repositories |

Load `references/examples.md` for code examples of each type.

## Test Pyramid

| Layer | What to Test | Volume | Tools |
|-------|-------------|--------|-------|
| **Unit** | Domain logic, use cases | Many, fast | Jest |
| **Integration** | Repositories, external services | Some, medium | Jest + TestContainers |
| **E2E** | Full user flows | Few, slow | Playwright, Supertest |

## Red-Green-Refactor Rules

### RED Phase
- Write the test BEFORE any implementation
- Test MUST fail — if it passes immediately, the test is wrong or the feature exists
- Test one behavior at a time

### GREEN Phase
- Write MINIMUM code to pass — no over-engineering, no extra features
- It's OK if the code is ugly — that's what refactor is for

### REFACTOR Phase
- Improve without changing behavior (extract methods, rename, remove duplication)
- Run tests after EVERY change — they must stay green
- If tests break, undo and try a smaller refactor step

## Anti-Patterns

- Writing tests after implementation
- Testing implementation details instead of behavior
- Tests that depend on each other
- Mocking everything (test the real thing when possible)
- Skipping refactor phase
- Tests without assertions
- Too many assertions per test

## Reference Files

- `references/examples.md` — Complete code: AAA pattern, test doubles, Gherkin→tests, red/green/refactor phases, testing exceptions/async/events

## Output Standards

- Be CONCISE — test code first, minimal explanation
- Use AAA pattern (Arrange/Act/Assert) in every test
- One assertion per test when possible
- Descriptive test names: "should [behavior] when [condition]"
