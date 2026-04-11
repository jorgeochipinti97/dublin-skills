# API Observability — Logs, Metrics, Traces, Alerts

Reference for making an API observable. Sources: Google SRE books, *Observability Engineering* (Charity Majors et al.), OpenTelemetry docs, Honeycomb / Datadog engineering blogs, Liz Fong-Jones talks.

---

## 1. The Three Pillars — and Why They're Different

| Pillar | Shape | Question it answers |
|---|---|---|
| **Logs** | Discrete events | "What happened at this point in time?" |
| **Metrics** | Numeric aggregates over time | "How is the system behaving on average?" |
| **Traces** | Request paths across services | "Where did the time go in this request?" |

You need all three. None replaces the others.

Modern stack: unified with **OpenTelemetry** (OTel) — one SDK, one wire format, multiple backends.

---

## 2. The Observability Mindset

**Monitoring** tells you IF something is wrong (predefined alerts).
**Observability** lets you ask arbitrary questions after the fact — including questions you didn't know you'd need to ask.

The shift: from "dashboards of known failures" to "rich data you can query when the unknown happens."

### 2.1 The rule

> If you can't debug a production problem you've never seen before, you're not observable.

### 2.2 High cardinality > low cardinality

Old monitoring: aggregates like "avg latency by service". Loses user-specific info.

New observability: per-request data including user_id, tenant_id, request_id, feature flags, version, region. When something breaks, you filter by user and see exactly what happened.

High-cardinality fields (user IDs, trace IDs, request IDs) are essential. Your tool must support them (Honeycomb, Datadog APM, Lightstep/New Relic, Grafana Cloud, Clickhouse-backed custom).

---

## 3. Structured Logging

### 3.1 Structured, not strings

**Bad**:
```
[ERROR] User 123 failed to checkout with card ending 4242 after 3 retries
```

**Good**:
```json
{
  "ts": "2026-04-11T14:30:00.123Z",
  "level": "error",
  "msg": "checkout_failed",
  "user_id": "123",
  "card_last4": "4242",
  "retry_count": 3,
  "error": "card_declined",
  "trace_id": "abc123",
  "request_id": "req_xyz"
}
```

Structured logs are queryable: `level:error AND user_id:123 AND error:card_declined`. String logs are not.

### 3.2 Required fields on every log line

- `ts` — ISO 8601 UTC timestamp
- `level` — debug / info / warn / error / fatal
- `msg` — short event name (`checkout_started`, `db_query_slow`)
- `trace_id` — links to the request trace
- `request_id` — unique per request (generated at the edge)
- `service` — name of the service
- `version` — build/commit SHA
- `env` — prod / staging / dev
- `user_id`, `tenant_id` — when available
- `duration_ms` — for timed operations

### 3.3 Log levels — use correctly

- **DEBUG** — step-by-step internal detail, OFF in prod usually
- **INFO** — normal events worth recording (signup, checkout, deploy)
- **WARN** — unexpected but recoverable (retry succeeded, deprecated API used)
- **ERROR** — failure that affects a user (card declined, 5xx)
- **FATAL** — process-ending, unrecoverable (config missing, can't connect to DB at startup)

### 3.4 What NOT to log

- **PII in plaintext** — passwords, tokens, CVV, full card numbers, SSN, health info
- **Secrets** — API keys, JWT payloads, signed URLs
- **Huge bodies** — request/response bodies (use sampling if needed)
- **Sensitive headers** — Authorization, Cookie (redact)

Set up log redaction at the logging library level, not hope developers remember.

### 3.5 Sampling

At high volume, log everything is expensive. Sample:
- 100% of errors
- 100% of slow requests (> threshold)
- 1-10% of normal requests
- Keep trace-level sampling consistent (same trace = all or nothing)

Tail-based sampling (decide after the fact) is better than head-based but more complex.

---

## 4. Metrics — RED and USE

### 4.1 RED method (for services / APIs)

For every endpoint:

- **Rate** — requests per second
- **Errors** — failed requests per second (rate, not ratio)
- **Duration** — latency distribution (p50, p95, p99)

These three cover 90% of service monitoring needs.

### 4.2 USE method (for infrastructure / resources)

For every resource (CPU, memory, disk, network):

- **Utilization** — % time busy
- **Saturation** — queue depth, wait time
- **Errors** — error count

Complements RED. RED = what users experience, USE = what your machines are doing.

### 4.3 Histograms, not averages

Average latency is a lie. A service where 99% of requests take 10ms and 1% take 10s has a 110ms average — looks fine, feels broken.

**Always use histograms**:
- p50 (median) — typical request
- p95 — "slow" request
- p99 — "the annoying 1%"
- p99.9 — tail

Prometheus histograms, OTel histograms, DataDog distributions. Never just `avg()`.

### 4.4 Counters, gauges, histograms

- **Counter** — monotonic (always increases): request count, error count, queue push count
- **Gauge** — snapshot value (up or down): active connections, queue depth, memory in use
- **Histogram** — distribution of values: request latency, response size, batch size

Use the right type. Counter / gauge / histogram are not interchangeable.

### 4.5 Cardinality discipline in metrics

Metrics are typically **low cardinality**. Don't put user IDs or request IDs in labels — Prometheus explodes.

- Bad: `http_requests_total{user_id="123", request_id="xyz"}` → millions of series
- Good: `http_requests_total{endpoint="/orders", method="GET", status="200"}`

Put high-cardinality data in traces and logs. Keep metrics low cardinality.

### 4.6 Key API metrics to track

| Metric | Type | Labels |
|---|---|---|
| `http_requests_total` | counter | method, route, status |
| `http_request_duration_seconds` | histogram | method, route |
| `http_request_size_bytes` | histogram | method, route |
| `http_response_size_bytes` | histogram | method, route |
| `db_query_duration_seconds` | histogram | query_name, status |
| `cache_hits_total` | counter | cache_name |
| `cache_misses_total` | counter | cache_name |
| `queue_depth` | gauge | queue_name |
| `job_duration_seconds` | histogram | job_name, status |
| `external_call_duration_seconds` | histogram | service, status |

---

## 5. Distributed Tracing

### 5.1 Why traces

In a microservice or multi-step system, a single user request hits 5-20 services. When it's slow, you need to know **which hop** ate the time.

Traces answer that exact question.

### 5.2 Key concepts

- **Trace** — a complete request path, identified by `trace_id`
- **Span** — a single unit of work within a trace (DB query, HTTP call, function)
- **Parent/child spans** — traces form a tree
- **Span attributes** — metadata on each span (method, route, status, custom tags)
- **Span events** — timestamped logs within a span

### 5.3 Propagation

Trace context propagates via headers between services.

**W3C Trace Context** (industry standard):
```
traceparent: 00-<trace_id>-<span_id>-<flags>
tracestate: <vendor-specific>
```

Every service:
1. Reads `traceparent` on incoming requests
2. Creates child spans under the parent
3. Injects `traceparent` on outgoing calls
4. Exports spans to a collector (OTel Collector → Jaeger / Tempo / DataDog / Honeycomb)

### 5.4 What to instrument

- Every HTTP endpoint (automatic via OTel auto-instrumentation)
- Every DB query
- Every cache call
- Every external API call
- Every queue operation (publish and consume)
- Expensive functions (reports, ML inference)
- Background jobs (with the trace_id from the enqueuing request)

### 5.5 Sampling strategy

At scale, tracing every request is expensive.

- **Head-based sampling**: decide at the start (random 1%). Simple, may miss errors.
- **Tail-based sampling**: decide at the end (always keep errors, slow requests, sampled normal). Better but requires a collector with buffering (OTel Collector, Refinery).

Sample 100% of errors always. Sample normal traffic based on budget.

### 5.6 OpenTelemetry (OTel)

The vendor-neutral standard. One SDK → one format → any backend.

- **Instrumentation libraries** for every major language and framework
- **Auto-instrumentation** covers HTTP, DB, cache, queues, gRPC
- **Manual instrumentation** for business spans
- **OTel Collector** — receives, processes, exports to your backend

**Use OTel, not vendor-specific SDKs.** Portability matters when you change backends.

---

## 6. Error Tracking

### 6.1 Purpose

Capture unhandled errors and exceptions with stack traces, breadcrumbs, user context, and grouping.

### 6.2 Tools

- Sentry (most common)
- Rollbar
- Bugsnag
- Honeycomb (via traces)
- Datadog Error Tracking

### 6.3 What they give you

- Stack traces with source code context
- Grouping — same error shape collapses into one issue
- Frequency and affected users
- Release tracking (which deploy introduced the error)
- Breadcrumbs (recent actions before the crash)
- Alerts for new errors or regressions

### 6.4 Best practices

- Tag with release (commit SHA) and environment
- Attach user context (user_id, tenant_id — not PII)
- Use source maps / debug symbols for readable traces
- Link to the trace_id so you jump from error → trace
- Don't report expected errors (validation failures, 404s)

---

## 7. Alerting

### 7.1 The principle

Alerts wake people up at 3am. Every alert must be:
- **Urgent** — requires human action NOW
- **Actionable** — there's something to do
- **Specific** — clear about what's broken

Alerts that aren't urgent → demote to a dashboard or a ticket.

### 7.2 SLO-based alerts (recommended)

Don't alert on "latency > 500ms". Alert on "we're burning the monthly error budget too fast."

**Multi-window, multi-burn-rate alerting** (Google SRE):

- **Fast burn** — last 1h consumed > 2% of monthly budget → page
- **Slow burn** — last 6h consumed > 5% of monthly budget → ticket

This catches both sudden outages and slow degradations while avoiding noise.

### 7.3 Anti-patterns

- **Static thresholds** — "alert if CPU > 80%". What if it's a batch job? Noise.
- **Too sensitive** — pages on every blip. Alert fatigue kills response.
- **Not actionable** — "system load high". What do I DO?
- **Missing context** — "error count increased". Error on what? Where?
- **No runbook link** — alerts should link to documentation of what to check

### 7.4 Alert routing

- Pages → PagerDuty / OpsGenie / incident.io (wake the on-call)
- Tickets → Jira / Linear (fix in business hours)
- Slack → informational only (never urgent)
- Email → basically never urgent

### 7.5 On-call rotation

- Sustainable load — alerts per shift < 2 on average
- Clear escalation — secondary, manager, exec
- Runbooks for every alert
- Post-mortem for every page (learn from every wake-up)

---

## 8. Dashboards — Few and Focused

### 8.1 Types of dashboards

- **Overview** — one dashboard, key SLIs at a glance, health check (for leadership / NOC)
- **Service** — per service, RED metrics, top errors, resource usage (for the service team)
- **Debug** — for drilling into specific issues (for on-call)
- **Business** — user-facing metrics (signups, revenue, DAU) — separate from eng dashboards

### 8.2 Rules

- **One screen** — no endless scrolling
- **Top-down** — SLIs at the top, details below
- **Consistent time range** across all panels
- **Color for meaning** — red = bad, green = good, not aesthetic
- **Title each panel with the question it answers** — "Are we meeting the latency SLO?"
- **Link to runbooks** — when a panel is red, what do I do?

### 8.3 Tools

- **Grafana** — the standard, works with everything
- **Datadog** — commercial, batteries-included
- **Honeycomb** — high-cardinality, trace-first
- **New Relic** — full-stack APM
- **Built-in cloud dashboards** (CloudWatch, Stackdriver) — minimum viable

---

## 9. Correlation — the Observability Superpower

The real power of observability: **jumping between logs, metrics, and traces seamlessly.**

### 9.1 The pattern

- Metric shows a latency spike → click → see traces during that window
- Trace shows a slow span → click → see logs for that service + trace_id
- Log shows an error → click → see the full trace and related metrics
- Error tracker shows a new error → click → see the trace that produced it

### 9.2 What makes it work

- **Consistent trace_id** across all three pillars (added via OTel)
- **Same time sync** (NTP across all services)
- **Backend that supports linking** (Datadog, Honeycomb, Grafana Cloud, New Relic)

Without correlation, you're debugging with three disconnected tools. With it, you're diagnosing in minutes, not hours.

---

## 10. Black-Box vs White-Box Monitoring

- **White-box** — internal metrics (CPU, memory, DB query time, cache hit rate). Tells you WHY.
- **Black-box** — external probes (synthetic checks, real-user monitoring). Tells you WHAT the user sees.

You need both. Internal metrics might say "everything is fine" while DNS is broken and users can't reach you. Black-box catches that.

### 10.1 Synthetic checks

- Every minute, hit `/health` and key endpoints
- From multiple regions
- Alerts on failure
- Tools: Datadog Synthetics, Pingdom, Checkly, StatusGator, UptimeRobot

### 10.2 Real-user monitoring (RUM)

- JavaScript SDK in the web app
- Captures actual user latency, errors, Core Web Vitals
- Especially important for frontend-heavy apps
- Tools: Datadog RUM, New Relic Browser, Sentry, Vercel Speed Insights

---

## 11. Log / Metric / Trace Cost Management

Observability is expensive. Watch the bill.

### 11.1 Where costs come from

- Log volume — every line costs
- Metric cardinality — every unique label combination is a new series
- Trace sampling — full traces are ~1KB each, multiplied by QPS
- Retention — keeping data longer costs linearly

### 11.2 Levers

- **Sample traces** — keep errors + slow, downsample normal
- **Reduce metric labels** — remove high-cardinality ones
- **Drop debug logs** in production
- **Compress logs** at ingestion
- **Tiered retention** — 7 days hot, 30 days warm, 1 year cold
- **Separate logs** for different audiences (security logs have different retention than app logs)

---

## 12. The Observability Checklist

- [ ] Structured JSON logs with required fields
- [ ] Sensitive data redacted at the logging library
- [ ] OpenTelemetry SDK installed and exporting
- [ ] Auto-instrumentation for HTTP, DB, cache, queues
- [ ] Trace context propagated across every service hop
- [ ] RED metrics on every endpoint (rate, errors, duration)
- [ ] Histograms for latency (not averages)
- [ ] SLOs defined with p95/p99 thresholds
- [ ] SLO-based burn-rate alerts (not static thresholds)
- [ ] Error tracking (Sentry / Rollbar / Datadog)
- [ ] Dashboards: one overview, one per service, one per team
- [ ] Runbooks linked from every alert
- [ ] Synthetic checks + RUM for user-facing perspective
- [ ] Log/metric/trace correlation via trace_id
- [ ] Cost monitoring on the observability pipeline itself
- [ ] On-call rotation with sustainable alert volume
- [ ] Post-mortem process for every page
