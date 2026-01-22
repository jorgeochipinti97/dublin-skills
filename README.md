# Dublin Skills

A collection of skills for [Claude Code](https://claude.ai/code) that extend its capabilities in specific domains.

## What are Skills?

Skills are structured prompts with detailed instructions, code patterns, and references that Claude Code can use for specialized tasks. Each skill includes:

- **When to use it** — Context and use cases
- **How it works** — Methodology and principles
- **Reference code** — Ready-to-use implementations
- **Anti-patterns** — What to avoid

## Available Skills

| Skill | Description |
|-------|-------------|
| **[premium-frontend-design](skills/frontend/premium-frontend-design)** | Apple/Framer-quality React/Next.js interfaces: glass effects, gradients, micro-interactions |
| **[hexagonal-architect](skills/architecture/hexagonal-architect)** | Hexagonal architecture (ports & adapters) for NestJS |
| **[domain-modeler](skills/architecture/domain-modeler)** | Domain modeling with DDD: entities, value objects, aggregates |
| **[tdd-workflow](skills/implementation/tdd-workflow)** | Test-driven development: red-green-refactor |
| **[product-planner](skills/product/product-planner)** | Product planning: PRDs, user stories, MVP scoping |
| **[systems-thinking](skills/discovery/systems-thinking)** | Systems analysis: feedback loops, leverage points |
| **[bind-api](skills/bind-api)** | BIND Argentina API integration (Open Banking) |

## Usage

### With Claude Code

Load the skill as context at the start of your conversation:

```
Read skills/frontend/premium-frontend-design/SKILL.md and its references
```

### Skill Structure

```
skills/
└── [category]/
    └── [skill-name]/
        ├── SKILL.md           # Main instructions
        └── references/        # Additional code and documentation
            ├── example.md
            └── template.ts
```

## Creating a New Skill

1. Create a folder in the appropriate category
2. Add a `SKILL.md` with frontmatter:

```yaml
---
name: skill-name
description: Short description of when to use this skill
---

# Skill Name

[Detailed content...]
```

3. Add references in `references/` if the skill needs extensive code

## Categories

- **architecture** — Software architecture patterns
- **discovery** — Problem analysis and exploration
- **frontend** — Interface development
- **implementation** — Development practices
- **product** — Product planning

## License

MIT
