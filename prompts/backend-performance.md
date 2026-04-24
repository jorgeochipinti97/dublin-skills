---
description: Audit and optimize backend performance — N+1 queries, blocking event loop, caching (Redis/HTTP/CDN), connection pooling, payload shape, rate limiting, OpenTelemetry tracing, SLO/error budgets.
---

Activate the backend-performance skill for this task. Read the SKILL.md and relevant reference files before proceeding.

## Example Activations

- "Audit this endpoint for performance issues"
- "This query is slow, help me find out why"
- "Is there an N+1 in this code?"
- "How should I cache this read path?"
- "Add Redis caching with stampede protection"
- "Do we have an event loop blocking problem here?"
- "Set up OpenTelemetry tracing in this NestJS app"
- "Review our rate limiting strategy"
- "Why is our p95 latency climbing?"
- "Help me size the Postgres connection pool"
- "Should this be streaming instead of a single JSON response?"
- "Add RED metrics per route and expose /metrics"
- "We're burning through our error budget — where should I look?"

## Typical Workflow

1. **Measure first** — what do the traces / metrics say? Don't optimize blind
2. **Queries** — run EXPLAIN, look for N+1, check index coverage
3. **Async & I/O** — event loop lag, blocking crypto, unbounded Promise.all
4. **Caching** — what's cacheable, TTL, stampede protection
5. **Payload shape** — overfetching, compression, streaming
6. **Observability** — make sure the next regression is visible

## Hand-offs

- Schema/index design → `database-architect`
- Error taxonomy / retry / circuit breaker / Sentry → `error-handling`
- Infrastructure / WAF / CDN / cost optimization → `infra-security`
