# Drift Detection — Signal Catalog

Observable, diff-able signals only. If a claim isn't measurable, it's opinion.

## Signal Sources (read order)

```
1. package.json          (stack, scripts, versions)
2. Directory structure   (ls -R, fd, or Glob)
3. Git log (last 20)     (convention drift)
4. skills/*/SKILL.md     (if Dublin repo)
5. Config files          (tsconfig, tailwind, drizzle, prisma, ...)
6. .env.example          (env vars)
7. CLAUDE.md             (LAST — to avoid bias)
```

---

## 1. Stack Detection (`package.json`)

### What to extract

```json
{
  "name": "my-app",
  "packageManager": "bun@1.1.0",
  "engines": { "node": ">=20" },
  "scripts": {
    "dev": "next dev",
    "test": "vitest",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^15.0.0",
    "drizzle-orm": "^0.30.0",
    "@base-ui-components/react": "^0.5.0"
  }
}
```

### Signals derived

| Signal | From | Example |
|---|---|---|
| Package manager | `packageManager` field OR lockfile | `bun.lockb` → bun |
| Node version | `engines.node` / `.nvmrc` / `.tool-versions` | `>=20` |
| Runtime framework | `dependencies` top-level | `next`, `remix`, `astro` |
| ORM | `dependencies` | `drizzle-orm`, `@prisma/client`, `typeorm`, `kysely` |
| UI primitives | `dependencies` | `@base-ui-components/react`, `@radix-ui/*`, `react-aria-components` |
| Styling | `dependencies` + config | `tailwindcss`, `styled-components`, `emotion` |
| Testing | `devDependencies` | `vitest`, `jest`, `playwright`, `@testing-library/react` |
| Scripts declared | `scripts` | Commands the user can actually run |

### Drift examples

```diff
// CLAUDE.md says:
- **ORM:** Prisma

// package.json has:
"drizzle-orm": "^0.30.0"
(no @prisma/client)

// Severity: CRITICAL
```

```diff
// CLAUDE.md says:
- Run tests with `pnpm test`

// package.json scripts:
"test": "vitest"
"packageManager": "bun@1.1.0"

// Proposed:
+ Run tests with `bun test`
```

---

## 2. Directory Structure

### Detection

```bash
# Top-level
ls -la

# Deeper (e.g., src or skills)
fd --type d --max-depth 3 . src
```

### Signals derived

| Signal | Source | Example |
|---|---|---|
| Monorepo vs single package | `pnpm-workspace.yaml`, `package.json workspaces`, `apps/` + `packages/` | Monorepo |
| Architecture style | `src/domain/`, `src/application/`, `src/infrastructure/` | Hexagonal |
| Framework structure | `app/`, `pages/`, `src/pages/` | App Router / Pages / Remix |
| Tests location | `__tests__/`, `*.test.ts` co-located, `test/` | Co-located |
| Documentation location | `docs/`, `README.md`, `ADR/` | Has ADRs |

### Drift examples

```diff
// CLAUDE.md says:
- Structure follows `src/domain/ → src/application/ → src/infrastructure/`

// Actual:
src/
├── components/
├── lib/
├── app/

// Severity: CRITICAL — architecture claim is false
```

---

## 3. Git Log Signals (last 20 commits)

### What to extract

```bash
git log -20 --pretty=format:"%h %s" --name-only
```

### Signals derived

| Signal | What to look for | Example |
|---|---|---|
| Convention adherence | Do commits match documented rules? | "Use gap over margin" — do recent commits show `gap-*`? |
| Stack migration in progress | Commits like "migrate X to Y" | Migrating Prisma → Drizzle |
| Deprecation | Commits removing features | "remove old auth" |
| Active areas | Most-touched folders | Tells you what's "hot" |

### When to flag

- If CLAUDE.md claims convention X but **5+ recent commits** contradict it → drift
- If a migration is in progress and CLAUDE.md doesn't mention it → drift (suggest adding a "Migration: Prisma → Drizzle (in progress)" section)

---

## 4. Dublin Skills Signals (if repo has Dublin)

### Detection

```bash
# Has Dublin?
test -f skills.manifest.json || test -f skills/meta/orchestrator/skills.manifest.json
```

### Signals derived

| Signal | Source | Drift |
|---|---|---|
| Skills enumerated in CLAUDE.md | `skills/*/SKILL.md` actually exist? | Missing / extra |
| Dublin conventions followed | e.g., `frontend-foundation` installed but CLAUDE.md doesn't mention dark+light rule | Drift |
| AI Tells section in CLAUDE.md | Matches current `premium-frontend-design` skill content? | Update if skill changed |

---

## 5. Config Files

### Which to read

| File | Reveals |
|---|---|
| `tsconfig.json` | Path aliases, strict mode, target |
| `tailwind.config.ts` / `@theme` in globals.css | Theme tokens, breakpoints |
| `drizzle.config.ts` / `prisma/schema.prisma` | DB schema source |
| `next.config.ts` | App Router flags, experimental features |
| `.eslintrc.json` / `eslint.config.js` | Code style |
| `vitest.config.ts` / `jest.config.js` | Test setup |

### Drift examples

```diff
// CLAUDE.md says:
- Path alias `@/` → `src/`

// tsconfig.json:
"paths": { "@/*": ["./*"] }

// Severity: CRITICAL
```

---

## 6. Environment Variables

### Source

- `.env.example`
- `src/config/env.ts` / `env.mjs`
- `process.env.*` grep across `src/`

### Drift

```diff
// CLAUDE.md says:
- Required env: DATABASE_URL, JWT_SECRET

// Code uses (grep):
- DATABASE_URL ✓
- JWT_SECRET ✓
- STRIPE_SECRET_KEY ← not in CLAUDE.md
- SENTRY_DSN ← not in CLAUDE.md

// Proposed:
+ Required env: DATABASE_URL, JWT_SECRET, STRIPE_SECRET_KEY, SENTRY_DSN
```

---

## 7. Severity Rubric

| Severity | When to assign | Action |
|---|---|---|
| **CRITICAL** | Wrong stack, broken command, wrong path | Propose update, flag at top of report |
| **MODERATE** | Structure evolved, missing env var, drifted convention in 5+ commits | Propose update |
| **MINOR** | Stale example, typo, marginal path change | Propose but mark low priority |
| **OPINION (skip)** | No diff-able signal, vibes, future state | Do NOT propose |

---

## 8. What NOT to detect as drift

Skip silently — these are not drift:

- "Our philosophy is..." / "We believe in..."
- "This project aims to..." (future state)
- Code style that's not enforced by a linter (subjective)
- Team processes ("we do standups")
- Roadmap items
- Historical context / why-decisions (unless code directly contradicts the why)

If you cannot point to a file + line that proves it wrong, it's not drift.

---

## 9. Report Template

```markdown
# CLAUDE.md Drift Report — {date}

**Signals inspected:** package.json, filesystem, git log (20 commits), Dublin skills, configs
**Items analyzed:** N claims
**Drift detected:** M items

---

## CRITICAL ({count})

### 1. {short title}
- **Declared** (CLAUDE.md:{line}): "{quote}"
- **Observed** ({source}:{line}): "{evidence}"
- **Proposed patch:**
  ```diff
  - {old line}
  + {new line}
  ```

## MODERATE ({count})
...

## MINOR ({count})
...

## Skipped (opinion, not drift)
- {count} items — no diff-able signal

---

## How to apply

Option A — overwrite: `mv CLAUDE.md.proposed CLAUDE.md`
Option B — copy sections manually
Option C — explicitly tell me "apply" and I will do the overwrite
```
