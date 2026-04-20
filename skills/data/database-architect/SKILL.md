---
name: database-architect
description: Design schemas, write safe migrations, diagnose performance issues for production databases (Postgres primarily). Use when modeling a new domain, adding indexes, writing zero-downtime migrations, debugging N+1 or slow queries, planning sharding/partitioning, choosing between Prisma/Drizzle/TypeORM/Kysely, or auditing schema for integrity. Covers Postgres internals (B-tree, GIN, MVCC, lock modes), connection pooling, and RLS for multi-tenancy. Pairs with auth-architect (user/session schema) and hexagonal-architect (repository layer).
---

# Database Architect

The database is usually the hardest part to change later. Get the schema right, write migrations that don't take production down, and measure before you optimize.

## Database Choice

| DB | When |
|---|---|
| **Postgres** | Default for 95% of apps. JSON, arrays, full-text, extensions, RLS. |
| **MySQL** | Legacy stacks, specific tooling. Otherwise no reason to pick over Postgres. |
| **SQLite** | Single-node apps, embedded (desktop/mobile), edge (Turso, Cloudflare D1). |
| **MongoDB** | Truly schemaless (rare), document-heavy. Usually a mistake — Postgres JSONB covers this. |
| **DynamoDB** | Hyper-scale, predictable access patterns, no joins. AWS lock-in. |
| **Redis/KeyDB** | Cache, rate limits, queues, ephemeral data. Not a primary store. |

**Default: Postgres.** Reach for anything else only with a clear reason.

## ORM / Query Builder Choice

| Tool | When |
|---|---|
| **Prisma** | TypeScript default. Great DX, migrations, type inference. Heavier runtime. |
| **Drizzle** | Lighter, SQL-first, edge-compatible. Growing fast. |
| **Kysely** | Type-safe query builder, no ORM overhead. Best if you think in SQL. |
| **TypeORM** | Legacy NestJS projects. Active bugs, decorator-heavy. Avoid for new work. |
| **Raw SQL + pg** | When performance or SQL features matter more than DX. |

**Default: Prisma** for speed of shipping, **Drizzle** or **Kysely** when you want close to SQL.

## Schema Design — Non-Negotiables

### Primary Keys

- **UUID v7** (time-ordered) for public-facing IDs — better than UUID v4 (random destroys index locality)
- **BIGINT auto-increment** for internal high-volume tables (events, logs) — smaller, faster
- **Never expose auto-increment IDs in URLs** — reveals volume to competitors, enables IDOR

### Timestamps

Every table gets:

```sql
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
```

Use `TIMESTAMPTZ` (with timezone), NEVER `TIMESTAMP`. Store in UTC. Format in the UI.

### Soft Delete vs Hard Delete

- **Default: hard delete.** Soft delete pollutes every query with `WHERE deleted_at IS NULL`.
- Use soft delete only when recovery is an explicit feature. Even then, prefer archive tables.

### Nullability

- Default: **NOT NULL**. Null is a footgun — every downstream query has to handle it.
- Use default values for fields that conceptually always exist.

### Foreign Keys

- **Always** add foreign key constraints. "We'll do it at the app layer" is a lie — you won't.
- **ON DELETE** policy: `CASCADE` for owned data, `SET NULL` for optional links, `RESTRICT` (default) for critical references.

### Multi-tenancy

- `tenant_id` on every tenant-scoped table
- **RLS (Row-Level Security)** policies in Postgres to enforce at DB layer
- Composite indexes starting with `tenant_id` (`(tenant_id, created_at)`)

## Indexes — The Rules

### When to index

- **Any column in a `WHERE` clause** on a large table
- **Any column in a `JOIN`** condition (usually FK — auto-index FKs)
- **Any column in `ORDER BY`** on a large table (especially with `LIMIT`)
- **Composite indexes** for multi-column filters (order matters: most selective first)

### When NOT to index

- Columns with very low cardinality (boolean, status with 3 values) — unless combined with others
- Tables with < 10k rows — sequential scan is faster
- Write-heavy tables — each index slows INSERTs

### Index types (Postgres)

| Type | Use |
|---|---|
| **B-tree** (default) | Equality, range, sorting |
| **GIN** | JSONB, arrays, full-text search |
| **GiST** | Geometry, full-text, ranges |
| **BRIN** | Huge time-series tables with natural order |
| **HASH** | Equality-only, rare use |

### Partial indexes (free performance)

```sql
-- Only index active rows
CREATE INDEX idx_users_active_email ON users(email) WHERE active = true;

-- Only index rows that matter
CREATE INDEX idx_orders_pending ON orders(created_at) WHERE status = 'pending';
```

### Covering indexes (include columns)

```sql
CREATE INDEX idx_users_email_include ON users(email) INCLUDE (name, avatar_url);
-- Query can be satisfied entirely from index — no table lookup
```

### Verify indexes are used

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE email = 'x';
-- Look for "Index Scan" not "Seq Scan"
```

## Zero-Downtime Migrations (CRITICAL)

### The Rules

1. **Never rename columns or tables in one migration.** Add new, backfill, switch reads, drop old.
2. **Never drop columns still read by the old app version.** Use deploy pipeline: code first, DB drop later.
3. **Never add NOT NULL column without default.** Postgres rewrites the whole table (locks).
4. **Never add FK to large table without `NOT VALID` + `VALIDATE`.**
5. **Never run long migrations inside app deploy.** Run via separate job, gated behind feature flag.

### Safe patterns

**Adding a column:**
```sql
-- ✅ Safe: default as expression (Postgres 11+)
ALTER TABLE users ADD COLUMN tier TEXT NOT NULL DEFAULT 'free';
-- ❌ Dangerous pre-PG11: rewrites table, locks
```

**Renaming a column (3-step):**
```sql
-- Step 1 — deploy: add new column, dual-write from app
ALTER TABLE users ADD COLUMN full_name TEXT;
-- Deploy app that writes to both `name` and `full_name`

-- Step 2 — deploy: backfill + switch reads
UPDATE users SET full_name = name WHERE full_name IS NULL;
-- Deploy app that reads from `full_name`

-- Step 3 — deploy: drop old column (after all instances on v2)
ALTER TABLE users DROP COLUMN name;
```

**Adding a NOT NULL without default:**
```sql
-- Step 1: add nullable
ALTER TABLE orders ADD COLUMN status TEXT;
-- Step 2: backfill in batches
UPDATE orders SET status = 'pending' WHERE id IN (SELECT id FROM orders WHERE status IS NULL LIMIT 10000);
-- Step 3: add CHECK NOT VALID
ALTER TABLE orders ADD CONSTRAINT status_not_null CHECK (status IS NOT NULL) NOT VALID;
-- Step 4: validate (doesn't block writes)
ALTER TABLE orders VALIDATE CONSTRAINT status_not_null;
-- Step 5: eventually SET NOT NULL + drop check
```

**Adding an index:**
```sql
-- ✅ CONCURRENTLY — doesn't block writes
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
-- ❌ Regular CREATE INDEX — locks writes for minutes on big tables
```

**Adding a foreign key:**
```sql
-- ✅ NOT VALID first, then VALIDATE
ALTER TABLE orders ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id) NOT VALID;
ALTER TABLE orders VALIDATE CONSTRAINT fk_user;
```

## Transactions

- **Use transactions** for any multi-statement write that must be atomic
- **Keep them short** — long transactions block others, hold locks
- **SERIALIZABLE** isolation only when you genuinely need it (rare); default `READ COMMITTED` is fine
- **Retry on serialization failure** — SELECT...FOR UPDATE SKIP LOCKED for queue patterns

## N+1 Queries — The #1 Perf Killer

```ts
// ❌ N+1
const users = await prisma.user.findMany();
for (const u of users) {
  u.posts = await prisma.post.findMany({ where: { userId: u.id } }); // N queries
}

// ✅ Single query with join
const users = await prisma.user.findMany({ include: { posts: true } });

// ✅ DataLoader pattern for GraphQL / batch resolvers
```

Tool: enable Prisma `log: ["query"]` in dev. If you see 50 queries on one page, you have N+1.

## Connection Pooling

- **PgBouncer** or **Supavisor** (Supabase) in front of Postgres
- Serverless (Lambda, Vercel): **must** use a pooler, or use HTTP-based (Neon, Supabase Data API)
- Pool size rule of thumb: `(max_connections - reserved) / app_instances`
- Transaction mode pooling breaks prepared statements — Prisma needs `?pgbouncer=true` param

## Postgres Specifics Worth Knowing

- **JSONB > JSON** — binary, indexable, fast queries
- **Arrays** — native, not a code smell in Postgres
- **Full-text search** — `tsvector` + GIN index. For anything complex, use Meilisearch/Typesense/Elasticsearch.
- **LISTEN/NOTIFY** — cheap pub/sub for low-volume events
- **Generated columns** — `GENERATED ALWAYS AS (...) STORED` for computed fields with indexes
- **pg_stat_statements** — enable it. Shows your slow queries.

## Audit Checklist (before shipping)

- [ ] Every table has `created_at`, `updated_at` (TIMESTAMPTZ, UTC)
- [ ] Every FK has a matching index
- [ ] Every tenant-scoped table has `tenant_id` + RLS policy
- [ ] No columns rely on app-layer null checks — use NOT NULL + default
- [ ] Slow query log enabled (`log_min_duration_statement = 500`)
- [ ] `pg_stat_statements` extension enabled
- [ ] Backups + point-in-time recovery configured
- [ ] Connection pooler in front of Postgres (prod)
- [ ] Migration pipeline uses CONCURRENTLY for index creation
- [ ] No production migrations run inside app deploy

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| UUID v4 as PK | Random → destroys B-tree locality, slow writes | UUID v7 (time-ordered) |
| TIMESTAMP (no tz) | Breaks across timezones | TIMESTAMPTZ |
| Soft delete everywhere | `WHERE deleted_at IS NULL` on every query | Hard delete by default |
| FK without index | Slow cascades, slow joins | Always index FKs |
| Big migrations in deploy | Lock tables, take site down | Run separately, feature-flagged |
| `SELECT *` in app code | Breaks on schema change, over-fetches | Select specific columns |
| N+1 | 50 queries where 1 would do | Include/join, DataLoader |
| No constraints, validate in app | App bugs corrupt data | CHECK constraints, FKs, NOT NULL |
| Enum as TEXT with no check | Typos in data | `CHECK (status IN (...))` or native enums |

## Output Standards

- Always include the migration file and the rollback plan
- Show the `EXPLAIN` output when claiming a query is fast
- Every proposed schema must pass the audit checklist
- Call out zero-downtime concerns explicitly for any migration on a production table

## Reference Files

- `references/patterns.md` — Schema templates (users, sessions, multi-tenant, audit log), safe migration recipes, Prisma/Drizzle/Kysely setup, connection pooling config, RLS policies
