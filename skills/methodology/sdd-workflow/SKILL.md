---
name: sdd-workflow
description: Spec-Driven Development orchestration — proposal → specs → design → tasks → apply → verify → archive. Use when the user says 'sdd init', 'sdd new <name>', 'sdd ff', 'sdd apply', 'sdd verify', 'sdd archive', 'iniciar sdd', 'nuevo cambio', 'fast forward', or when a described feature/change is substantial enough (new feature, refactor, multi-file change) to warrant planning before implementation. Provides triggers, commands, dependency graph, artifact store policy (Engram/OpenSpec/none), and sub-agent launching pattern. Single source of truth for SDD — the dublin-agent (and any other agent) references this skill instead of embedding the methodology inline.
---

# Spec-Driven Development (SDD) Workflow

SDD = plan before code. Proposal → Specs (WHAT) → Design (HOW) → Tasks (STEPS) → Apply (BUILD) → Verify (CHECK) → Archive.

## When SDD Applies

**Use SDD for:**
- New features (non-trivial, multi-file)
- Refactors that touch ≥ 3 files or cross module boundaries
- Architectural changes
- Migrations
- Anything where "get it right" > "ship fast"

**Skip SDD for:**
- Single-file edits
- Quick bug fixes with known cause
- Questions / explanations
- Prototypes where spec would be overhead

**The judgment call:** if you'd feel bad throwing away the implementation, SDD is worth it. If not, skip.

---

## Triggers

The agent invoking this skill should recognize these triggers in user input:

| Trigger (ES / EN) | Command |
|---|---|
| "sdd init" / "iniciar sdd" / "initialize specs" | `/sdd-init` |
| "sdd new <name>" / "nuevo cambio" / "new change" / "sdd explore" | `/sdd-new` |
| "sdd continue" / "continuar" | `/sdd-continue` |
| "sdd ff" / "fast forward" | `/sdd-ff` |
| "sdd apply" / "implementar" / "implement" | `/sdd-apply` |
| "sdd verify" / "verificar" | `/sdd-verify` |
| "sdd archive" / "archivar" | `/sdd-archive` |
| User describes substantial feature/change | Suggest `/sdd-new {suggested-name}` |

**Suggestion, not coercion:** when you detect a substantial change, SUGGEST SDD. Don't force it on small tasks.

Example prompt to the user:
> "Esto me parece buen candidato para SDD. ¿Arrancamos con `/sdd-new {suggested-name}`?"

---

## Commands

| Command | What it does |
|---|---|
| `/sdd-init` | Bootstrap SDD context in current project |
| `/sdd-explore <topic>` | Think through an idea (no files created — conversational only) |
| `/sdd-new <change-name>` | Start new change (creates proposal artifact) |
| `/sdd-continue [change-name]` | Create the next needed artifact (spec / design / tasks) |
| `/sdd-ff [change-name]` | Fast-forward: proposal → spec → design → tasks in sequence |
| `/sdd-apply [change-name]` | Implement the tasks (code writing phase) |
| `/sdd-verify [change-name]` | Validate implementation against specs |
| `/sdd-archive [change-name]` | Sync specs + archive the change |

---

## Dependency Graph

```
proposal ─┬─► specs ──┬─► tasks ──► apply ──► verify ──► archive
          │           │
          └─► design ─┘
```

- **proposal** is the root (WHAT + WHY, no solutions)
- **specs** and **design** can be created in **parallel** (both depend only on proposal)
- **tasks** depends on BOTH specs and design
- **apply** depends on tasks
- **verify** is optional but recommended before archive
- **archive** is terminal

---

## Artifact Store Policy

Three possible backends for storing artifacts:

| Mode | Backend | When to use |
|---|---|---|
| `engram` | [engram MCP](https://github.com/gentleman-programming/engram) | **Recommended.** Memory-backed, searchable, versioned |
| `openspec` | File artifacts in project (`openspec/` folder) | User explicitly requests project files |
| `none` | No persistent artifacts — conversational only | Default fallback; recommend enabling engram |

**Default resolution:**
1. If Engram is available → use `engram`
2. If user explicitly requests file artifacts → `openspec`
3. Otherwise → `none`

**Critical rule:** `openspec` is NEVER chosen automatically. Only when the user explicitly asks for project files.

**In `none` mode:** do NOT write project files unless the user asks. Keep everything in conversation. Recommend enabling engram for better results.

---

## Engram Artifact Convention

When using Engram, artifacts follow deterministic naming:

```
topic_key:   sdd/{change-name}/{artifact-type}
title:       sdd/{change-name}/{artifact-type}
artifact-type: proposal | specs | design | tasks
```

### Recovery Protocol (two-step, ALWAYS both)

Engram's `mem_search` returns truncated previews. To read full content you MUST also call `mem_get_observation`:

```
1. mem_search("sdd/{change-name}/{type}")   → returns truncated preview + ID
2. mem_get_observation(id)                   → returns FULL content (REQUIRED)
```

Skipping step 2 gives you partial data and silent bugs.

### Writing / Updating

Use `topic_key` for upserts — avoids creating duplicates.

---

## Orchestrator Rules (for the lead agent)

These apply to the ORCHESTRATOR (the agent invoking SDD). Sub-agents launched by the orchestrator are NOT bound by these rules — they have full capability to read/write code.

1. Orchestrator NEVER reads source code directly — sub-agents do that
2. Orchestrator NEVER writes implementation code — sub-agents do that
3. Orchestrator NEVER writes specs/proposals/design — sub-agents do that
4. Orchestrator ONLY: tracks state, presents summaries to user, asks for approval, launches sub-agents
5. Between sub-agent calls, ALWAYS show the user what was done and ask to proceed (except `/sdd-ff` which batches)
6. Orchestrator keeps context MINIMAL — pass file paths to sub-agents, not file contents
7. NEVER run phase work inline as lead. Always delegate.
8. **META-COMMANDS** (`/sdd-ff`, `/sdd-continue`, `/sdd-new`) are handled by the ORCHESTRATOR, NOT via Skill tool. Orchestrator launches individual Task tool calls for each sub-agent phase.
9. When a sub-agent suggests a next command ("run /sdd-ff"), treat it as a **SUGGESTION TO SHOW THE USER** — not auto-executable. Always ask.

---

## Sub-Agent Launching Pattern

When launching a sub-agent for an SDD phase, use this pattern:

```
Task(
  description: '{phase} for {change-name}',
  subagent_type: 'general-purpose',
  prompt: `You are an SDD {phase} sub-agent.

CONTEXT:
- Project: {project path}
- Change: {change-name}
- Artifact store mode: {engram | openspec | none}
- Previous artifacts: {list of paths or engram topic keys to read}

TASK:
{phase-specific instructions — see references/sub-agent-patterns.md for exact templates per phase}

Return structured output:
- status: (success | blocked | failed)
- executive_summary: (1-3 sentences)
- detailed_report: (optional longer context)
- artifacts: (what you created/updated)
- next_recommended: (suggested next command)
- risks: (anything the user should know)
`
)
```

### Phase-specific instructions

The templates in `references/sub-agent-patterns.md` embed the full phase instructions inline — no external phase skill files required. If you later extract them into separate skills under `.claude/skills/sdd-{phase}/`, the orchestrator can reference them by path in the prompt; otherwise the inline templates are self-contained.

Phases covered:
- `explore` — Investigate codebase (no artifacts)
- `propose` — Create proposal (WHY + WHAT)
- `spec` — Behavioral specifications (can parallel with design)
- `design` — Technical design (can parallel with spec)
- `tasks` — Break design into implementation tasks
- `apply` — Implement the tasks (batched)
- `verify` — Validate implementation against specs
- `archive` — Archive the change

---

## Command → Phase Mapping

| Command | Phases to launch (in order) |
|---|---|
| `/sdd-init` | sdd-init |
| `/sdd-explore <topic>` | sdd-explore |
| `/sdd-new <name>` | sdd-explore → sdd-propose |
| `/sdd-continue [name]` | Next needed from: sdd-spec, sdd-design, sdd-tasks (check dependency graph) |
| `/sdd-ff [name]` | sdd-propose → sdd-spec → sdd-design → sdd-tasks (all four, batched) |
| `/sdd-apply [name]` | sdd-apply |
| `/sdd-verify [name]` | sdd-verify |
| `/sdd-archive [name]` | sdd-archive |

---

## State Tracking

After each sub-agent completes, track:

- **Change name**
- **Artifact status**: proposal ✓ / specs ✓ / design ✗ / tasks ✗
- **Task completion** (if in apply phase): which tasks done, which blocked
- **Issues or blockers** reported by the sub-agent

Tracking can live in:
- **Engram** (preferred) — topic `sdd/{change-name}/state`
- **TaskCreate** entries — one per phase + approval gate
- **In-memory** (ephemeral, only if engram/tasks unavailable)

---

## Fast-Forward Strategy (`/sdd-ff`)

`/sdd-ff` batches: `sdd-propose → sdd-spec → sdd-design → sdd-tasks`.

**Rules:**
- Launch sequentially (each depends on previous)
- Show the user ONE summary **after all four complete**, not between each
- If any phase fails, stop and report — do not skip

---

## Apply Strategy

For large task lists in `/sdd-apply`:

- **Batch tasks** to sub-agents (e.g. "implement Phase 1, tasks 1.1-1.3")
- **Do NOT send all tasks at once** — break into manageable batches of 3-5 related tasks
- After each batch: show progress to user, ask to continue
- Sub-agents in apply phase have FULL access to coding skills (TDD, React, TypeScript, etc.)

---

## Approval Gates

| Gate | When |
|---|---|
| Before first phase launches | Show plan, ask OK |
| Between phases (non-ff mode) | Show what was done, ask to continue |
| `/sdd-ff` batches | Only ONE gate — at the end, show all four |
| Destructive actions in apply (migrations, deletes, refactors > 10 files) | Always gate |
| Additive actions in apply (new file, new function) | No gate unless user asked for auto-approve |

**Escape hatch:** User can say "auto-approve" at start → orchestrator skips intermediate gates, only stops on failure or destructive actions.

---

## Failure Modes

| Failure | Orchestrator behavior |
|---|---|
| Phase instructions missing / ambiguous | Ask the user for clarification. Do NOT fabricate steps. |
| Sub-agent returns `status: failed` | Show error, ask user: retry / skip / abort |
| Sub-agent returns `status: blocked` | Show blocker, ask user how to resolve |
| Engram unavailable mid-workflow | Warn user, offer to continue in `none` mode |
| User cancels mid-phase | Save state to engram/tasks if possible, document where to resume |
| Artifact drift (spec ≠ code after apply) | Flag in verify phase, suggest re-spec or re-apply |

---

## Reference Files

- `references/sub-agent-patterns.md` — Detailed launching templates, example prompts, structured output contract
- `references/artifact-policy.md` — Engram setup, openspec file conventions, fallback rules
