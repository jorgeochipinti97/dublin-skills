# Observability — Metrics, Tracing, Logging

You can't fix what you can't see. Instrumentation is not optional in production.

## The Three Signals

| Signal | Question it answers | Tool |
|---|---|---|
| **Metrics** (numbers over time) | "Is the system healthy overall? What's p95?" | Prometheus, CloudWatch, Datadog |
| **Traces** (request journey) | "Where did this one slow request spend its time?" | OpenTelemetry → Tempo / Jaeger / Datadog APM |
| **Logs** (structured events) | "What exactly happened on this request?" | Pino → Loki / CloudWatch / Datadog |

All three share a `correlationId` so you can pivot between them.

## Pino — Structured Logs

```ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL ?? 'info',
  base: { service: 'api', env: process.env.NODE_ENV },
  timestamp: pino.stdTimeFunctions.isoTime,
  redact: {
    paths: ['req.headers.authorization', 'req.headers.cookie', '*.password', '*.token'],
    censor: '[REDACTED]',
  },
});
```

**Middleware to inject correlation + request context**:
```ts
import { randomUUID } from 'node:crypto';
import { AsyncLocalStorage } from 'node:async_hooks';

const als = new AsyncLocalStorage<{ correlationId: string; userId?: string }>();

export function requestContext(req, res, next) {
  const correlationId = req.headers['x-correlation-id'] ?? randomUUID();
  res.setHeader('x-correlation-id', correlationId);
  als.run({ correlationId }, () => next());
}

// Pino child logger that pulls from ALS:
export function log() {
  const ctx = als.getStore();
  return logger.child({ correlationId: ctx?.correlationId, userId: ctx?.userId });
}
```

Usage: `log().info({ event: 'user.signed_in' }, 'signed in')`.

## OpenTelemetry — Distributed Tracing

```ts
import { NodeSDK } from '@opentelemetry/sdk-node';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-http';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';

const sdk = new NodeSDK({
  resource: new Resource({
    [SemanticResourceAttributes.SERVICE_NAME]: 'api',
    [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: process.env.NODE_ENV,
  }),
  traceExporter: new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();
```

**Auto-instrumentation covers**: HTTP in/out, Postgres (`pg`), Redis (`ioredis`), gRPC, AWS SDK.

**Custom span around business logic**:
```ts
import { trace } from '@opentelemetry/api';
const tracer = trace.getTracer('checkout');

async function processCheckout(orderId: string) {
  return tracer.startActiveSpan('processCheckout', async (span) => {
    span.setAttribute('order.id', orderId);
    try {
      const result = await doWork();
      span.setStatus({ code: 1 });
      return result;
    } catch (err) {
      span.recordException(err);
      span.setStatus({ code: 2, message: err.message });
      throw err;
    } finally {
      span.end();
    }
  });
}
```

## Prometheus Metrics (`prom-client`)

```ts
import client from 'prom-client';

client.collectDefaultMetrics({ prefix: 'api_' });

export const httpDuration = new client.Histogram({
  name: 'api_http_duration_seconds',
  help: 'HTTP request duration',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
});

export const dbQueryDuration = new client.Histogram({
  name: 'api_db_query_duration_seconds',
  help: 'DB query duration',
  labelNames: ['operation', 'model'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
});

export const cacheLookups = new client.Counter({
  name: 'api_cache_lookups_total',
  help: 'Cache lookups',
  labelNames: ['key_type', 'hit'],
});
```

**Expose `/metrics`**:
```ts
app.get('/metrics', async (_req, res) => {
  res.setHeader('Content-Type', client.register.contentType);
  res.send(await client.register.metrics());
});
```

## RED Metrics per Route

Rate, Errors, Duration. Wire as middleware:

```ts
app.use((req, res, next) => {
  const start = process.hrtime.bigint();
  res.on('finish', () => {
    const durationSec = Number(process.hrtime.bigint() - start) / 1e9;
    const route = req.route?.path ?? 'unknown';
    httpDuration
      .labels(req.method, route, String(res.statusCode))
      .observe(durationSec);
  });
  next();
});
```

Grafana dashboards:
- **Rate**: `rate(api_http_duration_seconds_count[5m])`
- **Errors**: `rate(api_http_duration_seconds_count{status=~"5.."}[5m])`
- **Duration**: `histogram_quantile(0.95, rate(api_http_duration_seconds_bucket[5m]))`

## USE Metrics (Dependencies)

Per dependency (DB pool, Redis, external API): Utilization, Saturation, Errors.

```ts
// Pool utilization (pg):
new client.Gauge({
  name: 'api_pg_pool_idle',
  help: 'Idle pg clients',
  collect() { this.set(pool.idleCount); },
});
new client.Gauge({
  name: 'api_pg_pool_total',
  help: 'Total pg clients',
  collect() { this.set(pool.totalCount); },
});
new client.Gauge({
  name: 'api_pg_pool_waiting',
  help: 'Waiting acquires',
  collect() { this.set(pool.waitingCount); },
});
```

Alarm: `pool_waiting > 0` sustained = pool exhaustion.

## Event Loop Lag

```ts
import { monitorEventLoopDelay } from 'node:perf_hooks';

const eld = monitorEventLoopDelay({ resolution: 10 });
eld.enable();

new client.Gauge({
  name: 'api_event_loop_lag_p99_ms',
  help: 'Event loop lag p99 (ms)',
  collect() {
    this.set(eld.percentile(99) / 1e6);
    eld.reset();
  },
});
```

**Alarm**: p99 > 50 ms sustained → something is blocking the loop.

## SLOs & Error Budgets

- **SLO**: "99% of requests complete in < 500 ms over 30 days"
- **Error budget**: 1% = ~7 hours of bad performance / month
- When budget burn rate > 1× → page
- When burn rate > 10× → critical incident

Use **Sloth** (Prometheus SLO generator) or Grafana's SLO panel.

## Sampling Strategy

Full-fidelity traces on every request gets expensive.

- **Head sampling**: random 1–10% of requests fully traced
- **Tail sampling**: always keep errors + slow requests; sample the rest
- **Per-route overrides**: 100% on `/auth/*`, 1% on `/healthz`

OpenTelemetry Collector handles both.

## Dashboards You Need Day 1

1. **API overview** — RED per route, top 10 slowest routes
2. **DB** — pool utilization, query latency p95, slow query log count
3. **Redis** — hit rate, latency, connection count
4. **Event loop** — lag p99, GC pause time, RSS memory
5. **External deps** — HTTP client latency p95, error rate per upstream
6. **SLO** — error budget remaining, burn rate

## Hand-off

- **Error taxonomy + Sentry + Problem Details (RFC 7807)** → delegate to `error-handling`
- **Schema-level tracing (pg_stat_statements, slow query log)** → delegate to `database-architect`
