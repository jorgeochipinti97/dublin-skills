# SESSION.md — Full Format Reference

Template, examples, and section-by-section guidance.

## Full Template

```markdown
---
session: 2026-04-19
started: 14:30
last-update: 16:45
status: in-progress | paused | ready-to-archive
project: my-project-name
---

# Session — {brief topic, 3-8 words}

## Current task

<!-- 1-3 lines. What are you working on RIGHT NOW? -->
Refactoring checkout form to use React Hook Form + Zod.

## Files touched (this session)

<!-- Max 15 entries. Include 1-line what-changed. -->
- `src/components/checkout/CheckoutForm.tsx` — added RHF, Zod schema
- `src/schemas/checkout.ts` — new file, shared schema
- `src/app/api/checkout/route.ts` — now parses with zodSchema.safeParse

## Decisions made this session

<!--
Each decision is a short statement + rationale.
Mark promotion candidacy: count how many of 2-of-3 criteria match.
-->

- **Decision:** All forms will use RHF + Zod. No exceptions.
  - **Rationale:** Type safety, single schema client+server, better a11y via `aria-invalid`.
  - **Promotion:** 3/3 (repeated across 3 sessions, affects 4 files, stated as "todo form debe usar RHF+Zod")

- **Decision:** Checkout success redirects to `/dashboard/orders/:id`.
  - **Rationale:** Consistent with other post-action patterns.
  - **Promotion:** 1/3 (single session, single file, not rule-framed) — keep in archive only

## In progress / interrupted

<!-- What's half-done? Where did I stop? -->
- `CheckoutForm.tsx` — `onSubmit` handler refactored, but error mapping from server → RHF `setError` not done yet
- Tests: unit tests added for schema, component tests not updated

## Next steps (when I retoma)

1. Wire server errors back to RHF via `setError` in `CheckoutForm.tsx:89`
2. Update component tests in `CheckoutForm.test.tsx` to mock zodResolver
3. Run `bun test` to confirm green
4. Commit as one atomic commit

## Questions / blockers

- **Open:** Should we debounce async email validation? (decision postponed to next session)
- **Blocked:** Waiting on Stripe webhook secret from DevOps

## Scratch

<!-- Free-form, ephemeral, not promoted -->

- TODO: remember to check `next-themes` docs for SSR hydration edge case
- IDEA: shared schema factory for paginated lists — tabled for now

---

<!-- If this file exceeds 300 lines, the skill will archive it and start fresh. -->
```

---

## Section-by-Section Guidance

### Frontmatter

**Required:**
- `session`: ISO date of start
- `started`: HH:MM when session began
- `last-update`: HH:MM on last write
- `status`: `in-progress` / `paused` / `ready-to-archive`

**Optional:**
- `project`: repo or project name (useful when grepping across archives)

### Current task

One focused topic. If you're juggling 3 unrelated things, either:
- Pick the primary one
- Or split into multiple sessions (the human can only context-switch so fast)

**GOOD:** "Refactoring checkout form to use React Hook Form + Zod"
**BAD:** "Working on stuff" (useless for future you)
**BAD:** "Checkout form, auth improvements, dashboard redesign, docs" (too wide)

### Files touched

**Rules:**
- 1 line per file: `path — what changed`
- Max 15 entries. If exceeded, archive and start new session.
- Don't list files you only read — only files you modified.

**GOOD:** `src/app/api/checkout/route.ts — now parses with zodSchema.safeParse`
**BAD:** `src/app/api/checkout/route.ts — changes` (no info)

### Decisions made

**Every entry needs:**
- What was decided (1 line)
- Why (1 line)
- Promotion candidacy (X/3)

**Not a decision:**
- Execution details ("I used a for loop")
- Context that isn't a choice
- Questions (those go to Questions/blockers)

### In progress / interrupted

This is the most valuable section for future-you. Specific, actionable.

**GOOD:**
- `CheckoutForm.tsx:89` — refactored submit, need to wire server errors to RHF setError
- Tests: unit added (schema), component pending

**BAD:**
- "halfway through stuff"
- "need to finish checkout"

Include file + line numbers where applicable.

### Next steps

Ordered list. Each is one concrete action. If a step is "think about X" or "decide Y", put it in Questions/blockers instead.

### Questions / blockers

Two types:
- **Open questions:** decisions you didn't make yet
- **Blockers:** external dependencies (waiting on X)

Mark explicitly which is which.

### Scratch

Free-form. Ephemeral. **Never** promoted. For notes you want close at hand but don't deserve structured treatment.

When archiving, the scratch section is often just deleted or heavily trimmed.

---

## Examples — GOOD vs BAD sessions

### GOOD session entry

```markdown
## Current task
Migrating users table from bigint to UUID v7 primary keys.

## Files touched
- `drizzle/migrations/0042_uuid_migration.sql` — new migration, 3-step dual-write
- `src/db/schema.ts` — added uuid column (nullable for now)
- `src/domain/user/User.ts` — accept both id types during migration window

## Decisions made this session
- **Decision:** Use UUID v7 (time-ordered) for all new tables; migrate existing critical tables.
  - **Rationale:** B-tree locality + collision-free across services.
  - **Promotion:** 2/3 (repeated from 2026-04-12 session, multi-file, not rule-framed yet)

## In progress
- Migration running in staging, waiting 24h before production
- Need to update `UserRepository.findById` to handle both id types

## Next steps
1. Monitor staging for 24h (check query performance metrics)
2. Update `UserRepository.findById` to accept `string | bigint` during migration
3. Update API serializer to return string UUID to clients
```

### BAD session entry (why it's bad)

```markdown
## Current task
Fixing stuff in checkout.

## Files touched
- some files
- the checkout component

## Decisions
- Decided to use a library.

## Next
- more work
```

**Problems:**
- "Fixing stuff" — no topic to retake
- "Some files" — useless
- "Use a library" — which one, why, for what
- "More work" — no actionable step

---

## Archive Flow

When SESSION.md hits a limit (300 lines or 72h):

1. **Rename** SESSION.md → `.context/sessions/YYYY-MM-DD-HH-MM.md`
2. **Preserve** frontmatter + all sections as-is
3. **Start fresh** SESSION.md with:
   ```markdown
   ---
   session: {new date}
   started: {now}
   last-update: {now}
   status: in-progress
   ---
   
   # Session — {topic}
   
   <!-- Previous session archived: .context/sessions/2026-04-18-22-15.md -->
   
   ## Current task
   Continuing from yesterday: {1-2 line carry-over}
   
   ## Next steps (from archive)
   1. {copy forward the active next steps}
   ```

4. **Archive retention:** keep all for now. Suggest consolidation to `.context/sessions/archive-YYYY/` when archive folder exceeds 100 files.

---

## Integration with claude-md-keeper

When writing a decision with promotion candidacy ≥ 2/3:

1. Mark it in SESSION.md (`Promotion: 2/3`)
2. At end of write, tell user: "{N} candidates pending review. Invoke `claude-md-keeper promote` to review."
3. `claude-md-keeper` reads all recent sessions (current + archives) and deduplicates candidates by topic.

**Never write to CLAUDE.md from this skill.** Always defer.
