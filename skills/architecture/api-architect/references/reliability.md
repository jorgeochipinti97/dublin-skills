# API Reliability — Retries, Timeouts, Circuit Breakers, SLOs

Reference for making APIs resilient under failure. Sources: Google SRE books, *Release It!* (Michael Nygard), AWS Well-Architected Reliability Pillar, Netflix Hystrix / Resilience4j, Stripe engineering posts.

---

## 1. The Reliability Mindset

**Everything fails eventually.** Network blips, DB crashes, upstream timeouts, disk full, OOM, bad deploys. The question is not *if* but *when* — and whether your system degrades gracefully or goes down hard.

Reliability is about **containing failure** so that one component's problem doesn't cascade into a full outage.

---

## 2. Timeouts — Your First Defense

### 2.1 The rule

**Every I/O call has a timeout.** No exceptions. The default timeout of "forever" in many HTTP clients is a loaded gun.

- DB queries: 1-5s max
- Cache calls: 100-500ms
- Upstream HTTP calls: 1-10s based on endpoint
- Outbound webhooks: 10-30s
- Internal service calls: 500ms-2s

### 2.2 Timeout hierarchy

Timeouts propagate through the stack. If the client has a 30s timeout, every nested call must sum to < 30s. Otherwise you'll return stale responses or the client sees a failure while work continues.

**Pattern**: deadline propagation.
- Client sets deadline (e.g., `now + 10s`)
- Server derives remaining time on every hop
- Each hop checks: "do I have time for this call?"

gRPC supports this natively. HTTP needs a convention (e.g., `X-Deadline` header).

### 2.3 Connect vs read timeouts

- **Connect timeout** — how long to wait for a TCP handshake (usually 1-3s)
- **Read timeout** — how long to wait for the first byte of response (1-30s depending on operation)
- **Total timeout** — overall cap

Set all three. Many libraries only set one by default.

---

## 3. Retries — Done Right

### 3.1 When to retry

**Only retry idempotent operations.** Retrying a POST that already charged a card = double charge. See `design.md §11` for idempotency keys.

Retryable errors:
- Network errors (connection refused, TCP reset)
- 5xx from server (503, 504)
- 408 Request Timeout
- 429 Too Many Requests (with `Retry-After`)

NOT retryable:
- 4xx client errors (your request is wrong, retrying won't fix it)
- 400 Bad Request, 401, 403, 404, 422

### 3.2 Exponential backoff + jitter

Retrying immediately causes a **thundering herd** — all clients hit the failing server at the same time.

**Solution**: exponential backoff with jitter.

```
attempt 1: wait 100ms
attempt 2: wait 200-400ms (random)
attempt 3: wait 400-800ms
attempt 4: wait 800-1600ms
attempt 5: give up
```

Pseudocode:
```
delay = min(cap, base * 2^attempt)
jittered = random(0, delay)  # "full jitter" - AWS recommended
sleep(jittered)
```

### 3.3 Maximum attempts

Always cap retries. 3-5 attempts is typical. Infinite retries create cascading failures and exhaust resources.

### 3.4 Budget retries

In Google SRE: **retry budget**. Limit the ratio of retry traffic to normal traffic (e.g., max 10% retries). When the budget is exceeded, stop retrying — the system is clearly in trouble and retries are making it worse.

### 3.5 Don't retry at every layer

If the client retries, the gateway retries, the service retries, and the DB retries, one failure becomes 625 attempts. Pick ONE layer to retry at (usually the outermost client).

---

## 4. Circuit Breakers

### 4.1 The concept (Netflix Hystrix)

When an upstream service is failing, the circuit breaker stops calling it, returning failures immediately. After a cooldown, it lets a test call through. If it succeeds, the circuit closes (traffic resumes).

### 4.2 States

- **CLOSED** — normal, calls pass through
- **OPEN** — failing, all calls fail fast
- **HALF-OPEN** — testing recovery, small % of calls allowed

### 4.3 When to use

Any call to an external service or a non-critical internal service:
- Third-party APIs (payment providers, email senders)
- Non-essential downstream services (analytics, recommendations)
- External search / ML endpoints

### 4.4 Libraries

- **Java/Kotlin**: Resilience4j
- **Node**: opossum, cockatiel
- **Go**: gobreaker, sony/gobreaker
- **Python**: pybreaker, tenacity
- **Service mesh**: Envoy / Istio handles this for you

### 4.5 Fallbacks

When the circuit is open, return a fallback:
- Cached (stale) data
- Degraded experience (partial result)
- Friendly error
- Default values

**Example**: product page without recommendations is better than no product page.

---

## 5. Bulkheads

### 5.1 The concept

Isolate resources so that one failing dependency can't drain all capacity.

Named after ship bulkheads: one compartment floods, the ship still floats.

### 5.2 Patterns

- **Connection pool per upstream** — slow DB can't consume all connections needed for cache
- **Thread pool per dependency** — slow payment API can't block user login
- **Semaphore limits** — max N concurrent calls to any given upstream
- **Separate deployments** for critical vs non-critical work

### 5.3 Example

You have one Postgres connection pool of 50. A slow analytics query holds 49 connections. Login can't get a connection → site outage.

**Fix**: separate pools (or separate services) for transactional reads vs analytics.

---

## 6. Graceful Degradation

When things are broken, degrade instead of failing entirely.

### 6.1 Patterns

- **Stale-while-error** — serve cached data when upstream is down
- **Disabled features** — turn off non-essential features under load (feature flags)
- **Progressive timeouts** — reduce latency budgets under load to preserve SLOs
- **Read-only mode** — disable writes during DB incidents
- **Static fallbacks** — hard-coded responses for critical endpoints

### 6.2 Feature flags as reliability levers

Flags for:
- Kill switches (disable a feature if it's breaking)
- Gradual rollouts (canary)
- Per-tenant overrides (disable for a problematic customer)
- Load-shedding flags (disable expensive endpoints under load)

Tools: LaunchDarkly, Unleash, GrowthBook, Statsig, flagd, ConfigCat, or a DB table + Redis cache.

---

## 7. Load Shedding

When the system is overloaded, reject some requests to save the rest.

### 7.1 Patterns

- **Rate limit** (see `scalability.md`) — preventative
- **Priority queuing** — drop low-priority work first
- **Random shedding** — reject X% of requests (simple)
- **Adaptive shedding** — monitor p99 latency; shed more as latency grows
- **503 Service Unavailable + Retry-After** — tell clients to back off

### 7.2 Example

During a traffic spike, the system detects p99 > 1s. It starts returning 503 to 10% of requests. If latency keeps climbing, shed more. If it recovers, resume full traffic.

Libraries: envoy overload manager, Netflix concurrency-limits, Vegeta for testing.

---

## 8. Idempotency (for reliability, not just design)

Covered in `design.md §11`. Reliability perspective:

- Idempotency keys let clients safely retry
- Servers must store and dedupe correctly
- Without them, network hiccups cause duplicate operations (charges, orders, emails)

**This is mandatory** for payments, inventory, anything with real-world effects.

---

## 9. Health Checks

### 9.1 Three levels

- **Liveness** (`/healthz`) — "is the process alive?" Usually just returns 200. Used by Kubernetes to restart dead containers.
- **Readiness** (`/readyz`) — "can this instance handle traffic?" Checks DB connectivity, cache, migrations. Used by load balancers to route traffic.
- **Deep health** (`/healthz/deep`) — verifies downstream dependencies. Used for monitoring and on-call.

### 9.2 Readiness vs liveness — critical distinction

- Liveness fails → kill the pod. Use sparingly. A flapping liveness probe causes restart loops.
- Readiness fails → stop routing traffic, but don't kill. The pod can recover.

**Don't use DB checks in liveness** — if the DB blips, every pod restarts, worsening the outage.

### 9.3 What to check in readiness

- DB connection (cheap ping, not a query)
- Cache connection
- Required config loaded
- Migrations up-to-date
- Any hard dependency the service needs to function

---

## 10. Graceful Shutdown

### 10.1 The flow

When a server receives SIGTERM (deployment, scale-down):

1. Stop accepting NEW connections
2. Finish in-flight requests (with a timeout, ~30s)
3. Drain connection pools
4. Flush logs and metrics
5. Exit cleanly

### 10.2 Kubernetes integration

- `terminationGracePeriodSeconds` — how long K8s waits before SIGKILL
- `preStop` hook — run custom cleanup
- **PreStop sleep** — wait a few seconds after readiness probe fails so the load balancer has time to drain

### 10.3 Why it matters

Hard kills mean:
- In-flight requests fail
- Users see 502/503 during deploys
- Data may be half-written
- Sessions drop

Graceful shutdown turns deploys into no-op events for users.

---

## 11. SLO / SLI / SLA (know the difference)

### 11.1 Definitions

- **SLI (Service Level Indicator)** — a measurement. "p99 latency of GET /orders"
- **SLO (Service Level Objective)** — a target. "p99 < 300ms, 99.9% of the time, measured over 30 days"
- **SLA (Service Level Agreement)** — a contract. "If we miss the SLO, we refund X%."

**Internal teams**: live and breathe SLOs, not SLAs.

### 11.2 Picking SLIs

Good SLIs:
- **Availability** — % of requests that succeeded
- **Latency** — % of requests faster than threshold (e.g., % under 300ms)
- **Quality** — % of requests with correct results
- **Freshness** — how stale the data is (for caches)

Bad SLIs:
- Server CPU (what users don't care about)
- Number of pods
- Queue depth (unless it's the product)

### 11.3 Error budget

If your SLO is 99.9% uptime, you have a **0.1% error budget** = ~43 minutes per 30 days.

**Policy**:
- Budget not yet spent → ship features freely
- Budget spent → stop shipping, focus on reliability
- Budget exhausted twice → post-mortem and process review

The error budget aligns product and reliability teams. No more "eng wants to slow down, product wants to ship faster" — the numbers decide.

### 11.4 Burn rate alerts

Static thresholds (e.g., "alert if latency > 500ms") cause alert fatigue.

**SLO-based alerting**:
- Alert when you're burning the monthly budget too fast
- Example: "alert if the last 1h of traffic consumed > 2% of the monthly budget"

This ties alerts directly to user impact. See Google's "Site Reliability Workbook" chapter on alerting.

---

## 12. Chaos Engineering

### 12.1 The concept

Intentionally break things in controlled environments to find weaknesses before users do.

### 12.2 Start simple

- Kill random pods in staging
- Inject latency into DB calls
- Fill a disk
- Drop packets
- Simulate DNS failures

### 12.3 Tools

- **Chaos Mesh** (Kubernetes-native)
- **Gremlin** (commercial)
- **Litmus** (open source)
- **Toxiproxy** (network chaos for local dev)

### 12.4 Only if you have the maturity

Chaos engineering works when you have: observability, runbooks, blameless culture, and SLOs. Otherwise you're just creating outages without learning.

---

## 13. Deployment Safety

### 13.1 Techniques

- **Blue-green** — run new and old side-by-side, flip traffic instantly, rollback is a flip
- **Canary** — send 1% → 10% → 50% → 100% over time, watch metrics at each step
- **Rolling update** — replace instances gradually (K8s default)
- **Feature flags** — decouple deploy from release (deploy dark, flip flag)
- **Shadow traffic** — mirror production traffic to new version without affecting users

### 13.2 Rollback must be faster than roll-forward

If you discover a bad deploy, rollback in seconds. Not minutes, not hours.

- Automated rollback on SLO breach
- Simple commands (`kubectl rollout undo`)
- No manual approval gates that block during an incident

### 13.3 Database migrations

Never couple a backward-incompatible migration with a code deploy. Use **expand-contract**:

1. **Expand**: add new column/table, write to both old and new, read from old
2. **Migrate**: backfill historical data
3. **Contract**: switch reads to new, stop writing to old, drop old

Each step is independently deployable and rollback-safe.

---

## 14. Disaster Recovery

### 14.1 RPO and RTO

- **RPO** (Recovery Point Objective) — how much data can you afford to lose? (1h? 1 day?)
- **RTO** (Recovery Time Objective) — how long to recover? (15min? 4h?)

Cheaper recovery = higher RPO/RTO. Pick based on business need.

### 14.2 Backup strategy

- **Automated backups** — daily full + continuous WAL (point-in-time recovery)
- **Tested restores** — you haven't backed up until you've restored. Practice quarterly.
- **Offsite / cross-region** — natural disaster, region outage, account compromise
- **Encrypted at rest** — with keys in a separate account/vault
- **Retention policy** — 30 days hot, 1 year cold, legal holds per compliance

### 14.3 Multi-region

For very high availability (99.99%+):
- Active-passive — standby region, failover on disaster
- Active-active — both regions serve traffic, complexity rises (replication lag, split-brain)

**Cost**: multi-region doubles infra costs. Most products don't need it. Get single-region right first.

---

## 15. Dependency Management

### 15.1 Every dependency is a potential outage

Map your dependencies:
- Upstream services (internal / external)
- Databases
- Caches
- Message queues
- Third-party APIs (payment, email, SMS, analytics)
- DNS providers
- Cloud services (S3, SQS, etc.)

### 15.2 Criticality tiers

- **Tier 1** (critical path) — can't function without → must be highly available, fallbacks, circuit breakers
- **Tier 2** (enhances experience) — degrade gracefully if down
- **Tier 3** (nice to have) — silent failure is okay

### 15.3 Third-party APIs

- Budget their latency and errors against your SLOs
- Monitor their status pages
- Have fallbacks for critical ones
- Rate-limit your own usage to avoid hitting their limits
- Negotiate SLAs for mission-critical dependencies

---

## 16. Post-Incident Practice

### 16.1 Blameless post-mortems

- Focus on **systems**, not **people**
- Ask "how did the system let this happen?" not "who made the mistake"
- Document: timeline, root cause, contributing factors, action items, lessons

### 16.2 Action items

- Small, assigned, dated
- Prevent the same failure, not punish the failure
- Published internally for others to learn

### 16.3 Game days

Periodically simulate incidents — on-call practice, runbook verification, tool familiarity. The first time you use a runbook should not be during an actual outage.

---

## 17. Reliability Checklist

- [ ] Every I/O call has a timeout
- [ ] Retries use exponential backoff + jitter
- [ ] Retries capped at 3-5 attempts
- [ ] Retries only at one layer
- [ ] Circuit breakers on external dependencies
- [ ] Bulkheads (separate pools/queues for critical vs non-critical)
- [ ] Idempotency keys on all mutating endpoints
- [ ] Liveness and readiness probes defined correctly
- [ ] Graceful shutdown (SIGTERM → drain → exit)
- [ ] SLOs defined for availability and latency
- [ ] Error budget policy
- [ ] SLO-based alerting (burn rate, not static thresholds)
- [ ] Deployments are blue-green / canary / rolling
- [ ] Rollback is fast and tested
- [ ] DB migrations are expand-contract
- [ ] Backup + tested restore
- [ ] Runbooks for common incidents
- [ ] Blameless post-mortem process
- [ ] Dependency map with criticality tiers
