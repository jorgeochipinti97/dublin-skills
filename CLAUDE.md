# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Claude Code skills library** — a collection of specialized prompts, reference materials, and code templates that extend Claude Code's capabilities in specific domains.

## Structure

```
skills/
├── architecture/
│   ├── api-architect/        # Scalable/reliable/secure API design or audit (REST/GraphQL/gRPC)
│   │   └── references/       # design.md, security.md, scalability.md, reliability.md, observability.md
│   ├── domain-modeler/       # DDD patterns: entities, value objects, aggregates, domain events
│   └── hexagonal-architect/  # Ports & adapters architecture for NestJS
├── content/
│   ├── blog-writer/          # Professional blog posts in English/Spanish
│   ├── institutional-site-architect/  # Multi-page corporate / institutional site blueprints (sitemap, IA, brand voice, trust)
│   │   └── references/       # information-architecture.md, brand-voice.md, page-anatomy.md, trust-authority.md, org-types.md
│   └── landing-page-architect/  # Conversion-optimized landing page blueprints (copy + structure)
│       └── references/       # copywriting-theory.md, landing-fundamentals.md, conversion-by-goal.md
├── data/
│   └── data-viz-architect/   # Dashboard + data viz architect — chart selection with WHY, layout, libraries
│       └── references/       # chart-selection.md, dashboard-design.md, data-from-api.md, libraries.md
├── discovery/
│   └── systems-thinking/     # System analysis: feedback loops, leverage points, stocks/flows
├── frontend/
│   ├── premium-frontend-design/  # Apple/Framer-quality UI with glass effects, gradients, animations
│   │   └── references/           # Code libraries for effects, typography, motion, anti-patterns
│   ├── product-tour/             # Interactive product tours & onboarding flows for Next.js
│   │   └── references/           # onboarding-patterns.md, accessibility.md, implementation-examples.md
│   └── react-performance/        # React/Next.js performance: useEffect elimination, RSC, bundle optimization
│       └── references/           # react-patterns.md, nextjs-patterns.md, code-examples.md
├── github/
│   └── github-safety/       # Safe Git workflow: prevents force push, history rewriting, destructive ops
├── implementation/
│   └── tdd-workflow/         # Red-green-refactor cycle, test patterns, AAA structure
│       └── references/       # examples.md
├── media/
│   └── remotion-video/       # Programmatic video generation with Remotion + React
├── product/
│   ├── product-planner/      # PRDs, user stories (Given/When/Then), MVP scoping
│   └── product-ux-advisor/   # UX audit: diagnoses missing patterns (onboarding, wizards, e-commerce)
│       └── references/       # patterns.md, examples.md, ecommerce.md
├── bind-api/                 # BIND Argentina Open Banking API integration
│   ├── references/           # Full API documentation
│   └── scripts/              # TypeScript client implementation
├── infra-security/           # Infrastructure architect + cybersecurity specialist
│   └── references/           # aws.md, ai-infra.md, vps.md, security.md, architecture.md, azure.md
└── skill-creator/            # Guide for creating new skills
    └── references/           # design-philosophy.md, creation-process.md
```

## Skill File Convention

Each skill has a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: When and how to use this skill
---
```

The description field tells Claude when to invoke the skill.

## Key Skills

### premium-frontend-design
Creates luxury React/Next.js interfaces with:
- Glass morphism, mesh gradients, aurora backgrounds
- Framer Motion animations with specific easing curves
- Typography: distinctive font pairings, -0.02em to -0.05em tracking on headlines
- Anti-patterns to avoid (v0-style purple-blue gradients, cramped padding, uniform border-radius)

Reference files in `references/` contain complete CSS/React code for all effects.

### react-performance
Audits and optimizes React/Next.js applications:
- useEffect elimination (derived state, event handlers, key prop reset)
- React Compiler (React 19+) vs manual memoization strategy
- Server Components decision tree, 'use client' boundary placement
- Bundle optimization (dynamic imports, barrel files, tree shaking)
- Data fetching patterns (React.cache, preloading, waterfall avoidance)

Reference files: `react-patterns.md` (rendering, memoization), `nextjs-patterns.md` (RSC, caching, CWV).

### product-tour
Builds interactive product tours and onboarding flows for Next.js:
- Library selection: Driver.js (recommended, 5KB), NextStep.js (multi-page tours)
- Guided walkthroughs with DOM element highlighting
- Onboarding patterns: activation checklists, welcome modals, progress tracking
- Complex interaction tours (file uploads, form wizards, action-gated steps)
- Accessibility: focus management, screen readers, keyboard nav, reduced motion

Reference files: `onboarding-patterns.md` (checklists, modals, beacons), `accessibility.md` (WCAG, focus traps, ARIA).

### github-safety
Prevents destructive Git operations:
- Absolute prohibitions: force push, rebase on pushed branches, reset --hard, amend pushed commits, --no-verify
- Required practices: new commits over rewrites, feature branches, verify before push
- Emergency protocol: STOP → show status → explain → propose → wait for confirmation

### hexagonal-architect
Structures NestJS projects with:
- Domain layer (entities, value objects, domain events)
- Application layer (ports/interfaces, use cases)
- Infrastructure layer (adapters: REST controllers, repositories)

Dependency rule: Domain → Application → Infrastructure (dependencies point inward).
Reference files: `implementation-patterns.md` (ports, use cases, adapters, module wiring, tests).

### domain-modeler
Models business logic using DDD:
- Entities (identity matters) vs Value Objects (immutable, defined by attributes)
- Aggregates (consistency boundaries with a root entity)
- Domain Events (past tense, immutable records of what happened)

### tdd-workflow
Guides test-driven development:
- Red (failing test) → Green (minimal code) → Refactor
- AAA pattern: Arrange, Act, Assert
- Test doubles: Stubs (return values), Mocks (verify interactions), Fakes (simplified implementations)

### bind-api
Integration with BIND Argentina Open Banking sandbox:
- OAuth 2.0 Direct Login authentication
- Endpoints: accounts, transfers, DEBIN, eCheqs, CBU/CVU validation
- TypeScript client in `scripts/bind_client.ts`

### infra-security
Senior infrastructure architect + cybersecurity specialist:
- AWS-first (EC2, ECS, Lambda, Bedrock, VPC, IAM, cost optimization)
- AI as a Service patterns: agent platforms, vLLM, vector DBs, Bedrock deep dive
- VPS hardening: nginx, SSL, SSH, Docker, firewall
- Security audits: OWASP, WAF, IAM policies, incident response
- Architecture from scratch: tiered cost/complexity options, HA, DR, anti-patterns

### product-ux-advisor
Product UX consultant that audits web products and diagnoses missing patterns:
- Prioritized diagnosis: Critical / Recommended / Polish
- SaaS patterns: onboarding, wizards, empty states, activation checklists, command palette
- E-commerce patterns: PDP (gallery, reviews, variants, notify OOS), PLP, cart, checkout
- Real-world references: Linear, Vercel, Stripe, Notion, Zara, ASOS, Amazon
- Pairs with `premium-frontend-design` for implementation

## Working with This Repository

When adding or modifying skills:

1. **SKILL.md structure**: Start with frontmatter (`name`, `description`), then detailed instructions
2. **Reference files**: Put reusable code/templates in a `references/` subdirectory
3. **Anti-patterns**: Document what NOT to do — this is as important as the positive guidance
4. **Output standards**: Specify the expected format (complete code, types, specific patterns)
5. **Update install.sh**: Add new skills to the `SKILLS` array in `install.sh` (alphabetical order)
6. **Update README.md**: Add to the "Available Skills" table and "Available skills for installation" list

When using skills in other projects, load the SKILL.md and relevant reference files as context.
