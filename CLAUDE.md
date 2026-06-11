# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code skills library** — a collection of specialized prompts, reference materials, and code templates that extend Claude Code's capabilities in specific domains. Currently **40 skills** across 16 categories, paired with the user-scope **dublin-agent** (personal senior-architect mentor) and a shared memory layer.

## Structure

```
agents/
└── dublin-agent.md           # Senior-architect mentor agent (installed to ~/.claude/agents/ via install.sh agent)
env/                          # Team environment installed by `./install.sh install` (on top of skills + agent)
├── rules/TEAM-RULES.md       # Team working rules → CLAUDE.md (Claude) / AGENTS.md (others), merged between markers
├── OPERATING-MODEL.md        # Human onboarding doc (roles + flow) → <project>/OPERATING-MODEL.md
├── CHEATSHEET.md             # Bilingual ES/EN usage cheatsheet (triggers, big-vs-small) → <project>/CHEATSHEET.md
├── templates/                # Scaffold templates for `install.sh new` (SESSION.md, TASKS.md, gitignore)
├── memory/                   # Pre-seeded shared team memories → <project>/.claude/team-memory/
├── hooks/settings.json       # Hook wiring → <project>/.claude/settings.json (merged with jq)
├── hooks/change-safety-guard.sh  # Bash PreToolUse guard — blocks DROP/TRUNCATE/UPDATE-no-WHERE/force-push (no LLM tokens)
└── mcp/mcp.json             # engram persistent-memory MCP server → <project>/.mcp.json (merged)
skills/
├── architecture/
│   ├── api-architect/        # Scalable/reliable/secure API design or audit (REST/GraphQL/gRPC)
│   │   └── references/       # design.md, security.md, scalability.md, reliability.md, observability.md
│   ├── domain-modeler/       # DDD patterns: entities, value objects, aggregates, domain events
│   └── hexagonal-architect/  # Ports & adapters architecture for NestJS
│       └── references/       # implementation-patterns.md
├── backend/
│   └── backend-performance/  # Backend performance audit — N+1, async/event loop, caching, observability
│       └── references/       # queries.md, async-and-io.md, caching.md, observability.md
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
│   ├── frontend-foundation/      # Day-0: 6 Pillars — dual theme (View Transitions slow-fast-slow), spacing, headless component system (Base UI/Radix), Mobile-First with content priority, CLS Zero, Icon Budget. Plus DESIGN.md contract per project (extends Google Labs DESIGN.md format)
│   │   └── references/           # theming.md, spacing.md, component-system.md, mobile-first.md, cls-zero.md, icon-budget.md, design-contract.md
│   ├── premium-frontend-design/  # Apple/Framer-quality UI — 3 dials (VARIANCE/MOTION/DENSITY), AI Tells with names (LILA BAN, Jane Doe Effect, Acme Slop, Filler Word Index, 99.99% Problem, Icon Soup, Mobile Afterthought, Layout Shift Sloppy)
│   │   └── references/           # effects-library.md, typography-system.md, motion-patterns.md, anti-patterns.md
│   ├── frontend-output-validator/ # Review gate AFTER frontend implementation. Layer 1 static (rg patterns) + Layer 2 Lighthouse. Checks contrast, CLS, icon budget, touch targets, mobile-first, viewport, AI Tells, DESIGN.md drift
│   │   ├── references/           # check-catalog.md (every check), grep-patterns.md (rg/AST patterns), lighthouse-integration.md
│   │   └── scripts/              # validate-frontend.ts (Layer 1 implementation)
│   ├── mobile-design/            # Mobile as a first-class surface — Shrunk Desktop AI Tell, overflow killers, mobile-native patterns (bottom sheet, FAB, swipe, sticky CTA, segmented control), thumb zones, touch targets, fluid type, mobile form config
│   │   └── references/           # overflow-killers.md, mobile-patterns.md, touch-and-type.md
│   ├── product-tour/             # Interactive product tours & onboarding flows for Next.js
│   │   └── references/           # onboarding-patterns.md, accessibility.md, implementation-examples.md
│   └── react-performance/        # React/Next.js performance: useEffect elimination, RSC, bundle optimization
│       └── references/           # react-patterns.md, nextjs-patterns.md, code-examples.md
├── github/
│   ├── github-safety/       # Safe Git workflow: prevents force push, history rewriting, destructive ops
│   └── git-workflow/        # Team Git workflow (constructive) — Conventional Commits, PR conventions, branch strategy, conflict/rebase, husky hooks, CODEOWNERS, branch protection. 4 AI Tells: Garbage Commit, Frankenstein PR, Eternal Branch, History Bomb
│       └── references/      # branch-strategy.md, commit-conventions.md, pr-conventions.md, conflict-and-rebase.md, team-templates.md
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
├── ops/
│   └── change-safety/        # Pre-flight guardrail before any prod write — snapshot, rollback, comms, in-flight check, change window
│       └── references/       # checklist.md, rollback-playbook.md, postmortem-template.md
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
├── ugc/
│   ├── ugc-scriptwriter/     # UGC video scripts for AI avatar delivery — 10 ad angles, hook engineering, per-platform pacing, ES/EN
│   │   └── references/       # angles.md (10 angle skeletons + selection heuristics)
│   ├── ai-avatar-director/   # Vendor-agnostic director brief — casting, wardrobe, setting, framing, voice — for HeyGen/Hedra/Akool/Arcads/Synthesia
│   ├── ugc-video-prompting/  # Text-to-video / image-to-video prompts for Veo 3 and Seedance 2.0 — UGC realism tells, negative-prompt boilerplate, character consistency pack
│   └── ugc-post-production/  # Edit Decision List: captions, visual hooks, B-roll, music, SFX — every effect earns its place
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

## Team Environment (`env/` + `./install.sh install`)

This repo is the **model/source**, not where the team works: they clone it and install the environment **into their own working repos** (`SESSION.md`/`TASKS.md` live in those projects, not here). Two entry points:
- **`./install.sh new <path>`** — scaffold a fresh project: `git init` + `SESSION.md` + `TASKS.md` + `.gitignore` + `OPERATING-MODEL.md` (from `env/templates/`, with `__PROJECT__`/`__DATE__` filled), then the full environment.
- **`./install.sh install [<path>]`** — layer the environment onto an existing project.

`./install.sh install` installs a complete, ready-to-use AI agent environment for the whole team in **two commands** (`git clone … && cd dublin-skills && ./install.sh install`). It asks tool + scope, then installs, in order:

1. **All 40 skills** (reuses `install_all`)
2. **dublin-agent** (claude/opencode; both for `universal`)
3. **Team rules** — `env/rules/TEAM-RULES.md` → `CLAUDE.md` (Claude) or `AGENTS.md` (OpenCode/Codex/Universal). Eight sections: (1) hard rules, (2) frontend conventions, (3) forbidden AI Tells, (4) process, (5) technical defaults, (6) agent operating discipline (work routing / delegation contract / TDD evidence / model routing — adopted from gentle-ai, no infra), (7) project tracking (file-based `SESSION.md` status + `TASKS.md` shared backlog with Client-pains/Backlog/Doing/Done/Future buckets + `TASKS.<you>.local.md` private gitignored, plus mandatory context upkeep — tick task + update SESSION.md + save decision to engram at the end of every unit of work), (8) roles & operating model (Tech Lead = the agent, Approver = owner, Dev = team incl. non-technical; one flow; agent prioritizes/builds order when none exists). Companion: `env/OPERATING-MODEL.md` (human onboarding doc) → installed to project root. Merged between `<!-- DUBLIN-TEAM-RULES:START/END -->` markers so hand edits outside the block survive. Idempotent; `--force` refreshes the block.
4. **Shared memory** — `env/memory/*` → `<project>/.claude/team-memory/` (5 pre-seeded team facts: zero-hallucinations, finish-now, change-safety, foundation-first-frontend, forbidden-ai-tells)
5. **Hooks** — `change-safety-guard.sh` (Bash `PreToolUse`, blocks `DROP`/`TRUNCATE`/`UPDATE`-without-`WHERE`/force-push/`reset --hard`/`--no-verify` with exit 2, zero LLM tokens) + `settings.json` merged into the project's settings with `jq`. Claude Code only — skipped with a notice for other tools.
6. **engram (persistent memory)** — wires [engram](https://github.com/Gentleman-Programming/engram) as an MCP server by writing/merging `<project>/.mcp.json` (`{"command":"engram","args":["mcp"]}`). engram is a standalone Go binary (SQLite, 19 MCP tools: `mem_save`, `mem_search`, `mem_session_start`…) giving the agent real cross-session memory. The config is written automatically; the **binary is per-machine** — the installer detects it and prints `brew install gentleman-programming/tap/engram` rather than installing silently. Adopted from the Gentleman ecosystem (the one genuinely-missing piece vs. static `team-memory/`); the rest of gentle-ai/gentle-pi is intentionally NOT adopted (Claude Code is the team runtime, never Pi).

**Re-running `install` is a safe upgrade**, not a clobber: rules refresh only when the managed block actually changed (diff-checked — no backup noise; `--force` overrides), every touched file is backed up first, `settings.json`/`.mcp.json` merge, skills dropped from the model are pruned to `<skills>/.dublin-orphans/`, and `SESSION.md`/`TASKS.md` are never overwritten. Each install stamps `<project>/.dublin-env` with the model's git short SHA; **`./install.sh doctor <path>`** reads it and reports up-to-date vs outdated (scans subfolders when given a projects directory).

Safety: every existing file is backed up (`*.bak.<timestamp>`) before being touched. The team rules are **new team-scope rules**, deliberately separate from any individual's personal preferences (which stay in user-scope config). To change them: edit `env/rules/TEAM-RULES.md`, commit, and have the team re-run `./install.sh install --force`. Reference: `env/README.md`.

## Companion Assets (outside `skills/`)

- **`agents/dublin-agent.md`** (in this repo) — versioned source of the senior-architect mentor agent. Installed to `~/.claude/agents/dublin-agent.md` via `./install.sh agent` (creates a timestamped backup if a previous version exists). Invoked via `Task(subagent_type: 'dublin-agent')`. Auto-detects this library and delegates to skills. Successor to the historical `gentleman` agent.
- **`~/.claude/agent-memory/shared/preferences.md`** — universal user preferences (voseo, no emojis, bun, philosophy, Dublin conventions). Read by dublin-agent and any future agent. Stays user-scope, not in this repo.
- **`~/.claude/agent-memory/dublin-agent/`** — agent-specific operational memory. Stays user-scope.

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
Day-0 frontend architecture. **6 Pillars** — invoke BEFORE `premium-frontend-design` when starting a new product:
- **Pillar 1 — Dual theme** (dark + light) from day 0 via semantic CSS variables (next-themes + Tailwind v4). Theme toggle uses View Transitions API with slow-fast-slow ease `cubic-bezier(0.65, 0, 0.35, 1)` (off-main-thread)
- **Pillar 2 — Spacing system**: one scale, layout primitives own spacing (Stack, Row, Grid, Section, Container), never arbitrary values, `gap` over margin
- **Pillar 3 — Component system** on headless primitives (Base UI / Radix / React Aria) + branded `ui/` layer with CVA variants. Sidebar collapsible with icon-rail
- **Pillar 4 — Mobile-First with Content Priority**: design starts at 360px. Content priority worksheet (critical / primary / secondary / tertiary) BEFORE any layout. Touch targets ≥ 44×44 CSS px. `100dvh` not `100vh`. Mobile pattern swaps (sidebar → bottom tab, dropdown → bottom sheet, modal → full-screen sheet)
- **Pillar 5 — CLS Zero**: target < 0.05. Every image has `width`+`height` or `aspect-ratio`. Iframes wrapped in aspect-ratio container. Web fonts use `font-display: swap` + size-adjust fallback + preload. Banners overlay (`fixed`), never inline. Accordions use `grid-template-rows: 0fr → 1fr`. Skeletons match real content dimensions
- **Pillar 6 — Icon Budget**: nav ≤ 5, hero ≤ 1, card ≤ 2, button ≤ 1, form field ≤ 1, footer social ≤ 3. One library per project. `currentColor` for inheritance. Decorative `aria-hidden`, functional `aria-label`. Icon Soup forbidden
- **Cross-cutting mandates**: dependency verification (grep package.json before import), interactive states (loading/empty/error/active), hardware acceleration (transform/opacity only)
- **Design Contract per project**: `DESIGN.md` at repo root combining YAML tokens (breakpoints, colors, typography, spacing, motion, iconBudget, contentPriority, aiTellsEnforced) with markdown rationale. Format borrows from [Google Labs DESIGN.md](https://github.com/google-labs-code/design.md) and extends with Dublin specifics

Reference files: `theming.md`, `spacing.md`, `component-system.md`, `mobile-first.md` (content priority worksheet, mobile pattern swaps, touch targets, safe-area, container queries, `clamp()`), `cls-zero.md` (BAD/GOOD pairs for every CLS source), `icon-budget.md` (per-region budgets, Icon Soup examples), `design-contract.md` (DESIGN.md template + CI lint script).

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
  - **Icon Soup** (icons everywhere, no budget — enforce `frontend-foundation` Pillar 6)
  - **Mobile Afterthought** ("responsive later" → mobile becomes shrunk-desktop. Use mobile-first content priority)
  - **Layout Shift Sloppy** (CLS > 0.05 — premium products do not jump on load)
- Glass morphism with inner border + tinted shadow
- Framer Motion spring physics, magnetic buttons via `useMotionValue` (never `useState`)
- Typography: distinctive font pairings, -0.02em to -0.05em tracking on headlines
- Mandatory interactive states (loading / empty / error / active with `-translate-y-[1px]`)

Reference files in `references/` contain complete CSS/React code for all effects.

#### mobile-design
Mobile as a first-class surface, not a desktop scaled down. Pairs with `frontend-foundation` (Pillar 4 owns the baseline) — this skill owns mobile-as-its-own-medium and the killer of horizontal overflow. Run AFTER `frontend-foundation`, BEFORE `premium-frontend-design` polish.

- **New AI Tell — Shrunk Desktop**: mobile UI is the desktop UI compressed into 360px (sidebar squeezed onto a 360px strip, modal centered at 90%, hover dropdowns, top-right CTAs). Sibling to `Mobile Afterthought` from premium-frontend-design.
- **Overflow killers** — every cause of "se sale de pantalla" with BAD/GOOD pairs: `width: 100vw` (Vee-Vee-Dub Trap), `min-width` on grid children, long unbroken text without `overflow-wrap: anywhere`, images without `max-width: 100%`, tables without scroll wrapper, `<pre>` without `overflow-x: auto`, padding sum > viewport, headlines without `clamp()`, too many columns at 360px. Includes runtime detection snippet and the `* { outline }` debug recipe.
- **Mobile-native patterns** — bottom tab bar, bottom sheet (Vaul), FAB, swipe actions, pull-to-refresh, sticky bottom CTA, segmented control, full-screen modal sheet, hamburger as anti-pattern. Each with when YES / when NO / minimal snippet.
- **Touch & type** — Hoo's Map thumb zones (natural / stretch / hard), 44×44 touch targets with hit slop, fluid type with `clamp()`, line-height 1.5-1.6 mobile body, mobile form config (`inputMode` + `autoComplete` + `font-size: 16px`), safe area insets, image strategy (`<picture>`, `srcset`, AVIF→WebP→JPG).
- **5 non-negotiable mandates**: design starts at 360px / touch ≥ 44×44 with ≥ 8px spacing / zero horizontal overflow / `100dvh` not `100vh` / safe area on every fixed bottom element.

Reference files: `overflow-killers.md`, `mobile-patterns.md`, `touch-and-type.md`.

#### forms-and-validation
Production forms with React Hook Form + Zod:
- Shared Zod schema client + server
- Error UX: inline, aria-invalid, aria-live, focus first error
- Multi-step wizard with URL state
- Async validation with TanStack Query + debounce
- File upload with progress (XHR, direct-to-S3)
- Server Actions integration
- Full a11y checklist

#### frontend-output-validator
Non-destructive review gate that runs AFTER any frontend implementation skill. Pairs with `react-performance` (perf audit) — this audits **design contract compliance**:
- **Layer 1 — static checks** (rg / AST grep): forbidden tokens (Pure Black Tell, raw hex in components), LILA BAN gradient detection, gradient text on headlines, mixed icon libraries, `100vh` instead of `100dvh`, `<img>` without dimensions, `transition-all` / `transition-[height]`, `addEventListener('scroll')`, viewport meta validation, body text size on inputs (iOS auto-zoom), safe-area on fixed bottom bars, hover-only interactions, Filler Word Index (Elevate / Unleash / Seamless / Next-gen / Revolutionize / etc.), Jane Doe Effect (John Doe / Sarah Chan / Acme / Nexus / Lorem ipsum), Unsplash link rot, 99.99% Problem
- **Layer 2 — Lighthouse CI**: actual CLS measurement (target < 0.05), LCP, computed contrast (light + dark), `tap-targets` audit, `viewport`, `image-aspect-ratio`, `font-display`. Run mobile (360×800) + desktop separately
- **Layer 3 — Visual regression** (optional, expensive): Playwright screenshots at 360 / 768 / 1280 viewports
- **DESIGN.md compliance**: file exists, YAML parses, required keys present (breakpoints, iconBudget, cls.target, aiTellsEnforced), token drift detection (DESIGN.md vs Tailwind config / CSS vars)
- **Output contract**: pass/fail report with `file:line` references, severity (🔴 fail / 🟡 warn / 🟢 info), grouped by rule. > 5 warnings → suggest `claude-md-keeper` review for systemic drift

Auto-invoke after `frontend-foundation`, `premium-frontend-design`, `forms-and-validation`, `product-tour`, `landing-page-architect`. Conditional: new components/layouts, new images/videos/iframes/fonts/icons, > 1 component touched, hover/focus/active states modified. Skip on copy-only or type-only changes.

Reference files: `check-catalog.md` (every check + example failure), `grep-patterns.md` (exact rg/AST patterns for static checks), `lighthouse-integration.md` (lhci config, GitHub Actions, mobile vs desktop runs). Script: `scripts/validate-frontend.ts` (Layer 1 starting implementation).

#### react-performance
Audits and optimizes React/Next.js applications:
- useEffect elimination (derived state, event handlers, key prop reset)
- React Compiler (React 19+) vs manual memoization strategy
- Server Components decision tree, 'use client' boundary placement
- Bundle optimization (dynamic imports, barrel files, tree shaking)
- Data fetching patterns (React.cache, preloading, waterfall avoidance)

Reference files: `react-patterns.md` (rendering, memoization), `nextjs-patterns.md` (RSC, caching, CWV), `code-examples.md` (BAD/GOOD pairs).

### Backend

#### backend-performance
Non-destructive review gate after backend implementation skills. Audits Node.js/TypeScript APIs for:
- **Queries** — N+1, missing indexes, SELECT *, OFFSET on large tables, long transactions, ORM gotchas (Prisma/Drizzle/Kysely)
- **Async & I/O** — blocking event loop, sync crypto, large JSON, worker threads, sequential vs parallel awaits, `p-limit` for fan-out, timeouts, streaming
- **Caching** — HTTP headers + CDN, Redis read-through, stampede protection (single-flight), SWR, keyspace discipline, hit-rate metrics
- **Connection pooling** — pool sizing, PgBouncer modes, serverless gotchas
- **Payload shape** — DTOs vs full entities, compression, NDJSON streaming, Fastify schema-based serialization
- **Rate limiting & backpressure** — per-user/per-IP limits, circuit breakers, queue depth alarms
- **Observability** — OpenTelemetry auto-instrumentation, Pino with correlation IDs, Prom metrics (RED + USE), event loop lag, SLOs + error budgets

Auto-invoke after `api-architect`, `hexagonal-architect`, `database-architect`, `auth-architect`. Delegates to `database-architect` for schema/index design and to `error-handling` for error taxonomy/resilience.

Reference files: `queries.md`, `async-and-io.md`, `caching.md`, `observability.md`.

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

### UGC Pipeline

End-to-end AI UGC creation. Two rendering branches share `ugc-scriptwriter` and `ugc-post-production`:

- **Lipsync branch** (talking head): `ugc-scriptwriter` → `ai-avatar-director` → `ugc-post-production`. For HeyGen / Hedra / Akool / Arcads / Synthesia.
- **Generative branch** (Veo 3 / Seedance 2.0): `ugc-scriptwriter` → `ugc-video-prompting` → `ugc-post-production`. For scene-based UGC, B-roll, POV, demo shots.

The two branches can be combined in one campaign (e.g. lipsync for the talking-head testimonial + generative for B-roll product shots).

Shared vocabulary (Filler Word Index, Jane Doe Effect, Pure Black Tell, Data Realism) consistent with the rest of the ecosystem.

#### ugc-scriptwriter
Writes shoot-ready UGC scripts for AI avatar delivery:
- **10 ad angles** with fixed skeletons: testimonial, problem-solution, founder, reaction, demo, before-after, comparison, myth-bust, POV, list
- **Hook engineering** — 7 formulas (specific result, contrarian, callout, curiosity gap, direct address, visual anomaly, pattern interrupt) + 5 anti-patterns
- **Per-platform pacing** — TikTok / Reels / Shorts / Meta Feed / YouTube Pre-roll with hook windows, caption density, CTA style
- **Per-region language** — ES (AR / MX / ES / LATAM neutro) / EN (US / UK)
- **Multi-variant mode** — same angle different hooks (A/B/C) or different angles for split-test
- **Output**: timing table (time / spoken line / on-screen text / B-roll) + direction notes + claims used with `⚠️ PLACEHOLDER` flags
- **Filler Word Index** enforced (ES + EN), Data Realism (messy numbers, no Jane Doe, no Acme Slop)

Reference: `angles.md` (10 angle skeletons + selection heuristics, loaded only when in use).

#### ai-avatar-director
Translates a script into a vendor-agnostic director brief:
- **Casting framework** — demographic match × angle archetype × product-category credibility (skincare vs SaaS vs fintech vs luxury etc.)
- **Wardrobe** by brand voice (premium / friendly / expert / irreverent / clinical / street) × angle overrides, with anti-patterns (busy patterns, logos, Pure Black Tell, stark white)
- **Setting / background** — home / home office / neutral studio / bedroom / outdoor / office / gym matched to angle, with depth-of-field rules
- **Framing & movement** — shot size per beat (hook MCU, body alternate, CTA push-in), locked vs handheld feel
- **Voice direction** — tone × cadence × energy (1-10) per angle, accent by region (ES-AR voseo mandatory, not neutral)
- **Anti-patterns named**: Jane Doe Effect, Uncanny Valley Triad, Inter Tell of Avatars, Demographic Cosplay, Same-Face Syndrome
- **Vendor notes** for HeyGen / Hedra / Akool / Arcads / Synthesia, plus a copy-paste vendor-agnostic prompt block
- **Output**: director brief (casting / wardrobe / setting / framing / voice / do-not) + vendor-agnostic prompt

#### ugc-video-prompting
Writes text-to-video and image-to-video prompts for **Google Veo 3 / Veo 3.1** and **ByteDance Seedance 2.0** that produce UGC (not cinema):
- **7-slot anatomy** — Subject / Context / Action / Camera / Lighting / Style / Audio, adapted per model
- **UGC realism "tells"** — selfie framing, handheld sway, natural light, realistic skin, phone audio feel
- **UGC anti-tells** — cinematic lighting, 4K, dolly, drone, Dutch angle, perfect skin, cinematic bokeh (all banned for UGC)
- **Veo 3 specifics** — 5-part formula [Cinematography + Subject + Action + Context + Style], camera in its own sentence, film grammar it understands, dialogue in quotes for sync audio
- **Seedance 2.0 specifics** — motion-first when I2V (model sees the reference, don't re-describe), multi-asset (talent + product + env), mandatory negative-prompt boilerplate (no logos / no extra fingers / no jump cuts / no whip pans / character consistency / realistic physics)
- **Angle → prompt matrix** — per ad angle: camera / framing / action template
- **Character & object consistency pack** — master reference + locked seed + canonical 1-sentence fragment for multi-shot campaigns
- **Output**: structured prompt + negative prompt + seed/consistency plan + audio lines + validation checklist

Alternative to `ai-avatar-director` when the pipeline uses generative video; complementary when used for B-roll alongside a lipsync talking head.

#### ugc-post-production
Edit Decision List (EDL) for the final cut — every FX has a stated reason or it gets cut:
- **Captions** — style per brand voice (karaoke / phrase / sentence bottom), font/weight/color, timing schemes, placement safe zones (avoid bottom-left/right UI bands)
- **Visual hooks library** with when-to-use / when-NOT-to-use: zoom punch, jump cut, shake, whip pan, flash frame, speed ramp, freeze frame + text, B-roll intercut, PiP
- **B-roll strategy** — A/B-roll ratio per angle, timing rules (never cut during critical spoken words, min 0.8s hold, max 4s cutaway)
- **Music & sound design** — genre × brand voice, BPM range, drop alignment to hook/CTA, ducking -12dB under speech, silence-before-CTA pattern
- **Export specs** — aspect ratio, resolution, codec (H.264 10-12 Mbps), audio (-16 LUFS Meta/TikTok, -14 LUFS YouTube), file naming
- **Anti-patterns named**: edit-dumping, caption wall (>7 words), music drowning dialogue, B-roll during critical words, Inter Tell captions, Pure Black Tell, default library SFX at full volume
- **Output**: EDL table (time / beat / cut / FX / caption / B-roll / SFX / music / WHY) + caption plan + music plan + B-roll list + sound design + export specs + missing assets

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

#### git-workflow
Constructive counterpart of `github-safety` — how a team works WELL in git, with enforcement that runs LOCAL via hooks (zero LLM tokens at runtime). Use for team setup, onboarding, conflict help, audits.

- **4 named AI Tells**: Garbage Commit (`fix`/`wip`/`asdf`), Frankenstein PR (> 1000 LOC, mixed concerns), Eternal Branch (> 7 days), History Bomb (force push to shared branches)
- **Non-negotiables**: nobody pushes to `main`, PR ≤ 400 LOC, Conventional Commits enforced by `commit-msg` hook, branches live ≤ 7 days, `--no-verify` BANNED, squash by default
- **Output (lands in user's repo, not this one)**: `CONTRIBUTING.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `.husky/` (pre-commit + commit-msg + pre-push), `commitlint.config.js`, `.gitmessage`, `CODEOWNERS`, branch protection script via `gh api`, minimal `ci.yml`
- **Decision tree per repo state**: new repo with team / new repo solista / repo viejo sin convención (no rewrites history) / repo con convención propia (audit only) / onboarding only

Reference files: `branch-strategy.md`, `commit-conventions.md`, `pr-conventions.md`, `conflict-and-rebase.md`, `team-templates.md` (all copy-paste-ready).

Pairs with `github-safety` (defensive), `change-safety` (when PR touches prod), `testing-strategy` (`pre-push` hook content).

#### change-safety
Pre-flight guardrail before any production write. Auto-invokes on signals: `ALTER`, `DROP`, `TRUNCATE`, `RENAME`, `UPDATE`/`DELETE` without `WHERE`, mass batches, deploy to prod, store/CMS catalog or pricing or inventory edit, env/secret rotation, DNS change, TLS swap, IAM/security group change, infra parameter change.

Forces seven-step protocol before execution:
1. One-sentence change description (verb + object + system + window)
2. Snapshot/backup taken AND tested by restoring to scratch
3. Rollback plan written (trigger + procedure + RTO) — copy-paste runbook ready
4. Stakeholder communication (customer T-24h banner + internal + on-call)
5. In-flight transaction check (`pg_stat_activity`, queue depth, replication lag, active checkouts)
6. Change window declared (off-peak by audience timezone, hard deadline)
7. Approval gate (second human for medium+ changes, pair-execute for destructive)

Decision trees by change type: DB schema (3-step rename, lock_timeout, NOT VALID + VALIDATE), DB data (SELECT first, transaction with explicit limit, COPY before DELETE), Store/CMS (export catalog/theme/pages first, draft channel test, bulk-edit history), Deploy (last green SHA, decoupled migration+code, feature flag ramp), Config (diff before/after, nginx -t, DNS TTL pre-lower), Infra (RDS param apply_method, autoscaling cooldown, blue-green resize).

Per-system rollback playbook: Postgres (pg_dump + PITR), MySQL (mysqldump --single-transaction), Mongo (mongodump + Atlas snapshot), Redis (BGSAVE + dump.rdb), Shopify (catalog CSV + theme zip), WooCommerce (wp db export + wp-content tar), Vercel (rollback via SHA), Netlify (rollbackSiteDeploy), S3/R2 (versioning + delete bad version), DNS (lowered TTL + restore values), App config (vault-stored values + redeploy), TLS (ACME automated), IAM (saved JSON re-apply).

Postmortem template included: blameless, timeline, root cause vs trigger, action items with owner+due+priority+type, "what went well / what went poorly / where we got lucky".

Pairs with `database-architect` (zero-downtime migrations), `github-safety` (non-destructive git), `infra-security` (security audits), `error-handling` (rollback trigger detection).

Reference files: `checklist.md` (full pre-flight, copy into runbook), `rollback-playbook.md` (per-system commands), `postmortem-template.md` (template + GOOD/BAD examples).

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
5. **`install.sh`** — add to the `SKILLS` array (alphabetical order). The installer is multi-tool: Claude Code (`~/.claude/skills/` or `<project>/.claude/skills/`), OpenCode (`~/.config/opencode/skills/` or `<project>/.opencode/skills/`), Codex CLI (`~/.agents/skills/` or `<project>/.agents/skills/`), or Universal mode (writes to `~/.agents/skills/` — read by all 3 tools). Has wizard + flag modes (`--tool`, `--scope`, `--all`). New skills work in all tools automatically as long as `SKILL.md` follows the standard frontmatter (`name`, `description`).
6. **`skills/meta/orchestrator/skills.manifest.json`** — add entry with tags, triggers, deps, cost, value.
7. **`README.md`** — table row + "Available skills for installation" list + `prompts/` index.
8. **`CLAUDE.md`** (this file) — tree + Key Skills entry. Or run `claude-md-keeper` afterwards to catch drift.
9. **`prompts/<name>.md`** — activation prompts + example use cases.

When using skills in other projects, load the SKILL.md and relevant reference files as context.

## Conventions (Dublin)

- **Foundation-first**: `frontend-foundation` precedes `mobile-design` / `premium-frontend-design` / `forms-and-validation` / `product-tour` / `landing-page-architect`
- **Mobile-as-medium-before-polish**: `mobile-design` runs AFTER `frontend-foundation` (Pillar 4 baseline) and BEFORE `premium-frontend-design` polish. Triggers on user reports of horizontal overflow, mobile UX issues, or any product where mobile traffic > desktop traffic.
- **Data-before-auth**: `database-architect` precedes `auth-architect` (auth needs user/session tables)
- **Domain-before-architecture**: `domain-modeler` precedes `hexagonal-architect` / `api-architect`
- **Polish-last**: `premium-frontend-design` is polish — run after `product-ux-advisor` and `frontend-foundation`
- **Security-pre-ship**: `infra-security` runs before any production deploy
- **Change-safety pre-write**: `change-safety` runs as a mandatory gate BEFORE any production write. Auto-invokes on `ALTER`/`DROP`/`TRUNCATE`/`RENAME`, `UPDATE`/`DELETE` without `WHERE`, mass batch operations, deploy to prod, store/CMS catalog or pricing or inventory edits, env/secret rotation, DNS change, TLS swap, IAM/security group change. Forces snapshot + rollback plan + comms + in-flight check + change window + approver before execution. Pairs with `database-architect` (zero-downtime migrations) and `github-safety` (non-destructive git). NOT a code generator — a gate that returns Go/No-Go.
- **Git workflow for teams**: `git-workflow` is the constructive complement of `github-safety` (defensive). Invoke on team setup, onboarding new devs, conflict resolution help, or repo audits. Generates LOCAL enforcement (husky hooks, commitlint, branch protection, PR template, CODEOWNERS, CONTRIBUTING.md) so day-to-day rules cost ZERO LLM tokens. 4 named AI Tells: Garbage Commit, Frankenstein PR, Eternal Branch, History Bomb. PR tope: 400 LOC (warn at 400, hard limit 1000). Default merge: squash.
- **SDD for substantial changes**: `sdd-workflow` activates on triggers or when changes touch ≥ 3 files / architecture
- **Performance audit after frontend**: `react-performance` runs as a non-destructive review gate after any frontend implementation skill (`frontend-foundation`, `premium-frontend-design`, `forms-and-validation`, `product-tour`, `landing-page-architect`) produces React code. Conditional: fires only if new components, `useEffect`, data fetching, render loops, or > 2 components touched. Skip on trivial edits, copy-only changes, or style-only tweaks.
- **Performance audit after backend**: `backend-performance` runs as a non-destructive review gate after any backend implementation skill (`api-architect`, `hexagonal-architect`, `database-architect`, `auth-architect`) produces code. Conditional: fires on new endpoint/handler, new DB query, async/IO work, loop with awaits, large payloads, or > 2 backend files touched. Skip on config-only, doc-only, or type-only changes.
- **Design audit after frontend**: `frontend-output-validator` runs as a non-destructive review gate after any frontend implementation skill produces UI. Reads project `DESIGN.md` as source of truth. Validates contrast, CLS, icon budget, touch targets, viewport meta, mobile-first compliance, forbidden AI Tells (Pure Black / LILA BAN / Inter Tell / Icon Soup / Mobile Afterthought / Layout Shift Sloppy / Filler Word Index / Jane Doe Effect / Acme Slop). Conditional: fires on new components/layouts, new images/videos/fonts/icons, > 1 component touched, hover/focus/active states modified. Skip on copy-only or type-only changes. Pairs with `react-performance` (perf vs design contract).
- **Design contract per project**: every project ships a `DESIGN.md` at repo root combining YAML tokens (breakpoints, colors, typography, spacing, motion, iconBudget, contentPriority, aiTellsEnforced) with markdown rationale. Format borrows from [Google Labs DESIGN.md](https://github.com/google-labs-code/design.md) and extends with Dublin specifics (motion, breakpoints, icon budget, content priority, AI Tells). Agent reads it at start of every session. CI validates with `scripts/validate-design.ts` (Zod schema). Optional: `npx @google/design.md lint` for contrast + token diff.
- **Mobile-first content priority**: every screen has a `contentPriority` block in `DESIGN.md` (critical / primary / secondary / tertiary). Layouts are designed at 360px first, then scaled up. Mobile pattern swaps mandatory: sidebar → bottom tab bar, dropdown → bottom sheet, modal → full-screen sheet, hover-only → persistent active state.
- **CLS Zero target**: < 0.05 (Core Web Vitals "Good" is < 0.1). Every image has `width`+`height` or `aspect-ratio`. Web fonts use `font-display: swap` + size-adjust fallback + preload. Banners overlay (`fixed`), never inline. Accordions use `grid-template-rows: 0fr → 1fr`.
- **Icon budget enforcement**: nav ≤ 5, hero ≤ 1, card ≤ 2, button ≤ 1, form field ≤ 1, footer social ≤ 3. One library per project (no mixing). Counted by `frontend-output-validator`, not vibed.
- **UGC pipeline order**:
  - Lipsync branch: `ugc-scriptwriter` → `ai-avatar-director` → `ugc-post-production`
  - Generative branch: `ugc-scriptwriter` → `ugc-video-prompting` → `ugc-post-production`
  - Hybrid campaigns use both branches (lipsync for talking head, generative for B-roll/scene)
  - Never skip the scriptwriter — the script drives both casting and prompt engineering
  - Never skip post-production — generative renders still need captions, music sync, and hook FX
