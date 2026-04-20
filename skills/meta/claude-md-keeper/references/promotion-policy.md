# Promotion Policy — SESSION.md → CLAUDE.md

When a decision from `.claude/SESSION.md` (or archived sessions) qualifies to become durable project knowledge in `CLAUDE.md`.

Shared reference — `claude-md-keeper` uses it on promote, `session-bridge` uses it to mark candidates.

## The Rule: 2-of-3 Criteria (accumulative)

A session decision becomes a CLAUDE.md candidate ONLY when **2 or 3** of these are true:

### Criterion 1 — Repeated across sessions

Decision appeared in **2+ distinct sessions** without being contradicted. Contradiction = user said "actually, no" or "let's not do that" in a later session.

**How to check:** scan archived sessions in `.claude/sessions/` for the same topic/rule.

### Criterion 2 — Affects multiple files or skills

Decision affects **2+ files or skills** (not local to a single task).

**How to check:** if the session notes reference ≥ 2 files, or the decision is a pattern/convention (not a specific fix).

### Criterion 3 — Formulated as a rule

User stated it as a rule — "siempre X", "nunca Y", "todo Z debe...", "always", "never".

**How to check:** literal phrase match or clear imperative framing.

---

## Decision Table

| C1 (repeated) | C2 (multi-file) | C3 (rule) | Action |
|:-:|:-:|:-:|---|
| ✓ | ✓ | ✓ | **Propose to CLAUDE.md** (strong signal) |
| ✓ | ✓ | ✗ | **Propose to CLAUDE.md** (pattern emerged) |
| ✓ | ✗ | ✓ | **Propose to CLAUDE.md** (validated rule) |
| ✗ | ✓ | ✓ | **Propose to CLAUDE.md** (explicit + broad) |
| ✓ | ✗ | ✗ | Keep in SESSION archive, do not propose |
| ✗ | ✓ | ✗ | Keep in SESSION archive, do not propose |
| ✗ | ✗ | ✓ | Keep in SESSION archive (single mention, may not stick) |
| ✗ | ✗ | ✗ | Discard / do not archive |

---

## Candidate Output Format

```markdown
# Promotion Candidates — Session {date}

## Strong candidates (3-of-3)

### 1. Always validate forms with Zod + RHF
- Repeated: sessions of 2026-04-12, 2026-04-15 (✓)
- Affects: auth forms + checkout form + settings form (✓)
- Rule form: "nunca formularios sin Zod" (✓)
- **Proposed for CLAUDE.md:**
  ```markdown
  ## Forms
  All forms use React Hook Form + Zod. See `forms-and-validation` skill.
  ```

## Moderate candidates (2-of-3)

### 2. ...

## Weak candidates (1-of-3, NOT promoted)

### 3. Debug log kept on for next session
- Repeated: 1 session only
- Only affects 1 file
- Not a rule
- → Kept in SESSION archive only.
```

---

## User Approval Flow

1. Skill presents the candidate list to the user
2. User tildes which ones to promote (checkbox format works)
3. For each approved: skill generates a `CLAUDE.md.proposed` diff
4. User reviews diff + applies manually (or approves explicit apply)

**NEVER auto-promote.** Even 3-of-3 candidates need explicit tilde.

---

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| Promote after 1 mention | Arbitrary, noisy CLAUDE.md | Require 2-of-3 |
| Auto-promote 3-of-3 | User loses agency | Always user-approved |
| Promote session-specific context | CLAUDE.md is long-term | Session archive only |
| Promote half-baked decisions | Will be reverted later | Wait for consolidation |
| Delete SESSION archive after promote | Audit trail lost | Always keep archive |
