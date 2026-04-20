# orchestrator

## Activation Prompts

```
Plan the MVP of [product]
```

```
Which skills should I use for [task]?
```

```
Orchestrate this task: [description]
```

```
Validate this plan: [ordered list of skills]
```

```
Audit this repo for missing engineering foundations
```

```
Build a roadmap for shipping [feature]
```

## Example Use Cases

- Starting a new product — which skills, in what order
- Adding a complex feature spanning multiple domains
- Auditing a codebase and mapping findings to skills that can fix them
- Validating a human-provided plan against dependency rules
- Breaking a big task into phases + TaskCreate entries

## Operating Modes

- **Mode A** — Fresh plan from scratch
- **Mode B** — Validate a user-provided plan (annotated kept/added/removed/reordered)
- **Mode C** — Audit mode (map repo gaps to skills)

## Output

- Context analysis + inferred scope
- Ranked skills with relevance score + reason
- "Skipped" list with rationale
- Phased execution order
- Open questions before execution
- TaskCreate entries so the plan becomes executable state

## Requires

- `skills.manifest.json` in `.claude/skills/orchestrator/` for fast planning
- Or fallback: reads each SKILL.md frontmatter
