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
| **[brand-identity](skills/brand-identity)** | Brand identity systems: color palettes, typography, spacing, UX principles |
| **[brand-guidelines](skills/brand-guidelines)** | Anthropic brand colors, typography, and visual styling |
| **[premium-frontend-design](skills/frontend/premium-frontend-design)** | Apple/Framer-quality React/Next.js interfaces: glass effects, gradients, micro-interactions |
| **[react-performance](skills/frontend/react-performance)** | React/Next.js performance optimization: useEffect elimination, rendering, RSC, bundle analysis |
| **[hexagonal-architect](skills/architecture/hexagonal-architect)** | Hexagonal architecture (ports & adapters) for NestJS |
| **[domain-modeler](skills/architecture/domain-modeler)** | Domain modeling with DDD: entities, value objects, aggregates |
| **[tdd-workflow](skills/implementation/tdd-workflow)** | Test-driven development: red-green-refactor |
| **[product-planner](skills/product/product-planner)** | Product planning: PRDs, user stories, MVP scoping |
| **[product-ux-advisor](skills/product/product-ux-advisor)** | UX audit that diagnoses missing or critical patterns — onboarding, wizards, empty states, activation flows |
| **[systems-thinking](skills/discovery/systems-thinking)** | Systems analysis: feedback loops, leverage points |
| **[bind-api](skills/bind-api)** | BIND Argentina API integration (Open Banking) |
| **[infra-security](skills/infra-security)** | Infrastructure architect and security specialist — AWS, VPS, Azure, AI-as-a-Service, Docker cleanup & disk hygiene |
| **[blog-writer](skills/content/blog-writer)** | Professional blog posts in English/Spanish — no hype, no fluff |
| **[remotion-video](skills/media/remotion-video)** | Programmatic video generation from React components with Remotion |

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
bind-api              blog-writer           brand-guidelines
brand-identity        domain-modeler        hexagonal-architect
infra-security        premium-frontend-design  product-planner
product-ux-advisor    react-performance     remotion-video
skill-creator         systems-thinking      tdd-workflow
```

### Global command (recommended)

Create a symlink to use `dublin-skill-install` from anywhere:

```bash
sudo ln -sf /path/to/dublin-skills/install.sh /usr/local/bin/dublin-skill-install
```

Then use from any project:

```bash
cd my-project
dublin-skill-install .        # Interactive mode
dublin-skill-install . --all  # Install all skills
```

### Updating skills

Update previously installed skills to their latest versions:

```bash
cd my-project
dublin-skill-install update   # Updates all installed skills
```

The installer automatically detects your system language (`LANG` environment variable) and displays messages in Spanish or English.

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
├── bind-api.md
├── blog-writer.md
├── brand-guidelines.md
├── brand-identity.md
├── domain-modeler.md
├── hexagonal-architect.md
├── infra-security.md
├── premium-frontend-design.md
├── product-planner.md
├── product-ux-advisor.md
├── react-performance.md
├── remotion-video.md
├── skill-creator.md
├── systems-thinking.md
└── tdd-workflow.md
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
- **content** — Writing and content creation
- **discovery** — Problem analysis and exploration
- **frontend** — Interface development
- **implementation** — Development practices
- **media** — Video and multimedia generation
- **product** — Product planning

## License

MIT
