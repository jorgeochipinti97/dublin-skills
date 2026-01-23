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
| **[skill-creator](skills/skill-creator)** | Guide for creating effective skills that extend Claude's capabilities |
| **[brand-guidelines](skills/brand-guidelines)** | Anthropic brand colors, typography, and visual styling |
| **[premium-frontend-design](skills/frontend/premium-frontend-design)** | Apple/Framer-quality React/Next.js interfaces: glass effects, gradients, micro-interactions |
| **[hexagonal-architect](skills/architecture/hexagonal-architect)** | Hexagonal architecture (ports & adapters) for NestJS |
| **[domain-modeler](skills/architecture/domain-modeler)** | Domain modeling with DDD: entities, value objects, aggregates |
| **[tdd-workflow](skills/implementation/tdd-workflow)** | Test-driven development: red-green-refactor |
| **[product-planner](skills/product/product-planner)** | Product planning: PRDs, user stories, MVP scoping |
| **[systems-thinking](skills/discovery/systems-thinking)** | Systems analysis: feedback loops, leverage points |
| **[bind-api](skills/bind-api)** | BIND Argentina API integration (Open Banking) |

## Installation

Install skills into any project's `.claude/skills/` directory:

```bash
# Interactive mode (select from menu)
./install.sh /path/to/your/project

# Install all skills
./install.sh /path/to/your/project --all

# Install specific skills
./install.sh /path/to/your/project tdd-workflow domain-modeler premium-frontend-design
```

The installer will create `.claude/skills/` if it doesn't exist.

### Available skills for installation

```
bind-api              domain-modeler        hexagonal-architect
brand-guidelines      premium-frontend-design    product-planner
skill-creator         systems-thinking      tdd-workflow
```

### Global alias (optional)

Add to your shell config:

```bash
alias dublin-skills-install="/path/to/dublin-skills/install.sh"
```

Then use from any project:

```bash
cd my-project
dublin-skills-install . --all
```

## Usage

### With Claude Code

Load the skill as context at the start of your conversation:

```
Read skills/frontend/premium-frontend-design/SKILL.md and its references
```

### Prompt Cheat Sheets

Each skill has a prompt file in `prompts/` with activation examples:

```
prompts/
├── skill-creator.md
├── brand-guidelines.md
├── premium-frontend-design.md
├── hexagonal-architect.md
├── domain-modeler.md
├── tdd-workflow.md
├── product-planner.md
├── systems-thinking.md
└── bind-api.md
```

Use these as quick reference for how to invoke each skill.

### Skill Structure

```
skills/
└── [skill-name]/
    ├── SKILL.md           # Main instructions
    ├── scripts/           # Executable code (Python/Bash/etc.)
    ├── references/        # Documentation loaded as needed
    └── assets/            # Files used in output (templates, icons, etc.)
```

## Creating a New Skill

Use the **skill-creator** skill for guidance, or follow this structure:

1. Create a folder for your skill
2. Add a `SKILL.md` with frontmatter:

```yaml
---
name: skill-name
description: Short description of when to use this skill
---

# Skill Name

[Detailed content...]
```

3. Add optional resources:
   - `scripts/` — Executable code for deterministic tasks
   - `references/` — Documentation to load as needed
   - `assets/` — Templates, images, or files for output

## Categories

- **architecture** — Software architecture patterns
- **discovery** — Problem analysis and exploration
- **frontend** — Interface development
- **implementation** — Development practices
- **product** — Product planning

## License

MIT
