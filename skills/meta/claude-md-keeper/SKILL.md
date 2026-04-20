---
name: claude-md-keeper
description: Keeps the project's CLAUDE.md aligned with reality. Detects drift between declared state (CLAUDE.md) and observed state (package.json, filesystem, git log, skills manifest). NEVER writes CLAUDE.md directly — always generates a proposed diff for the user to review. Use on-demand ("alinéate", "actualizá CLAUDE.md", "check drift"), NEVER via automatic hook. Pairs with session-bridge (for promoting durable decisions from SESSION.md to CLAUDE.md) and orchestrator (for re-planning when drift affects strategy).
---

# CLAUDE.md Keeper

Mantain the project's CLAUDE.md aligned with the code. On-demand only. Never auto-writes.

## The Rule (non-negotiable)

**NEVER edit CLAUDE.md directly.** Always generate a proposal for diff review.

Output goes to `CLAUDE.md.proposed` at repo root. User reviews the diff, approves, and merges manually (or approves and the skill applies it on explicit second invocation).

If you cannot diff-review, you cannot write. Full stop.

---

## When to Invoke

- User says: "alinéate", "actualizá CLAUDE.md", "check drift", "review CLAUDE.md"
- User reports CLAUDE.md feels stale or inaccurate
- After a significant refactor or stack change (recommend the user run it)
- **NEVER** via automatic hook. Decisión humana siempre.

Do NOT invoke for:
- Small edits the user can make themselves
- Fresh projects without stable CLAUDE.md yet
- During active SDD apply phase (wait until the change lands)

---

## The Algorithm

### Step 1 — Inspect code FIRST, CLAUDE.md SECOND

Auto-reference loop prevention: if you read CLAUDE.md first, you reinforce its biases. Inspect the code first, then compare.

Read in this order:
1. `package.json` (stack, scripts, deps)
2. Directory structure (`ls`, `fd` recursive)
3. Recent git log (last 20 commits)
4. `skills/*/SKILL.md` frontmatter if repo has Dublin skills
5. Relevant config files (tsconfig, tailwind, drizzle, prisma, etc.)
6. **THEN** read CLAUDE.md

### Step 2 — Detect Drift (observable signals only)

Drift = diff between **declared** (CLAUDE.md) and **observed** (code/filesystem/git). If a claim is not diff-able, it's opinion — skip it.

Signals to check:

| Claim in CLAUDE.md | Observable source | Drift if mismatch |
|---|---|---|
| Stack ("We use Prisma + Postgres") | `package.json` dependencies | Yes |
| Package manager ("Use bun") | `packageManager` field, lockfile (bun.lockb vs package-lock.json vs pnpm-lock.yaml) | Yes |
| Node version / runtime | `engines.node`, `.nvmrc`, `.tool-versions` | Yes |
| Commands ("Run `pnpm test`") | `package.json scripts` | Yes |
| Folder structure ("`src/domain/...`") | `ls src/` | Yes |
| Frameworks/libraries | Top-level dependencies | Yes |
| Skills enumerated (Dublin repos) | `skills/*/SKILL.md` existing | Yes |
| Environment vars documented | `.env.example`, `src/config/env.ts`, `process.env` references | Yes |
| "Our convention is X" | Last 20 commits obey X? | Only if contradicted clearly |
| Architectural choices (hexagonal, DDD) | Folder structure + domain entities | Yes if structure diverged |

**NOT drift signals** (these are opinions, skip):
- Vibes, tone, general philosophy
- "We aim to..." / future state
- Code style preferences without explicit rules

### Step 3 — Classify each drift item

| Severity | Criteria | Action |
|---|---|---|
| **CRITICAL** | Wrong stack claim, wrong command, broken instruction | Propose update |
| **MODERATE** | Structure evolved, convention drifted in ≥ 5 recent commits | Propose update |
| **MINOR** | Stale example, minor path change | Propose update but mark low priority |
| **OPINION** | Not diff-able | Do NOT propose. Skip. |

### Step 4 — Emit Proposed Diff

Write to `CLAUDE.md.proposed` at repo root. Show:

```markdown
# CLAUDE.md Drift Report

## Severity: CRITICAL

### 1. Stack mismatch
- **Declared:** "We use Prisma"
- **Observed:** `package.json` has `drizzle-orm`, no `@prisma/client`
- **Evidence:** package.json line 23
- **Proposed patch:**
  ```diff
  - **ORM:** Prisma
  + **ORM:** Drizzle
  ```

## Severity: MODERATE

### 2. Folder structure
...

## NOT CHANGED (skipped as opinion)
- Philosophy sections — no diff-able signal
- General guidance paragraphs

---

## How to apply

Review the diff above. If you approve:
- `mv CLAUDE.md.proposed CLAUDE.md` (overwrites)
- Or copy sections manually
- Or run `/claude-md-keeper apply` (I will ONLY apply after explicit second invocation)
```

### Step 5 — Never Apply Without Second Confirmation

After emitting `CLAUDE.md.proposed`, the skill stops. Applying requires a **separate, explicit user command** (e.g. "aplicá el diff", "apply", "mv the proposed file").

If the user says "just do it" or "apply all" at the start, honor it — but still generate the proposed file first, then apply.

---

## Promotion from SESSION.md (when session-bridge is also installed)

When invoked with `promote` intent ("promoveme las decisiones de esta sesión a CLAUDE.md"):

1. Read `.claude/SESSION.md` (or `.context/session.md`)
2. Read archived sessions in `.claude/sessions/` (last N)
3. Apply the promotion policy from `references/promotion-policy.md`:
   - **2 of 3 criteria**: appeared in 2+ sessions / affects 2+ files-or-skills / user formulated as rule
4. For each candidate, propose as diff — user approves or skips each one

---

## Three-Layer Memory Awareness

Before proposing, check for conflicts across three memory layers:

```
~/.claude/agent-memory/shared/preferences.md     # user universal
~/.claude/agent-memory/{agent}/MEMORY.md          # agent operational (dublin-agent, etc.)
{repo}/CLAUDE.md                                  # project scope
```

**Write destination rules:**

| Type of info | Goes to |
|---|---|
| Applies to THIS project only | `CLAUDE.md` |
| Applies to ALL user's projects | `shared/preferences.md` (flag for user to promote manually) |
| Heuristic about how the agent works | `agent-memory/{agent}/` |
| In doubt | **DO NOT WRITE** — ask user |

**Conflict detection:**

On invocation, scan all three layers for:
- Same topic stated differently (e.g., "use bun" in shared, "use pnpm" in CLAUDE.md)
- Obsolete statements that still reference old stack

Report conflicts in the proposed diff. Do not auto-resolve.

---

## Failure Modes

| Failure | Behavior |
|---|---|
| No CLAUDE.md exists | Offer to generate one from scratch via scan. Get explicit OK first. |
| `.claude/SESSION.md` missing | Skip promotion flow. Only do drift detection. |
| Git not initialized | Skip git-log signals. Note limitation in output. |
| Package.json malformed | Report error, skip package-based signals. |
| User rejected previous proposals 3x in a row | Warn: "skill is proposing noise, recalibrate". Ask what signals to down-weight. |
| Conflict between `shared/preferences.md` and CLAUDE.md | Report but never resolve. User decides. |

---

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Read CLAUDE.md first, then inspect code | Reinforces biases | Code FIRST, CLAUDE.md SECOND |
| Auto-write CLAUDE.md | Silent corruption | Always propose diff |
| Propose changes from "vibes" | Opinion not drift | Only observable signals |
| Hook at session end | User loses control | On-demand ONLY |
| Resolve conflicts between memory layers | Oversteps | Report, user decides |
| Promote to CLAUDE.md on single mention | Arbitrary | 2-of-3 policy (see promotion-policy.md) |

---

## Reference Files

- `references/drift-detection.md` — Signal catalog, regex patterns, how to read each source, drift severity rubric
- `references/promotion-policy.md` — Criteria for promoting session decisions to CLAUDE.md (2-of-3 rule, candidate selection, diff template)
