# Caching — Patterns & Gotchas

## Where Should the Cache Live?

Cheapest → strongest:

| Layer | Good for | Tool |
|---|---|---|
| Browser + CDN | Public, versioned assets | `Cache-Control: public, max-age, immutable` |
| CDN only | Semi-dynamic public pages | Cloudflare / Fastly / Vercel Edge |
| HTTP cache (origin) | Conditional requests | `ETag` / `If-None-Match` |
| In-process (LRU) | Hot, small, single-instance data | `lru-cache` |
| Redis | Shared state across instances | `ioredis` / `redis` client |
| Materialized view | Expensive aggregation, tolerable staleness | Postgres `REFRESH MATERIALIZED VIEW` |

**Rule**: push the cache as close to the client as acceptable staleness allows.

## HTTP Cache Headers (free wins)

Public, immutable (versioned asset):
```
Cache-Control: public, max-age=31536000, immutable
```

Public, revalidate quickly:
```
Cache-Control: public, max-age=60, stale-while-revalidate=600
```

Private, user-specific but cacheable:
```
Cache-Control: private, max-age=300
```

Never cache:
```
Cache-Control: no-store
```

**Conditional requests** — cheap way to skip re-sending the body:
```ts
const etag = computeETag(resource);
if (req.headers['if-none-match'] === etag) {
  return res.status(304).end();
}
res.setHeader('ETag', etag);
res.json(resource);
```

## Redis — Basic Read-Through

```ts
async function getUser(id: string): Promise<User> {
  const key = `user:${id}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  const user = await db.user.findUniqueOrThrow({ where: { id } });
  await redis.set(key, JSON.stringify(user), 'EX', 300); // 5 min TTL
  return user;
}
```

**Invalidate on write**:
```ts
await db.user.update({ where: { id }, data });
await redis.del(`user:${id}`);
```

## Stampede Protection (Single-Flight)

Problem: TTL expires, 1000 concurrent requests all miss, all hit the DB.

**Solution 1 — in-process coalescing**:
```ts
const inflight = new Map<string, Promise<User>>();

async function getUser(id: string): Promise<User> {
  const cached = await redis.get(`user:${id}`);
  if (cached) return JSON.parse(cached);

  if (inflight.has(id)) return inflight.get(id)!;

  const p = (async () => {
    try {
      const user = await db.user.findUniqueOrThrow({ where: { id } });
      await redis.set(`user:${id}`, JSON.stringify(user), 'EX', 300);
      return user;
    } finally {
      inflight.delete(id);
    }
  })();

  inflight.set(id, p);
  return p;
}
```

**Solution 2 — Redis lock (cross-instance)**:
```ts
// SET NX with a short TTL on a "lock" key; only one caller refreshes, others retry.
const got = await redis.set(`lock:user:${id}`, '1', 'PX', 2000, 'NX');
if (got) { /* refresh and publish */ } else { /* brief wait + re-read cache */ }
```

## Stale-While-Revalidate (SWR)

Serve stale data immediately, refresh in background.

```ts
async function getWithSWR<T>(
  key: string,
  fresh: () => Promise<T>,
  { ttl = 300, staleFor = 3600 } = {},
): Promise<T> {
  const raw = await redis.get(key);
  if (raw) {
    const { value, writtenAt } = JSON.parse(raw);
    if (Date.now() - writtenAt > ttl * 1000) {
      // Serve stale, refresh in background.
      void refreshInBackground(key, fresh);
    }
    return value;
  }
  return refreshInBackground(key, fresh);
}
```

Great for data where "a minute stale" is OK but "DB hit on every miss" is not.

## Keyspace Discipline

**BAD** (collision-prone, non-obvious):
```ts
redis.set(userId, JSON.stringify(user));
```

**GOOD** (namespaced):
```ts
redis.set(`user:${userId}:profile`, JSON.stringify(user));
redis.set(`user:${userId}:settings`, JSON.stringify(settings));
redis.set(`tenant:${tenantId}:feature-flags`, JSON.stringify(flags));
```

Benefits:
- `SCAN user:*` groups operations
- Clear ownership
- Safe deletion: `DEL user:{id}:*` via Lua script

## Cache Hit Rate Metrics

Every cache read should emit a metric:
```ts
const hit = cached !== null;
metrics.counter('cache.lookup', 1, { key_type: 'user', hit: String(hit) });
```

Target: **≥ 80% hit rate** on hot paths. Below that, either TTL is too short, invalidation is too aggressive, or the cache isn't helping enough.

## What NOT to Cache

- Per-request authorization decisions (auth bugs via stale perms)
- Financial state reads (use the DB; let it be fast)
- Anything changing faster than your TTL allows (just don't cache)
- Compressed/encoded blobs stored twice (once in DB, once as Redis) — think once

## Rate Limiting Counters (Redis)

```ts
// Sliding window with a sorted set.
const key = `rl:${userId}`;
const now = Date.now();
const windowMs = 60_000;
const max = 100;

await redis.zremrangebyscore(key, 0, now - windowMs);
const count = await redis.zcard(key);
if (count >= max) throw new TooManyRequestsError();
await redis.zadd(key, now, `${now}-${crypto.randomUUID()}`);
await redis.pexpire(key, windowMs);
```

Or use `rate-limiter-flexible` which handles the Lua atomics.

## Redis Client Config

```ts
import Redis from 'ioredis';

export const redis = new Redis(process.env.REDIS_URL!, {
  maxRetriesPerRequest: 3,
  enableReadyCheck: true,
  connectTimeout: 5_000,
  lazyConnect: false,
});

redis.on('error', (err) => logger.error({ err }, 'redis error'));
```

For pub/sub or streams, use a **separate** client — one for commands, one for subscriptions.

## CDN Strategy

- **Static assets**: long `max-age`, versioned filename
- **HTML**: short `max-age` + `stale-while-revalidate`
- **API responses** (public): `s-maxage` (CDN-only) + private `max-age=0`
- **Purge on deploy**: API call to CDN to invalidate paths

## Hand-off

If the audit surfaces **schema-level caching** (materialized views, Postgres-level caches), delegate to `database-architect`. Redis / HTTP / CDN stays in this skill.
