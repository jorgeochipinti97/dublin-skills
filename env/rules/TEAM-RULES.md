<!-- DUBLIN-TEAM-RULES:START -->
<!-- Managed by `./install.sh team`. Edit the source in dublin-skills/env/rules/TEAM-RULES.md and re-run, or edit below and it will be preserved on re-install (content between markers is replaced only with --force). -->

# Team Rules — Dublin Environment

Working rules for every AI agent (Claude Code / OpenCode / Codex) on this team's
projects. Installed via `./install.sh team`. These rules take priority over the
agent's default behavior.

> These are **team** rules. Each developer's personal preferences (language,
> tone, editor) live in their own user-scope config, not here.

---

## 1. Hard Rules — non-negotiable

### Zero hallucinations
- READ / CHECK / ASK before stating anything about the code.
- Never invent file names, functions, flags, endpoints, or APIs.
- "I don't know" / "I need to verify" is a valid answer and is preferred over a guess.
- If a fact can't be verified in the repo, say so explicitly.

### Finish now
- No deferring ("let's continue tomorrow", "we'll see that later").
- Finish everything that can be finished in the current session.
- If something is blocked, state exactly what's missing and what unblocks it.

### Change-safety before touching production
Before any write to production (DB, store/CMS, deploy, config, infra, DNS, secrets):
1. Snapshot/backup taken **and tested** by restoring it.
2. Rollback plan written (trigger + procedure + RTO).
3. Stakeholders + on-call notified.
4. In-flight transaction check.
5. Change window declared (off-peak).
6. Second-human approval for medium+ changes.

Triggers: `ALTER` / `DROP` / `TRUNCATE` / `RENAME`, `UPDATE`/`DELETE` without
`WHERE`, mass batches, deploy to prod, catalog/price/stock edits, secret
rotation, DNS/TLS/IAM changes.

### Safe Git
- Nobody pushes directly to `main`.
- Forbidden: force push to shared branches, rebasing already-pushed commits,
  `reset --hard` over others' work, `--no-verify`.
- New changes go in new commits, never by rewriting history.

---

## 2. Frontend conventions

- **Foundation-first**: `frontend-foundation` before any visual polish.
- **Dual theme from day 1**: dark + light via semantic CSS variables. Never add
  the second theme "later".
- **Real mobile-first**: design at 360px first, not a shrunk desktop. Touch
  targets ≥ 44×44px. `100dvh`, not `100vh`.
- **CLS Zero**: target < 0.05. Every image has `width`+`height` or
  `aspect-ratio`. Banners overlay (`fixed`), never inline.
- **Icon budget**: nav ≤ 5, hero ≤ 1, card ≤ 2, button ≤ 1, form field ≤ 1,
  footer social ≤ 3. One icon library per project.
- **Spacing system**: one scale; layout primitives own spacing. No arbitrary values.
- **Component system** on headless primitives (Base UI / Radix / React Aria)
  with a branded layer on top.
- **DESIGN.md per project**: tokens + rationale at the repo root.

---

## 3. Forbidden AI Tells

Patterns that betray output generated without judgment. Not used:

| Tell | What it bans |
|---|---|
| LILA BAN | Generic AI purple/blue |
| Jane Doe Effect | Generic names/avatars (John Doe, Sarah Chen) |
| Acme Slop | Invented generic brands (Acme, Nexus) |
| Filler Word Index | Elevate, Unleash, Seamless, Next-gen, Revolutionize |
| 99.99% Problem | Predictable demo numbers |
| Pure Black Tell | Never pure `#000` |
| Inter Tell | Generic default sans |
| Icon Soup | Icons everywhere with no budget |
| Mobile Afterthought | "Responsive later" → shrunk-desktop mobile |
| Layout Shift Sloppy | CLS > 0.05 |

Data Realism: messy numbers, real names, no placeholder brands.

---

## 4. How we work (process)

- **SDD for substantial changes**: if it touches ≥ 3 files or architecture, plan
  before implementing (proposal → specs → design → tasks → apply).
- **Skill order**:
  - `domain-modeler` → `hexagonal-architect` / `api-architect`
  - `database-architect` → `auth-architect`
  - `frontend-foundation` → `mobile-design` → `premium-frontend-design`
  - `infra-security` before any deploy
- **Non-destructive review gates** after implementing:
  - Frontend → `react-performance` + `frontend-output-validator`
  - Backend → `backend-performance`
- **Conventional Commits** + PR ≤ 400 LOC + squash by default.

---

## 5. Team technical defaults

- **DB**: Postgres by default. UUID v7, `TIMESTAMPTZ`, FK + indexes always.
- **Migrations**: zero-downtime (3-step rename, `NOT VALID` + `VALIDATE`,
  `CONCURRENTLY`).
- **Web auth**: sessions via httpOnly cookies (no JWT in localStorage).
- **Errors**: Problem Details (RFC 7807) with `code` + `correlationId`.
- **Tests**: pyramid ~70/20/10. Testcontainers for real integration.

---

## 6. Agent operating discipline

Adopted from the Gentleman ecosystem (gentle-ai). Operational rules — they keep
the agent from the common failure modes (jumping to code, losing decisions,
giant diffs, deferred testing).

### Work routing — classify before acting
Every request is routed, not improvised:
- **Small, clear edit** → do it inline, no ceremony.
- **Context-heavy / exploration** → delegate to a focused subagent so the main
  thread stays clean.
- **Large / ambiguous / architectural** (≥ 3 files or a design decision) → run
  the SDD flow (proposal → specs → design → tasks → apply → verify).

### Delegation contract
When the orchestrator spawns a subagent, it passes the **explicit list of skills
to load** for that subagent's phase. Subagents do **not** independently discover
or load other project skills — they execute with what the parent handed them.
The parent owns memory retrieval and passes the needed context into the prompt.

### TDD evidence (not just "tests pass")
For test-driven work, record the cycle as evidence:
**RED** (failing test written) → **GREEN** (minimal code to pass) →
**TRIANGULATE** (add cases that force generalization) → **REFACTOR** (clean up,
tests stay green). State which phase each change belongs to.

### Model routing per phase
Match model cost to the phase:
- **Cheap / fast** model for exploration, search, mechanical edits.
- **Premium** model (Opus) for design, architecture, and review/verify.

Don't burn a premium model on a grep; don't review a security change with a
cheap one.

<!-- DUBLIN-TEAM-RULES:END -->
