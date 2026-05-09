# Trigger → Skill Map (full)

Inline in the agent prompt: the top 10-15 most-used. Full table here.

| User signal / phrase | Skill to invoke |
|---|---|
| "sdd init", "sdd new", "sdd ff", "sdd apply", "sdd verify", "sdd archive", "implementar feature grande", "refactor multi-archivo" | `sdd-workflow` |
| "diseñar/auditar API", "REST", "GraphQL", "gRPC", "endpoints" | `api-architect` |
| "schema DB", "migration", "postgres", "indexes", "query lenta", "N+1" | `database-architect` |
| "auth", "login", "JWT", "sessions", "RBAC", "OAuth", "passkeys" | `auth-architect` |
| "nuevo proyecto frontend", "theming", "dark mode", "spacing system", "sidebar" | `frontend-foundation` |
| "premium UI", "glass effect", "framer motion", "look and feel Apple/Framer" | `premium-frontend-design` |
| "formulario", "form validation", "RHF", "zod", "multi-step wizard", "file upload" | `forms-and-validation` |
| "product tour", "onboarding", "walkthrough", "driver.js" | `product-tour` |
| "landing page", "hero", "CTA", "conversion copy" | `landing-page-architect` |
| "institutional site", "sitio corporativo", "about/services/contact" | `institutional-site-architect` |
| "blog post", "write article", "escribir blog" | `blog-writer` |
| "brand identity", "color palette", "typography system" | `brand-identity` |
| "DDD", "domain modeling", "aggregates", "value objects", "domain events" | `domain-modeler` |
| "hexagonal", "ports adapters", "NestJS architecture" | `hexagonal-architect` |
| "UX audit", "missing patterns", "ecommerce flow", "PDP/PLP/checkout" | `product-ux-advisor` |
| "PRD", "user stories", "MVP scoping" | `product-planner` |
| "dashboard", "charts", "data viz", "KPIs", "chart selection" | `data-viz-architect` |
| "error handling", "error boundary", "retry/backoff", "problem details" | `error-handling` |
| "TDD", "red-green-refactor", "test first" | `tdd-workflow` |
| "testing strategy", "qué testear", "pyramid", "integration tests" | `testing-strategy` |
| "AWS", "VPS", "docker", "infra audit", "security audit", "OWASP" | `infra-security` |
| "Remotion", "video generation programática" | `remotion-video` |
| "BIND", "banco industrial", "CVU", "CBU", "DEBIN", "eCheq" | `bind-api` |
| "systems thinking", "feedback loops", "stocks flows", "leverage points" | `systems-thinking` |
| "git force push", "rebase pushed", "reset --hard", "destructive git" | `github-safety` |
| "git workflow", "commit convention", "Conventional Commits", "commitlint", "husky", "pre-commit hook", "PR template", "CONTRIBUTING.md", "branch strategy", "branch protection", "CODEOWNERS", "merge conflict", "stacked PRs", "team git setup" | `git-workflow` |
| "ALTER", "DROP", "TRUNCATE", "UPDATE/DELETE without WHERE", "deploy a prod", "shopify catalog", "rollback plan", "production change" | `change-safety` |
| "CLAUDE.md drift", "update CLAUDE.md", "CLAUDE.md stale" | `claude-md-keeper` |
| "SESSION.md", "session handoff", "continuity across sessions" | `session-bridge` |
| "Anthropic brand", "Claude colors" | `brand-guidelines` |
| "create new skill", "skill for X", "scaffold skill" | `skill-creator` |
| "UGC script", "guion avatar", "ad hook", "TikTok script" | `ugc-scriptwriter` |
| "avatar direction", "casting brief", "HeyGen brief", "wardrobe avatar" | `ai-avatar-director` |
| "Veo 3 prompt", "Seedance prompt", "text to video", "image to video", "negative prompt" | `ugc-video-prompting` |
| "edit ugc", "captions", "B-roll", "EDL", "music sync", "video FX" | `ugc-post-production` |
| "frontend audit", "design audit", "validate UI", "icon count", "contrast check", "CLS audit", "AI tells review" | `frontend-output-validator` |
| "perf audit react", "useEffect", "RSC", "bundle size", "core web vitals" | `react-performance` |
| "perf audit backend", "N+1", "slow query", "event loop", "OpenTelemetry", "p95/p99" | `backend-performance` |

**Ambiguous / multi-domain trigger?** → `Skill(orchestrator)`. It reads the manifest, scores relevance × value / cost, resolves deps, emits phased plan + TaskCreate entries.

## Dublin Dependency Order (respect always)

- `frontend-foundation` → `premium-frontend-design` / `forms-and-validation` / `product-tour` / `landing-page-architect`
- `domain-modeler` → `hexagonal-architect` / `api-architect`
- `database-architect` → `auth-architect`
- `product-ux-advisor` between foundation and polish
- `infra-security` pre-launch
- `change-safety` BEFORE any prod write (cuts across all)
- UGC pipeline: `ugc-scriptwriter` → (`ai-avatar-director` | `ugc-video-prompting`) → `ugc-post-production`

If the user asks for a downstream skill without the foundation, say so and offer to do foundation first.

## Approval Gates (SKILLS MODE)

| Gate | Policy |
|---|---|
| Before first skill launches | ALWAYS — show plan, ask OK |
| Between skills (non-ff) | ALWAYS — show summary, ask continue |
| `/sdd-ff` batched phases | ONE gate at the end |
| Destructive (migrations, refactors > 10 files, deletes) | ALWAYS |
| Pre-prod-write triggers | ALWAYS — invoke `change-safety` first |
| Additive (new file, new function) | Skip unless user asked for manual mode |
| User said "auto-approve" at start | Skip intermediate, only stop on failure or destructive |
