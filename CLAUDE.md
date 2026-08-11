# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A **Claude Code skills library** — specialized prompts, reference materials, and code templates that extend Claude Code in specific domains. Currently **41 skills** across 17 categories, paired with the user-scope **dublin-agent** (personal senior-architect mentor) and a shared memory layer.

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
│   ├── blog-writer/          # Blog posts in EN/ES — 8 post types, SEO-aware, hook engineering, distribution output (LinkedIn, Twitter thread, newsletter)
│   │   └── references/       # post-types.md, headline-engineering.md, hook-engineering.md, seo-writing.md, distribution.md
│   ├── presskit/             # Crea y mantiene PRESSKIT.md de marca — rutas a assets (logos, colores, video intro/outro, avatar, música), reglas de voz/tono, QUÉ SÍ/QUÉ NO, compliance, reglas por plataforma. Alimenta Filtro de Guión de video-creativo. 3 modos: crear / actualizar / auditar assets.
│   │   └── references/       # presskit-template.md (template completo con todas las secciones + tabla de integración con skills)
│   ├── institutional-site-architect/  # Multi-page corporate / institutional site blueprints
│   │   └── references/       # information-architecture.md, brand-voice.md, page-anatomy.md, trust-authority.md, org-types.md, content-strategy.md
│   └── landing-page-architect/  # Conversion-optimized landing page blueprints (copy + structure)
│       └── references/       # copywriting-theory.md, landing-fundamentals.md, conversion-by-goal.md, ab-testing-cro.md
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
├── mobile/
│   └── mobile-app-foundation/  # Day-0 CROSS-PLATFORM app architecture (React Native + Expo) — one codebase → iOS + Android + web. expo-router, NativeWind dual theme, FlashList + offline-first cache, dev builds, EAS Build, store submission, static web export, OTA. AI Tells (Web Brain, ScrollView Graveyard, Notch Blind, Keyboard Eater, JS Thread Jam, Expo Go Mirage, Ghost Tap, Version Roulette, Store Surprise, Offline Amnesia, pnpm Trap, One-Target Tell, Symmetric Storage Trap). Distinct from mobile-design (responsive CSS for a website)
│       ├── references/         # cross-platform.md, project-structure.md, styling-and-theming.md, data-and-offline.md, native-gotchas.md, builds-and-distribution.md, testing-on-device.md
│       ├── templates/          # Runnable Expo boilerplate overlay (src/app routes, tokens, Screen primitive, persisted query cache, DESIGN.md, eas.json)
│       └── scripts/            # create-mobile-app.sh — create-expo-app + Dublin overlay + expo install
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
│   ├── content-director/     # Orquestador del pipeline de video. El cliente da un brief de 1-2 líneas; el director determina el pipeline, corre los skills en orden, y solo para al cliente en 3 gates (gancho / SMP / guion). El cliente no conoce los skills internos.
│   │   └── references/       # pipeline-decision-tree.md (árbol + 4 pipelines resultantes), gate-templates.md (formato de los 3 gates + informe de arranque)
│   ├── gancho-argumental/    # Investigación web sistemática para encontrar tensión, ironía, paradoja o dato oculto que transforma un tema en historia. 11 tipos de gancho clasificados por potencial viral. Output: brief de investigación → alimenta CONCEPTO de video-creativo.
│   │   └── references/       # hook-taxonomy.md (11 tipos + ranking viral), search-playbook.md (8 dimensiones de búsqueda + queries modelo + verificación)
│   ├── video-creativo/       # Flujo completo CONCEPTO → IDEA → GUION → ESCENAS — corto (15-90 seg) y largo (3-20 min). Upstream de todo el pipeline UGC.
│   │   └── references/       # concepto-framework.md, idea-angles.md, guion-estructura.md, escenas-breakdown.md
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

This repo is the **model/source**, not where the team works: they clone it and install the environment **into their own working repos** (`SESSION.md`/`TASKS.md` live in those projects, not here). Entry points:

- **`./install.sh new <path>`** — scaffold a fresh project: `git init` + `SESSION.md` + `TASKS.md` + `.gitignore` + `OPERATING-MODEL.md` (from `env/templates/`, `__PROJECT__`/`__DATE__` filled), then the full environment.
- **`./install.sh app <path>`** — scaffold a **cross-platform app** (React Native + Expo → iOS + Android + web) via `skills/mobile/mobile-app-foundation/scripts/create-mobile-app.sh`, then layer the full environment. Deliberately **generates** rather than cloning a template repo: `create-expo-app` resolves the current SDK and every native version at scaffold time, so new apps never start on a stale SDK (a pinned template contradicts the skill's own mandate #1 and makes every new project begin in debt). The Dublin layer is what stays constant; versions float. Produces `SESSION.md` + `TASKS.md` (mobile-flavored, from the skill's `templates/`) plus `DESIGN.md`, `eas.json`, `.npmrc` (`node-linker=hoisted`).
- **`./install.sh daily <path> [--projects=<dir>]`** — scaffold a **cockpit / daily driver**: personal control center where `task: <x>` breaks work into sub-tasks and `daily` produces a rollup (In progress · Next · Blockers) across all projects in `<dir>`. Scaffolds cockpit-flavored `SESSION.md`/`TASKS.md` (`env/cockpit/`), runs full env, appends the cockpit block (`env/cockpit/COCKPIT.md`) **outside** the team-rules block, between `<!-- DUBLIN-COCKPIT:START/END -->` markers (idempotent). Projects-root is per-person (asked interactively, default = parent dir, or `--projects=`).
- **`./install.sh team-init <path>`** — scaffold the **team coordination hub** (separate git repo all clone): `TEAM.md` (roster + handles), `REGISTRY.md` (shared repos + remotes), generated `BOARD.md` + `members/<handle>.md`, `team.local.md` (per-machine path map, gitignored), plus full env + a `DUBLIN-TEAMHUB`-marked block (`env/teamhub/`). Companions: **`ds team-add <proyecto> <git-url>`** (register repo + map local path), **`ds team-board`** (regenerate board by parsing each cloned repo's `TASKS.md` — pure zsh, no deps), **`ds assign "<texto>" @handle [en <proyecto>]`** (tag a task in the right `TASKS.md`). Assignment = a `@handle` tag inside the project's `TASKS.md` (single source of truth); board only aggregates. `ds team-board --pull` does `git pull --ff-only` per repo before aggregating (opt-in; dirty/non-ff skipped). **`ds team-init --ci`** installs `<hub>/.github/workflows/board.yml` (GitHub Actions auto-regenerates board on push — "managed server" tier, clones REGISTRY repos in CI via `env/teamhub/scripts/build-board-ci.sh`, needs a `TEAM_REPOS_TOKEN` secret). Workflow ships as template under `env/teamhub/.github/` so it never runs on the public dublin-skills repo. Decision record: file+git hybrid (team-hub + per-repo `TASKS.md`), engram stays memory-only, full `engram cloud`/Postgres deliberately NOT adopted (would break the no-server premise; CI covers freshness without ops).
- **`./install.sh install [<path>]`** — layer the environment onto an existing project.

`./install.sh install` installs a complete AI agent environment for the team in **two commands** (`git clone … && cd dublin-skills && ./install.sh install`). Asks tool + scope, then installs in order:

1. **All 41 skills** (reuses `install_all`)
2. **dublin-agent** (claude/opencode; both for `universal`)
3. **Team rules** — `env/rules/TEAM-RULES.md` → `CLAUDE.md` (Claude) or `AGENTS.md` (OpenCode/Codex/Universal). Eight sections: (1) hard rules, (2) frontend conventions, (3) forbidden AI Tells, (4) process, (5) technical defaults, (6) agent operating discipline (work routing / delegation contract / TDD evidence / model routing), (7) project tracking (`SESSION.md` status + `TASKS.md` shared backlog with Client-pains/Backlog/Doing/Done/Future buckets + private gitignored `TASKS.<you>.local.md` + mandatory context upkeep), (8) roles & operating model (Tech Lead = agent, Approver = owner, Dev = team incl. non-technical; agent builds order when none exists). Companion `env/OPERATING-MODEL.md` → project root. Merged between `<!-- DUBLIN-TEAM-RULES:START/END -->` markers (hand edits outside survive). Idempotent; `--force` refreshes.
4. **Shared memory** — `env/memory/*` → `<project>/.claude/team-memory/` (5 pre-seeded facts: zero-hallucinations, finish-now, change-safety, foundation-first-frontend, forbidden-ai-tells)
5. **Hooks** — scripts + `settings.json` merged with `jq`. Claude Code only (skipped with notice for other tools):
   - `change-safety-guard.sh` (`PreToolUse`) — blocks `DROP`/`TRUNCATE`/`UPDATE`-no-`WHERE`/force-push/`reset --hard`/`--no-verify` with exit 2, zero LLM tokens.
   - `session-context-loader.sh` (`SessionStart`) — injects persistent context: HARD RULES banner (zero-hallucination / no-suposiciones / finish-now / change-safety) first, then `.claude/team-memory/*` facts (skips `MEMORY.md` index) + `SESSION.md` as `additionalContext`, plus a LOUD 🔴 warning when the `engram` binary is missing.
   - `context-upkeep-nudge.sh` (`Stop`) — write-side of context upkeep (TEAM-RULES §7): if source files changed but `SESSION.md` is unlogged, exit 2 + stderr forces a context update before stopping. Guarded by `stop_hook_active` (nudges once, no loop); no-op on clean tree or outside a Dublin git project.
6. **engram (persistent memory)** — wires [engram](https://github.com/Gentleman-Programming/engram) as MCP server via `<project>/.mcp.json` (`{"command":"engram","args":["mcp"]}`). Standalone Go binary (SQLite, 19 MCP tools: `mem_save`, `mem_search`, `mem_session_start`…) giving real cross-session memory. Config written automatically; **binary is per-machine** — installer detects it and prints `brew install gentleman-programming/tap/engram` rather than installing silently. The rest of gentle-ai/gentle-pi is intentionally NOT adopted (Claude Code is the team runtime).

**Re-running `install` is a safe upgrade**: rules refresh only when the managed block changed (diff-checked; `--force` overrides), touched files backed up first, `settings.json`/`.mcp.json` merge, dropped skills pruned to `<skills>/.dublin-orphans/`, `SESSION.md`/`TASKS.md` never overwritten. Each install stamps `<project>/.dublin-env` with the model's git short SHA; **`./install.sh doctor <path>`** reports up-to-date vs outdated (scans subfolders) and checks the per-machine `engram` binary (🔴 if missing).

Safety: every existing file backed up (`*.bak.<timestamp>`) before being touched. Team rules are **team-scope**, separate from individual preferences (which stay user-scope). To change: edit `env/rules/TEAM-RULES.md`, commit, team re-runs `./install.sh install --force`. Reference: `env/README.md`.

## Companion Assets (outside `skills/`)

- **`agents/dublin-agent.md`** — versioned source of the senior-architect mentor agent. Installed to `~/.claude/agents/dublin-agent.md` via `./install.sh agent` (timestamped backup of any prior version). Invoked via `Task(subagent_type: 'dublin-agent')`. Auto-detects this library and delegates to skills. Successor to the historical `gentleman` agent.
- **`~/.claude/agent-memory/shared/preferences.md`** — universal user preferences (voseo, no emojis, bun, philosophy, Dublin conventions). Read by dublin-agent. User-scope, not in this repo.
- **`~/.claude/agent-memory/dublin-agent/`** — agent-specific operational memory. User-scope.

## Skill File Convention

Each skill has a `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: When and how to use this skill
---
```

The `description` field tells Claude when to invoke the skill (keep it sharp — it's what auto-selection runs on). Reference files live in `references/` and load on demand.

## Key Skills — relationships & operating notes

The directory tree above describes each skill and its reference files. This section captures only what the tree does NOT: cross-skill relationships, pipelines, modes, and non-obvious operating rules.

### Meta — invoke on multi-step tasks

- **orchestrator** — Skill Router / Supervisor. Reads `skills.manifest.json` (or falls back to per-`SKILL.md` scan), scores each skill by relevance × value / cost, resolves deps, emits a phased plan + `TaskCreate` entries. Three modes: **A** fresh plan, **B** validate a user plan (kept/added/removed/reordered with rationale), **C** audit (map repo gaps to skills).
- **claude-md-keeper** — **NEVER** writes CLAUDE.md directly; emits `CLAUDE.md.proposed` for review. On-demand only, never hooked. Three-layer memory awareness (CLAUDE.md project / shared preferences / agent memory).
- **session-bridge** — three-phase rollout: Phase 1 on-demand (default), Phase 2 opt-in `Stop` hook with `--dry-run`, Phase 3 full-auto Stop hook. Marks promotion candidates for `claude-md-keeper`.
- **sdd-workflow** — single source of truth for SDD; dublin-agent references it instead of carrying SDD logic inline. Dep graph: proposal → specs + design → tasks → apply → verify → archive. Artifact store: `engram` (recommended) / `openspec` (only when user asks) / `none`. Approval gates by phase; destructive actions always gated.

### Architecture / Data / Security

- **domain-modeler** → precedes `hexagonal-architect` / `api-architect`.
- **api-architect** — never writes code; hands implementation to `hexagonal-architect` (NestJS) or the engineer.
- **database-architect** — precedes `auth-architect` (auth needs user/session tables). Non-negotiables: UUID v7, TIMESTAMPTZ, hard-delete default, FK + indexes; zero-downtime migrations (3-step rename, NOT VALID + VALIDATE, CONCURRENTLY).
- **data-viz-architect** — outputs a blueprint, hands off to `premium-frontend-design` for implementation.
- **auth-architect** — web = sessions via httpOnly cookies; refresh-token rotation (reuse = compromise → revoke all). Pairs with `database-architect` + `error-handling`.

### Frontend (dependency-ordered)

`frontend-foundation` (Day-0, 6 Pillars + DESIGN.md contract) → `mobile-design` (mobile-as-medium, overflow killers) → `premium-frontend-design` (polish: 3 dials, named AI Tells) → `forms-and-validation` / `product-tour` / `landing-page-architect`.

- **frontend-foundation** — invoke BEFORE any aesthetic layer. Owns dual theme (View Transitions slow-fast-slow `cubic-bezier(0.65,0,0.35,1)`), spacing scale, headless component system, mobile-first content priority, CLS Zero (< 0.05), icon budget, and the per-project `DESIGN.md`.
- **mobile-design** — runs AFTER foundation, BEFORE premium polish. New AI Tell: **Shrunk Desktop**. 5 mandates: 360px-first / touch ≥ 44×44 + ≥ 8px / zero horizontal overflow / `100dvh` not `100vh` / safe-area on every fixed bottom element.
- **premium-frontend-design** — polish only (runs after `product-ux-advisor` + foundation). 3 dials: `DESIGN_VARIANCE` / `MOTION_INTENSITY` / `VISUAL_DENSITY` (1-10). Named AI Tells: LILA BAN, Jane Doe Effect, Acme Slop, 99.99% Problem, Filler Word Index, Pure Black Tell, Inter Tell, Generic 3-Card Row, Icon Soup, Mobile Afterthought, Layout Shift Sloppy. Magnetic buttons via `useMotionValue` (never `useState`).
- **frontend-output-validator** — design-contract review gate after any frontend skill (pairs with `react-performance` for perf). Layer 1 static (rg/AST), Layer 2 Lighthouse CI (CLS/LCP/contrast/tap-targets, mobile + desktop), Layer 3 optional visual regression. Reads `DESIGN.md` as source of truth. Output: pass/fail with `file:line` + severity. > 5 warnings → suggest `claude-md-keeper`.
- **react-performance** — perf review gate after frontend skills: useEffect elimination, React Compiler vs manual memo, RSC boundary placement, bundle optimization, data-fetching waterfalls.
- **product-ux-advisor** — diagnosis only (Critical / Recommended / Polish), SaaS + e-commerce patterns; implementation delegated to `premium-frontend-design`.

### Mobile (native apps)

- **mobile-app-foundation** — Day-0 for apps that ship to the **App Store / Play Store — and to the web from the same codebase**. Explicitly NOT `mobile-design`: that one is responsive CSS for a website, this one is a compiled binary plus a static web build. Fires the disambiguation question first ("does this need a store, push, or offline?") — if no, it routes back to a web stack.
  - **Multiplataforma is the Dublin default**, not an upsell: iOS + Android + web, always. Dropping web is an explicit decision. Web ships via `expo export --platform web` (`output: "static"`) → real URLs, SEO, deployable to a VPS with nginx and no Node server (`try_files $uri $uri.html …` — expo-router emits `/settings.html`, so without the `.html` fallback a refresh on a deep route 404s).
  - **Two modules fail SILENTLY on web** (verified by reading their web builds on SDK 57, not assumed): `expo-secure-store` is `export default {}` → any call throws; `Alert.alert` is `static alert() {}` in react-native-web → the message never appears. A green build proves nothing. Templates ship `src/lib/notify.ts` and `src/lib/session-storage.ts` to close both. Verified OK on web: expo-haptics (navigator.vibrate + iOS Safari fallback), FlashList v2, expo-image, AsyncStorage, netinfo, safe-area-context.
  - **Never mirror a native token into `localStorage`** to make the code symmetric — that converts a Keychain-protected secret into an XSS-readable one (**Symmetric Storage Trap**). Web sessions belong in an httpOnly cookie.
  - Stack with rationale: Expo managed (EAS cloud builds, no local Xcode) · expo-router (file-based, deep links near-free) · NativeWind 4 (reuses Tailwind muscle memory) · FlashList 2 (new-arch only, no size estimates) · TanStack Query + AsyncStorage persister (offline-first) · `expo-secure-store` for tokens, never AsyncStorage.
  - 8 mandates: `npx expo install` never hand-pinned versions · FlashList over ~20 items · safe areas via a `Screen` primitive · dark + light day 0 (`userInterfaceStyle: "automatic"` in `app.json` or the OS pins you to light) · offline behavior defined per data screen · physical-device dev build before "done" · `.npmrc` `node-linker=hoisted` for pnpm · **all three targets bundle before anything is done**.
  - 13 named AI Tells: Web Brain, ScrollView Graveyard, Notch Blind, Keyboard Eater, JS Thread Jam, Expo Go Mirage, Ghost Tap, Version Roulette, Store Surprise, Offline Amnesia, The pnpm Trap, One-Target Tell, Symmetric Storage Trap.
  - Ships a **verified** boilerplate: `scripts/create-mobile-app.sh <path>` runs `create-expo-app` (Expo picks the SDK and native versions) then overlays the Dublin layer into `src/` (routes at `src/app/`, alias `@/*`). Verified end-to-end on SDK 57: scaffold → `tsc --noEmit` → `expo export` for **ios, android and web**. The `Screen` primitive caps content width on web so no screen has to remember the third target exists.
  - Pairs: `mobile-design` (thumb zones / pattern picks translate directly), `forms-and-validation` (RHF + Zod work unchanged), `auth-architect` (sessions + secure storage), `change-safety` (**an OTA update is a production write with no review gate**).

### Backend / Implementation

- **backend-performance** — review gate after `api-architect` / `hexagonal-architect` / `database-architect` / `auth-architect`. Audits queries (N+1, indexes), async/IO (event-loop blocking, `p-limit` fan-out), caching (Redis, stampede protection), pooling, payload shape, rate-limiting, observability (OTel + Pino + Prom). Delegates schema/index design to `database-architect`, error taxonomy to `error-handling`.
- **testing-strategy** — complements `tdd-workflow` (red-green-refactor): WHAT to test at which layer; pyramid ~70/20/10; testcontainers for real Postgres; MSW; Playwright; Pact.
- **error-handling** — typed hierarchy (DomainError → …), Problem Details (RFC 7807) with `code` + `correlationId`, Pino structured logging, React Error Boundaries, retry+backoff+jitter, circuit breakers, Sentry.

### Infra / Ops / Git

- **infra-security** — runs before any production deploy. AWS-first (Bedrock, ECS, Lambda, VPC, IAM), AI-as-a-Service patterns, VPS hardening, OWASP audits, architecture-from-scratch with tiered cost options.
- **github-safety** (defensive) ↔ **git-workflow** (constructive). git-workflow generates LOCAL enforcement (husky, commitlint, branch protection, PR template, CODEOWNERS, CONTRIBUTING.md) so day-to-day rules cost ZERO LLM tokens. 4 AI Tells: Garbage Commit, Frankenstein PR, Eternal Branch, History Bomb. PR ≤ 400 LOC (hard limit 1000), squash default. Pairs with `change-safety` when a PR touches prod.
- **change-safety** — pre-flight gate before ANY prod write (NOT a code generator — returns Go/No-Go). Auto-invokes on `ALTER`/`DROP`/`TRUNCATE`/`RENAME`, `UPDATE`/`DELETE` without `WHERE`, mass batches, deploy-to-prod, store/CMS catalog/pricing/inventory edits, env/secret rotation, DNS/TLS/IAM/infra change. Seven-step protocol: (1) one-sentence description, (2) snapshot tested by restore, (3) rollback plan (trigger + procedure + RTO), (4) stakeholder comms, (5) in-flight check (`pg_stat_activity`, queue depth, replication lag), (6) change window, (7) approval gate. Decision trees + per-system rollback playbook + blameless postmortem template. Pairs with `database-architect`, `github-safety`, `infra-security`, `error-handling`.

### Content & GTM

- **blog-writer** / **landing-page-architect** / **institutional-site-architect** — Filler Word Index + Data Realism (99.99% Problem, Jane Doe, Acme Slop) enforced. landing-page-architect hands off to `product-ux-advisor` + `premium-frontend-design`.
- **brand-identity** / **brand-guidelines** — feed `premium-frontend-design` so it doesn't improvise colors/typography.

### UGC Pipeline

Two rendering branches share `ugc-scriptwriter` (start) and `ugc-post-production` (end). Never skip either:
- **Lipsync** (talking head): `ugc-scriptwriter` → `ai-avatar-director` → `ugc-post-production`. For HeyGen / Hedra / Akool / Arcads / Synthesia.
- **Generative** (Veo 3 / Seedance 2.0): `ugc-scriptwriter` → `ugc-video-prompting` → `ugc-post-production`. For scene-based UGC, B-roll, POV, demo.
- Hybrid campaigns combine both (lipsync talking head + generative B-roll).
- Shared vocabulary across branches: Filler Word Index, Jane Doe Effect, Pure Black Tell, Data Realism. `ai-avatar-director` mandates ES-AR voseo voice (not neutral).

### Integration / Media / Meta

- **bind-api** — BIND Argentina Open Banking sandbox: OAuth 2.0 Direct Login; accounts, transfers, DEBIN, eCheqs, CBU/CVU validation; TS client `scripts/bind_client.ts`.
- **remotion-video** — programmatic video from React components.
- **skill-creator** — guide for creating new skills.

## Working with This Repository

When adding or modifying skills, update ALL of the following (in order):

1. **SKILL.md** — frontmatter (`name`, `description`) + detailed instructions. Description is what Claude auto-selects on — keep it sharp.
2. **Reference files** in `references/` — reusable code/templates, loaded on demand.
3. **Anti-patterns** — what NOT to do (as important as the positive guidance).
4. **Output standards** — expected format (complete code, types, specific patterns).
5. **`install.sh`** — add to the `SKILLS` array (alphabetical). Installer is multi-tool: Claude Code (`~/.claude/skills/` or `<project>/.claude/skills/`), OpenCode (`~/.config/opencode/skills/` or `<project>/.opencode/skills/`), Codex CLI (`~/.agents/skills/` or `<project>/.agents/skills/`), or Universal (`~/.agents/skills/`, read by all 3). Wizard + flag modes (`--tool`, `--scope`, `--all`). New skills work in all tools as long as `SKILL.md` follows standard frontmatter.
6. **`skills/meta/orchestrator/skills.manifest.json`** — add entry with tags, triggers, deps, cost, value.
7. **`README.md`** — table row + "Available skills for installation" list + `prompts/` index.
8. **`CLAUDE.md`** (this file) — tree + Key Skills entry. Or run `claude-md-keeper` afterwards to catch drift.
9. **`prompts/<name>.md`** — activation prompts + example use cases.

When using skills in other projects, load the SKILL.md and relevant reference files as context.

## Conventions (Dublin)

### Dublin v2 — Core Flow (anti-architecture-astronautics)

These four rules override the natural tendency to over-plan. They apply to every session, every skill, every project.

- **SCAN first**: Before any planning, read `SESSION.md` + `TASKS.md ## Doing` + code structure. Determine new vs. existing project. Existing project → adapt to what's there, never redesign from scratch.
- **ONE THING per session**: Articulate the single deliverable in one sentence before invoking any skill. If it doesn't fit in one sentence, cut scope. No skill, no SDD, no orchestrator runs until ONE THING is clear.
- **Skeleton-first**: The first output of any task is runnable code (even ugly). No design docs, no specs, no architecture diagrams as first deliverable. Skills run as review gates AFTER the skeleton exists.
- **Planning timebox**: 20 minutes (or 2 exchanges) max before first line of code. Skills are YAGNI-filtered: "Do I need this TODAY for the skeleton to work?" No → defer it. Anything answered "we'll need it eventually" = not in this session.
- **SDD threshold (revised)**: SDD activates when ≥ 3 files AND design is genuinely unclear. "I know what to build but it's big" → skeleton first, SDD on second pass if needed.

---

- **VPS-first / lightweight-first**: las apps Dublin se deployan en VPS por default (no Vercel/Netlify como reflejo). Optimizar para menor bundle size, menor build time, menor footprint de servidor.
  - **Package manager**: `pnpm` siempre (workspaces, hardlinks, disk-efficient, más rápido). Nunca `npm`/`yarn` en proyectos nuevos.
  - **Frontend**: elegir la opción más liviana que cumpla el requerimiento — Vite + React (SPA/apps), Astro (sitios de contenido/marketing, islands), SvelteKit, o Next.js con Turbopack/SWC cuando se necesita SSR/ISR/RSC. No elegir Next.js por reflejo; justificar si nginx + bundle estático no alcanza.
  - **Backend**: Hono (ultra-liviano, edge-compatible, corre en Node/Bun/Deno) o Fastify por default. NestJS solo para proyectos enterprise con DI y módulos complejos. Express solo legacy.
  - **Build**: target ES2022+, tree-shaking agresivo, sin polyfills innecesarios.
  - **Docker**: imagen Alpine o distroless, multi-stage build, `.dockerignore` en root. Considerar Bun como runtime (más rápido que Node para scripts y APIs).
  - **Runtime alternativo**: Bun — scripts, APIs nuevas, build pipeline. Node.js para proyectos que necesitan compatibilidad garantizada.
- **Foundation-first**: `frontend-foundation` precedes `mobile-design` / `premium-frontend-design` / `forms-and-validation` / `product-tour` / `landing-page-architect`
- **Mobile-as-medium-before-polish**: `mobile-design` runs AFTER `frontend-foundation` (Pillar 4 baseline) and BEFORE `premium-frontend-design` polish. Triggers on horizontal overflow reports, mobile UX issues, or any product where mobile traffic > desktop traffic.
- **Traducción de skills de diseño en proyectos RN**: ninguna skill de frontend de esta librería conoce React Native — todas asumen DOM. Su **criterio** sirve; su **código** no. En un proyecto RN (detectado por `expo` en `app.json`/`app.config.*` o `react-native` en `package.json`), el agente traduce la salida de `premium-frontend-design` / `frontend-foundation` / `mobile-design` / `product-tour` / `data-viz-architect` vía `mobile-app-foundation/references/design-skills-bridge.md` **antes de escribir código**, y dice qué sustituyó. Entregar `backdrop-filter`, Framer Motion o Radix a un codebase RN es un defecto (**Web Code Handoff**) — quien pide una app mobile es el menos capaz de convertirlo. `frontend-output-validator` **no corre** sobre nativo: Lighthouse no perfila un binario y sus greps dan verde sin medir (**False Green**); su rol lo cubre `references/testing-on-device.md`, manual por necesidad.
- **Multiplataforma por default**: toda app de `mobile-app-foundation` sale a **iOS + Android + web** desde una sola base de código. Bajar web es una decisión explícita, nunca el default. Verificación = los tres targets bundlean (`npx expo export --platform ios|android|web`) **y** una pasada manual, porque `expo-secure-store` (sin build web) y `Alert.alert` (no-op silencioso en react-native-web) fallan sin romper el build. Web sale como export estático → VPS con nginx, alineado con VPS-first.
- **Native-vs-web first**: `mobile-app-foundation` (React Native + Expo, store binaries) and `mobile-design` (responsive CSS in a browser) are different disciplines. Resolve which one is actually needed BEFORE any work: a native app costs an order of magnitude more to ship and maintain, and is only justified by stores, push, or offline. For a native app, `mobile-app-foundation` runs first; `mobile-design` then contributes pattern picks and thumb-zone ergonomics, which transfer directly.
- **OTA is a production write**: an `eas update` reaches every installed device with no store review in between. `change-safety` applies — verify on a `preview` branch and a real device first. An OTA whose JS needs native code the installed binary lacks crashes the app on launch for every user; the runtime version policy is the guard.
- **Data-before-auth**: `database-architect` precedes `auth-architect` (auth needs user/session tables)
- **Domain-before-architecture**: `domain-modeler` precedes `hexagonal-architect` / `api-architect`
- **Polish-last**: `premium-frontend-design` is polish — run after `product-ux-advisor` and `frontend-foundation`
- **Security-pre-ship**: `infra-security` runs before any production deploy
- **Change-safety pre-write**: `change-safety` is a mandatory gate BEFORE any production write. Auto-invokes on `ALTER`/`DROP`/`TRUNCATE`/`RENAME`, `UPDATE`/`DELETE` without `WHERE`, mass batches, deploy to prod, store/CMS catalog/pricing/inventory edits, env/secret rotation, DNS change, TLS swap, IAM/security-group change. Forces snapshot + rollback plan + comms + in-flight check + change window + approver. Pairs with `database-architect` and `github-safety`. NOT a code generator — a gate returning Go/No-Go.
- **Git workflow for teams**: `git-workflow` is the constructive complement of `github-safety` (defensive). Invoke on team setup, onboarding, conflict help, or audits. Generates LOCAL enforcement (husky, commitlint, branch protection, PR template, CODEOWNERS, CONTRIBUTING.md) so day-to-day rules cost ZERO LLM tokens. 4 AI Tells: Garbage Commit, Frankenstein PR, Eternal Branch, History Bomb. PR tope 400 LOC (warn 400, hard limit 1000). Default merge: squash.
- **SDD for substantial changes**: `sdd-workflow` activates on triggers or when changes touch ≥ 3 files / architecture
- **Performance audit after frontend**: `react-performance` runs as a non-destructive review gate after any frontend implementation skill produces React code. Conditional: fires on new components, `useEffect`, data fetching, render loops, or > 2 components touched. Skip on trivial/copy-only/style-only changes.
- **Performance audit after backend**: `backend-performance` runs as a non-destructive review gate after any backend implementation skill (`api-architect`, `hexagonal-architect`, `database-architect`, `auth-architect`) produces code. Conditional: fires on new endpoint/handler, new DB query, async/IO work, loop with awaits, large payloads, or > 2 backend files touched. Skip on config-only/doc-only/type-only changes.
- **Design audit after frontend**: `frontend-output-validator` runs as a non-destructive review gate after any frontend implementation skill produces UI. Reads project `DESIGN.md` as source of truth. Validates contrast, CLS, icon budget, touch targets, viewport meta, mobile-first, forbidden AI Tells (Pure Black / LILA BAN / Inter Tell / Icon Soup / Mobile Afterthought / Layout Shift Sloppy / Filler Word Index / Jane Doe Effect / Acme Slop). Conditional: fires on new components/layouts, new images/videos/fonts/icons, > 1 component touched, hover/focus/active states modified. Skip on copy-only/type-only changes. Pairs with `react-performance` (perf vs design contract).
- **Design contract per project**: every project ships a `DESIGN.md` at repo root combining YAML tokens (breakpoints, colors, typography, spacing, motion, iconBudget, contentPriority, aiTellsEnforced) with markdown rationale. Format borrows from [Google Labs DESIGN.md](https://github.com/google-labs-code/design.md) and extends with Dublin specifics. Agent reads it at start of every session. CI validates with `scripts/validate-design.ts` (Zod schema). Optional: `npx @google/design.md lint` for contrast + token diff.
- **Mobile-first content priority**: every screen has a `contentPriority` block in `DESIGN.md` (critical / primary / secondary / tertiary). Layouts designed at 360px first, then scaled up. Mobile pattern swaps mandatory: sidebar → bottom tab bar, dropdown → bottom sheet, modal → full-screen sheet, hover-only → persistent active state.
- **CLS Zero target**: < 0.05 (CWV "Good" is < 0.1). Every image has `width`+`height` or `aspect-ratio`. Web fonts use `font-display: swap` + size-adjust fallback + preload. Banners overlay (`fixed`), never inline. Accordions use `grid-template-rows: 0fr → 1fr`.
- **Icon budget enforcement**: nav ≤ 5, hero ≤ 1, card ≤ 2, button ≤ 1, form field ≤ 1, footer social ≤ 3. One library per project (no mixing). Counted by `frontend-output-validator`, not vibed.
- **UGC pipeline order**:
  - Upstream research (optional): `gancho-argumental` → systematic web search → brief de investigación → alimenta CONCEPTO de video-creativo
  - Upstream strategy (optional but recommended): `video-creativo` → produces CONCEPTO + IDEA + GUION + ESCENAS before any production skill
  - Lipsync branch: `video-creativo` (or `ugc-scriptwriter`) → `ai-avatar-director` → `ugc-post-production`
  - Generative branch: `video-creativo` (or `ugc-scriptwriter`) → `ugc-video-prompting` → `ugc-post-production`
  - Hybrid campaigns use both branches (lipsync talking head, generative B-roll/scene)
  - Use `video-creativo` when the comunicación strategic layer (concepto, insight, SMP) is not yet defined. Use `ugc-scriptwriter` directly when the angle and script are the only deliverable.
  - Never skip post-production (renders still need captions, music sync, hook FX)
