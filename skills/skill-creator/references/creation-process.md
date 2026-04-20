# Skill Creator — Creation Process

## Step 1: Understand the Skill with Concrete Examples

Ask the user about concrete usage patterns:
- "What functionality should this skill support?"
- "Can you give examples of how it would be used?"
- "What would a user say that should trigger this skill?"

Avoid overwhelming — start with key questions, follow up as needed. Conclude when functionality scope is clear.

## Step 2: Plan Reusable Contents

Analyze each concrete example:
1. How would you execute this from scratch?
2. What scripts, references, or assets would help when doing this repeatedly?

| Content Type | When to Include | Example |
|-------------|----------------|---------|
| `scripts/` | Same code rewritten repeatedly, deterministic reliability needed | `rotate_pdf.py` |
| `references/` | Documentation Claude should reference while working | `schema.md`, `api_docs.md` |
| `assets/` | Files used in output (templates, images, boilerplate) | `logo.png`, `template/` |

## Step 3: Initialize the Skill

Run `scripts/init_skill.py` for new skills:

```bash
scripts/init_skill.py <skill-name> --path <output-directory>
```

Creates: skill directory, SKILL.md template with frontmatter + TODOs, example `scripts/`, `references/`, `assets/` directories. Skip if skill already exists.

## Step 4: Edit the Skill and Create Prompt Cheat Sheet

### Implement Resources
- Start with scripts, references, and assets identified in Step 2
- Test scripts by running them (at least a representative sample)
- Delete unused example files from init

### Write SKILL.md

**Frontmatter** (YAML):
- `name`: Skill name
- `description`: Primary trigger mechanism. Include what the skill does AND specific triggers/contexts. Put all "when to use" info here (body loads after triggering, so trigger info in body doesn't help)
- No other fields

**Body** (Markdown): Instructions for using the skill and its resources. Use imperative form.

Consult for design patterns:
- **Multi-step processes**: See `references/workflows.md`
- **Output formats/quality**: See `references/output-patterns.md`

### Create Prompt Cheat Sheet

Location: `prompts/<skill-name>.md`

```markdown
# <skill-name>

## Activation Prompts
\```
Example prompt that triggers this skill
\```

## Example Use Cases
- Use case 1
- Use case 2
```

Include 3-5 activation prompts with placeholders like `[product]`, `[feature]`. Keep it concise.

## Step 5: Package the Skill

```bash
scripts/package_skill.py <path/to/skill-folder>
# Optional output dir:
scripts/package_skill.py <path/to/skill-folder> ./dist
```

Validates (frontmatter, naming, structure, description quality) then packages into `.skill` file (zip with .skill extension). Fix errors and retry if validation fails.

## Step 6: Iterate

1. Use skill on real tasks
2. Notice struggles or inefficiencies
3. Update SKILL.md or resources
4. Test again
