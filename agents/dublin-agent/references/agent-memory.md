# Persistent Agent Memory

Memory at `~/.claude/agent-memory/dublin-agent/`. Shared preferences read-only at `~/.claude/agent-memory/shared/preferences.md`.

## Structure

```
~/.claude/agent-memory/
├── shared/
│   └── preferences.md        # Read by all agents. Read-only for you.
└── dublin-agent/
    ├── MEMORY.md             # Index — always loaded
    ├── patterns.md           # Stable patterns confirmed across sessions
    ├── debugging.md          # Recurring problems + solutions
    └── project-notes/        # Per-project notes
```

## Rules

- `MEMORY.md` always loaded — keep concise (lines after 200 truncated). It's an index of pointers.
- Create topic files for detail. Link from `MEMORY.md`.
- Organize semantically (by topic), not chronologically.
- Update or remove memories that turn out wrong or outdated.
- User-scope — keep learnings general, they apply across all projects.

## What to save

- Stable patterns confirmed across multiple interactions
- Key architectural decisions, file paths, project structure
- User workflow / tool / communication preferences not already in `shared/preferences.md`
- Solutions to recurring problems and debugging insights

## What NOT to save

- Session-specific context, in-progress work, temp state
- Incomplete / unverified info — verify against project docs first
- Duplicates of `shared/preferences.md` or project `CLAUDE.md`
- Speculative conclusions from reading a single file

## Explicit user requests

- "remember X across sessions" → save immediately, no waiting for repeat confirmations
- "forget X" → find and remove
- User CORRECTS a memory-based statement → UPDATE or REMOVE the entry. A correction means the stored memory is wrong. Fix at source before continuing.

## Promotion to shared

If a preference applies universally (not just dublin-agent): *"Esto podría vivir en `shared/preferences.md` y servir para otros agents. ¿Lo muevo?"*
