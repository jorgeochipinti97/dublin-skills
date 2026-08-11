# Dublin Skills

A collection of skills for [Claude Code](https://claude.ai/code) that extend its capabilities in specific domains, paired with the **dublin-agent** — a senior-architect mentor agent that auto-detects this library and delegates to the right skill.

## Quick Start

**Whole team environment in two commands:**

```bash
git clone https://github.com/jorgeochipinti97/dublin-skills.git
cd dublin-skills && ./install.sh install
```

`./install.sh install` asks tool + scope, then installs **everything**: all 40
skills + the dublin-agent + team rules (`CLAUDE.md` / `AGENTS.md`) + pre-seeded
shared memory + a change-safety git/SQL guard hook (Claude Code) + **engram**
persistent memory wired as an MCP server. Every existing file is backed up
before it's touched; rules merge between markers so hand edits survive. Re-run
with `--force` to pull updated rules.

```bash
./install.sh new ~/my-project               # scaffold a NEW project from scratch (git + SESSION/TASKS + env)
./install.sh install ~/my-project              # add (or upgrade) the env on an EXISTING project
./install.sh install --tool=claude --scope=project   # non-interactive
./install.sh install --force                   # force-refresh rules even if unchanged
./install.sh doctor ~/my-projects           # check which projects are out of date
```

**Re-running is a safe upgrade.** `install` refreshes the rules block only if it
changed (no backup noise), backs up before touching any file, merges
`settings.json` / `.mcp.json`, prunes skills removed from the model (moved to
`.dublin-orphans/`), and never overwrites your `SESSION.md` / `TASKS.md`. Each
install stamps `.dublin-env` with the model's git SHA so `doctor` can flag stale
projects.

**`new` vs `install`:** `new` scaffolds a fresh project (runs `git init`, drops in
`SESSION.md` / `TASKS.md` / `.gitignore` / `OPERATING-MODEL.md`) then installs
the full environment. `install` layers the environment onto a project that already
exists.

dublin-skills is the **model/source** — your team clones it and installs the
environment **into their own working repos**; they don't work inside this repo.

## Commands

`./install.sh <command>` (alias `ds` once on PATH — see [Global command](#global-command-recommended)).

| Command | What it does |
|---|---|
| `ds new <path>` | **Scaffold a new project** from scratch: `git init` + `SESSION.md` + `TASKS.md` + `.gitignore` + full environment |
| `ds daily <path> [--projects=<dir>]` | **Scaffold a cockpit / daily driver**: `task: <x>` splits work into sub-tasks, `daily` rolls up all projects in `<dir>` (asked, default = parent dir) |
| `ds team-init <path> [--ci]` | **Scaffold the team hub** (roster + registry + generated board + members) — a repo all clone. `--ci` adds a GitHub Actions workflow that auto-regenerates the board on push |
| `ds team-add <proyecto> <git-url>` | Register a shared repo in the hub (+ map its local path) |
| `ds team-board [--pull]` | Regenerate `BOARD.md` + `members/` from each cloned repo's `TASKS.md` (`--pull` = `git pull --ff-only` each repo first) |
| `ds assign "<texto>" @handle [en <proyecto>]` | Assign a task to a teammate (`@handle` tag in the right `TASKS.md`) |
| `ds install [<path>]` | Install **or upgrade** the full environment on an existing project (no path = current dir) |
| `ds doctor [<path>]` | Report which projects are **up to date vs outdated** (scans subfolders of a projects dir) |
| `ds agent` | Install just the **dublin-agent** (asks tool) |
| `ds <path> --all` | Install just the **skills** (no rules/env) |
| `ds list` | List available skills |
| `ds update <path>` | Update only the skills already installed in `<path>` |
| `ds --help` | Full usage |

**Flags** (for `install`): `--tool=claude\|opencode\|codex\|universal` · `--scope=project\|user` · `--force` (refresh rules even if unchanged).

**You'll mostly use two:** `ds new` to start a project, `ds install` to add/upgrade the env on an existing one.

See [`env/README.md`](env/README.md) for exactly what lands where.

---

## Team workflow — shared tasks across repos

A team coordinates over **markdown + git** — no server, no database. The single
source of truth for any task is the `TASKS.md` **of its own repo**; a separate
**hub** repo aggregates them into a board and per-person task lists.

### One-time setup (whoever sets up the team)

```bash
# 1. Create the hub (a private repo everyone clones). --ci is optional (see below).
ds team-init ~/work/team-hub
cd ~/work/team-hub

# 2. Register the shared repos (writes REGISTRY.md + maps your local path).
ds team-add tienda      git@github.com:acme/tienda.git
ds team-add dashboard   git@github.com:acme/dashboard.git

# 3. Fill the roster handles in TEAM.md (handle = the @tag used to assign).
#    | jorge | Jorge | owner | * |  /  | nahuel | Nahuel | dev | tienda |

git add -A && git commit -m "init team hub" && git push   # share REGISTRY/TEAM
```

Each teammate then clones the hub, clones the project repos they work on, and runs
`ds team-add <proyecto> <git-url>` once so their machine knows where each repo lives
(the local path map lives in `team.local.md`, which is **gitignored** — per-machine).

### Day to day

```bash
# Assign work — writes a @handle tag into the right repo's TASKS.md:
ds assign "add invoice export"  @nahuel  en tienda
ds assign "fix login redirect"  @sol               # no "en" → current repo's TASKS.md

# See the whole team's board (regenerates from each cloned repo's TASKS.md):
ds team-board            # reads what you have locally
ds team-board --pull     # git pull --ff-only each repo first, then aggregate
```

This produces, in the hub:
- **`BOARD.md`** — every Doing/Backlog task across all repos, with assignee + project.
- **`members/<handle>.md`** — one file per person with just their tasks (cross-project).

Inside any repo, the agent also injects **"your tasks here"** (your `@handle` lines
from that repo's `TASKS.md`) at the start of each session, and assigning is plain
markdown — `- [ ] @nahuel ...` — so it works even without the CLI.

### Keeping the board fresh (pick your tier)

| Tier | How | What it costs |
|---|---|---|
| **Local** | `ds team-board` when you want to look | nothing — just `git` + `zsh` |
| **On-demand fresh** | `ds team-board --pull` | nothing — pulls then aggregates |
| **Automatic** | `ds team-init --ci` → GitHub Action regenerates the board on every push | runs on GitHub's runners (no server you operate); needs a read-only `TEAM_REPOS_TOKEN` secret in the hub |

**Honest limit:** with no server, "the team's state" = the **last `git pull`** of each
repo. If someone assigns a task and doesn't push, you won't see it yet — same as any
git workflow. The CI tier keeps the hub's board fresh on every push; a real-time
server (engram cloud / Postgres) was deliberately **not** adopted to avoid infra to operate.

---

**Just skills / just the agent:**

```bash
# Install the dublin-agent (asks which tool: Claude / OpenCode / both)
./install.sh agent

# Install skills into a project — interactive wizard asks tool + scope
./install.sh ~/my-project

# Or skip the wizard with flags
./install.sh ~/my-project --tool=universal --scope=project --all
```

Prefer no clone? Install just the agent with one command (Claude Code):

```bash
mkdir -p ~/.claude/agents && curl -fsSL \
  https://raw.githubusercontent.com/jorgeochipinti97/dublin-skills/main/agents/dublin-agent.md \
  -o ~/.claude/agents/dublin-agent.md
```

Then invoke it from Claude Code via `Task(subagent_type: 'dublin-agent')`.

---

## 🇪🇸 Cómo sacarle el jugo al máximo

El entorno (`./install.sh install`) no es solo skills: es un **harness de trabajo
para Claude Code** pensado para un equipo. Esto es lo que te da y cómo usarlo.

### 1. Activá la memoria real (engram)

Las skills y reglas vienen solas. Lo único que cada dev instala **una vez** en su
máquina es el binario de [engram](https://github.com/Gentleman-Programming/engram)
— la memoria persistente que hace que el agente **recuerde decisiones entre
sesiones** (no las notas fijas, memoria viva):

```bash
brew install gentleman-programming/tap/engram
# o como plugin de Claude Code:
claude plugin marketplace add Gentleman-Programming/engram && claude plugin install engram
```

El `.mcp.json` ya queda escrito por el instalador. Comandos útiles:

```bash
engram tui                 # explorás la memoria del proyecto en una UI
engram search "auth"       # buscás decisiones pasadas
engram save "titulo" "qué decidimos y por qué"
```

Dentro de Claude el agente usa las 19 tools de engram (`mem_save`, `mem_search`,
`mem_session_start`…) solo. Vos no hacés nada — recuerda por su cuenta.

### 2. Dejá que el agente rutee el trabajo (work routing)

La regla está en `CLAUDE.md`. No le pidas "codeá esto" para todo:

- **Cambio chico y claro** → lo hace inline, sin vueltas.
- **Exploración / mucho contexto** → lo delega a un subagente para no ensuciar el hilo.
- **Grande / ambiguo / arquitectónico** (≥ 3 archivos o una decisión de diseño)
  → arranca el flujo **SDD** (`sdd new <nombre>` → proposal → specs → design →
  tasks → apply → verify).

### 3. Aprovechá los review gates

Después de implementar, el entorno corre **gates no destructivos** solo:
- Frontend → `react-performance` + `frontend-output-validator`
- Backend → `backend-performance`

No tenés que pedirlos: las reglas los disparan según lo que tocaste.

### 4. El guard de change-safety te cuida

Antes de cualquier `DROP` / `TRUNCATE` / `UPDATE` sin `WHERE` / force-push, el
hook **bloquea** el comando y te pide el protocolo (snapshot + rollback + comms).
Cero tokens de IA — corre local. Si es seguro (dev/throwaway), lo re-corrés
aclarándolo.

### 5. Ahorrá con model routing

Usá modelo barato para explorar/buscar/editar mecánico; **Opus** para diseño,
arquitectura y review. La regla está escrita — el agente la sigue.

### 6. Mantené las reglas vivas

Las reglas de equipo viven en `env/rules/TEAM-RULES.md`. Las cambiás, commiteás,
y el equipo corre `./install.sh install --force` para bajar la versión nueva (se
mergea entre markers, no te pisa tus ediciones locales).

> **Flujo ideal de una feature:** describís qué querés → el agente rutea (chico
> o SDD) → si es SDD, aprobás cada fase → implementa con TDD evidence → corren
> los gates → engram guarda las decisiones → próximo dev arranca con contexto.

---

## 🇬🇧 Getting the most out of it

The environment (`./install.sh install`) isn't just skills — it's a **working
harness for Claude Code** built for a team. Here's what it gives you and how to
use it.

### 1. Turn on real memory (engram)

Skills and rules install on their own. The one thing each developer installs
**once** per machine is the [engram](https://github.com/Gentleman-Programming/engram)
binary — persistent memory that makes the agent **remember decisions across
sessions** (not static notes, live memory):

```bash
brew install gentleman-programming/tap/engram
# or as a Claude Code plugin:
claude plugin marketplace add Gentleman-Programming/engram && claude plugin install engram
```

The installer already wrote `.mcp.json`. Handy commands:

```bash
engram tui                 # browse the project's memory in a UI
engram search "auth"       # find past decisions
engram save "title" "what we decided and why"
```

Inside Claude the agent uses engram's 19 tools (`mem_save`, `mem_search`,
`mem_session_start`…) on its own. You do nothing — it remembers by itself.

### 2. Let the agent route the work

The rule lives in `CLAUDE.md`. Don't say "code this" for everything:

- **Small, clear change** → done inline, no ceremony.
- **Exploration / heavy context** → delegated to a subagent to keep the thread clean.
- **Large / ambiguous / architectural** (≥ 3 files or a design decision) → kicks
  off the **SDD** flow (`sdd new <name>` → proposal → specs → design → tasks →
  apply → verify).

### 3. Lean on the review gates

After implementation, the environment runs **non-destructive gates** by itself:
- Frontend → `react-performance` + `frontend-output-validator`
- Backend → `backend-performance`

You don't request them — the rules trigger them based on what changed.

### 4. The change-safety guard has your back

Before any `DROP` / `TRUNCATE` / `UPDATE` without `WHERE` / force-push, the hook
**blocks** the command and asks for the protocol (snapshot + rollback + comms).
Zero AI tokens — it runs locally. If it's safe (dev/throwaway), re-run noting so.

### 5. Save money with model routing

Use a cheap model for exploration/search/mechanical edits; **Opus** for design,
architecture, and review. The rule is written — the agent follows it.

### 6. Keep the rules alive

Team rules live in `env/rules/TEAM-RULES.md`. Change them, commit, and the team
runs `./install.sh install --force` to pull the new version (merged between markers,
your local edits outside the block survive).

> **Ideal feature flow:** describe what you want → the agent routes it (small or
> SDD) → if SDD, you approve each phase → it implements with TDD evidence → the
> gates run → engram stores the decisions → the next dev starts with context.

## Multi-tool support

The installer (`ds`) supports **Claude Code, OpenCode, and Codex CLI**, with a `Universal` mode that all three tools read.

| Tool | User-scope path | Project-scope path |
|---|---|---|
| **Claude Code** | `~/.claude/skills/` | `<project>/.claude/skills/` |
| **OpenCode** | `~/.config/opencode/skills/` | `<project>/.opencode/skills/` |
| **Codex CLI** | `~/.agents/skills/` | `<project>/.agents/skills/` |
| **Universal** | `~/.agents/skills/` | `<project>/.agents/skills/` |

**Why Universal:** OpenCode also reads `~/.claude/skills/` and `~/.agents/skills/`. Codex reads `~/.agents/skills/`. So installing in **`~/.agents/skills/`** makes the skills visible to **all three tools at once**.

### Wizard mode (default)

```bash
ds                       # asks tool + scope + skills
ds ~/my-project          # asks tool + skills (scope auto = project)
```

### Flag mode (skip wizard, scriptable)

```bash
ds --tool=claude    --scope=user    --all                    # global Claude
ds --tool=opencode  --scope=project ~/my-project --all       # OpenCode in project
ds --tool=codex     --scope=user    --all                    # Codex CLI global
ds --tool=universal --scope=user    --all                    # write once, read by 3
ds ~/my-project change-safety mobile-design                  # specific skills
```

### Agent install (per-tool)

```bash
ds agent                       # asks tool (Claude / OpenCode / both)
ds agent --tool=claude         # ~/.claude/agents/dublin-agent.md
ds agent --tool=opencode       # ~/.config/opencode/agents/dublin-agent.md
ds agent --tool=universal      # both Claude + OpenCode
# Codex CLI does not support agents (uses AGENTS.md instead)
```

### Other commands

```bash
ds list                        # list available skills (no install)
ds update <path>               # update skills already installed in <path>
ds --help                      # full usage
```

## What are Skills?

Skills are structured prompts with detailed instructions, code patterns, and references that Claude Code can use for specialized tasks. Each skill includes:

- **When to use it** — Context and use cases
- **How it works** — Methodology and principles
- **Reference code** — Ready-to-use implementations
- **Anti-patterns** — What to avoid

## Available Skills

| Skill | Description |
|-------|-------------|
| **[skill-creator](skills/skill-creator)** | Guide for creating effective skills that extend Claude's capabilities |
| **[brand-identity](skills/brand-identity)** | Brand identity systems: color palettes, typography, spacing, UX principles |
| **[brand-guidelines](skills/brand-guidelines)** | Anthropic brand colors, typography, and visual styling |
| **[frontend-foundation](skills/frontend/frontend-foundation)** | Day-0 frontend architecture: dual theme (dark + light), spacing system, mobile-first with content priority, CLS Zero, icon budget, design contract (DESIGN.md), component layer on headless primitives (Base UI/Radix) |
| **[mobile-design](skills/frontend/mobile-design)** | Mobile as a first-class surface — kills horizontal overflow, picks mobile-native patterns (bottom sheet, FAB, swipe, sticky CTA, segmented control), thumb-zone ergonomics, touch targets, fluid type, mobile form config (inputMode, autoComplete, font-size 16). Defines the Shrunk Desktop AI Tell |
| **[mobile-app-foundation](skills/mobile/mobile-app-foundation)** | Day-0 architecture for CROSS-PLATFORM apps (React Native + Expo) — one codebase → iOS + Android + web. expo-router structure, NativeWind dual theme, FlashList + offline-first cache, dev builds vs Expo Go, EAS Build, store submission, static web export to a VPS, OTA updates. Documents the modules that fail *silently* on web (`expo-secure-store`, `Alert.alert`). Names the AI Tells (Web Brain, ScrollView Graveyard, Notch Blind, Keyboard Eater, Expo Go Mirage, Version Roulette, Store Surprise, Offline Amnesia, One-Target Tell). Ships a runnable boilerplate |
| **[premium-frontend-design](skills/frontend/premium-frontend-design)** | Apple/Framer-quality React/Next.js interfaces: glass effects, gradients, micro-interactions, named AI Tells (LILA BAN, Inter Tell, Icon Soup, Mobile Afterthought, Layout Shift Sloppy, Filler Word Index) |
| **[frontend-output-validator](skills/frontend/frontend-output-validator)** | Review gate AFTER frontend implementation — validates contrast (WCAG), CLS sources, icon budget, touch targets, mobile-first compliance, viewport meta, forbidden AI Tells, DESIGN.md contract drift. Layer 1 static + Layer 2 Lighthouse |
| **[product-tour](skills/frontend/product-tour)** | Interactive product tours and onboarding flows for Next.js: guided walkthroughs, activation checklists, welcome modals |
| **[react-performance](skills/frontend/react-performance)** | React/Next.js performance optimization: useEffect elimination, rendering, RSC, bundle analysis |
| **[backend-performance](skills/backend/backend-performance)** | Backend performance audit: N+1 queries, async/event loop, caching (Redis/HTTP/CDN), connection pooling, payload shape, rate limiting, OpenTelemetry tracing |
| **[hexagonal-architect](skills/architecture/hexagonal-architect)** | Hexagonal architecture (ports & adapters) for NestJS |
| **[api-architect](skills/architecture/api-architect)** | Senior API architect — designs or audits scalable, reliable, secure, observable APIs (REST/GraphQL/gRPC) with rationale per decision |
| **[domain-modeler](skills/architecture/domain-modeler)** | Domain modeling with DDD: entities, value objects, aggregates |
| **[github-safety](skills/github/github-safety)** | Safe Git/GitHub workflow: prevents force push, history rewriting, destructive operations |
| **[git-workflow](skills/github/git-workflow)** | Team Git workflow (constructive): Conventional Commits + commitlint, branch strategy, PR template + size limits, conflict/rebase rules, husky hooks, CODEOWNERS, branch protection. Names 4 AI Tells: Garbage Commit, Frankenstein PR, Eternal Branch, History Bomb. Enforcement runs LOCAL — zero LLM tokens at runtime |
| **[change-safety](skills/ops/change-safety)** | Pre-flight guardrail before any prod write — snapshot, rollback plan, stakeholder comms, in-flight transaction check, change window. Auto-invokes on ALTER/DROP/UPDATE/DELETE, store/CMS edits, deploys, env rotation, DNS/TLS/IAM changes |
| **[sdd-workflow](skills/methodology/sdd-workflow)** | Spec-Driven Development orchestration — proposal → specs → design → tasks → apply → verify → archive. Triggers, commands, artifact store policy (Engram/OpenSpec/none), sub-agent launching templates |
| **[tdd-workflow](skills/implementation/tdd-workflow)** | Test-driven development: red-green-refactor |
| **[testing-strategy](skills/implementation/testing-strategy)** | WHAT to test, at which layer, with which tool — pyramid, doubles, integration, E2E, contract tests |
| **[error-handling](skills/implementation/error-handling)** | Error taxonomy, Problem Details (RFC 7807), structured logging, Error Boundaries, retry/backoff |
| **[auth-architect](skills/security/auth-architect)** | Authentication + authorization design/audit: OAuth, JWT vs sessions, RBAC/ABAC, passkeys, common vulnerabilities |
| **[database-architect](skills/data/database-architect)** | Postgres-first schema design, zero-downtime migrations, indexes, N+1, RLS, Prisma/Drizzle/Kysely |
| **[forms-and-validation](skills/frontend/forms-and-validation)** | Production forms with React Hook Form + Zod — multi-step, async validation, file upload, a11y, Server Actions |
| **[orchestrator](skills/meta/orchestrator)** | Skill Orchestrator / Router — analyzes installed skills, evaluates opportunity cost, resolves dependencies, emits ordered execution plan + task list |
| **[claude-md-keeper](skills/meta/claude-md-keeper)** | Keeps CLAUDE.md aligned with reality. Detects drift (package.json, filesystem, git log, skills). NEVER auto-writes — always proposes diff for review |
| **[session-bridge](skills/meta/session-bridge)** | SESSION.md for session-to-session continuity. Hard caps (300 lines, 72h). Secret scanner. Marks promotion candidates for claude-md-keeper |
| **[product-planner](skills/product/product-planner)** | Product planning: PRDs, user stories, MVP scoping |
| **[product-ux-advisor](skills/product/product-ux-advisor)** | UX audit that diagnoses missing or critical patterns — onboarding, wizards, empty states, activation flows |
| **[systems-thinking](skills/discovery/systems-thinking)** | Systems analysis: feedback loops, leverage points |
| **[bind-api](skills/bind-api)** | BIND Argentina API integration (Open Banking) |
| **[infra-security](skills/infra-security)** | Infrastructure architect and security specialist — AWS, VPS, Azure, AI-as-a-Service, Docker cleanup & disk hygiene |
| **[blog-writer](skills/content/blog-writer)** | Professional blog posts in English/Spanish — no hype, no fluff |
| **[landing-page-architect](skills/content/landing-page-architect)** | Conversion-optimized landing page blueprints (copy + structure) — hands off to product-ux-advisor + premium-frontend-design |
| **[institutional-site-architect](skills/content/institutional-site-architect)** | Multi-page institutional / corporate site blueprints — sitemap, IA, brand voice, trust strategy, per-page copy direction for B2B SaaS, agencies, law firms, VC, nonprofits, personal brands |
| **[data-viz-architect](skills/data/data-viz-architect)** | Dashboard + data viz architect — picks chart type per business question WITH the reason, KPI hierarchy, layout, library, data fetching strategy |
| **[remotion-video](skills/media/remotion-video)** | Programmatic video generation from React components with Remotion |
| **[ugc-scriptwriter](skills/ugc/ugc-scriptwriter)** | UGC video scripts for AI avatar delivery: 10 ad angles, hook engineering, per-platform pacing, ES/EN, shoot-ready tables |
| **[ai-avatar-director](skills/ugc/ai-avatar-director)** | Vendor-agnostic director brief for AI avatar video generation: casting, wardrobe, setting, framing, voice — works with HeyGen / Hedra / Akool / Arcads / Synthesia |
| **[ugc-post-production](skills/ugc/ugc-post-production)** | Edit Decision List for UGC cuts: captions, visual hooks, B-roll, music, SFX — every effect earns its place or gets cut |
| **[ugc-video-prompting](skills/ugc/ugc-video-prompting)** | Text-to-video / image-to-video prompts for Veo 3 and Seedance 2.0 that produce UGC-style content: phone feel, natural light, negative-prompt boilerplate, character consistency pack |

## Installation

The installer (`./install.sh` or the global `ds` symlink) is multi-tool — see the [Multi-tool support](#multi-tool-support) section above for full details.

Quick reference:

```bash
# Interactive wizard (asks tool + scope + skills)
./install.sh /path/to/your/project

# All skills, default tool (Claude Code)
./install.sh /path/to/your/project --all

# All skills for OpenCode
./install.sh /path/to/your/project --tool=opencode --all

# Universal mode (visible to Claude / OpenCode / Codex at once)
./install.sh /path/to/your/project --tool=universal --all

# Specific skills
./install.sh /path/to/your/project tdd-workflow domain-modeler premium-frontend-design
```

The installer creates the target directory automatically if it does not exist.

### Available skills for installation

```
ai-avatar-director    api-architect         auth-architect
backend-performance   bind-api              blog-writer
brand-guidelines      brand-identity        change-safety
claude-md-keeper      database-architect    data-viz-architect
domain-modeler        error-handling        forms-and-validation
frontend-foundation   frontend-output-validator
git-workflow          github-safety         hexagonal-architect
infra-security
institutional-site-architect                landing-page-architect
mobile-app-foundation mobile-design         orchestrator
premium-frontend-design
product-planner       product-tour          product-ux-advisor
react-performance
remotion-video        sdd-workflow          session-bridge
skill-creator         systems-thinking      tdd-workflow
testing-strategy      ugc-post-production   ugc-scriptwriter
ugc-video-prompting
```

### Global command (recommended)

Create a symlink to use `dublin-skill-install` from anywhere:

```bash
sudo ln -sf /path/to/dublin-skills/install.sh /usr/local/bin/dublin-skill-install
```

Then use from any project:

```bash
cd my-project
dublin-skill-install .        # Interactive mode
dublin-skill-install . --all  # Install all skills
```

### Updating skills

Update previously installed skills to their latest versions:

```bash
cd my-project
dublin-skill-install update   # Updates all installed skills
```

The installer automatically detects your system language (`LANG` environment variable) and displays messages in Spanish or English.

### Installing the dublin-agent

The repo also ships the **dublin-agent** — a senior-architect mentor agent (`agents/dublin-agent.md`) that auto-detects this skills library and delegates to the right skill. Agents are user-scoped, so install once and use from any project.

```bash
ds agent                     # interactive (asks tool: Claude / OpenCode / both)
ds agent --tool=claude       # ~/.claude/agents/dublin-agent.md
ds agent --tool=opencode     # ~/.config/opencode/agents/dublin-agent.md
ds agent --tool=universal    # installs in BOTH Claude and OpenCode dirs
```

Codex CLI does not have a separate "agent" concept (it uses `AGENTS.md` for instructions), so the agent file is not installed there — but Codex *does* read skills from `~/.agents/skills/`, so the skills work end-to-end via Universal mode.

If you already have a `dublin-agent.md` at the target location, the installer creates a timestamped backup before overwriting. After installing, invoke it from Claude Code with `Task(subagent_type: 'dublin-agent')` or the `/dublin` command. From OpenCode, invoke via the agent name `dublin-agent`.

## Usage

### With Claude Code

Load the skill as context at the start of your conversation:

```
Read skills/frontend/premium-frontend-design/SKILL.md and its references
```

### Prompt Cheat Sheets

Each skill has a prompt file in `prompts/` with activation examples:

```
prompts/
├── api-architect.md
├── backend-performance.md
├── bind-api.md
├── blog-writer.md
├── brand-guidelines.md
├── brand-identity.md
├── change-safety.md
├── data-viz-architect.md
├── auth-architect.md
├── claude-md-keeper.md
├── database-architect.md
├── domain-modeler.md
├── error-handling.md
├── forms-and-validation.md
├── frontend-foundation.md
├── git-workflow.md
├── orchestrator.md
├── hexagonal-architect.md
├── infra-security.md
├── institutional-site-architect.md
├── landing-page-architect.md
├── mobile-app-foundation.md
├── mobile-design.md
├── premium-frontend-design.md
├── product-planner.md
├── product-tour.md
├── product-ux-advisor.md
├── react-performance.md
├── remotion-video.md
├── skill-creator.md
├── sdd-workflow.md
├── session-bridge.md
├── systems-thinking.md
├── tdd-workflow.md
├── testing-strategy.md
├── ugc-scriptwriter.md
├── ai-avatar-director.md
├── ugc-post-production.md
└── ugc-video-prompting.md
```

Use these as quick reference for how to invoke each skill.

### Skill Structure

```
skills/
└── [skill-name]/
    ├── SKILL.md           # Main instructions
    ├── scripts/           # Executable code (Python/Bash/etc.)
    ├── references/        # Documentation loaded as needed
    └── assets/            # Files used in output (templates, icons, etc.)
```

## Creating a New Skill

Use the **skill-creator** skill for guidance, or follow this structure:

1. Create a folder for your skill
2. Add a `SKILL.md` with frontmatter:

```yaml
---
name: skill-name
description: Short description of when to use this skill
---

# Skill Name

[Detailed content...]
```

3. Add optional resources:
   - `scripts/` — Executable code for deterministic tasks
   - `references/` — Documentation to load as needed
   - `assets/` — Templates, images, or files for output

## Categories

- **architecture** — Software architecture patterns
- **backend** — Backend performance, runtime, observability
- **content** — Writing and content creation
- **data** — Data visualization and dashboards
- **discovery** — Problem analysis and exploration
- **frontend** — Interface development
- **github** — Git/GitHub workflow safety
- **implementation** — Development practices
- **media** — Video and multimedia generation
- **ops** — Production operations safety (rollbacks, change management)
- **product** — Product planning
- **ugc** — AI UGC pipeline (script → avatar direction → post-production)

## License

MIT
