# Orchestrator — Scoring Examples

Worked examples of how to score and order skills for representative tasks.

> **Source of truth:** `skills.manifest.json`. The graph below is generated from its `depends_on` field — never hand-edit; regenerate when the manifest changes.

## Dependency Graph (generated from manifest)

Hard dependencies (must run before):

```
product-planner
  ├──► domain-modeler
  │       ├──► hexagonal-architect  ──► api-architect
  │       └──► database-architect   ──► auth-architect
  ├──► product-ux-advisor
  └──► data-viz-architect

frontend-foundation
  ├──► premium-frontend-design
  ├──► forms-and-validation
  └──► product-tour
```

Soft orchestration (not hard deps, but strongly recommended order):

- `systems-thinking` → `product-planner` (when the domain is complex)
- `landing-page-architect` → `premium-frontend-design` (polish after structure)
- `brand-identity` → `premium-frontend-design`
- `session-bridge` → `claude-md-keeper` (promotion flow)

Root skills with no deps:
`systems-thinking`, `product-planner`, `frontend-foundation`, `error-handling`, `testing-strategy`, `tdd-workflow`, `sdd-workflow`, `react-performance`, `landing-page-architect`, `institutional-site-architect`, `blog-writer`, `remotion-video`, `infra-security`, `github-safety`, `bind-api`, `brand-identity`, `brand-guidelines`, `skill-creator`, `claude-md-keeper`, `session-bridge`, `orchestrator`.

Cross-cutting (woven into every phase, not tacked on):
- `testing-strategy` — every layer has tests
- `error-handling` — every layer handles errors
- `tdd-workflow` — red-green-refactor
- `github-safety` — commit discipline
- `react-performance` — audit after build
- `infra-security` — before shipping

## Example 1 — "Build a B2B SaaS MVP for project management"

### Task analysis
- Verb: build new → full stack
- Domain: B2B SaaS → multi-tenant, auth, complex domain
- Deliverables: frontend + backend + db + auth + basic ops

### Scored skills

| Skill | Relevance | Reason |
|---|---|---|
| product-planner | 10 | MVP requires PRD, scoping |
| systems-thinking | 8 | B2B domain benefits from systems analysis |
| domain-modeler | 9 | Project/Task/Member/Organization aggregates |
| database-architect | 10 | Multi-tenant schema is the backbone |
| auth-architect | 10 | Multi-tenant B2B = SSO readiness, RBAC |
| hexagonal-architect | 8 | NestJS layering for a non-trivial domain |
| api-architect | 7 | REST/GraphQL choice matters |
| frontend-foundation | 10 | Non-negotiable day 0 |
| product-ux-advisor | 9 | SaaS = onboarding, activation, empty states |
| premium-frontend-design | 7 | Quality polish |
| forms-and-validation | 9 | Every SaaS is forms |
| product-tour | 8 | B2B onboarding is critical |
| error-handling | 9 | Multi-tenant requires clean error boundaries |
| testing-strategy | 9 | Can't ship MVP without |
| infra-security | 8 | Before shipping |

### Skipped

| Skill | Reason |
|---|---|
| blog-writer | No content output in MVP |
| remotion-video | No video needed |
| bind-api | Not Argentine banking |
| landing-page-architect | MVP is app, not marketing site (yet) |
| institutional-site-architect | Same reason |
| data-viz-architect | Dashboards come post-MVP |

### Execution order

**Phase 1 — Discovery (days 1-2)**
1. systems-thinking (map the domain)
2. product-planner (PRD, MVP scope)

**Phase 2 — Domain + Data (days 3-5)**
3. domain-modeler (Project, Task, Organization aggregates)
4. database-architect (schema with tenant_id + RLS)

**Phase 3 — Backend Architecture (days 6-10)**
5. hexagonal-architect (NestJS layout)
6. auth-architect (Better-Auth or custom + RBAC)
7. api-architect (REST, Problem Details, rate limits)
8. error-handling (taxonomy + filter + logging)

**Phase 4 — Frontend Foundation (days 11-12)**
9. frontend-foundation (tokens, theme, spacing, component system)

**Phase 5 — UX + UI (days 13-20)**
10. product-ux-advisor (check missing patterns)
11. premium-frontend-design (polish)
12. forms-and-validation (auth + core entity forms)
13. product-tour (onboarding walkthrough)

**Phase 6 — Quality gate (throughout + day 21)**
14. testing-strategy (unit + integration + 3-5 E2E)
15. react-performance (audit after feature complete)

**Phase 7 — Ship (day 22)**
16. infra-security (AWS/VPS setup, WAF, secrets)

---

## Example 2 — "Add a Stripe checkout flow to this app"

### Task analysis
- Verb: add feature → incremental
- Domain: payments → money, errors, webhooks
- Deliverable: one flow

### Scored skills

| Skill | Relevance | Reason |
|---|---|---|
| database-architect | 8 | Orders/subscriptions schema, idempotency keys |
| api-architect | 7 | Webhook endpoint design, idempotency |
| error-handling | 10 | Payment errors are the whole game |
| forms-and-validation | 9 | Checkout form is the UX |
| product-ux-advisor | 8 | Cart/checkout patterns (e-commerce) |
| premium-frontend-design | 6 | Checkout deserves polish |
| frontend-foundation | 5 | Assumed already set up (invoke only if not) |
| testing-strategy | 10 | Payment paths MUST be tested |
| auth-architect | 3 | Only if not already in place |
| infra-security | 6 | Webhook signature verification, secrets |

### Skipped
systems-thinking, product-planner, domain-modeler (the domain is narrow and standard), product-tour, landing-page-architect, blog-writer, etc.

### Execution order

**Phase 1 — Contract**
1. database-architect (orders, payments, idempotency_keys tables)
2. api-architect (webhook endpoint, retries, idempotency)

**Phase 2 — Implementation**
3. error-handling (payment error taxonomy: card_declined, insufficient_funds, etc.)
4. forms-and-validation (checkout form)
5. product-ux-advisor (checkout UX patterns)
6. premium-frontend-design (polish)

**Phase 3 — Shipping**
7. testing-strategy (mock Stripe + real checkout session tests)
8. infra-security (webhook signature, secret rotation)

---

## Example 3 — "Audit this repo for missing engineering"

### Task analysis
- Verb: audit → diagnostic only, no build
- No artifact, just analysis

### Scored skills (as lenses)

| Skill | Use as lens |
|---|---|
| react-performance | useEffect abuse, RSC misuse, bundle bloat |
| product-ux-advisor | missing UX patterns |
| testing-strategy | pyramid inverted? mocks everywhere? no integration? |
| error-handling | swallowed catches, stack traces to users, no taxonomy |
| auth-architect | session fixation, token storage, rate limits |
| database-architect | missing indexes, N+1, soft-delete-everywhere |
| infra-security | OWASP, secrets in env files, etc. |

### Execution order

All skills run as **audit lenses in parallel** — each returns a prioritized diagnosis (Critical / Recommended / Polish). Orchestrator consolidates into a single ranked report.

---

## Example 4 — "Write a blog post about our new feature"

### Task analysis
- Single-skill task
- No planning needed

### Output
Orchestrator **declines to plan** and hands off directly: "This is a single-skill task. Invoke `blog-writer` directly."

---

## Example 5 — Validate user's existing plan

User says: "I want to build this in order: 1) premium-frontend-design, 2) forms-and-validation, 3) auth-architect"

### Orchestrator's response

```markdown
### Validation

**Issues:**
1. `premium-frontend-design` BEFORE `frontend-foundation` — violates dependency.
   Polish before base = rework + theming retrofit.
2. `auth-architect` LAST — but forms for login/signup depend on auth primitives
   (session provider, CSRF, etc.)
3. Missing: `database-architect` — auth needs user/session tables before code.
4. Missing: `error-handling` — surfacing server errors inline in forms needs the taxonomy first.

**Recommended order:**
1. frontend-foundation
2. database-architect
3. auth-architect
4. error-handling
5. forms-and-validation
6. premium-frontend-design (polish pass last)

**Kept from your plan:** forms-and-validation, auth-architect, premium-frontend-design.
**Added:** frontend-foundation, database-architect, error-handling.
**Reordered:** all three of your original items.
```

---

## Opportunity Cost Quick Table

| Skill | Approx tokens (SKILL.md only) | Invoke cost | Invoke value |
|---|---|---|---|
| systems-thinking | ~3k | Low | High (if complex domain) |
| product-planner | ~3k | Low | High (any new product) |
| domain-modeler | ~3k | Low | High (any non-CRUD domain) |
| database-architect | ~8k | Medium | Very high (schema decisions stick) |
| auth-architect | ~6k | Medium | Very high (hard to retrofit) |
| frontend-foundation | ~5k | Medium | Very high (non-negotiable) |
| premium-frontend-design | ~3k + refs 10k | Medium | Medium (polish) |
| product-ux-advisor | ~3k + refs 5k | Medium | High (catches gaps) |
| forms-and-validation | ~5k | Medium | High (every form) |
| error-handling | ~8k | Medium | High (saves debugging time) |
| testing-strategy | ~6k | Medium | High (but pays off late) |
| infra-security | ~4k + refs 15k | High | High (pre-launch) |

Rule of thumb: if `value / cost < 2`, skip and note as optional.
