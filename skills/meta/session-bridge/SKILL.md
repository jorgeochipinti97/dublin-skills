---
name: session-bridge
description: Maintains a lightweight SESSION.md file for session-to-session continuity. Reads at session start to restore context (what was in progress, what's next, blockers). Writes at session end (on-demand by default, opt-in hook with dry-run review). Hard caps (300 lines, 72h TTL). Scans for secret leaks before writing. Marks candidates for promotion to CLAUDE.md using the 2-of-3 policy. Pairs with claude-md-keeper (which handles durable promotion).
---

# Session Bridge

Session-to-session memory for the project. Efímero, con límites duros, con escaneo de secretos.

## File Locations

**Default path:** `.context/session.md` (not `.claude/SESSION.md` — tool-neutral).

**Archive:** `.context/sessions/YYYY-MM-DD-HH-MM.md`

**Rationale:** `.claude/` is tool-specific. `.context/` works if you migrate tools or share the repo.

If the project already uses `.claude/` for everything, fall back to `.claude/SESSION.md` — but warn the user about the coupling risk.

---

## When to Invoke

### Read (at session start)
- User says: "retomá", "dónde quedamos", "resume session", or explicitly invokes
- Auto-recommended at the start of any non-trivial session

### Write (at session end)
- On-demand only: user says "cerrá la sesión", "guardá contexto", "archivá"

### Update (mid-session)
- After significant decisions
- Before long breaks (user going afk)

---

## SESSION.md Format

```markdown
---
session: 2026-04-19
started: 14:30
last-update: 16:45
status: in-progress | paused | ready-to-archive
---

# Session — {brief topic}

## Current task
- {what you're working on, 1-3 lines}

## Files touched
- `path/to/file.ts` — what changed
- `path/to/another.tsx` — what changed
(max 15 entries; if more, archive partial and start new section)

## Decisions made this session
- Decision: {short}
  - Rationale: {why}
  - Promotion candidate: yes/no (if yes, tick criteria — see below)

## In progress / interrupted
- Function `foo()` in `bar.ts` — refactor 2/3 done, need to update tests
- Blocker: waiting on X

## Next steps (when you retoma)
1. {first thing}
2. {second thing}

## Questions / blockers
- Open question: {}
- Blocked on: {}

## Scratch
<!-- Free-form notes, ephemeral -->
```

**See `references/session-format.md` for full template.**

---

## Hard Limits

### 300 lines maximum
If exceeded:
1. Auto-archive the full session to `.context/sessions/YYYY-MM-DD-HH-MM.md`
2. Start fresh SESSION.md with a link to the archive at top
3. Carry forward ONLY: current task, immediate next steps, active blockers

### 72-hour TTL
If SESSION.md is older than 72h:
1. Auto-archive on next read
2. Start fresh

### These are HARD limits
No "best effort", no "slightly over is fine". The moment the limit is exceeded → archive + restart. Stale context pollutes more than help.

---

## Secret Scanner (MANDATORY before every write)

Before writing ANY content to SESSION.md or archive, run the secret scanner on the content.

### Patterns to detect

```regex
# API keys / tokens
sk-[a-zA-Z0-9]{20,}          # OpenAI / Anthropic / Stripe secrets
ghp_[a-zA-Z0-9]{36}          # GitHub personal access token
ghs_[a-zA-Z0-9]{36}          # GitHub secret
gho_[a-zA-Z0-9]{36}          # GitHub OAuth
github_pat_[a-zA-Z0-9_]{82}  # GitHub fine-grained
AKIA[0-9A-Z]{16}             # AWS access key
aws_secret_access_key        # AWS secret (string match)
xox[baprs]-[a-zA-Z0-9-]+     # Slack tokens
AIza[0-9A-Za-z_-]{35}        # Google API
sbp_[a-f0-9]{40}             # Supabase
[a-zA-Z0-9_-]+\.apps\.googleusercontent\.com  # Google OAuth client
password\s*[:=]\s*['"][^'"]+['"]              # literal password= "x"
PRIVATE KEY-----             # PEM keys
Bearer\s+[a-zA-Z0-9_.=-]+    # Bearer tokens in session content
postgres(ql)?:\/\/[^@]+@     # Postgres URL with creds
mongodb(\+srv)?:\/\/[^@]+@   # Mongo URL with creds
```

### Behavior on match

1. **Redact** the matched string (replace with `{REDACTED-<type>}`)
2. **Warn** the user: "⚠️ Detected possible secret in session content. Redacted before writing. Review the archive if needed."
3. **Never silently skip** — the user must know

### False positive handling

If the user says "that's not a secret" or explicitly approves — write with a comment:
```markdown
<!-- User-approved: not a secret (2026-04-19) -->
```

---

## Gitignore Enforcement

On first invocation per project:

1. Check `.gitignore` for `.context/sessions/` (or `.claude/sessions/` if fallback)
2. If missing → propose adding it + ask user approval before modifying `.gitignore`
3. If approved → add:
   ```
   # Session bridge archives (may contain ephemeral debug info)
   .context/sessions/
   ```
4. **The SESSION.md itself** (not archives) is user's call — some want it committed (team context), some don't. Ask once per project.

---

## Promotion Candidates

At write time, scan decisions for the 2-of-3 promotion policy (see `claude-md-keeper/references/promotion-policy.md`):

1. **Repeated** — cross-reference archived sessions for same topic
2. **Multi-file** — count files/skills affected in the decision
3. **Rule form** — look for "siempre", "nunca", "always", "never", "todo {X} debe..."

Mark each decision with `promotion-candidate: yes (2/3)` or similar. Never promote from this skill. **Always defer to `claude-md-keeper`** for the actual CLAUDE.md diff.

---

## Read Flow (session start)

```
1. Check if SESSION.md exists and < 72h old
   ├── YES → display summary: task, next steps, blockers
   └── NO → check last archive, offer to summarize
2. Surface any "Questions / blockers" from previous session
3. If promotion candidates were marked, remind: "N candidates pending review via claude-md-keeper"
4. Return control to main conversation
```

### Summary format on load

```
📌 Retomando sesión de {date}:

**Tarea en curso:** {current task}

**Próximos pasos:**
1. {step 1}
2. {step 2}

**Blockers:**
- {blocker, or "none"}

**Decisiones pendientes de promoción a CLAUDE.md:** {N}
```

---

## Write Flow (session end / mid-session)

```
1. Gather session content:
   - What's been worked on (from conversation context)
   - Files touched (from git status / tool calls)
   - Decisions made (explicit statements or confirmed choices)
   - Open items
2. Scan for secrets → redact if found, warn user
3. Apply hard caps → archive if > 300 lines or > 72h
4. Write SESSION.md
5. Offer: "Querés que marque candidates for CLAUDE.md? (corré claude-md-keeper con intent promote)"
```

---

## Failure Modes

| Failure | Behavior |
|---|---|
| SESSION.md exists but > 300 lines | Archive immediately, start fresh |
| SESSION.md > 72h old | Archive immediately, start fresh |
| `.context/` or `.claude/` doesn't exist | Create on first write (with gitignore prompt) |
| Secret detected in content | Redact + warn + keep going |
| User cancels mid-write | Discard buffer, don't partial-write |
| `.gitignore` not in repo (no git) | Skip gitignore step, warn |
| Archive directory getting huge (>100 files) | Warn user: consider archiving older ones to `.context/sessions/archive-YYYY/` |

---

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Writing secrets to SESSION.md | Leak if `.claude/` hits git | Secret scanner is mandatory |
| Skip the 300-line cap "just this once" | Grows forever, noise | Hard cap, no exceptions |
| Auto-promote decisions to CLAUDE.md | Wrong skill's job, no 2-of-3 | Defer to claude-md-keeper |
| Coupling to `.claude/` path | Tool-specific, hard to migrate | `.context/` default |
| Archive with no gitignore | Secrets hit git | Gitignore step is step 1 |
| Overwriting SESSION.md without backing up current | Loss of last checkpoint | Always archive before overwrite |

---

## Reference Files

- `references/session-format.md` — Full template, section-by-section guidance, examples of good vs bad session entries
- `../claude-md-keeper/references/promotion-policy.md` — The 2-of-3 rule for candidate marking (shared with claude-md-keeper)
