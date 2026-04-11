# API Scalability — Patterns & Tradeoffs

Reference for scaling APIs from 10 req/s to 100k+ req/s. Sources: AWS Well-Architected Framework, *Designing Data-Intensive Applications* (Kleppmann), Google SRE book, High Scalability archive, real-world postmortems.

---

## 1. The Scalability Hierarchy (cheapest → most expensive)

When you hit a scale ceiling, climb the hierarchy in this order:

1. **Optimize the current code** (remove N+1, add indexes, batch calls) — free
2. **Vertical scaling** (bigger box) — fast, limited
3. **Caching** (CDN → app → DB) — biggest ROI
4. **Read replicas** — scale reads linearly
5. **Queues + async workers** — decouple slow work from the request path
6. **Horizontal scaling** (more boxes) — requires statelessness
7. **Sharding / partitioning** — complex, avoid until necessary
8. **Event-driven architecture** — complex, high power
9. **Microservices** — organizational tool, NOT a scaling tool

Start cheap. Most teams skip steps and pay for it.

---

## 2. Statelessness — the prerequisite for horizontal scaling

A stateless API server holds no in-memory state that another server would need. Any server can handle any request.

### What NOT to hold in process memory:

- **Session data** → Redis / DB / signed JWT
- **Uploaded files** → object storage (S3, GCS, R2)
- **In-memory caches of user data** → distributed cache (Redis, Memcached)
- **Cron state / leader election** → external lock service (Redis SETNX, Zookeeper, etcd)
- **WebSocket connections as source of truth** → pub/sub (Redis Streams, Kafka)

### What's fine to hold in memory:

- Immutable config
- Connection pools (DB, HTTP, Redis)
- Short-lived request context
- Computed caches with small TTLs (you'll hit them on some servers, miss on others — acceptable)

### Sticky sessions — avoid

Load balancers can pin a client to one server. Convenient, but kills horizontal scaling (server failure = user loses state). **Only use** for WebSocket fan-out, and even then prefer pub/sub.

---

## 3. Caching — The Highest ROI Lever

Caching shifts load from expensive operations to cheap lookups. It is the single biggest performance win in most systems.

### 3.1 Cache layers (from edge to data)

| Layer | Latency | What to cache | TTL |
|---|---|---|---|
| **CDN** (Cloudflare, CloudFront, Fastly) | 1-10ms | Public GET responses, static assets | 1h-24h |
| **Edge cache** (API gateway, regional) | 5-20ms | Geolocated, short-lived data | 10s-5min |
| **Application cache** (Redis, Memcached) | 0.5-2ms | User data, computed results, sessions | 1min-1h |
| **In-process** (Node lru-cache, Go ristretto) | < 0.1ms | Hot config, small lookup tables | seconds |
| **DB query cache** | 1-5ms | Repeated queries in the same request | request lifetime |
| **Materialized views** (Postgres, Clickhouse) | 5-50ms | Pre-aggregated data | nightly refresh |

### 3.2 Caching patterns

- **Cache-aside (lazy)** — app checks cache, on miss reads DB, writes cache. Simple, most common.
- **Read-through** — cache library handles the DB read on miss.
- **Write-through** — app writes to cache and DB synchronously. Consistency win, latency cost.
- **Write-behind** — write to cache, DB updated asynchronously. Fast, risks loss on crash.
- **Refresh-ahead** — proactively refresh before TTL expires. For hot keys.

### 3.3 Cache invalidation

The hard problem. Three approaches:

- **TTL-based** — cache for N seconds, accept staleness. Simple. Best default.
- **Event-driven** — on write, publish invalidation. Accurate, complex.
- **Tag-based** — group cache keys under tags, invalidate all at once. Good middle ground (Next.js `revalidateTag`, CDN surrogate keys).

### 3.4 Cache key design

Key must include every parameter that affects the response:

```
user:{user_id}:profile:v2
orders:list:tenant={tid}:status={s}:cursor={c}:limit={n}
```

Include a **version suffix** (`:v2`) so you can invalidate everything by bumping the version.

### 3.5 Cache stampede (thundering herd)

When a hot cache key expires, all requests hit the DB simultaneously.

**Mitigations**:
- **Probabilistic early expiration** — some requests refresh before TTL
- **Singleflight** — one request refreshes, others wait for it (Go has `singleflight`, Node can use promise memoization)
- **Lock on refresh** — only one request is allowed to refresh a given key
- **Jittered TTL** — randomize TTL slightly so keys don't all expire together

### 3.6 What NOT to cache

- Frequently-written data (cache is invalidated too often)
- User-specific data at the CDN (unless you partition by user)
- Sensitive data without encryption
- Anything with legal retention requirements (GDPR erasure)

---

## 4. Rate Limiting

### 4.1 Why rate limit

- Protect against abuse (scraping, brute force)
- Protect against cost runaway (downstream services, DB)
- Ensure fair access (one tenant can't starve others)
- Protect SLOs (avoid cascading failures)

### 4.2 Algorithms

| Algorithm | Pros | Cons |
|---|---|---|
| **Fixed window** | Simple, low memory | Bursts at window edge |
| **Sliding window** | Smooth | Slightly more state |
| **Token bucket** | Allows bursts, refills continuously | Most popular, Stripe-style |
| **Leaky bucket** | Enforces a steady rate | Rejects bursts |
| **GCRA** (Generic Cell Rate Algorithm) | Constant memory, precise | Less intuitive |

**Default pick**: token bucket (allows legitimate bursts, smooth average).

### 4.3 Granularity

Multi-level rate limiting is the norm:

- **Per IP** — blocks volumetric attacks
- **Per user / API key** — fair usage
- **Per endpoint** — protect expensive endpoints harder
- **Per tenant** — multi-tenant fairness
- **Global** — final protection against system overload

### 4.4 Where to enforce

- **Edge / CDN** — cheapest, catches most abuse
- **API gateway** (Kong, Tyk, Envoy) — consistent policy across services
- **Application** — final enforcement, business-level rules

Use Redis for distributed rate limit counters (INCR with TTL, or a Lua script for atomicity).

### 4.5 Response headers

Always return:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 47
X-RateLimit-Reset: 1712345678
Retry-After: 30
```

And status **429 Too Many Requests**.

### 4.6 Different tiers

- **Anonymous**: harsh limit (10-30/min)
- **Authenticated**: medium (100-500/min)
- **Paid tier**: generous (1000-10000/min)
- **Enterprise**: custom / negotiated

---

## 5. Async Work & Queues

### 5.1 When to make work async

Anything that doesn't need to block the request:

- Sending emails
- Generating reports / PDFs
- Image / video processing
- Webhook delivery
- Batch imports / exports
- AI/ML inference (if > 1s)
- Any work with retries

**Rule**: if it takes > 300ms, consider making it async.

### 5.2 Queue options

| Tool | Use case |
|---|---|
| **Redis + BullMQ / Sidekiq / Celery** | Simple, familiar, low setup |
| **AWS SQS** | Managed, cheap, durable |
| **RabbitMQ** | Feature-rich (routing, priorities) |
| **Kafka / Redpanda** | High throughput, event log, streaming |
| **NATS JetStream** | Lightweight, fast |
| **Temporal / Inngest** | Durable workflows with retries and state |

**Default pick for startups**: Redis + BullMQ (or language equivalent).
**For durable workflows**: Temporal or Inngest.
**For high throughput event streams**: Kafka.

### 5.3 Queue design principles

- **Idempotent consumers** — a message may be delivered twice; the handler must tolerate it
- **Dead letter queue** — failed messages go to a DLQ for inspection
- **Retries with backoff** — exponential backoff + jitter
- **Maximum retries** — after N attempts, DLQ (not infinite retries)
- **Visibility timeout** — how long a consumer has to process before the message reappears
- **Ordering guarantees** — only some queues provide strict ordering (Kafka per-partition, FIFO SQS)
- **Message size limits** — store large payloads in S3 and pass a reference

### 5.4 Sync vs async decision

```
Does the user need to know the result NOW?
├── Yes → sync response, optimize the critical path
└── No  → accept + 202, enqueue, return job_id
           ├── Client polls /jobs/{id} for status
           └── Or client subscribes (WebSocket / SSE / webhook)
```

---

## 6. Database Scaling

### 6.1 Vertical first

Bigger box before sharding. Modern Postgres on a large instance handles 10k+ QPS. Don't shard prematurely.

### 6.2 Read replicas

Postgres, MySQL, and most managed DBs support read replicas trivially. Route read queries to replicas, writes to primary.

**Gotchas**:
- **Replication lag** — replicas are seconds behind. Read-your-own-writes breaks unless you route the user's immediate reads back to primary.
- **Connection pooling** — one pool per target (primary + replicas)
- **Failover** — the driver / proxy must handle replica death

### 6.3 Connection pooling

Every process opens a fixed number of DB connections. Postgres has a hard connection limit (~500 default). 50 processes × 20 connections = 1000 — boom.

**Solution**: PgBouncer (transaction-mode pooling). Shares physical connections across many logical ones.

**Rule**: always use a pooler (PgBouncer, RDS Proxy, Cloud SQL Proxy) for Postgres at scale.

### 6.4 Indexing

Indexes turn O(n) scans into O(log n) lookups.

- Index every column used in WHERE, JOIN, ORDER BY
- Composite indexes for multi-column queries (order matters — high cardinality first)
- Partial indexes for filtered queries (`WHERE status = 'active'`)
- Covering indexes include all needed columns → index-only scan
- **Watch out**: too many indexes slow down writes

Use `EXPLAIN ANALYZE` before and after — measure, don't guess.

### 6.5 N+1 queries

The #1 performance bug in ORM-based APIs.

```
orders = Order.all()             # 1 query
for o in orders:                 # N queries
    print(o.user.name)           # one per order
```

**Fix**: eager loading (`includes` / `select_related` / `with`), or DataLoader pattern.

Detect in CI with tools like `prosopite`, `bullet` (Rails), Laravel N+1 detectors, or Prisma's query logging.

### 6.6 Partitioning (single DB, multiple tables)

Postgres supports **declarative partitioning** by range / list / hash. One logical table split into many physical ones.

**Use for**:
- Time-series data (partition by month)
- Multi-tenant data (partition by tenant_id)
- Tables > 100M rows

### 6.7 Sharding (multiple DBs)

Split data across physical databases. **Only when** a single DB can no longer keep up.

**Shard key strategies**:
- **By tenant_id** — natural for multi-tenant, easy
- **By user_id** — common for B2C
- **By hash(id)** — even distribution, no hot spots, hard to re-shard

**Gotchas**:
- Cross-shard queries become hard
- Resharding is painful (plan for it)
- Transactions across shards don't exist (unless using distributed tx like Spanner / CockroachDB)

**Alternative to sharding**: distributed SQL (CockroachDB, Yugabyte, Spanner, TiDB, Neon). They shard automatically.

### 6.8 Choosing a database

| Workload | Pick |
|---|---|
| OLTP (typical CRUD app) | Postgres (almost always) |
| Globally distributed | CockroachDB, Spanner, Yugabyte |
| Serverless scale-to-zero | Neon, PlanetScale, Supabase, Turso |
| Key-value at huge scale | DynamoDB, ScyllaDB, Redis |
| Time-series | TimescaleDB, InfluxDB, Clickhouse |
| Analytics / OLAP | Clickhouse, BigQuery, Snowflake, DuckDB |
| Full-text search | Elasticsearch, Meilisearch, Typesense, Algolia, Postgres FTS |
| Vector / embeddings | pgvector, Pinecone, Qdrant, Weaviate |
| Graph | Neo4j, Memgraph, Neptune |
| Document | MongoDB, Postgres JSONB |

**Default for most teams in 2026**: Postgres. It handles JSON, full-text search, time-series, and vectors. Only add specialized stores when Postgres hits its ceiling.

---

## 7. Load Balancing

### 7.1 Layers

- **DNS-level** (Route 53 latency / geolocation routing) — regional distribution
- **Anycast / CDN** — single IP routes to nearest PoP
- **L4 load balancer** (TCP) — NLB, fast, simple
- **L7 load balancer** (HTTP) — ALB, Envoy, Nginx, HAProxy — content-aware

### 7.2 Algorithms

- **Round-robin** — simple, default
- **Least connections** — better for long-lived requests
- **Consistent hashing** — for cache affinity (same user → same cache)
- **Weighted** — for canary / gradual rollouts

### 7.3 Health checks

- **Shallow** — `/healthz` returns 200 if process is up
- **Deep** — `/readyz` checks DB connectivity, cache, downstream dependencies
- Load balancer removes unhealthy instances from rotation

---

## 8. CDN Strategy

### 8.1 What to put on the CDN

- Static assets (JS, CSS, images, fonts) — always
- Public API responses (product catalog, public feeds) — with care
- Generated assets (OG images, thumbnails) — yes
- Video / audio — yes (with signed URLs if private)

### 8.2 Cache headers

```
Cache-Control: public, max-age=3600, s-maxage=86400
```
- `max-age` — browser cache
- `s-maxage` — CDN cache (can be longer than browser)
- `public` — allows shared caches
- `private` — browser-only, never CDN

### 8.3 Invalidation

- **Versioned URLs** (`app.v42.js`) — preferred, infinite TTL
- **Purge API** — surgical invalidation
- **Surrogate keys / tags** — group invalidation (Fastly, Cloudflare)

---

## 9. Horizontal Scaling Patterns

### 9.1 Stateless app tier

N identical servers behind a load balancer. Add/remove servers to match load. This is the default modern web architecture.

### 9.2 Auto-scaling

- **Reactive** — scale based on CPU / memory / queue depth / request rate
- **Predictive** — scale ahead of known patterns (daily peak)
- **Scheduled** — scale at fixed times (batch jobs)

Metrics to scale on:
- CPU > 70% for 2 minutes → add instance
- Request queue depth → scale workers
- p99 latency → scale when SLO at risk

### 9.3 Cold start problem (serverless)

Lambda / Cloud Functions have startup latency. Mitigations:
- **Provisioned concurrency** (pre-warmed instances)
- **Keep-warm pings** (cron)
- **Lighter runtimes** (Deno Deploy, Cloudflare Workers — V8 isolates = no cold start)

---

## 10. Denormalization & Read Models

### 10.1 The tradeoff

- Normalized schemas (3NF) → correct, clean, slow complex reads
- Denormalized schemas → fast reads, duplication, consistency challenges

### 10.2 When to denormalize

- Read-heavy endpoints with joins across many tables
- Aggregations on high-volume data
- Pre-computed counters (likes, views, followers)
- Search indices (dedicated store)

### 10.3 Materialized views

Postgres supports materialized views — pre-computed query results refreshable on demand or schedule.

**Use for**:
- Dashboards
- Analytics endpoints
- Leaderboards

Refresh strategies: full refresh (nightly), incremental (continuous with pg_ivm or trigger-based).

### 10.4 Read models (CQRS-lite)

Write to the normalized main DB. A background worker projects into a read-optimized store (Elasticsearch, Clickhouse, Redis, denormalized Postgres tables). Reads hit the read store.

Tradeoff: read store is eventually consistent.

---

## 11. Event-Driven Architecture

For very high scale or complex domains, events become the backbone.

### 11.1 Pattern

Services publish events (`OrderCreated`, `PaymentCaptured`, `UserSignedUp`). Other services subscribe and react.

### 11.2 Benefits

- Decoupling — producers don't know consumers
- Scalability — consumers scale independently
- Replayability — event log is the source of truth

### 11.3 Costs

- Complexity (tracing, ordering, duplicates)
- Debugging is harder
- Eventual consistency everywhere

### 11.4 When to adopt

- When domain events are already clear (DDD)
- When multiple services need the same data
- NOT as a default for a new project (start monolithic, extract later)

---

## 12. Microservices Reality Check

**Microservices are an organizational tool, not a performance tool.**

Use when:
- > 20 engineers and feature teams conflict
- Different parts of the system scale differently AND you can't scale them together
- Different parts have different tech needs (ML vs CRUD)
- Compliance/security requires isolation

Don't use when:
- Team size < 20
- You're starting out
- You haven't hit a single-service scaling wall

Monoliths scale to billions of requests. Stack Overflow, Shopify, GitHub, and Basecamp run (or ran) on monoliths at huge scale. The problem is almost never "we need microservices."

---

## 13. Latency Budget

Set explicit targets and measure.

### 13.1 Example budget (p99 < 300ms total)

| Stage | Budget |
|---|---|
| TLS handshake | 30ms |
| Auth check | 10ms |
| Rate limit check | 5ms |
| Business logic | 50ms |
| DB queries | 100ms |
| External API calls | 80ms |
| Serialization | 15ms |
| Network (client) | 10ms |

If any stage exceeds budget, optimize or cache. Measure with tracing.

### 13.2 Tail latency matters more than average

- p50 (median) = typical user
- p95 = worst 5% (slowest 1 in 20)
- p99 = worst 1% (slowest 1 in 100)
- p99.9 = worst 0.1% (slowest 1 in 1000)

For any popular service, p99.9 users hit the slow path daily. Optimize tails, not averages.

Causes of tail latency: GC pauses, thundering herds, slow queries, cold caches, retries on slow upstreams.

---

## 14. Scalability Anti-Patterns

- **Premature microservices** — overhead > benefits until org is big
- **Caching without invalidation plan** — stale data silently
- **No rate limiting** — first abuser kills the system
- **In-memory state on horizontally-scaled servers** — inconsistent behavior
- **Synchronous fan-out** (call N services in parallel, wait for all) — worst-case latency = slowest service
- **N+1 queries** — orders-of-magnitude slowdowns
- **Retries without backoff** — thundering herd during outages
- **No circuit breakers on upstreams** — one slow downstream drags everything down
- **Sticky sessions** — no horizontal scaling
- **Writing to primary DB for reads** — replica lag ignored, primary overloaded
- **No connection pooler** — Postgres connection limit crash
- **Offset pagination on huge tables** — DB scans
- **Caching private data at the CDN** — data leaks between users
- **Scaling servers instead of scaling the DB** — the DB is almost always the bottleneck
