# session-bridge

## Activation Prompts

### Read (session start)
```
retomá
```

```
dónde quedamos
```

```
resume session
```

### Write (session end / mid-session)
```
cerrá la sesión
```

```
guardá contexto
```

```
archivá la sesión
```

```
update SESSION.md con lo que hicimos
```

## Example Use Cases

- Starting a work session after hours/days away
- Closing a session with in-progress work
- Mid-session checkpoint before a long break
- Capturing decisions that might become CLAUDE.md rules later

## Hard Limits (non-negotiable)

- **300 lines max** — auto-archives on overflow
- **72-hour TTL** — auto-archives if stale
- **Secret scanner** runs before every write (API keys, tokens, connection strings)
- **.gitignore** enforcement for `.context/sessions/`

## File Locations

- Active: `.context/session.md` (tool-neutral default)
- Archive: `.context/sessions/YYYY-MM-DD-HH-MM.md`
- Falls back to `.claude/SESSION.md` if repo already uses `.claude/`

## Pairs With

- `claude-md-keeper` — promotion of marked candidates (2-of-3 policy)
- `github-safety` — ensure archives are gitignored
- All domain skills — their decisions get captured here

## Modes

- **Phase 1** (default): on-demand only
- **Phase 2** (after 2 weeks trust): opt-in `Stop` hook with `--dry-run`
- **Phase 3** (full auto): Stop hook without dry-run
