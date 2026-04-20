# Skill Creator — Design Philosophy

## Concise is Key

The context window is a public good. Skills share it with system prompt, conversation history, other skills' metadata, and user requests.

**Default assumption: Claude is already very smart.** Only add context Claude doesn't already have. Challenge each piece: "Does Claude really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

## Set Appropriate Degrees of Freedom

Match specificity to the task's fragility and variability:

| Freedom Level | When to Use | Example |
|--------------|-------------|---------|
| **High** (text instructions) | Multiple valid approaches, context-dependent | General workflow guidance |
| **Medium** (pseudocode/scripts with params) | Preferred pattern exists, some variation OK | Template with configuration |
| **Low** (specific scripts, few params) | Fragile operations, consistency critical | PDF rotation, API calls |

Think of Claude exploring a path: narrow bridge with cliffs = low freedom (guardrails); open field = high freedom (many routes).

## Progressive Disclosure

Three-level loading system for context efficiency:

1. **Metadata (name + description)** — Always in context (~100 words)
2. **SKILL.md body** — When skill triggers (<5k words, target <500 lines)
3. **Bundled resources** — As needed (scripts can execute without loading into context)

### Disclosure Patterns

**Pattern 1: High-level guide with references**
```markdown
# PDF Processing
## Quick start
[code example]
## Advanced features
- **Form filling**: See [FORMS.md](FORMS.md)
- **API reference**: See [REFERENCE.md](REFERENCE.md)
```

**Pattern 2: Domain-specific organization**
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```
When user asks about sales metrics, Claude only reads sales.md.

**Pattern 3: Conditional details**
```markdown
## Creating documents
Use docx-js. See [DOCX-JS.md](DOCX-JS.md).
## Editing documents
For simple edits, modify XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

### Guidelines
- Avoid deeply nested references — keep one level deep from SKILL.md
- For files >100 lines, include table of contents at top
- If files are >10k words, include grep patterns in SKILL.md
- Information should live in SKILL.md OR references, not both
