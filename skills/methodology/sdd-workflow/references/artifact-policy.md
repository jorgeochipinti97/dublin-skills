# SDD — Artifact Store Policy

Rules for storing SDD artifacts (proposals, specs, designs, tasks, state) across three backends.

## The Three Modes

```
┌─────────────────┬─────────────────────────┬────────────────────────┐
│ Mode            │ Backend                 │ When                   │
├─────────────────┼─────────────────────────┼────────────────────────┤
│ engram          │ Engram MCP memory       │ Recommended default    │
│ openspec        │ openspec/ folder (fs)   │ User explicitly asks   │
│ none            │ Conversation only       │ Fallback               │
└─────────────────┴─────────────────────────┴────────────────────────┘
```

---

## Mode: `engram` (recommended)

### Setup

Engram MCP must be configured in Claude Code. Check:
- Claude Code settings include `engram` MCP server
- Tools `mem_search`, `mem_get_observation`, `mem_create_observation` available
- Connection to `https://github.com/gentleman-programming/engram` instance (local or hosted)

### Topic Key Convention

```
sdd/{change-name}/{artifact-type}
```

Artifact types:
- `proposal`
- `specs`
- `design`
- `tasks`
- `state` (ephemeral progress tracking)
- `verify` (validation results)

Example for a change named "add-stripe-checkout":
- `sdd/add-stripe-checkout/proposal`
- `sdd/add-stripe-checkout/specs`
- `sdd/add-stripe-checkout/design`
- `sdd/add-stripe-checkout/tasks`
- `sdd/add-stripe-checkout/state`

### Reading — Two-Step Protocol (NON-NEGOTIABLE)

Engram's search returns truncated previews. To read the full observation:

```
// Step 1 — search by topic key
results = mem_search("sdd/add-stripe-checkout/proposal")

// Step 2 — fetch full content
full = mem_get_observation(results[0].id)
```

**Skipping step 2** gives you partial content → silent bugs where a sub-agent acts on incomplete info.

### Writing — Upsert via topic_key

Always pass `topic_key` when creating an observation. Engram upserts — no duplicates.

```
mem_create_observation({
  topic_key: "sdd/add-stripe-checkout/proposal",
  title: "sdd/add-stripe-checkout/proposal",
  content: "# Proposal\n\n..."
})
```

### Pros / Cons

| Pros | Cons |
|---|---|
| Searchable across all projects | Requires Engram MCP setup |
| Versioned (implicit via observations) | User can't `ls` artifacts locally |
| Persists across sessions | Not committed to git |
| No git noise | |

---

## Mode: `openspec` (file artifacts)

**Choose ONLY when user explicitly asks** for project files. Never default to this.

### Folder Convention

```
{project-root}/
└── openspec/
    ├── changes/
    │   └── {change-name}/
    │       ├── proposal.md
    │       ├── specs.md
    │       ├── design.md
    │       ├── tasks.md
    │       ├── state.md
    │       └── verify.md
    └── archive/
        └── {change-name}/       # moved here after sdd-archive
```

### File Format

Each file starts with frontmatter:

```markdown
---
change: add-stripe-checkout
artifact: proposal
created: 2026-04-19
status: active | archived
---

# Proposal: Add Stripe Checkout

...
```

### Git Tracking

- By default, `openspec/` is committed
- If the team prefers local-only, add `openspec/` to `.gitignore` — document this choice

### Pros / Cons

| Pros | Cons |
|---|---|
| User can read files in editor | Commits become noisy |
| Works without Engram | Merge conflicts in `tasks.md` |
| Portable across tools | Stale artifacts pollute repo |

---

## Mode: `none` (fallback)

**Use when:** Engram unavailable AND user didn't ask for files.

### Behavior

- Keep artifacts in **conversation context only**
- Do NOT write project files
- Do NOT attempt Engram operations (will fail)
- On every phase completion, echo full artifact inline so it's in scrollback

### When orchestrator detects this mode

At the start of the first SDD interaction, the orchestrator should say:

> "Estoy operando en modo `none` — no voy a persistir artefactos. Para sesiones más largas te recomiendo habilitar Engram o decirme que use `openspec` para archivos locales."

---

## Default Resolution Logic

```python
if engram_available:
    mode = "engram"
elif user_said_write_files:
    mode = "openspec"
else:
    mode = "none"
    recommend_engram_to_user()
```

**Critical:** `openspec` is NEVER picked automatically. Only when the user explicitly asks.

---

## Mode Switching Mid-Workflow

If Engram fails mid-workflow:

1. Warn user
2. Offer to continue in `none` mode
3. If user continues, echo all artifacts inline from now on
4. Never silently fall back

If user asks mid-workflow to switch to `openspec`:

1. Export all current engram artifacts to `openspec/changes/{change-name}/`
2. Continue in `openspec`
3. Confirm the export to user

---

## Archiving

### In `engram` mode

Add tag `archived=true` to all observations under `sdd/{change-name}/*`. They remain searchable with `archived=true` filter.

### In `openspec` mode

Move folder:
```
openspec/changes/{change-name}/  →  openspec/archive/{change-name}/
```

### In `none` mode

No-op. The archive step is conversational only — user copies output somewhere if they want.

---

## Anti-Patterns

| Anti-pattern | Fix |
|---|---|
| `mem_search` without `mem_get_observation` | Always two-step |
| Default to `openspec` because "files are nicer" | Only when user asks |
| Creating files while in `none` mode | Never — keep in conversation |
| Multiple observations with same topic_key (no upsert) | Always pass `topic_key` for upsert |
| Storing code (not artifacts) in Engram | Engram is for artifacts only. Code lives in the repo. |
| Manually syncing engram ↔ openspec | Pick one mode per change. Switching = explicit migration. |
