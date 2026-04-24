# Dublin Skills

A collection of skills for [Claude Code](https://claude.ai/code) that extend its capabilities in specific domains.

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
| **[frontend-foundation](skills/frontend/frontend-foundation)** | Day-0 frontend architecture: dual theme (dark + light) from start, spacing system, reusable component layer on headless primitives (Base UI/Radix) |
| **[premium-frontend-design](skills/frontend/premium-frontend-design)** | Apple/Framer-quality React/Next.js interfaces: glass effects, gradients, micro-interactions |
| **[product-tour](skills/frontend/product-tour)** | Interactive product tours and onboarding flows for Next.js: guided walkthroughs, activation checklists, welcome modals |
| **[react-performance](skills/frontend/react-performance)** | React/Next.js performance optimization: useEffect elimination, rendering, RSC, bundle analysis |
| **[backend-performance](skills/backend/backend-performance)** | Backend performance audit: N+1 queries, async/event loop, caching (Redis/HTTP/CDN), connection pooling, payload shape, rate limiting, OpenTelemetry tracing |
| **[hexagonal-architect](skills/architecture/hexagonal-architect)** | Hexagonal architecture (ports & adapters) for NestJS |
| **[api-architect](skills/architecture/api-architect)** | Senior API architect — designs or audits scalable, reliable, secure, observable APIs (REST/GraphQL/gRPC) with rationale per decision |
| **[domain-modeler](skills/architecture/domain-modeler)** | Domain modeling with DDD: entities, value objects, aggregates |
| **[github-safety](skills/github/github-safety)** | Safe Git/GitHub workflow: prevents force push, history rewriting, destructive operations |
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

Install skills into any project's `.claude/skills/` directory:

```bash
# Interactive mode (select from menu)
./install.sh /path/to/your/project

# Install all skills
./install.sh /path/to/your/project --all

# Install specific skills
./install.sh /path/to/your/project tdd-workflow domain-modeler premium-frontend-design
```

The installer will create `.claude/skills/` if it doesn't exist.

### Available skills for installation

```
ai-avatar-director    api-architect         auth-architect
backend-performance   bind-api              blog-writer
brand-guidelines      brand-identity        claude-md-keeper
database-architect    data-viz-architect    domain-modeler
error-handling        forms-and-validation  frontend-foundation
github-safety         hexagonal-architect   infra-security
institutional-site-architect                landing-page-architect
orchestrator          premium-frontend-design                product-planner
product-tour          product-ux-advisor    react-performance
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
├── data-viz-architect.md
├── auth-architect.md
├── claude-md-keeper.md
├── database-architect.md
├── domain-modeler.md
├── error-handling.md
├── forms-and-validation.md
├── frontend-foundation.md
├── orchestrator.md
├── hexagonal-architect.md
├── infra-security.md
├── institutional-site-architect.md
├── landing-page-architect.md
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
- **product** — Product planning
- **ugc** — AI UGC pipeline (script → avatar direction → post-production)

## License

MIT
