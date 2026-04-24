# Queries — Patterns & Fixes

## Reading EXPLAIN ANALYZE (Postgres)

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE user_id = $1 ORDER BY created_at DESC LIMIT 20;
```

**What to look for:**
- `Seq Scan` on a large table → missing index
- `Rows Removed by Filter: N` high → index not selective enough
- `Sort Method: external merge Disk` → `work_mem` too low or needs index on `ORDER BY`
- `Buffers: shared read=XXXX` vs `hit=XXXX` → low hit ratio = cold cache or missing index
- `actual time` >> estimated → stats are stale → `ANALYZE table_name`
- `Nested Loop` over a large outer → usually bad; want Hash Join or Merge Join

**Rule of thumb**: queries on hot paths should complete in `< 10 ms`. Anything > 100 ms under load is a red flag.

## N+1 — The Classic

**BAD** (one query per user + one per post):
```ts
const users = await db.user.findMany({ take: 50 });
for (const u of users) {
  u.posts = await db.post.findMany({ where: { userId: u.id } }); // 50 queries
}
```

**GOOD — Prisma**:
```ts
const users = await db.user.findMany({
  take: 50,
  include: { posts: true }, // single JOIN or grouped IN
});
```

**GOOD — raw SQL with IN**:
```ts
const users = await db.$queryRaw`SELECT * FROM users LIMIT 50`;
const ids = users.map(u => u.id);
const posts = await db.$queryRaw`SELECT * FROM posts WHERE user_id = ANY(${ids})`;
// Then group in memory.
```

**GOOD — DataLoader (GraphQL / per-request batching)**:
```ts
import DataLoader from 'dataloader';

const postsByUserLoader = new DataLoader<string, Post[]>(async (userIds) => {
  const posts = await db.post.findMany({ where: { userId: { in: [...userIds] } } });
  const map = new Map<string, Post[]>();
  for (const p of posts) {
    const arr = map.get(p.userId) ?? [];
    arr.push(p);
    map.set(p.userId, arr);
  }
  return userIds.map(id => map.get(id) ?? []);
});

// Usage inside a resolver:
const posts = await postsByUserLoader.load(user.id);
```

**Scope DataLoader per-request** (not global) — otherwise you cache stale data across requests.

## Keyset (Cursor) Pagination

`OFFSET` on a 10M-row table scans all skipped rows.

**BAD**:
```sql
SELECT * FROM orders ORDER BY created_at DESC OFFSET 100000 LIMIT 20;
-- Scans 100020 rows.
```

**GOOD — keyset**:
```sql
SELECT * FROM orders
WHERE (created_at, id) < ($last_created_at, $last_id)
ORDER BY created_at DESC, id DESC
LIMIT 20;
-- Uses the (created_at, id) index. O(log N) + 20.
```

Client passes back the last row's `(created_at, id)` tuple as the next cursor.

## Avoid `SELECT *`

- Explicit columns → smaller rows over the wire, smaller serialization cost
- If you add a `TEXT` or `BYTEA` column later, `SELECT *` silently ships it
- ORM: use `select: { id: true, email: true }` (Prisma) / `.select({...})` (Drizzle/Kysely)

## `COUNT(*)` on Every List Request

Pagination UIs often show "showing 1-20 of 452,311". That count runs a full table scan.

Options:
- **Approximate count**: `SELECT reltuples::bigint FROM pg_class WHERE relname = 'orders'` (fast, within a few %)
- **Cached count**: maintained by trigger or materialized view, refreshed every N min
- **No count**: just show "Next →" button (most apps don't need total count)

## Long-Held Transactions

**BAD**:
```ts
await db.$transaction(async (tx) => {
  const user = await tx.user.findUnique({ where: { id } });
  await sendEmail(user.email); // HTTP call — holds DB row lock + pool slot
  await tx.user.update({ where: { id }, data: { notified: true } });
});
```

**GOOD**:
```ts
const user = await db.user.findUnique({ where: { id } });
await sendEmail(user.email);
await db.user.update({ where: { id }, data: { notified: true } });
// Or: enqueue the email job outside the transaction.
```

Transactions should hold locks for **milliseconds**, not seconds.

## Prisma-Specific Gotchas

- **`include` tree too deep** → ships huge JSON. Use `select` to pick only needed fields
- **`findFirst` vs `findUnique`** — `findUnique` uses the DataLoader-style batching; prefer it on keys
- **Middleware for soft-delete** blocks optimizer — prefer explicit `where: { deletedAt: null }`
- **Connection URL `?connection_limit=1`** for serverless — use PgBouncer-friendly mode

## Drizzle-Specific Notes

- Drizzle ships thinner SQL — closer to raw, easier to reason about in EXPLAIN
- Use `.prepare()` for repeated queries — Postgres caches the plan
- `.$with(...)` for CTEs when reuse matters

## Kysely-Specific Notes

- SQL-first — you see exactly what runs
- Type-safe raw escapes: `sql<MyType>\`...\``
- Great with Postgres-first apps that need tight control

## Index Checklist

| Query pattern | Index |
|---|---|
| `WHERE status = 'active' AND user_id = ?` | `(status, user_id)` |
| `WHERE created_at > now() - interval '1 day'` | B-tree on `created_at`; BRIN if append-only |
| `WHERE tags @> ARRAY['foo']` | GIN |
| `WHERE data->>'type' = 'x'` | Expression index: `((data->>'type'))` |
| `ORDER BY created_at DESC LIMIT 20` | B-tree `(created_at DESC)` |
| `WHERE email ILIKE 'foo%'` | B-tree with `text_pattern_ops`; trigram (`pg_trgm`) for contains |
| Multi-column filter, common subset | Partial index: `WHERE archived = false` |

**Rule**: cover the most selective column first. Put equality before range.

## Hand-off

If the audit surfaces **schema or index design decisions**, delegate to `database-architect`. This skill spots the problem in code; `database-architect` designs the fix.
