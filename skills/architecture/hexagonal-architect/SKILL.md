---
name: hexagonal-architect
description: Design hexagonal (ports & adapters) architecture for NestJS and other frameworks. Use when structuring a new project or refactoring to clean architecture. Outputs folder structure, port interfaces, adapter implementations, and dependency flow.
---

# Hexagonal Architect

Structure code so business logic is independent of frameworks, databases, and external services.

## Core Rule

Dependencies point INWARD. Domain knows nothing about adapters.

## Folder Structure (NestJS)

```
src/modules/[module-name]/
├── domain/                    # Core business logic
│   ├── entities/
│   ├── value-objects/
│   ├── events/
│   ├── errors/
│   └── services/              # Domain services (optional)
├── application/               # Use cases
│   ├── ports/
│   │   ├── input/             # Use case interfaces
│   │   └── output/            # Repository interfaces
│   ├── use-cases/
│   └── dto/
├── infrastructure/            # Adapters
│   ├── adapters/
│   │   ├── input/             # Controllers (REST, GraphQL)
│   │   └── output/            # Repositories, external services
│   └── config/
└── [module-name].module.ts
```

Shared cross-cutting concerns go in `src/shared/` (base entity, exception filters).

## Dependency Rules

| Layer | Can Depend On | Cannot Depend On |
|-------|---------------|------------------|
| Domain | Nothing external | Application, Infrastructure |
| Application | Domain | Infrastructure |
| Infrastructure | Application, Domain | — |

Use **Symbols** for dependency injection — use cases depend on port interfaces, never concrete adapters.

## Testing Strategy

- **Domain**: Unit tests, no mocks needed (pure logic)
- **Application**: Unit tests, mock ports
- **Infrastructure**: Integration tests (real DB, real APIs)
- **E2E**: Full flow tests

## Anti-Patterns

- Domain importing from infrastructure
- Use cases depending on concrete implementations
- Business logic in controllers
- ORM entities used as domain entities
- Skipping ports (controller → repository directly)

## Reference Files

Load `references/implementation-patterns.md` for complete code examples: ports, use cases, adapters, module wiring, DI patterns, and tests.

## Output Standards

- Be CONCISE — lead with code, minimize explanations
- Complete, runnable TypeScript — no placeholders
- Follow the folder structure above
- Every port must have a Symbol for DI
