# Activate change-safety skill

Use when about to write to production: DB schema, DB data, store/CMS, deploy, config, infra.

## Activation prompts

```
Read skills/ops/change-safety/SKILL.md.

Act as the change-safety guardrail.

I am about to: <describe the change in one sentence>
System: <Postgres / Shopify / Vercel / etc.>
Window: <when>

Walk me through the pre-flight checklist. Refuse to clear me until each box is answered.
Output:
1. Pre-flight checklist with answers
2. Rollback plan (trigger / procedure / RTO)
3. Estimated downtime + impact window
4. Go / No-Go verdict
5. Stakeholder comms templates if user-impacting
```

## Example use cases

### Drop a column on a live Postgres table

```
Activate change-safety.

Change: drop column `legacy_status` from `orders` in prod Postgres
Volume: ~12M rows
Window: Tue 03:00 ART
Stack: Neon Postgres, Vercel, NestJS

Run me through the checklist. Include the lock-safe SQL session pattern and a
3-step rename alternative if dropping is not strictly necessary yet.
```

### Bulk update prices in Shopify

```
Activate change-safety.

Change: update prices on ~4,200 SKUs from old tier to new tier in Shopify Plus
Window: Wed 09:30 ART
Customer base: B2C Argentina

Walk me through the export-first protocol, draft channel test, and rollback via
CSV re-import. Flag anything that should pause active checkouts.
```

### Promote a feature flag to 100%

```
Activate change-safety.

Change: feature flag `checkout_v2` from 10% to 100% in prod
Window: Fri 14:00 ART
Stack: Vercel + LaunchDarkly

I want a ramp plan with metrics-per-step, rollback trigger thresholds, and the
exact LaunchDarkly rollback command. Note: prior version writes data the new
version reads. Forward-fix risk?
```

### Deploy a payment provider switch

```
Activate change-safety.

Change: switch payment provider from MP to Stripe in prod
Window: Sun 04:00 ART
Stack: Next.js + NestJS + Postgres

This is a critical change. I want the full pre-flight, dual-running plan,
shadow mode for 48h before cutover, rollback that does not lose in-flight
transactions, and stakeholder comms (customer banner + ops + support).
```

### Rotate database credentials

```
Activate change-safety.

Change: rotate PG password used by 3 services
Stack: Postgres + Fly.io services

Walk me through the dual-secret pattern (deploy reads new var → rotate value →
remove old). Flag any service that might still hold pooled connections on the
old creds.
```

### Refactor a live endpoint that 200k users hit hourly

```
Activate change-safety.

Change: rewrite GET /v1/feed handler with new caching layer
Volume: ~200k req/h, p95 SLA 200ms
Window: weekday off-peak

I want the canary plan, rollback trigger thresholds (error rate, p95, cache
hit), and a forward-fix plan for the case where rolling back loses Redis cache
warmth.
```

## When NOT to use this skill

- Pure dev / staging changes (no prod impact)
- Reading data only (`SELECT`, `GET` reports)
- Adding a new file / function / route that no one is using yet
- Documentation, tests, type annotations, internal tooling

For those, the checklist is overhead. Reserve change-safety for actual prod writes.

## Pairs with

- `database-architect` — Zero-downtime migration patterns
- `github-safety` — Non-destructive git
- `infra-security` — IAM / WAF / network audits
- `error-handling` — Observability that detects rollback triggers fast
