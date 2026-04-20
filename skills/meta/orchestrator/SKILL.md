---
name: orchestrator
description: Skill Orchestrator / Router. Use at the START of any non-trivial task to analyze the full set of installed skills in `.claude/skills/`, evaluate opportunity cost (token cost vs expected value), resolve dependencies, and produce an ordered execution plan as a task list. Invoke when the user describes a task that likely spans multiple skills (building a product, shipping a feature, auditing a codebase) or explicitly asks for a plan. Output: ranked skills + invocation order + task list. Pattern known as Skill Router / Supervisor Agent / Plan-and-Execute.
---

# Orchestrator — Skill Router

Think Jarvis — routes the task to the right tools in the right order, with rationale.

## When to Invoke

- User describes a multi-step / multi-domain task ("build a SaaS", "add checkout flow", "audit this app")
- User asks for a plan explicitly
- Before spending tokens implementing blindly — orchestrator plans first, then delegates
- When a task is ambiguous about which skills apply

**Do NOT invoke** for:
- Single-skill tasks ("write a blog post" → go straight to `blog-writer`)
- Trivial questions
- When the user is mid-flow on a single skill

## The Algorithm

### Step 1 — Read the Manifest (fast path)

Look for `skills.manifest.json` at the skills root. If present, parse it.

If absent, fall back to reading every `SKILL.md` frontmatter (`name`, `description`).

### Step 2 — Score Each Skill

For each installed skill, assign a **relevance score (0-10)**:

| Signal | Score |
|---|---|
| Task explicitly mentions the skill domain | +5 |
| Task involves an artifact the skill is built for | +3 |
| Skill is a prerequisite of another relevant skill | +2 |
| Task mentions a keyword from the skill's triggers | +1 per keyword |
| No relevance | 0 |

Then assign **opportunity cost** — rough token cost of invoking the skill:

| Skill size (SKILL.md + references) | Cost |
|---|---|
| < 5k tokens | Low |
| 5k – 20k | Medium |
| > 20k | High |

**Decision:** include only skills where `relevance × benefit > cost`. Borderline skills → mention as "optional" in the plan.

### Step 3 — Resolve Dependencies

Skills have ordering dependencies. Respect them strictly.

Examples from this repo:

```
frontend-foundation  →  premium-frontend-design
frontend-foundation  →  product-tour
frontend-foundation  →  react-performance
domain-modeler       →  hexagonal-architect
hexagonal-architect  →  tdd-workflow / testing-strategy
database-architect   →  hexagonal-architect (repositories know the schema)
auth-architect       →  database-architect (user/session tables)
error-handling       →  forms-and-validation (surfacing server errors)
product-planner      →  (everything downstream)
systems-thinking     →  product-planner (when the domain is complex)
landing-page-architect  →  premium-frontend-design
```

**Rule:** "Foundation" skills come first. Aesthetic/polish skills come last. Audits (testing, error-handling, security) are woven throughout, not tacked on the end.

### Step 4 — Group Into Phases

Output the plan in phases, not a flat list. Each phase is atomic — all its skills feed each other.

Typical phases for a new product:

```
Phase 1 — Discovery          → systems-thinking, product-planner
Phase 2 — Domain + Data      → domain-modeler, database-architect
Phase 3 — Architecture       → hexagonal-architect, api-architect, auth-architect
Phase 4 — Frontend Foundation → frontend-foundation
Phase 5 — UX + UI            → product-ux-advisor, premium-frontend-design, forms-and-validation
Phase 6 — Feature Layer      → product-tour, landing-page-architect
Phase 7 — Cross-cutting      → error-handling, testing-strategy, react-performance
Phase 8 — Ops                → infra-security, observability
Phase 9 — Go-to-market       → blog-writer, institutional-site-architect
```

Not every task needs all phases — cut aggressively.

### Step 5 — Emit the Plan

Output format:

```markdown
## Plan — {task summary}

### Context analysis
- Goal: {1-line goal}
- Inferred scope: {key artifacts}
- Red flags / ambiguities: {what's unclear, what to confirm before starting}

### Selected skills (ranked)

| # | Skill | Phase | Relevance | Reason |
|---|---|---|---|---|
| 1 | frontend-foundation | Foundation | 9/10 | Must precede any UI work |
| 2 | ...

### Skipped (and why)

| Skill | Reason skipped |
|---|---|
| blog-writer | No content output required |
| ...

### Execution order

**Phase 1 — Foundation**
1. frontend-foundation — set up theme, spacing, component system

**Phase 2 — ...**
...

### Open questions before execution

1. {Anything orchestrator needs to confirm with the user before proceeding}

### Estimated scope

- Skills in play: N
- Phases: N
- Rough complexity: S / M / L / XL
```

### Step 6 — (Optional) Create TaskList

If the harness exposes `TaskCreate` (Claude Code does), create one entry per skill invocation with dependencies via `addBlockedBy` to turn the plan into executable state. If the tool isn't available, skip — the emitted plan is still the output.

## Operating Modes

### Mode A — Fresh plan

User says: "plan a signup flow with auth + onboarding"

→ Orchestrator builds the plan from scratch, outputs phases + task list.

### Mode B — Validate an existing plan

User provides their own order. Orchestrator:

1. Checks for missing skills the user forgot
2. Checks for skills the user included but aren't needed
3. Checks dependency violations (e.g. `premium-frontend-design` before `frontend-foundation`)
4. Returns an annotated plan: kept / added / removed / reordered, each with a one-line rationale

### Mode C — Audit mode

User says: "what's missing in this repo?"

→ Orchestrator reads the repo, maps it against the installed skill library, and reports gaps ("no error handling layer visible — consider invoking `error-handling`").

## Scoring Heuristics (quick lookup)

| Task verb | Likely skills |
|---|---|
| "build", "create a new" | product-planner → domain-modeler → architecture → frontend-foundation → UX → premium-frontend-design |
| "audit", "review" | product-ux-advisor, react-performance, infra-security, testing-strategy, error-handling |
| "fix", "debug" | testing-strategy (reproduce), error-handling (classify), domain (root cause) |
| "optimize" | react-performance, database-architect (queries), infra-security (cost) |
| "migrate", "refactor" | systems-thinking (map), domain-modeler (remodel), testing-strategy (net) |
| "ship", "deploy" | infra-security, testing-strategy, error-handling |
| "design a page / UI" | product-ux-advisor, frontend-foundation, premium-frontend-design |
| "write content" | blog-writer, landing-page-architect, institutional-site-architect |
| "secure" | auth-architect, infra-security, error-handling (no leaks) |

## Token-Efficiency Rules

- **Never load a skill's references** during planning — only SKILL.md frontmatter + the skill's description
- **Manifest-first** — if `skills.manifest.json` exists, read that, skip per-SKILL.md reads
- **Cap relevance check** at skill count × 100 tokens — if that's too much, fall back to keyword heuristics on task description
- **Cache the plan** — if the user continues in the same session, don't re-plan unless scope shifts

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| Load every skill's full content to decide | Use description + manifest tags only |
| Include every skill "just in case" | Cost > benefit; skip borderline |
| Ignore dependencies ("`premium-frontend-design` first, then foundation") | Foundation always first |
| Output a flat list without phases | Phases make parallelism visible |
| Re-plan on every turn | Cache, only re-plan on scope change |

## Output Standards

- Plan is concise — one-line reasons per skill, not paragraphs
- Phases are labeled and ordered
- **Always** include "Skipped" section — proves orchestrator considered alternatives
- End with `TaskCreate` calls when the harness supports it
- Open questions surfaced BEFORE the task list, not after
- If any skill is missing that would clearly help, flag it ("I'd invoke `x-architect` here, but it's not installed")

## Example Invocations

```
"plan the MVP of a B2B SaaS for project management"
"build a checkout flow with Stripe for this Next.js app"
"audit this repo for missing engineering foundations"
"I want to ship a landing page this week — what do I need?"
"validate this plan: 1) premium-frontend-design, 2) forms-and-validation, 3) auth-architect"
```

## Reference Files

- `references/scoring.md` — Worked examples of relevance scoring across 5 archetypal tasks, skill-to-task matrix, dependency graph notation
