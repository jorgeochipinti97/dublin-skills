---
name: backend-performance
description: Audit and optimize backend performance — Node.js/TypeScript APIs, database access, async I/O, caching, and observability. Use when reviewing backend code for N+1 queries, missing indexes, blocking event loop, missing pagination, overfetching, absent caching (Redis/HTTP/CDN), connection pool issues, payload/serialization overhead, missing streaming, rate limiting gaps, or tracing holes. Runs as a non-destructive review gate after api-architect, hexagonal-architect, database-architect, and auth-architect produce code. Targets Node 20+, Postgres-first, NestJS/Fastify/Express.
---

# Backend Performance

Reduce latency, raise throughput, and keep the event loop healthy. Audit code already written — complements `api-architect` and `database-architect` (design-time) with a post-implementation review pass.

## Audit Workflow

Review in this order (most wins first):

1. **Queries** — N+1, missing indexes, SELECT *, missing pagination, transactions that hold too long
2. **Async & I/O** — blocking event loop, missing streams, sync crypto/JSON on large payloads, parallel vs sequential awaits
3. **Caching** — absent Redis / HTTP cache / CDN, wrong TTLs, cache stampedes
4. **Connection pooling** — pool size, leaks, pgbouncer mode
5. **Payload shape** — overfetching, serialization cost, missing compression, missing streaming for large responses
6. **Rate limiting & backpressure** — absent or global-only limits, missing per-user/per-IP
7. **Observability** — missing tracing, correlation IDs, metrics, SLO alarms

## Queries (usually the biggest win)

| Symptom | Fix |
|---|---|
| Loop with `await repo.findOne(...)` per item | Single `IN (...)` query or `DataLoader` batching |
| `include`/`populate` everything by default | Select only needed fields/relations |
| Missing index on `WHERE`/`ORDER BY`/`JOIN` column | Create B-tree; GIN for JSON/arrays; BRIN for append-only time series |
| Pagination with `OFFSET` on large tables | Keyset (cursor) pagination |
| `SELECT *` crossing the wire | Explicit column list |
| `COUNT(*)` on every list request | Approximate counts or cached counters |
| Long transactions holding row locks | Shorten scope; move non-DB work outside `BEGIN/COMMIT` |
| ORM lazy load inside JSON serialization | Eager-load explicitly; use DTOs |

Delegate to `database-architect` for deep schema/index work. This skill **spots the issue in code**; `database-architect` designs the solution.

See `references/queries.md` for EXPLAIN ANALYZE reading, DataLoader patterns, keyset pagination code, and ORM-specific examples (Prisma / Drizzle / Kysely / TypeORM).

## Async & I/O (Node.js specifics)

Node is single-threaded. One CPU-bound task blocks every request.

| Anti-pattern | Fix |
|---|---|
| `crypto.pbkdf2Sync` / `bcrypt.hashSync` in request path | Async variants (`pbkdf2`, `bcrypt.hash`) |
| `JSON.parse` / `JSON.stringify` on large payloads | Stream parse/stringify (`stream-json`, `JSONStream`); push work to worker thread |
| Sequential `await a(); await b();` with no dependency | `Promise.all([a(), b()])` |
| Reading file into memory with `fs.readFile` then sending | `fs.createReadStream().pipe(res)` |
| Sync zlib / sharp / parse-csv on request thread | Worker thread (`node:worker_threads`) or Piscina |
| `setTimeout(..., 0)` as "fix" for blocking | Fix the blocking work, don't hide it |
| Unbounded parallelism (`await Promise.all(items.map(heavyCall))`) | `p-limit` / Semaphore to cap concurrency |

**Heuristics:**
- If a request handler does CPU work > ~5 ms → move to worker thread
- If a response body > ~1 MB → stream it, don't buffer
- If you await N things inside a loop → probably need `Promise.all` or batching

See `references/async-and-io.md` for worker thread templates, streaming patterns, and concurrency limiters.

## Caching

Decision tree (cheapest → strongest):

1. **HTTP cache headers** (`Cache-Control`, `ETag`) + CDN → public/immutable responses
2. **In-process memo** (`lru-cache`) → small, stable data, single-instance
3. **Redis** → shared across instances, user-scoped data, rate limit counters, session cache
4. **Write-through / Write-behind** → hot counters, feature flags
5. **Stale-while-revalidate** → acceptable staleness, avoids stampede

| Anti-pattern | Fix |
|---|---|
| No cache at all on hot read path | Add Redis with explicit TTL |
| Infinite TTL with no invalidation | Tag-based invalidation or short TTL + SWR |
| Cache stampede (100 clients miss at once → 100 DB hits) | Single-flight / `singleflight`-style coalescing |
| Caching per-user data with global key | Namespace the key (`user:{id}:...`) |
| Caching inside hot loop instead of around it | Move cache lookup to the request boundary |
| No cache hit/miss metrics | Add counters; target ≥ 80% hit rate on hot paths |

See `references/caching.md` for Redis patterns (hash, sorted set, Lua script for atomicity), HTTP cache headers, and CDN strategy.

## Connection Pooling

| Symptom | Fix |
|---|---|
| Timeouts under load, DB CPU low | Pool too small — raise `max` |
| DB shows `idle in transaction` | Missing `COMMIT`/`ROLLBACK`; fix transaction hygiene |
| Serverless / edge runtime exhausting DB connections | PgBouncer in transaction mode; or Neon/Supabase pooler |
| `prisma` / `drizzle` creating new client per request | Module-scoped singleton |
| Long migration blocks pool | Migrations on a separate, small pool |

## Payload & Serialization

- **Overfetching**: don't return the full entity if the client uses 3 fields — ship DTOs
- **Compression**: gzip/brotli on responses > 1 KB (nginx/edge layer ideally)
- **Streaming**: `res.write` chunks for large lists; NDJSON for arrays; SSE for live feeds
- **Binary when it counts**: Protobuf/MessagePack for very high-throughput internal APIs (don't premature-optimize external REST)
- **`toJSON` on ORM entities**: strip sensitive fields at the DTO layer, not `toJSON` (fragile)

## Rate Limiting & Backpressure

| Layer | What to limit | Tool |
|---|---|---|
| Edge / CDN | Obvious abuse, global | Cloudflare, AWS WAF |
| API Gateway | Per-IP coarse | ALB, API Gateway |
| App | Per-user, per-key, per-endpoint | `rate-limiter-flexible` + Redis |
| Auth endpoints | Stricter: login/reset/signup | Per-IP + per-email combination |

Backpressure: if downstream is slow, **return 429/503 quickly** instead of queuing forever. Queue depth alarms + circuit breakers protect the fleet.

## Observability (you can't fix what you can't see)

Non-negotiables for any production backend:

- **Structured JSON logs** (Pino) with `correlationId`, `userId`, `tenantId`, `route`, `durationMs`, `statusCode`
- **Distributed tracing** (OpenTelemetry) — at minimum: HTTP in/out, DB queries, Redis calls, external APIs
- **RED metrics** per route: Rate, Errors, Duration (p50/p95/p99)
- **USE metrics** per dependency: Utilization, Saturation, Errors (DB pool, Redis, event loop lag)
- **SLO + error budget** — define p95 latency target and error rate, alarm when budget burns
- **Event loop lag** — `perf_hooks.monitorEventLoopDelay` or Clinic.js; alarm at > 50 ms p99

Delegate to `error-handling` for structured errors + Sentry. This skill adds **the performance instrumentation layer**.

See `references/observability.md` for OpenTelemetry setup, Pino config, Prom metrics, event loop monitor.

## Framework-Specific Notes

**VPS-first / lightweight-first:** las apps Dublin se deployan en VPS por default. Elegir el framework más liviano que cumpla el requerimiento — Hono o Fastify por default, NestJS solo para enterprise con DI/módulos complejos, Express solo legacy. `pnpm` siempre; considerar Bun como runtime (más rápido que Node para APIs y scripts).

### Hono
- Ultra-liviano, edge-compatible — corre en Node/Bun/Deno y en runtimes edge (Cloudflare Workers, Vercel Edge)
- Default para APIs nuevas livianas; menor footprint y arranque más rápido que NestJS/Express
- `hono/compress`, middleware de cache y rate-limit propios o vía adaptadores; usa `c.json()` con serialización eficiente
- Combina bien con Bun como runtime para máximo throughput

### NestJS
- Interceptors for timing/metrics (don't scatter `performance.now()` in services)
- Use `@CacheInterceptor` + Redis store, or do it yourself with a `CacheService`
- `ClassSerializerInterceptor` + `@Expose()/@Exclude()` for DTO shaping
- Avoid circular deps — they often manifest as extra renders of providers

### Fastify
- Preferable for high-throughput plain JSON APIs (2–3× Express throughput)
- Use schema-based serialization (`fast-json-stringify`) — big win
- `@fastify/rate-limit`, `@fastify/compress`, `@fastify/helmet`

### Express
- If legacy, fine. For new: prefer Fastify or NestJS.
- Make sure `compression`, `helmet`, `express-rate-limit` are wired

## Anti-Patterns Checklist (quick scan)

| Anti-Pattern | Fix |
|---|---|
| N+1 in a loop | Batch with `IN (...)` or DataLoader |
| `OFFSET` pagination on large tables | Keyset (cursor) |
| `bcrypt.hashSync` / sync crypto in request path | Async variants |
| No cache on hot read path | Redis + explicit TTL |
| `JSON.stringify` large objects in request path | Stream or worker thread |
| No compression on API responses | Enable gzip/brotli |
| No rate limit on auth endpoints | Per-IP + per-email limiter |
| No correlation ID on logs | Middleware that injects + propagates |
| No tracing on DB/Redis/external | OpenTelemetry auto-instrumentation |
| No p95/p99 latency dashboards | RED metrics per route |
| Unbounded `Promise.all(items.map(...))` | `p-limit` |
| New DB client per request | Singleton |
| `SELECT *` everywhere | Explicit columns / DTOs |
| Long-lived DB transactions | Shorten; move non-DB work out |
| No event loop lag monitoring | Add `monitorEventLoopDelay` + alarm |
| Caching per-user with global key | Namespace keys |
| Cache stampede ignored | Single-flight / lock-and-refresh |

## Decision: Is It Worth Optimizing?

Before you optimize, **measure**:
1. What's the p95 latency of this endpoint in prod?
2. What's the QPS?
3. Where does the time actually go? (tracing span breakdown)
4. Is the bottleneck CPU, I/O, DB, or network?

Optimizing code that accounts for 2% of latency is wasted effort. **The trace tells you where to look.**

## Reference Files

- `references/queries.md` — EXPLAIN ANALYZE, N+1 examples, keyset pagination, DataLoader, Prisma/Drizzle/Kysely patterns
- `references/async-and-io.md` — Worker threads, streams, Promise.all vs p-limit, event loop monitoring
- `references/caching.md` — Redis patterns, HTTP cache headers, CDN, stampede protection, SWR
- `references/observability.md` — OpenTelemetry, Pino, Prom metrics, SLO/error budget

## Output Standards

- Be CONCISE — show problematic code, then fix, then one-line tradeoff
- Lead with the measurement ("what does the trace say?") when possible — don't optimize blindly
- When handing off to `database-architect` (schema/index design) or `error-handling` (error taxonomy), say so explicitly
- Never recommend a premature optimization without evidence from traces/metrics
