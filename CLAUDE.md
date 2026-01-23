# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code skills library** — a collection of specialized prompts, reference materials, and code templates that extend Claude Code's capabilities in specific domains.

## Structure

```
skills/
├── architecture/
│   ├── domain-modeler/       # DDD patterns: entities, value objects, aggregates, domain events
│   └── hexagonal-architect/  # Ports & adapters architecture for NestJS
├── discovery/
│   └── systems-thinking/     # System analysis: feedback loops, leverage points, stocks/flows
├── frontend/
│   └── premium-frontend-design/  # Apple/Framer-quality UI with glass effects, gradients, animations
│       └── references/           # Code libraries for effects, typography, motion, anti-patterns
├── implementation/
│   └── tdd-workflow/         # Red-green-refactor cycle, test patterns, AAA structure
├── product/
│   └── product-planner/      # PRDs, user stories (Given/When/Then), MVP scoping
└── bind-api/                 # BIND Argentina Open Banking API integration
    ├── references/           # Full API documentation
    └── scripts/              # TypeScript client implementation
```

## Skill File Convention

Each skill has a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: When and how to use this skill
---
```

The description field tells Claude when to invoke the skill.

## Key Skills

### premium-frontend-design
Creates luxury React/Next.js interfaces with:
- Glass morphism, mesh gradients, aurora backgrounds
- Framer Motion animations with specific easing curves
- Typography: distinctive font pairings, -0.02em to -0.05em tracking on headlines
- Anti-patterns to avoid (v0-style purple-blue gradients, cramped padding, uniform border-radius)

Reference files in `references/` contain complete CSS/React code for all effects.

### hexagonal-architect
Structures NestJS projects with:
- Domain layer (entities, value objects, domain events)
- Application layer (ports/interfaces, use cases)
- Infrastructure layer (adapters: REST controllers, repositories)

Dependency rule: Domain → Application → Infrastructure (dependencies point inward).

### domain-modeler
Models business logic using DDD:
- Entities (identity matters) vs Value Objects (immutable, defined by attributes)
- Aggregates (consistency boundaries with a root entity)
- Domain Events (past tense, immutable records of what happened)

### tdd-workflow
Guides test-driven development:
- Red (failing test) → Green (minimal code) → Refactor
- AAA pattern: Arrange, Act, Assert
- Test doubles: Stubs (return values), Mocks (verify interactions), Fakes (simplified implementations)

### bind-api
Integration with BIND Argentina Open Banking sandbox:
- OAuth 2.0 Direct Login authentication
- Endpoints: accounts, transfers, DEBIN, eCheqs, CBU/CVU validation
- TypeScript client in `scripts/bind_client.ts`

## Working with This Repository

When adding or modifying skills:

1. **SKILL.md structure**: Start with frontmatter (`name`, `description`), then detailed instructions
2. **Reference files**: Put reusable code/templates in a `references/` subdirectory
3. **Anti-patterns**: Document what NOT to do — this is as important as the positive guidance
4. **Output standards**: Specify the expected format (complete code, types, specific patterns)
5. **Update install.sh**: Add new skills to the `SKILLS` array in `install.sh` (alphabetical order)
6. **Update README.md**: Add to the "Available Skills" table and "Available skills for installation" list

When using skills in other projects, load the SKILL.md and relevant reference files as context.
