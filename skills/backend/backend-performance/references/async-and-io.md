# Async & I/O — Node.js Patterns

## The Single-Thread Reality

Node runs JS on ONE thread. Anything CPU-bound (hash, parse, compress, image) **blocks every request** on that instance.

**Rule**: if a function does CPU work > ~5 ms, it doesn't belong on the request thread.

## Detecting Event Loop Lag

```ts
import { monitorEventLoopDelay } from 'node:perf_hooks';

const h = monitorEventLoopDelay({ resolution: 10 });
h.enable();

setInterval(() => {
  const p99 = h.percentile(99) / 1e6; // ns → ms
  if (p99 > 50) console.warn({ p99, msg: 'event loop lag' });
  h.reset();
}, 10_000);
```

Expose as a metric. Alarm at p99 > 50 ms.

## Blocking Crypto (the most common sin)

**BAD**:
```ts
import bcrypt from 'bcrypt';
const hash = bcrypt.hashSync(password, 12); // blocks ~100–300 ms
```

**GOOD**:
```ts
const hash = await bcrypt.hash(password, 12); // libuv thread pool
```

Same for `pbkdf2`, `scrypt`, `argon2`. Always async variants.

## Large JSON

`JSON.stringify` of a 50 MB object blocks ~500 ms+. Options:

**Stream it** (`stream-json`):
```ts
import { streamArray } from 'stream-json/streamers/StreamArray.js';
import { chain } from 'stream-chain';
import { parser } from 'stream-json';

req.pipe(chain([ parser(), streamArray() ]))
   .on('data', ({ value }) => processItem(value));
```

**NDJSON for list responses**:
```ts
res.setHeader('Content-Type', 'application/x-ndjson');
for await (const row of db.streamQuery(sql)) {
  res.write(JSON.stringify(row) + '\n');
}
res.end();
```

**Fastify schema-based serialization** (big win for high-QPS JSON APIs):
```ts
fastify.get('/users/:id', {
  schema: {
    response: {
      200: { type: 'object', properties: { id: { type: 'string' }, email: { type: 'string' } } }
    }
  }
}, handler);
// Internally compiles to tight stringify code — 2-5x faster than JSON.stringify.
```

## Worker Threads

For CPU work you can't avoid (image resize, PDF parse, cryptographic heavy lifting):

```ts
import { Worker } from 'node:worker_threads';
import path from 'node:path';

function runInWorker<T>(data: unknown): Promise<T> {
  return new Promise((resolve, reject) => {
    const w = new Worker(path.resolve('./worker.js'), { workerData: data });
    w.on('message', resolve);
    w.on('error', reject);
    w.on('exit', (code) => {
      if (code !== 0) reject(new Error(`exit ${code}`));
    });
  });
}
```

**Production**: use `piscina` — a worker-thread pool with retry and limits.

```ts
import Piscina from 'piscina';
const pool = new Piscina({ filename: path.resolve('./worker.js'), maxThreads: 4 });
const result = await pool.run({ imageBuffer });
```

## Sequential vs Parallel Awaits

**BAD** (sequential, no dependency):
```ts
const user = await fetchUser(id);
const org = await fetchOrg(orgId);
const perms = await fetchPerms(id);
```

**GOOD**:
```ts
const [user, org, perms] = await Promise.all([
  fetchUser(id),
  fetchOrg(orgId),
  fetchPerms(id),
]);
```

**BUT** — unbounded `Promise.all` can destroy the DB:

**BAD**:
```ts
await Promise.all(ids.map(id => db.heavyQuery(id))); // 10k parallel queries
```

**GOOD — cap concurrency with `p-limit`**:
```ts
import pLimit from 'p-limit';
const limit = pLimit(10);
const results = await Promise.all(ids.map(id => limit(() => db.heavyQuery(id))));
```

Or a semaphore pattern for long-running tasks.

## Streams for Large Responses

**BAD** (load 500 MB into memory):
```ts
const buf = await fs.readFile('/path/to/big.csv');
res.send(buf);
```

**GOOD**:
```ts
fs.createReadStream('/path/to/big.csv').pipe(res);
```

Backpressure is handled automatically by `.pipe` — the fs stream slows to match the socket.

**Downloading from S3 and piping through**:
```ts
const obj = await s3.send(new GetObjectCommand({ Bucket, Key }));
obj.Body.pipe(res); // no buffer in Node memory
```

## Backpressure & Timeouts

Every external call needs a timeout. Without one, a hung upstream starves your pool.

```ts
const controller = new AbortController();
const timer = setTimeout(() => controller.abort(), 3_000);
try {
  const res = await fetch(url, { signal: controller.signal });
} finally {
  clearTimeout(timer);
}
```

**NestJS**: `HttpService` from `@nestjs/axios` with interceptors.
**Undici** (Node 20+): `fetch` with `AbortSignal.timeout(3000)` — cleaner.

## Fire-and-Forget Jobs

Don't block the HTTP response on non-essential work. Enqueue.

**BAD**:
```ts
await createUser(data);
await sendWelcomeEmail(data.email); // 500 ms blocking the response
res.send({ ok: true });
```

**GOOD**:
```ts
await createUser(data);
await emailQueue.add('welcome', { email: data.email });
res.send({ ok: true });
// Worker processes the queue.
```

Use **BullMQ** (Redis-backed) or **pg-boss** (Postgres-backed) — don't invent your own.

## Event Loop Golden Rules

1. No sync crypto / zlib / JSON on large payloads in request path
2. Cap concurrency on fan-out (p-limit)
3. Timeouts on every external call
4. Stream anything > ~1 MB
5. Monitor event loop delay — alarm at p99 > 50 ms
6. Worker threads for unavoidable CPU work

## Hand-off

If the audit surfaces **resilience / retry / circuit breaker** needs, delegate to `error-handling`. This skill covers throughput; `error-handling` covers failure modes.
