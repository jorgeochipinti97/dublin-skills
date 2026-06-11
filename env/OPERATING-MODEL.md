# Operating Model

How this team ships work with an AI agent. One flow, three roles, context that
stays alive on its own. Installed by `./install.sh install`.

## Roles

| Role | Who | Does |
|---|---|---|
| **Tech Lead** | the agent (dublin-agent) | Leads. Classifies work, runs SDD, prioritizes, **builds the order when none exists**, splits into scoped tasks, decides architecture, runs review gates, keeps context files current. |
| **Approver** | the owner | Approves SDD phase gates and merges PRs. Stays in control of direction without being in every detail. |
| **Dev** | team member (incl. non-technical) | Brings requirements; may start an SDD flow (guided phase-by-phase in plain language); executes scoped tasks on a branch → PR. Never pushes to `main`. |

**Guardrail:** architectural decisions and any production-affecting change always
need the owner's sign-off — a non-technical dev approving a spec does not replace
that.

## The one flow

```
Objective / client requirement
  → Tech Lead classifies
      ├─ big   → SDD: proposal → specs → design → tasks   (owner approves each gate)
      └─ small → direct task
  → Tech Lead prioritizes; if no order exists, builds it:
        client/deadline → unblocks others → impact → effort   (owner approves)
  → tasks land in TASKS.md (shared) or TASKS.<dev>.local.md (private)
  → Dev executes on a branch → review gates run → PR (≤400 LOC, squash)
  → owner approves & merges
  → context files update automatically (below)
```

## Context files (per project, file-based, no external tool)

| File | What | Git |
|---|---|---|
| `SESSION.md` | Running state: in progress · next · blockers | versioned |
| `TASKS.md` | Shared backlog: **Client pains · Backlog · Doing · Done · Future/ideas** | versioned |
| `TASKS.<you>.local.md` | Your private personal tasks | gitignored |

**Upkeep is automatic.** At the end of every unit of work the Tech Lead, without
being asked: ticks the finished task (→ `Done`), appends a dated line to
`SESSION.md`, and saves non-obvious decisions to engram. "Done" means the work
**and** its context are updated — so the next dev (or you, next week) starts with
full context, never from zero.

## How you talk to it (no commands)

- `"how's <project> going?"` / `"daily"` → reads `SESSION.md`(s), summarizes.
- `"add task to <project>: … for <client>"` → shared backlog. `"… for me"` → your private file.
- `"my tasks"` / `"what's pending for me"` → your open items across projects.
- `"let's build <feature>"` → Tech Lead routes it (small task or SDD) and leads.
- `"mark <x> as done"` → moves it to Done and updates `SESSION.md`.

## Pointers

- Team rules (what the agent must follow): `CLAUDE.md` (installed from `TEAM-RULES.md`).
- Persistent memory: [engram](https://github.com/Gentleman-Programming/engram) — `brew install gentleman-programming/tap/engram` once per machine.
