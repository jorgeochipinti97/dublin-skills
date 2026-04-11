# API Gateways — Theory, Options, Patterns

Focused reference for designing API gateways and edge layers. Covers: what a gateway is (and isn't), when to use one, the off-the-shelf options, deployment patterns (edge vs central), GraphQL federation, protocol translation, and anti-patterns.

For the mechanics of what gateways *do* (rate limiting algorithms, auth protocols, circuit breakers, observability), load the corresponding references: `security.md`, `scalability.md`, `reliability.md`, `observability.md`.

---

## 1. What Is an API Gateway

A gateway is **a single entry point** in front of one or more backend services that handles cross-cutting concerns so services don't have to.

### 1.1 Core responsibilities

- **Routing** — match incoming URL to a backend service
- **Authentication** — verify tokens / keys before hitting services
- **Authorization** (optional) — enforce scopes / policies at the edge
- **Rate limiting** — protect backends from abuse
- **Caching** — serve cached responses without hitting backends
- **Request/response transformation** — rewrite paths, headers, bodies
- **Protocol translation** — HTTP ↔ gRPC, REST ↔ GraphQL
- **TLS termination** — offload HTTPS
- **Load balancing** — distribute requests across instances
- **Circuit breaking** — fail fast on dead upstreams
- **Observability** — log, meter, trace every request in one place
- **Versioning** — route by version header or URL path
- **WAF / bot protection** — block obvious attacks
- **API composition** — aggregate multiple calls into one response (lightweight BFF)

### 1.2 What a gateway is NOT

- **Not a service mesh** — meshes handle service-to-service; gateways handle client-to-service (north-south vs east-west). Some products (Istio, Linkerd) do both.
- **Not a business logic layer** — business logic lives in services. If your gateway has domain rules, you're doing it wrong.
- **Not a database** — don't store app state in it.
- **Not a silver bullet** — adds a hop (latency), a SPOF (reliability), and a config surface (complexity).

---

## 2. When to Use a Gateway

### 2.1 Use a gateway when

- You have **multiple backend services** and want one URL for clients
- You need **consistent auth / rate limit / logging** across services without duplicating code
- You need **public-facing** API with edge-level protection (DDoS, WAF, bot mitigation)
- You need **protocol translation** (gRPC services, HTTP clients)
- You need **API composition** (one client call → multiple backend calls)
- You want **gradual rollouts** (canary, feature flags, traffic shaping) at the edge
- You're doing **GraphQL federation** across multiple subgraphs
- You need **SDK-friendly versioning** and deprecation

### 2.2 Don't use a gateway when

- You have **one service** and no near-term plans for more (gateway is overhead)
- You have **internal-only** APIs with no edge concerns (use a service mesh instead)
- You're in a **monolith** and all traffic already hits one process (the monolith IS the gateway)
- You can't afford the **extra hop** (latency-sensitive workloads — trading, gaming)
- You don't have the **ops maturity** to run another piece of infra

### 2.3 Common mistake

Teams add a gateway "because microservices need one". You don't — a monolith with a CDN + WAF in front is often enough until you have 3+ services and a cross-cutting concern problem.

---

## 3. Gateway vs BFF vs Direct-to-Service

Three distinct patterns, often confused.

### 3.1 Direct-to-service

Client calls the service directly.

```
[ Client ] ──→ [ Service ]
```

**Good for**: single-service apps, internal tools, low-complexity stacks.

### 3.2 API Gateway (passthrough)

Generic gateway routes to services with minimal transformation.

```
           ┌─→ [ Users Service ]
[ Client ]─│
 [ GW ]    ├─→ [ Orders Service ]
           └─→ [ Payments Service ]
```

**Good for**: many services, uniform cross-cutting concerns, public API.

### 3.3 BFF (Backend for Frontend)

A per-client gateway that aggregates and shapes data for a specific client type (web, mobile, TV).

```
[ Web client ]──→ [ Web BFF ]──┐
                                ├──→ [ Services ]
[ iOS client ]──→ [ iOS BFF ]──┘
```

**Good for**: when different clients need different data shapes, different auth flows, different latency budgets. Popularized by SoundCloud and Netflix.

**Difference from a plain gateway**: BFFs contain **client-specific logic** (aggregation, formatting, UX-driven composition). Gateways are generic.

### 3.4 Hybrid — the common real-world shape

```
[ Client ] → [ Edge (CDN + WAF) ] → [ API Gateway ] → [ BFF per client ] → [ Services ]
```

Not every layer is needed. Add them when pain justifies it.

---

## 4. The Options (Matrix)

### 4.1 Decision axes

- **Deployment**: managed cloud / self-hosted
- **Performance**: latency, throughput, resource use
- **Protocol**: HTTP/1.1 / HTTP/2 / gRPC / WebSocket / GraphQL
- **Ecosystem lock-in**: cloud-specific / portable
- **Programmability**: config-only / custom plugins / WASM / JS
- **Config model**: file / API / declarative (CRD) / UI
- **Observability**: out of the box / bring your own
- **Cost**: pay-per-request / self-host ops cost

### 4.2 Quick picks

| Need | Pick |
|---|---|
| Ship fast on AWS, don't want ops | **AWS API Gateway** (HTTP API variant) |
| Ship fast on Azure | **Azure API Management** |
| Ship fast on GCP | **Apigee** or **Cloud Endpoints** |
| Self-hosted, open source, mature | **Kong** |
| Self-hosted, modern, cloud-native | **Envoy** (via Emissary, Gloo, Contour) |
| Kubernetes-native, simple | **Traefik** or **Envoy Gateway** |
| Lightweight, script-heavy config | **Nginx** (or OpenResty for programmability) |
| GraphQL federation | **Apollo Router** (Rust) |
| Edge compute + gateway | **Cloudflare** (Workers + API Shield) |
| Next.js-native edge layer | **Vercel Edge Middleware / Functions** |
| API-as-a-product SaaS | **Tyk** or **Kong Konnect** |
| Tiny / dev / simple | **Caddy** |

---

## 5. Option Deep Dives

### 5.1 Kong

**What**: The most widely deployed open-source gateway. Built on Nginx + Lua (OpenResty). Plugin ecosystem for auth, rate limit, logging, transformation.
**Pros**: mature, huge plugin ecosystem, runs anywhere, good performance, strong Kubernetes story (Kong Ingress Controller), both OSS and managed (Konnect).
**Cons**: Lua plugins feel dated vs WASM, DB-backed mode can be a bottleneck (use DB-less mode for scale), UI is commercial-only.
**Use when**: you need a proven gateway with a rich plugin library and you're okay running it yourself.

### 5.2 Envoy / Envoy Gateway / Gloo / Emissary

**What**: Envoy is a C++ proxy (originally Lyft, now CNCF). Envoy Gateway, Emissary (formerly Ambassador), and Gloo wrap it for Kubernetes.
**Pros**: best-in-class performance, HTTP/2 + gRPC native, xDS dynamic config, observability built in, basis for service meshes (Istio uses it), WASM plugins (portable, typed).
**Cons**: config is verbose without a wrapper, steep learning curve, operator knowledge required.
**Use when**: Kubernetes-heavy stack, gRPC + HTTP mix, performance-sensitive, want the best tech under the hood.

### 5.3 AWS API Gateway

**What**: Managed gateway on AWS. Two flavors:
- **REST API** — feature-rich, pay per request, higher latency
- **HTTP API** — simpler, 60% cheaper, lower latency, fewer features (no per-method caching, no API keys on usage plans... but covers 90% of cases)

**Pros**: zero ops, auto-scaling, tight integration with Lambda/Cognito/IAM/WAF, pay per request.
**Cons**: vendor lock-in, cold starts with Lambda integrations, limited programmability (no custom plugins — use Lambda authorizers), quirky config, no good local dev, can get expensive at high volume.
**Use when**: you're on AWS, want managed ops, traffic is moderate, backends are mostly Lambda or ALB.

### 5.4 Azure API Management (APIM)

**What**: Managed gateway on Azure with a developer portal, policies in XML.
**Pros**: best-in-class developer portal (auto-generated docs + try-it-out), policy engine is powerful, deep Azure integration, multi-region option.
**Cons**: expensive (minimum tier > $0/mo unlike AWS HTTP API), XML policies feel legacy, cold start on some tiers.
**Use when**: you're on Azure and want a real developer portal for partners.

### 5.5 Google Apigee / Cloud Endpoints

**Apigee** — enterprise-grade, expensive, powerful. Best for regulated / enterprise API programs.
**Cloud Endpoints** — lightweight, simple, OpenAPI-driven, cheap.
**Pros**: deep GCP integration, Apigee has mature analytics and monetization features.
**Cons**: Apigee is pricey and complex; Cloud Endpoints is limited.
**Use when**: GCP-native stack.

### 5.6 Tyk

**What**: Open-source gateway with a commercial dashboard. Go-based, fast, flexible.
**Pros**: good performance, API-as-a-product features (keys, quotas, analytics, developer portal), both self-host and cloud.
**Cons**: smaller community than Kong, some features behind paywall.
**Use when**: you want Kong-like capability with a more modern codebase.

### 5.7 Apollo Router

**What**: GraphQL federation gateway written in Rust. Replaces the older Apollo Gateway (Node.js).
**Pros**: fast, federation v2 support, query planning, introspection security, built-in tracing.
**Cons**: GraphQL only — not a general-purpose gateway.
**Use when**: you have multiple GraphQL subgraphs and need to federate them under one schema.

### 5.8 Cloudflare (Workers + API Shield + Gateway)

**What**: Edge compute + security + gateway. Deployed to 300+ cities.
**Pros**: global edge (<50ms latency most places), WAF + bot protection + DDoS mitigation built-in, Workers for programmable logic at the edge (JS/WASM/Rust), R2 and D1 for data at the edge, excellent DX.
**Cons**: Workers have runtime limits (CPU time, memory), Node APIs limited, eventual consistency for KV.
**Use when**: global audience, want edge compute + security + gateway in one platform. Great for public APIs.

### 5.9 Vercel Edge Middleware / Functions

**What**: Edge runtime built into Vercel. Middleware runs on every request before it hits your Next.js app.
**Pros**: native to Next.js, zero config, runs at the edge, fast cold starts (V8 isolates).
**Cons**: locked to Vercel, limited APIs (subset of Node), pricing can escalate.
**Use when**: Next.js app on Vercel, need lightweight gateway features (auth, A/B, geo, rewrites) without a full gateway.

### 5.10 AWS Lambda@Edge / CloudFront Functions

**Lambda@Edge** — run Lambda at CloudFront edge locations. More powerful than CF Functions.
**CloudFront Functions** — lightweight JS functions at the edge, sub-millisecond. Simple header/URL manipulation only.
**Use when**: you're on AWS + CloudFront and need programmable edge logic.

### 5.11 Nginx / OpenResty

**What**: The classic reverse proxy. OpenResty adds Lua scripting.
**Pros**: battle-tested, incredibly fast, low memory, huge community.
**Cons**: config syntax is its own thing, Lua scripting feels dated, no first-class plugin ecosystem for API-specific features (auth providers, etc.).
**Use when**: you want a simple, high-performance proxy with minimal features, or you need something that just works on bare metal.

### 5.12 Traefik

**What**: Modern reverse proxy + gateway, Kubernetes-native, automatic service discovery.
**Pros**: zero-config auto-discovery (K8s, Docker), automatic TLS with Let's Encrypt, dashboard, good DX.
**Cons**: smaller plugin ecosystem, less mature than Kong or Envoy for complex API management.
**Use when**: small-to-medium K8s stack, want something that "just works."

### 5.13 Caddy

**What**: Modern web server with automatic HTTPS. Can act as a lightweight gateway.
**Pros**: simplest config of any option, automatic TLS, great for small deployments.
**Cons**: limited API management features, small ecosystem.
**Use when**: small projects, dev environments, simple public APIs.

---

## 6. Deployment Patterns

### 6.1 Centralized (single region)

All traffic hits one gateway deployment in one region.

- **Pros**: simple, easy to reason about
- **Cons**: latency for far users, single point of failure for that region
- **Fit**: early-stage, single-region product

### 6.2 Multi-region (active-active)

Gateways deployed in 2-3 regions, routed via DNS (Route 53 latency / geo routing) or anycast.

- **Pros**: lower latency globally, disaster recovery
- **Cons**: config sync complexity, data locality concerns, cost
- **Fit**: growing product with global users

### 6.3 Edge (global PoPs)

Gateway logic runs at 100+ edge locations (Cloudflare, Fastly, AWS CloudFront).

- **Pros**: sub-50ms latency everywhere, DDoS absorption, massive capacity
- **Cons**: runtime limits (CPU, memory, API surface), debugging is harder, data is far from backends
- **Fit**: public consumer APIs, global audience, latency-sensitive

### 6.4 Sidecar (service mesh)

An Envoy sidecar runs next to each service pod. Cross-cutting concerns applied per pod.

- **Pros**: no central SPOF, per-service policies, east-west + north-south in one stack (Istio, Linkerd)
- **Cons**: operational complexity, resource overhead per pod, learning curve
- **Fit**: mature Kubernetes platform teams

### 6.5 Hybrid

Common real-world shape:

```
[ Client ]
    │
    ▼
[ CDN / Cloudflare ]           ← edge: caching, WAF, bot mitigation
    │
    ▼
[ API Gateway / Kong ]         ← regional: auth, rate limit, routing
    │
    ▼
[ BFF / GraphQL Router ]       ← per-client composition
    │
    ▼
[ Services behind mesh ]       ← east-west with Istio/Linkerd
```

Not every layer is needed. Add them when pain justifies it.

---

## 7. GraphQL Federation

If your backend is GraphQL split across teams, federation is the pattern.

### 7.1 Federation v2 (Apollo)

- Each team owns a **subgraph** (a GraphQL schema for their domain)
- A **router** (Apollo Router) composes them into one supergraph
- Clients query the router; it plans and executes across subgraphs

### 7.2 Alternatives

- **Schema stitching** — older, client-side composition; superseded by federation
- **GraphQL Mesh** — open-source federation + translation layer (can federate REST + gRPC + GraphQL)
- **Grafbase, Hasura, WunderGraph** — managed federation / data gateway options

### 7.3 Anti-pattern

Don't use federation to federate 2 subgraphs owned by the same team. Use one schema. Federation cost pays off around 3+ teams.

---

## 8. Protocol Translation

Gateways often bridge protocols.

### 8.1 REST → gRPC

Clients speak REST (simple), services speak gRPC (fast, typed).

- **grpc-gateway** (Go) — generates a REST gateway from .proto annotations
- **Envoy gRPC-JSON transcoder** — same idea, runtime
- **Connect RPC** — gRPC-compatible but works over plain HTTP, no proxy needed

### 8.2 REST → GraphQL

- **Hasura** — auto-generates GraphQL from Postgres/SQL Server
- **PostGraphile** — same for Postgres
- **GraphQL Mesh** — wraps REST APIs as GraphQL

### 8.3 GraphQL → REST

Rarely needed. Apollo REST connectors or custom resolvers.

### 8.4 HTTP/1.1 → HTTP/2

Most gateways terminate HTTP/1.1 from clients and speak HTTP/2 (or gRPC) to backends. Free latency and concurrency win.

---

## 9. Routing Patterns

### 9.1 Path-based

```
/api/users/*   → users-service
/api/orders/*  → orders-service
/api/payments/* → payments-service
```

Most common. Easy to reason about.

### 9.2 Host-based

```
api.example.com    → api-gateway
admin.example.com  → admin-service
webhook.example.com → webhook-service
```

Good for isolating public vs admin vs webhook traffic with different security policies.

### 9.3 Header-based

```
X-API-Version: 2  → v2-service
X-Canary: true    → canary-deployment
```

Good for versioning, canary routing, A/B tests.

### 9.4 Weighted (canary / gradual rollout)

```
99% → v1
 1% → v2
```

Incrementally shift traffic to a new version while watching metrics.

---

## 10. Gateway-Level Concerns (where they live)

| Concern | Where to put it |
|---|---|
| **TLS termination** | Gateway (always) |
| **Authentication** | Gateway (verify token, pass identity downstream in header) |
| **Coarse authorization** (has valid token, has scope) | Gateway |
| **Fine-grained authorization** (can this user edit this order) | Service (has business context) |
| **Rate limiting (global, per IP, per key)** | Gateway |
| **Rate limiting (per-user business rules)** | Service or gateway with custom logic |
| **Caching (public, short-TTL)** | Gateway |
| **Caching (private, user-specific)** | Service / app cache |
| **Request validation (schema)** | Gateway (if OpenAPI) or service |
| **Response transformation** | Gateway (thin) — don't put business logic here |
| **Logging / metrics / tracing** | Both (gateway has the full request, service has domain context) |
| **Circuit breaking** | Gateway (upstream failures) |
| **Error shaping** | Service (has domain errors); gateway normalizes if needed |

**Rule**: Put generic, cross-cutting, client-agnostic stuff in the gateway. Put business logic and fine-grained rules in services.

---

## 11. Auth at the Gateway

The most common gateway pattern: the gateway validates the token and passes identity to backends in signed headers.

### 11.1 Flow

1. Client sends `Authorization: Bearer <jwt>`
2. Gateway validates the JWT (signature, exp, iss, aud)
3. Gateway extracts claims (user_id, tenant_id, scopes)
4. Gateway injects headers: `X-User-Id`, `X-Tenant-Id`, `X-Scopes`
5. Gateway strips the original `Authorization` header (or forwards it — choose one convention)
6. Service trusts these headers — it never re-validates the JWT

### 11.2 Critical rule

**Services must refuse direct external traffic.** If a client can reach the service directly, they can spoof `X-User-Id`. Enforce with network policy (VPC, mesh, firewall).

### 11.3 Gateway as OIDC client

For public APIs with external identity providers (Google, Microsoft, Okta, Auth0):
1. Gateway handles the OIDC flow
2. Issues its own session token or forwards the IdP token
3. Refreshes on behalf of the client

Kong, Envoy, AWS API Gateway, Azure APIM, Cloudflare Access all support this.

---

## 12. Observability at the Gateway

The gateway is the perfect observability choke point — every request passes through it.

### 12.1 What to emit

- **Access log** per request: method, path, status, latency, user_id, tenant_id, request_id, trace_id
- **Metrics (RED)**: rate / errors / duration per route
- **Trace spans**: every request gets a trace started or continued here
- **Security events**: auth failures, rate limit triggers, WAF blocks
- **Origin health**: upstream status per service

### 12.2 Consistency win

If every service's logs use the same `request_id` and `trace_id` seeded by the gateway, correlation across services becomes trivial. **Always seed trace context at the gateway.**

See `observability.md` for the full pattern.

---

## 13. Anti-Patterns

### 13.1 Business logic in the gateway

If your gateway config has domain rules ("if user is premium, return discounted price"), stop. That belongs in a service. Gateways should be thin and generic.

### 13.2 The god gateway

One gateway with thousands of lines of config, custom plugins, and per-endpoint exceptions. Becomes a deployment bottleneck. Split into smaller gateways (per domain, per client, per version).

### 13.3 Authorization without context

Trying to do fine-grained authz at the gateway when the decision requires DB context ("is this user an admin of THIS specific org?"). The gateway lacks context; the service has it. Coarse authz at the gateway, fine at the service.

### 13.4 Chatty gateway calls

Gateway → service → gateway → other service. Each hop is latency. Either let services call each other directly (mesh), or compose at the service layer (BFF).

### 13.5 Two gateways in series without a reason

Gateway chaining (CDN → Gateway 1 → Gateway 2 → service) adds latency and SPOFs. Justify every hop.

### 13.6 Rate limiting only at the gateway

Gateway rate limits don't protect against internal abuse or bugs. Services should have their own guardrails too (DB connection pool limits, query timeouts, per-tenant budgets).

### 13.7 No canary / gradual rollout capability

If your only way to deploy a new version is "flip the DNS", you can't catch regressions before impact. Invest in weighted routing from day 1.

### 13.8 Single region for a global audience

A US-hosted gateway for European users adds 150ms+ to every request. Use edge or multi-region.

### 13.9 Config drift between environments

Gateway config in the UI → undocumented, unversioned. Always use **GitOps**: config in a repo, applied via CI/CD (kubectl apply, terraform, etc.).

### 13.10 No local dev story

If developers can't run the gateway locally, they can't test auth, rate limit, or routing changes before deploy. Use docker-compose or a lightweight alternative (Caddy, Traefik) for local.

### 13.11 Coupling the gateway to a deployment model

Don't choose Lambda@Edge if you might leave AWS. Don't choose Vercel Middleware if you might move off Vercel. Prefer portable options for the core gateway layer.

---

## 14. Gateway Checklist

- [ ] One clear purpose per gateway (routing / BFF / edge / federation — not all at once)
- [ ] Config in git, deployed via CI/CD
- [ ] Health checks to upstreams + gateway-level liveness/readiness
- [ ] Rate limiting tiered (global → per-IP → per-key → per-user)
- [ ] Auth validated here, identity forwarded via signed headers
- [ ] Services refuse direct external traffic (enforced at network level)
- [ ] Trace context (`traceparent`) propagated on every request
- [ ] Structured access logs with trace_id + user_id + request_id
- [ ] Circuit breakers on every upstream
- [ ] Graceful degradation (fallback responses when upstream is down)
- [ ] Canary / weighted routing supported
- [ ] WAF + bot protection (Cloudflare, AWS WAF, or built-in)
- [ ] TLS 1.2+ with auto-renewal
- [ ] Local dev story documented
- [ ] Multi-region or edge deployment for global users
- [ ] Observability dashboards for RED metrics per route
- [ ] Runbook for gateway-level incidents
- [ ] No business logic — only cross-cutting concerns

---

## 15. Decision Matrix — Picking a Gateway

Walk the questions top-down:

```
1. Are you on a specific cloud and want managed ops?
   AWS → AWS API Gateway (HTTP API) or Lambda@Edge
   Azure → Azure API Management
   GCP → Apigee (enterprise) or Cloud Endpoints (lightweight)

2. Need global edge (< 50ms latency worldwide + security)?
   → Cloudflare Workers + API Shield
   → Vercel Edge Middleware (if Next.js-native)

3. Kubernetes-native, open source, high performance?
   → Envoy Gateway / Gloo / Emissary
   → Traefik (simpler)

4. Self-hosted, mature, rich plugin ecosystem?
   → Kong (OSS or Konnect)
   → Tyk (OSS or cloud)

5. Federating multiple GraphQL subgraphs?
   → Apollo Router

6. Simple reverse proxy, minimal features?
   → Caddy (easiest config) or Nginx (most mature)

7. Need a dev portal for external partners?
   → Azure APIM (best portal) or Kong Konnect or Tyk

8. Running a service mesh already?
   → Use the mesh's ingress (Istio Gateway, Linkerd edge)
```

---

## 16. What to Write in the Blueprint

For the **Architecture Decision Summary** and new sections in the design blueprint, include:

```markdown
## Gateway Layer

- **Gateway pick**: [tool] — [1 line why]
- **Rejected**: [alternative] — [1 line why not]
- **Deployment**: [centralized / multi-region / edge / sidecar]
- **Routing**: [path / host / header] — [example]
- **Auth at gateway**: [JWT validate + inject headers / OIDC client / API keys]
- **Rate limit**: [per-IP X/min, per-user Y/min, per-key Z/min]
- **Caching**: [public GETs for N seconds / none]
- **Observability**: [trace_id seeded here, access logs to {sink}]
- **Canary / gradual rollout**: [supported via weighted routing / feature flags]
- **Protocol translation**: [if any — REST→gRPC, etc.]
- **BFF layer**: [yes per client / no]
- **Config source**: [GitOps repo + CI/CD]
```

And flag:
- Which services refuse direct external traffic
- How secrets (JWKS keys, API keys) are rotated
- Local dev story
- Multi-region failover plan
