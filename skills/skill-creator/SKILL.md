---
name: skill-creator
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
license: Complete terms in LICENSE.txt
---

# Skill Creator

Create modular, self-contained packages that extend Claude's capabilities with specialized knowledge, workflows, and tools.

## What Skills Provide

1. **Specialized workflows** — Multi-step procedures for specific domains
2. **Tool integrations** — Working with specific file formats or APIs
3. **Domain expertise** — Company-specific knowledge, schemas, business logic
4. **Bundled resources** — Scripts, references, and assets for complex tasks

## Core Principles

- **Concise is key** — Context window is shared. Only add what Claude doesn't already know. See `references/design-philosophy.md`
- **Match freedom to fragility** — High freedom for flexible tasks, low freedom for fragile operations. See `references/design-philosophy.md`
- **Progressive disclosure** — Metadata always loaded, SKILL.md on trigger, resources on demand. See `references/design-philosophy.md`

## Skill Structure

```
skill-name/
├── SKILL.md              # Required: frontmatter + instructions
├── scripts/              # Optional: executable code (Python/Bash)
├── references/           # Optional: docs loaded as needed
└── assets/               # Optional: files used in output (templates, icons)

prompts/<skill-name>.md   # Required: activation prompts cheat sheet
```

### SKILL.md

- **Frontmatter** (YAML): `name` and `description` only. Description is the trigger mechanism — include what the skill does AND when to use it
- **Body** (Markdown): Instructions for using the skill. Imperative form. Target <500 lines

### Bundled Resources

| Type | When to Include | Benefits |
|------|----------------|----------|
| `scripts/` | Same code rewritten repeatedly, deterministic reliability | Token efficient, deterministic |
| `references/` | Documentation Claude should reference while working | Keeps SKILL.md lean, loaded on demand |
| `assets/` | Files used in output (templates, images, boilerplate) | Separates output resources from docs |

**Key rule**: Information lives in SKILL.md OR references, never both.

### What NOT to Include

No README.md, INSTALLATION_GUIDE.md, QUICK_REFERENCE.md, CHANGELOG.md, or any auxiliary documentation. Only files an AI agent needs to do the job.

## Creation Process

1. **Understand** — Gather concrete usage examples from the user
2. **Plan** — Identify reusable scripts, references, and assets
3. **Initialize** — Run `scripts/init_skill.py <skill-name> --path <output-dir>`
4. **Edit** — Implement resources, write SKILL.md, create prompt cheat sheet
5. **Package** — Run `scripts/package_skill.py <path/to/skill-folder>`
6. **Iterate** — Test on real tasks, improve based on usage

See `references/creation-process.md` for detailed steps, examples, and guidelines for each phase.

## Design Pattern References

- `references/design-philosophy.md` — Conciseness, degrees of freedom, progressive disclosure patterns
- `references/creation-process.md` — Detailed 6-step creation process with examples
- `references/workflows.md` — Multi-step process design patterns
- `references/output-patterns.md` — Output format and quality standard patterns

## Output Standards

- Be CONCISE — minimal explanations, focus on actionable content
- Skills should be self-contained and runnable
- Test all scripts before packaging
- Include 3-5 activation prompts in `prompts/<skill-name>.md`
