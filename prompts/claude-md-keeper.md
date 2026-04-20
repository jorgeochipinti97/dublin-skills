# claude-md-keeper

## Activation Prompts

```
alineá el CLAUDE.md
```

```
check drift in CLAUDE.md
```

```
actualizá CLAUDE.md — review el archivo contra la realidad del código
```

```
promoveme las decisiones de esta sesión a CLAUDE.md
```

```
review CLAUDE.md para consistencia con Dublin conventions
```

## Example Use Cases

- After a stack migration (Prisma → Drizzle, pnpm → bun, etc.)
- After a refactor that changed folder structure
- After adding/removing major dependencies
- Every N sessions as a periodic alignment
- When CLAUDE.md feels stale

## The Rule

- **NEVER** writes CLAUDE.md directly
- Always generates `CLAUDE.md.proposed` with a diff report
- User reviews, approves, applies manually (or explicitly asks "apply")
- **NEVER** invoked via automatic hook — always on-demand

## Output

- Drift report: CRITICAL / MODERATE / MINOR
- Observable signals only (package.json, filesystem, git log, config files, Dublin manifest)
- NOT detected as drift: opinions, philosophy, vibes, future state
- Proposed `.diff` for each drift item
- Skipped section listing what was intentionally not touched

## Pairs With

- `session-bridge` — marks promotion candidates; claude-md-keeper promotes via 2-of-3 policy
- `orchestrator` — if drift affects strategy, orchestrator re-plans
- `github-safety` — user commits the approved diff safely
