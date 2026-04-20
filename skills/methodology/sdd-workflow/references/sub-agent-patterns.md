# SDD — Sub-Agent Launching Patterns

Detailed templates and contracts for launching SDD phase sub-agents.

Each template embeds the phase instructions inline — no external phase skill files required. The sub-agent only needs the prompt + context to do its job.

## Structured Output Contract

Every SDD sub-agent MUST return this structure (as JSON in the message, or clearly labeled sections):

```yaml
status: success | blocked | failed
executive_summary: "1-3 sentences for the user"
detailed_report: "Optional — longer context, only when user asked for depth"
artifacts:
  - type: proposal | specs | design | tasks | code | test
    location: "engram:sdd/{change}/{type}" | "path/to/file.md" | "in-memory"
    summary: "1 line"
next_recommended: "/sdd-spec {change-name}" | null
risks:
  - "1 line per risk"
blockers:
  - "1 line per blocker (only if status=blocked)"
```

The orchestrator parses this and presents to the user — NEVER raw sub-agent output.

---

## Template — Explore Phase

```
Task(
  description: "sdd-explore for {topic}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD explore sub-agent. No artifacts are created in this phase — only discovery.

CONTEXT:
- Project: {project_path}
- Topic: {topic}
- Artifact store: {engram | openspec | none}

TASK:
Investigate {topic} in the codebase. Identify:
1. Existing code that relates to this topic (file paths + what they do)
2. Constraints discovered (tech stack, conventions, coupling)
3. Questions that must be answered before proposing a change

Return the structured output contract. DO NOT create artifacts. DO NOT write code.`
)
```

---

## Template — Propose Phase

```
Task(
  description: "sdd-propose for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD propose sub-agent. Your job is to write a proposal artifact — WHAT + WHY, no HOW.

CONTEXT:
- Project: {project_path}
- Change: {change-name}
- Explore artifact (read first): {engram_key_or_path}
- Artifact store: {engram | openspec | none}

TASK:
Create the proposal artifact with these sections:
1. **Problem / motivation** — why this change exists, what's broken or missing
2. **Desired outcome** — WHAT the world looks like after (no implementation details)
3. **Scope** — explicit in-scope and out-of-scope lists
4. **Stakeholders / affected systems** — who cares, what's impacted
5. **Open questions** — things the proposal can't yet answer

Persist based on artifact store mode:
- engram: topic_key = "sdd/{change-name}/proposal"
- openspec: "openspec/{change-name}/proposal.md"
- none: return content in detailed_report

Return structured output with artifact location.`
)
```

---

## Template — Spec + Design (parallel)

When running these in parallel, launch TWO Task calls in the same message:

```
// Parallel call 1 — Spec
Task(
  description: "sdd-spec for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD spec sub-agent. Your job is to write the behavioral contract.

CONTEXT:
- Proposal to read: {engram_key_or_path}
- Artifact store: {engram | openspec | none}

TASK:
Write specifications:
1. **Behavioral contract** — input → output per capability (Given/When/Then if helpful)
2. **Acceptance criteria** — observable, testable statements
3. **Edge cases** — explicitly list non-happy paths
4. **Non-goals** — what the spec explicitly does NOT cover

No implementation details. No code. No architecture.

Persist to sdd/{change-name}/specs (or equivalent per store mode).
Return structured output.`
)

// Parallel call 2 — Design
Task(
  description: "sdd-design for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD design sub-agent. Your job is to describe HOW to satisfy the proposal.

CONTEXT:
- Proposal to read: {engram_key_or_path}
- Artifact store: {engram | openspec | none}

TASK:
Write the technical design:
1. **Architecture** — modules, boundaries, layers
2. **Data model** — entities, relationships, constraints
3. **Interfaces** — public APIs, contracts between modules
4. **Trade-offs** — choices made and alternatives rejected, with rationale
5. **Risks / unknowns** — what could break the design

Persist to sdd/{change-name}/design.
Return structured output.`
)
```

---

## Template — Tasks Phase

```
Task(
  description: "sdd-tasks for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD tasks sub-agent. Your job is to break design into executable tasks.

CONTEXT:
- Specs: {engram:sdd/{change}/specs}
- Design: {engram:sdd/{change}/design}

TASK:
Break the design into implementation tasks. Each task:
- Scoped to 1-4 hours of focused work
- Independent or clearly sequenced (note blockers)
- Has explicit acceptance criteria
- Grouped into phases (e.g. "Phase 1 — scaffolding", "Phase 2 — core logic")

Output format per task:
- ID (1.1, 1.2, 2.1, ...)
- Title (imperative verb)
- Files expected to change
- Acceptance criteria
- Blocks / blocked by

Persist to sdd/{change-name}/tasks. Return structured output with task count + phases.`
)
```

---

## Template — Apply Phase (batched)

For Phase 1 of a 4-phase task list:

```
Task(
  description: "sdd-apply Phase 1 (tasks 1.1-1.3) for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD apply sub-agent. Your job is to IMPLEMENT the listed tasks.

CONTEXT:
- Tasks: {engram:sdd/{change}/tasks}
- Phase to implement: Phase 1, tasks 1.1, 1.2, 1.3
- Specs (for reference): {engram:sdd/{change}/specs}

TASK:
Implement the listed tasks following the project's coding conventions. You have FULL access to all coding tools and may invoke relevant skills (tdd-workflow, testing-strategy, frontend-foundation, etc.) as needed.

Rules:
- Write tests alongside code (or first, if TDD applies to this project)
- Follow the acceptance criteria in the tasks artifact exactly
- If a task is blocked (missing info, ambiguous spec), stop and return status=blocked
- Record completion state in sdd/{change}/state after each task

Return structured output with: files changed, tests added, task completion status.`
)
```

---

## Template — Verify Phase

```
Task(
  description: "sdd-verify for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD verify sub-agent. Your job is to validate implementation against specs.

CONTEXT:
- Specs: {engram:sdd/{change}/specs}
- Code changes: {git diff summary or file list}

TASK:
For each acceptance criterion in specs:
1. Does the code cover it? Evidence: file + line range
2. Does a test exist? Evidence: test file + test name
3. Does the test actually run green? Run it if possible.

Output a coverage matrix: spec → code → test → status (✓ / ✗ / partial).

Flag drift: anywhere the code does X but the spec says Y, report it as a drift item with severity.

Return structured output with coverage %, drift items, and recommendation (ready to archive / re-apply / re-spec).`
)
```

---

## Template — Archive Phase

```
Task(
  description: "sdd-archive for {change-name}",
  subagent_type: "general-purpose",
  prompt: `You are an SDD archive sub-agent. Your job is to finalize and retire the change.

CONTEXT:
- All artifacts: sdd/{change}/*
- Verify result: {engram:sdd/{change}/verify}

TASK:
Archive the change:
1. Mark all artifacts as archived (engram: tag archived=true; openspec: move to openspec/archive/)
2. Update the project's changelog or release notes if one exists
3. Capture lessons learned if any surfaced during verify
4. Confirm no lingering TODOs reference this change-name

Return structured output with final artifact state and any follow-up items.`
)
```

---

## Orchestrator Response Pattern (to user)

After each sub-agent returns, the orchestrator presents:

```markdown
## {Phase} complete — {change-name}

**Status:** success

**What happened:** {executive_summary}

**Artifacts:**
- {type}: {location} — {summary}

**Risks:**
- {risk}

**Next:** {next_recommended}

¿Seguimos?  /  Continue?
```

Short. User-digestible. Not raw sub-agent output.

---

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| Orchestrator reads source code to understand the task | Launch sdd-explore sub-agent |
| Orchestrator writes the proposal inline | Launch sdd-propose sub-agent |
| Sub-agent returns prose, orchestrator tries to parse it | Enforce structured output contract |
| Sub-agent uses skill tool for SDD meta-commands | Meta-commands are orchestrator-handled, NEVER in Skill tool |
| Orchestrator skips user approval after phase | Always show summary + ask, except `/sdd-ff` |
| Phases run in apply without checking verify later | verify is optional but strongly recommended |
| Engram `mem_search` used without `mem_get_observation` | Previews are truncated — always two-step |
