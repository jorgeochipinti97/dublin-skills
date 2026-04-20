# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code skills library** — a collection of specialized prompts, reference materials, and code templates that extend Claude Code's capabilities in specific domains. Currently **31 skills** across 13 categories, paired with the user-scope **dublin-agent** (personal senior-architect mentor) and a shared memory layer.

## Structure

```
skills/
├── architecture/
│   ├── api-architect/        # Scalable/reliable/secure API design or audit (REST/GraphQL/gRPC)
│   │   └── references/       # design.md, security.md, scalability.md, reliability.md, observability.md
│   ├── domain-modeler/       # DDD patterns: entities, value objects, aggregates, domain events
│   └── hexagonal-architect/  # Ports & adapters architecture for NestJS
│       └── references/       # implementation-patterns.md
├── content/
│   ├── blog-writer/          # Professional blog posts in English/Spanish (Filler Word Index enforced)
│   ├── institutional-site-architect/  # Multi-page corporate / institutional site blueprints
│   │   └── references/       # information-architecture.md, brand-voice.md, page-anatomy.md, trust-authority.md, org-types.md
│   └── landing-page-architect/  # Conversion-optimized landing page blueprints (copy + structure)
│       └── references/       # copywriting-theory.md, landing-fundamentals.md, conversion-by-goal.md
├── data/
│   ├── data-viz-architect/   # Dashboard + data viz architect — chart selection with WHY, layout, libraries
│   │   └── references/       # chart-selection.md, dashboard-design.md, data-from-api.md, libraries.md
│   └── database-architect/   # Postgres-first schema design, migrations, indexes, N+1, RLS, Prisma/Drizzle/Kysely
│       └── references/       # patterns.md (schemas, migrations, pooling, RLS, queues)
├── discovery/
│   └── systems-thinking/     # System analysis: feedback loops, leverage points, stocks/flows
├── frontend/
│   ├── forms-and-validation/     # Production forms: React Hook Form + Zod, multi-step, async, file upload, a11y, Server Actions
│   │   └── references/           # patterns.md (templates)
│   ├── frontend-foundation/      # Day-0 architecture: dual theme (View Transitions slow-fast-slow), spacing system, headless component system (Base UI/Radix), sidebar pattern
│   │   └── references/           # theming.md, spacing.md, component-system.md
│   ├── premium-frontend-design/  # Apple/Framer-quality UI — 3 dials (VARIANCE/MOTION/DENSITY), AI Tells with names (LILA BAN, Jane Doe Effect, Acme Slop, Filler Word Index, 99.99% Problem)
│   │   └── references/           # effects-library.md, typography-system.md, motion-patterns.md, anti-patterns.md
│   ├── product-tour/             # Interactive product tours & onboarding flows for Next.js
│   │   └── references/           # onboarding-patterns.md, accessibility.md, implementation-examples.md
│   └── react-performance/        # React/Next.js performance: useEffect elimination, RSC, bundle optimization
│       └── references/           # react-patterns.md, nextjs-patterns.md, code-examples.md
├── github/
│   └── github-safety/       # Safe Git workflow: prevents force push, history rewriting, destructive ops
├── implementation/
│   ├── error-handling/       # Error taxonomy, Problem Details (RFC 7807), Error Boundaries, logging, retry/backoff, Sentry
│   │   └── references/       # patterns.md (hierarchy, filter, Pino, boundary, retry, fetch wrapper)
│   ├── tdd-workflow/         # Red-green-refactor cycle, test patterns, AAA structure
│   │   └── references/       # examples.md
│   └── testing-strategy/     # WHAT to test at which layer — pyramid, doubles, integration (testcontainers), E2E (Playwright), contract
│       └── references/       # patterns.md (Vitest, MSW, testcontainers, Playwright, factories, Pact)
├── media/
│   └── remotion-video/       # Programmatic video generation with Remotion + React
├── methodology/
│   └── sdd-workflow/         # Spec-Driven Development — triggers, commands, dep graph, artifact store (engram/openspec/none), sub-agent patterns
│       └── references/       # sub-agent-patterns.md, artifact-policy.md
├── meta/
│   ├── claude-md-keeper/     # CLAUDE.md drift detection + diff-review proposals. NEVER auto-writes. On-demand only.
│   │   └── references/       # drift-detection.md (signal catalog), promotion-policy.md (2-of-3 rule)
│   ├── orchestrator/         # Skill Orchestrator / Router — analyzes installed skills, ranks by opportunity cost, emits plan + task list
│   │   ├── references/       # scoring.md (worked examples, dependency graph, scoring heuristics)
│   │   └── skills.manifest.json  # Machine-readable index of all skills (tags, triggers, deps, cost)
│   └── session-bridge/       # SESSION.md continuity (hard caps 300 lines / 72h, secret scanner, promotion candidates)
│       └── references/       # session-format.md
├── product/
│   ├── product-planner/      # PRDs, user stories (Given/When/Then), MVP scoping
│   └── product-ux-advisor/   # UX audit: diagnoses missing patterns (onboarding, wizards, e-commerce)
│       └── references/       # patterns.md, examples.md, ecommerce.md
├── security/
│   └── auth-architect/       # Authentication + authorization: OAuth, JWT vs sessions, RBAC/ABAC, passkeys, common vulnerabilities
│       └── references/       # patterns.md (Better-Auth, NestJS + JWT rotation, RBAC guard, CASL, password reset, rate limit)
├── bind-api/                 # BIND Argentina Open Banking API integration
│   ├── references/           # Full API documentation
│   └── scripts/              # TypeScript client implementation (bind_client.ts)
├── brand-guidelines/         # Anthropic brand colors, typography, and visual styling
├── brand-identity/           # Brand identity systems: color palettes, typography, spacing, UX principles
├── infra-security/           # Infrastructure architect + cybersecurity specialist
│   └── references/           # aws.md, ai-infra.md, vps.md, security.md, architecture.md, azure.md
└── skill-creator/            # Guide for creating new skills
    └── references/           # design-philosophy.md, creation-process.md, output-patterns.md, workflows.md
```

## Companion Assets (outside `skills/`)

- **`~/.claude/agents/dublin-agent.md`** — user-scope senior-architect mentor agent (invoked via `Task(subagent_type: 'dublin-agent')`). Auto-detects this library and delegates to skills. Successor to the historical `gentleman` agent (backup kept as `gentleman.backup.md`).
- **`~/.claude/agent-memory/shared/preferences.md`** — universal user preferences (voseo, no emojis, bun, philosophy, Dublin conventions). Read by dublin-agent and any future agent.
- **`~/.claude/agent-memory/dublin-agent/`** — agent-specific operational memory.

## Skill File Convention

Each skill has a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: When and how to use this skill
---
```

The `description` field tells Claude when to invoke the skill. Reference files live in `references/` subdirectory and are loaded on demand.

## Key Skills

### Meta — invoke on multi-step tasks

#### orchestrator
Skill Router / Supervisor Agent. Given a task, it:
- Reads `skills.manifest.json` (fast) or falls back to per-SKILL.md scan
- Scores each skill by relevance × value / cost
- Resolves dependencies (e.g. `frontend-foundation` before `premium-frontend-design`)
- Emits a phased execution plan and creates `TaskCreate` entries

Three operating modes:
- **A** — fresh plan from scratch
- **B** — validate a user-provided plan (kept/added/removed/reordered, with rationale)
- **C** — audit mode: map repo gaps to skills

Reference: `scoring.md` (worked examples), `skills.manifest.json` (ground truth).

#### claude-md-keeper
Keeps CLAUDE.md aligned with reality via observable drift signals (package.json, filesystem, git log, skills manifest). **NEVER** writes directly — always emits `CLAUDE.md.proposed` for user review. On-demand only, never hooked. Three-layer memory awareness (CLAUDE.md project / shared preferences / agent memory).

Reference: `drift-detection.md` (signal catalog), `promotion-policy.md` (2-of-3 rule for promoting session decisions).

#### session-bridge
Session-to-session continuity via `SESSION.md`. Hard caps (300 lines / 72h TTL). Secret scanner (regex patterns for API keys, tokens, connection strings). Gitignore enforcement for archives. Marks promotion candidates for `claude-md-keeper`.

Phases:
- **Phase 1** (default): on-demand only
- **Phase 2** (after trust): opt-in `Stop` hook with `--dry-run`
- **Phase 3** (full auto): Stop hook without dry-run

Reference: `session-format.md` (full template, GOOD vs BAD examples).

### Methodology

#### sdd-workflow
Spec-Driven Development — single source of truth. The dublin-agent references this skill instead of carrying SDD logic inline:
- **Triggers**: "sdd init", "sdd new <name>", "sdd ff", "sdd apply", "sdd verify", "sdd archive", or substantial changes (≥ 3 files, architecture)
- **Dependency graph**: proposal → specs + design → tasks → apply → verify → archive
- **Artifact store**: `engram` (recommended, via MCP) / `openspec` (project files, only when user asks) / `none` (conversational)
- **Sub-agent launching templates** with structured output contract
- **Approval gates** by phase (destructive actions always gated)

Reference: `sub-agent-patterns.md` (launch templates), `artifact-policy.md` (engram/openspec/none rules).

### Discovery & Product

#### systems-thinking
System analysis: feedback loops, leverage points, stocks/flows. Use when domain complexity justifies mapping before planning.

#### product-planner
PRDs, user stories (Given/When/Then), MVP scoping.

#### product-ux-advisor
UX consultant that audits products and diagnoses missing patterns:
- Prioritized diagnosis: Critical / Recommended / Polish
- SaaS patterns: onboarding, wizards, empty states, activation checklists, command palette
- E-commerce patterns: PDP (gallery, reviews, variants, notify OOS), PLP, cart, checkout
- Real-world references: Linear, Vercel, Stripe, Notion, Zara, ASOS, Amazon
- Pairs with `premium-frontend-design` for implementation

### Architecture

#### domain-modeler
DDD: Entities (identity matters) vs Value Objects (immutable, defined by attributes), Aggregates (consistency boundaries with a root entity), Domain Events (past tense, immutable records).

#### hexagonal-architect
Structures NestJS projects: Domain → Application → Infrastructure (dependencies point inward). Reference: `implementation-patterns.md` (ports, use cases, adapters, module wiring, tests).

#### api-architect
Scalable/reliable/secure API design and audits (REST/GraphQL/gRPC) with rationale per decision. References: `design.md`, `security.md`, `scalability.md`, `reliability.md`, `observability.md`.

### Data

#### database-architect
Schema, migrations, performance (Postgres-first):
- Postgres default; when to reach for MySQL/SQLite/Mongo/DynamoDB/Redis
- ORM choice: Prisma (DX) vs Drizzle (lighter) vs Kysely (SQL-first)
- Non-negotiables: UUID v7, TIMESTAMPTZ, hard delete default, FK + indexes
- Zero-downtime migrations (3-step rename, NOT VALID + VALIDATE, CONCURRENTLY)
- Indexes: B-tree/GIN/BRIN, partial, covering
- RLS for multi-tenancy, connection pooling (PgBouncer)

#### data-viz-architect
Chart selection WITH the reason, KPI hierarchy, layout, library choice, data fetching strategy. References: `chart-selection.md`, `dashboard-design.md`, `data-from-api.md`, `libraries.md`.

### Security

#### auth-architect
Authentication + authorization for web/mobile:
- Stack decision tree (Better-Auth, Clerk, Supabase Auth, WorkOS, custom NestJS+Passport)
- JWT vs sessions (web = sessions via httpOnly cookies)
- Refresh token rotation (reuse = compromise → revoke all sessions)
- RBAC vs ABAC (CASL), multi-tenancy with RLS
- Audit checklist against common vulns (session fixation, CSRF, IDOR, mass assignment, token in URL)

### Frontend

#### frontend-foundation
Day-0 frontend architecture. Invoke BEFORE `premium-frontend-design` when starting a new product:
- **Dual theme** (dark + light) from day 0 via semantic CSS variables (next-themes + Tailwind v4)
- **Theme toggle** uses View Transitions API with slow-fast-slow ease `cubic-bezier(0.65, 0, 0.35, 1)` (off-main-thread)
- **Spacing system**: one scale, layout primitives own spacing (Stack, Row, Grid, Section, Container), never arbitrary values, `gap` over margin
- **Component system** on headless primitives (Base UI / Radix / React Aria) + branded `ui/` layer with CVA variants
- **Sidebar pattern**: collapsible with icon-rail, pill/oval trigger, `Cmd+B` shortcut
- **Cross-cutting mandates**: dependency verification (grep package.json before import), interactive states (loading/empty/error/active), hardware acceleration (transform/opacity only, `min-h-[100dvh]`)

Reference files: `theming.md` (CSS vars, next-themes, View Transitions, contrast), `spacing.md` (scale, layout primitives code), `component-system.md` (Base UI vs Radix, CVA templates, Sidebar).

#### premium-frontend-design
Creates luxury React/Next.js interfaces with:
- **3 dials** tunable per project: `DESIGN_VARIANCE`, `MOTION_INTENSITY`, `VISUAL_DENSITY` (1-10)
- **AI Tells named** (forbidden patterns with memorable names):
  - THE LILA BAN (no AI purple/blue)
  - Jane Doe Effect (no generic names/avatars)
  - Acme Slop (no generic brand names)
  - 99.99% Problem (no predictable demo numbers)
  - Filler Word Index (no Elevate/Unleash/Seamless/Next-gen)
  - Pure Black Tell (never `#000`)
  - Inter Tell (distinctive sans only)
  - Generic 3-Card Row (use zig-zag / bento / scroll instead)
- Glass morphism with inner border + tinted shadow
- Framer Motion spring physics, magnetic buttons via `useMotionValue` (never `useState`)
- Typography: distinctive font pairings, -0.02em to -0.05em tracking on headlines
- Mandatory interactive states (loading / empty / error / active with `-translate-y-[1px]`)

Reference files in `references/` contain complete CSS/React code for all effects.

#### forms-and-validation
Production forms with React Hook Form + Zod:
- Shared Zod schema client + server
- Error UX: inline, aria-invalid, aria-live, focus first error
- Multi-step wizard with URL state
- Async validation with TanStack Query + debounce
- File upload with progress (XHR, direct-to-S3)
- Server Actions integration
- Full a11y checklist

#### react-performance
Audits and optimizes React/Next.js applications:
- useEffect elimination (derived state, event handlers, key prop reset)
- React Compiler (React 19+) vs manual memoization strategy
- Server Components decision tree, 'use client' boundary placement
- Bundle optimization (dynamic imports, barrel files, tree shaking)
- Data fetching patterns (React.cache, preloading, waterfall avoidance)

Reference files: `react-patterns.md` (rendering, memoization), `nextjs-patterns.md` (RSC, caching, CWV), `code-examples.md` (BAD/GOOD pairs).

#### product-tour
Builds interactive product tours and onboarding flows for Next.js:
- Library selection: Driver.js (recommended, 5KB), NextStep.js (multi-page tours)
- Guided walkthroughs with DOM element highlighting
- Onboarding patterns: activation checklists, welcome modals, progress tracking
- Accessibility: focus management, screen readers, keyboard nav, reduced motion

### Content & GTM

#### blog-writer
Professional blog posts in English/Spanish. **Filler Word Index** enforced: banned hype verbs/adjectives/phrases (Elevate, Unleash, Seamless, Next-gen, etc.). Replacement rule: every forbidden word swapped for concrete verb + specific outcome.

#### landing-page-architect
Conversion-optimized landing page blueprints (copy + structure) — hands off to `product-ux-advisor` + `premium-frontend-design`. Filler Word Index + Data Realism (99.99% Problem, Jane Doe, Acme Slop) enforced in all copy and demo content.

#### institutional-site-architect
Multi-page corporate / institutional site blueprints — sitemap, IA, brand voice, trust strategy, per-page copy direction for B2B SaaS, agencies, law firms, VC, nonprofits, personal brands.

#### brand-identity
Brand identity systems: color palettes, typography, spacing, UX principles.

#### brand-guidelines
Anthropic brand colors, typography, and visual styling.

### Implementation

#### tdd-workflow
Red (failing test) → Green (minimal code) → Refactor. AAA pattern. Test doubles: Stubs / Mocks / Fakes.

#### testing-strategy
Complements `tdd-workflow` with WHAT to test and at which layer:
- Pyramid: ~70% unit / 20% integration / 10% E2E
- What to test by hexagonal layer (domain/app/infra/http/frontend)
- Testcontainers for real Postgres integration tests
- MSW for HTTP mocking, Playwright for E2E, Pact for contract tests
- Flaky test rules (no sleep, fresh state, independent order)

#### error-handling
End-to-end error story:
- Typed error hierarchy (DomainError → ValidationError, NotFoundError, etc.)
- API responses in Problem Details (RFC 7807) with `code` and `correlationId`
- Structured JSON logging (Pino) with correlation + user/tenant IDs
- React Error Boundaries per route + global fallback
- Retry with backoff + jitter, circuit breaker for external deps
- Sentry with sourcemaps, PII stripping

### Infra / Ops

#### infra-security
Senior infrastructure architect + cybersecurity specialist:
- AWS-first (EC2, ECS, Lambda, Bedrock, VPC, IAM, cost optimization)
- AI as a Service patterns: agent platforms, vLLM, vector DBs, Bedrock deep dive
- VPS hardening: nginx, SSL, SSH, Docker, firewall
- Security audits: OWASP, WAF, IAM policies, incident response
- Architecture from scratch: tiered cost/complexity options, HA, DR, anti-patterns

#### github-safety
Prevents destructive Git operations:
- Absolute prohibitions: force push, rebase on pushed branches, reset --hard, amend pushed commits, --no-verify
- Required practices: new commits over rewrites, feature branches, verify before push
- Emergency protocol: STOP → show status → explain → propose → wait for confirmation

### Integration & Media

#### bind-api
Integration with BIND Argentina Open Banking sandbox:
- OAuth 2.0 Direct Login authentication
- Endpoints: accounts, transfers, DEBIN, eCheqs, CBU/CVU validation
- TypeScript client in `scripts/bind_client.ts`

#### remotion-video
Programmatic video generation from React components with Remotion.

### Meta (self-referential)

#### skill-creator
Guide for creating new skills. References: `design-philosophy.md`, `creation-process.md`, `output-patterns.md`, `workflows.md`.

## Working with This Repository

When adding or modifying skills, update ALL of the following (in order):

1. **SKILL.md** — frontmatter (`name`, `description`) + detailed instructions. Keep description sharp — it's what Claude auto-selects on.
2. **Reference files** in `references/` subdirectory — reusable code/templates, loaded on demand.
3. **Anti-patterns** — document what NOT to do (as important as the positive guidance).
4. **Output standards** — specify expected format (complete code, types, specific patterns).
5. **`install.sh`** — add to the `SKILLS` array (alphabetical order).
6. **`skills/meta/orchestrator/skills.manifest.json`** — add entry with tags, triggers, deps, cost, value.
7. **`README.md`** — table row + "Available skills for installation" list + `prompts/` index.
8. **`CLAUDE.md`** (this file) — tree + Key Skills entry. Or run `claude-md-keeper` afterwards to catch drift.
9. **`prompts/<name>.md`** — activation prompts + example use cases.

When using skills in other projects, load the SKILL.md and relevant reference files as context.

## Conventions (Dublin)

- **Foundation-first**: `frontend-foundation` precedes `premium-frontend-design` / `forms-and-validation` / `product-tour` / `landing-page-architect`
- **Data-before-auth**: `database-architect` precedes `auth-architect` (auth needs user/session tables)
- **Domain-before-architecture**: `domain-modeler` precedes `hexagonal-architect` / `api-architect`
- **Polish-last**: `premium-frontend-design` is polish — run after `product-ux-advisor` and `frontend-foundation`
- **Security-pre-ship**: `infra-security` runs before any production deploy
- **SDD for substantial changes**: `sdd-workflow` activates on triggers or when changes touch ≥ 3 files / architecture
