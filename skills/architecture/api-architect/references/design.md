# API Design — Theory & Decisions

The theory of API design: style selection, resource modeling, HTTP semantics, versioning, pagination, filtering, errors, and documentation. Based on: Roy Fielding's dissertation, Mark Masse (*REST API Design Rulebook*), Arnaud Lauret (*The Design of Web APIs*), Google API Design Guide, Microsoft API Guidelines, Stripe/GitHub/Shopify public APIs.

---

## 1. API Style — REST vs GraphQL vs gRPC

No style is universally better. Pick based on clients, scale, and team.

### 1.1 REST (resource-oriented, HTTP-based)

**Use when**:
- Public API or B2B integrations (SDKs, partners, third-parties)
- Stable contracts needed over long periods
- Heterogeneous clients (web, mobile, curl, tools)
- You want free caching, free tooling, free CLI access
- OpenAPI-first workflow (spec-driven development)

**Pros**: universal, cacheable by HTTP infrastructure, debuggable with curl, mature tooling (OpenAPI, Postman), SDK generation, CDN-friendly.
**Cons**: over/under-fetching (clients get fields they don't need OR need multiple round-trips), verbose for nested data, versioning can be painful, N+1 risk.

### 1.2 GraphQL (query language, single endpoint)

**Use when**:
- Rapidly evolving frontend with many views
- Single product team owns both front and back
- Mobile clients need exact-field selection to save bandwidth
- Deeply nested data with many client-side needs
- One trusted consumer (your own frontend)

**Pros**: clients ask for exactly what they need, strong typing, self-documenting, single endpoint, no over/under-fetching.
**Cons**: caching is harder (everything is POST /graphql), rate limiting per-query is complex, N+1 risk (solved with dataloader), server-side complexity, file uploads awkward, query depth attacks.

### 1.3 gRPC (RPC over HTTP/2, protobuf)

**Use when**:
- Internal microservice-to-microservice communication
- Low-latency + high-throughput requirements
- Strongly typed contracts across polyglot services
- Streaming (bidirectional) is needed
- You control both sides

**Pros**: tiny payloads (protobuf), HTTP/2 multiplexing, streaming, code generation for every language, strict contracts.
**Cons**: not browser-friendly (needs gRPC-Web proxy), harder to debug (binary), less ecosystem for public APIs.

### 1.4 Hybrid — the common real-world shape

Most mature platforms end up with:
- **REST + OpenAPI** for external/public APIs (partners, SDKs, webhooks)
- **GraphQL** for the internal BFF layer serving the main frontend
- **gRPC** for service-to-service internal traffic

One style per purpose, not per service.

### 1.5 Decision matrix

| Need | Pick |
|---|---|
| Public API with SDKs | REST + OpenAPI |
| Your own frontend, deep nested data | GraphQL |
| Internal micro-to-micro, low latency | gRPC |
| Webhooks / callbacks | REST (POST JSON) |
| File upload / download | REST (or S3 presigned) |
| Real-time bidirectional | gRPC streaming or WebSocket |
| LLM tool calling | REST (OpenAPI schemas feed tool defs) |

---

## 2. Resource Modeling (REST)

### 2.1 Nouns, not verbs

Resources are **things**, not actions.

- `GET /users` → list users (good)
- `POST /getUserList` → RPC style (bad)
- `POST /users/{id}/ban` → action on resource (okay for RPC-like corner cases)

### 2.2 Plural resource names

Always plural. Consistency wins.

- `/users`, `/orders`, `/invoices` — yes
- `/user`, `/order`, `/invoice` — no

### 2.3 Nested resources — sparingly

One level deep is okay. Two levels is usually wrong.

- `GET /users/{id}/orders` — okay, makes sense
- `GET /users/{id}/orders/{oid}/items/{iid}` — overnested, use `/items/{iid}` instead

Prefer flat with filters:
- `GET /orders?user_id=123`
- `GET /items/{iid}` (then item has a `parent_order_id` link)

### 2.4 Use IDs in the path, not the query

- `GET /users/{id}` — yes
- `GET /users?id={id}` — no (that's for filtering lists)

### 2.5 Sub-resources for state transitions

When a state change deserves its own endpoint:
- `POST /orders/{id}/cancel` — semantically clear
- `POST /orders/{id}/refund` — same

Better than `PATCH /orders/{id}` with a `status: "cancelled"` field when the action triggers side effects.

---

## 3. HTTP Methods — Correct Usage

### 3.1 The semantic contract

| Method | Semantics | Idempotent? | Safe? | Body? |
|---|---|---|---|---|
| GET | Read | Yes | Yes | No |
| HEAD | Read headers only | Yes | Yes | No |
| POST | Create or non-idempotent action | No | No | Yes |
| PUT | Full replace | Yes | No | Yes |
| PATCH | Partial update | Not required* | No | Yes |
| DELETE | Remove | Yes | No | Optional |
| OPTIONS | Discover capabilities (CORS preflight) | Yes | Yes | No |

*PATCH is often made idempotent via idempotency keys.

### 3.2 Idempotency

**Idempotent** = calling N times produces the same result as calling once.

- GET, PUT, DELETE are idempotent by HTTP spec
- POST is NOT — use **idempotency keys** for safety
- PATCH depends on the body

**Idempotency keys**: client generates a unique key per logical request, sends it in `Idempotency-Key` header. Server stores (key → result) for 24h. Repeat requests with the same key return the cached result. Stripe popularized this pattern.

Critical for: payments, orders, resource creation, anything where accidental duplication is bad.

### 3.3 Safe methods

**Safe** = does not modify state. GET and HEAD are safe. Servers MUST NOT have side effects on safe methods. Log writes are okay; business-state changes are not.

---

## 4. Status Codes — Use Them Correctly

### 4.1 The classes

- **2xx** — success
- **3xx** — redirection
- **4xx** — client error (the caller's fault)
- **5xx** — server error (your fault)

### 4.2 The ones you'll use 95% of the time

| Code | When |
|---|---|
| **200 OK** | Successful GET/PATCH/PUT/DELETE (if returning the resource) |
| **201 Created** | Successful POST that created a resource. Include `Location` header |
| **202 Accepted** | Async job started, not yet complete |
| **204 No Content** | Successful DELETE or action with no response body |
| **301 Moved Permanently** | Resource relocated (rare in APIs) |
| **304 Not Modified** | Conditional GET (ETag match) |
| **400 Bad Request** | Malformed request (bad JSON, missing required field) |
| **401 Unauthorized** | Auth is missing or invalid (actually means "unauthenticated") |
| **403 Forbidden** | Authenticated but not allowed |
| **404 Not Found** | Resource doesn't exist |
| **405 Method Not Allowed** | Method not supported on this resource |
| **409 Conflict** | State conflict (version mismatch, duplicate key) |
| **410 Gone** | Permanently removed (different from 404) |
| **422 Unprocessable Entity** | Valid request shape but business rules fail |
| **429 Too Many Requests** | Rate limited. Include `Retry-After` header |
| **500 Internal Server Error** | Unhandled server error — you should never intend to return this |
| **502 Bad Gateway** | Upstream failed |
| **503 Service Unavailable** | Temporary overload. Include `Retry-After` |
| **504 Gateway Timeout** | Upstream timed out |

### 4.3 400 vs 422

- **400**: the request is malformed (invalid JSON, wrong type, missing required field) — the parser rejected it
- **422**: the request is well-formed but fails business rules (duplicate email, insufficient funds)

Some APIs use only 400. Pick a convention and stick to it.

### 4.4 Never do this

- **200 OK with `{"error": "..."}`** — caller's HTTP client sees success and doesn't retry/alert
- **500 for validation errors** — that's what 400/422 are for
- **404 for auth failures** — use 401 or 403
- **204 with a body** — 204 means no body

---

## 5. Error Response Shape

Use **RFC 7807 — Problem Details for HTTP APIs**. One consistent shape across every endpoint.

```json
{
  "type": "https://api.example.com/errors/insufficient-funds",
  "title": "Insufficient funds",
  "status": 422,
  "detail": "Account balance is $50, requested withdrawal is $100",
  "instance": "/accounts/123/withdrawals/req_abc",
  "traceId": "a1b2c3d4"
}
```

Fields:
- `type` — stable URI identifying the error kind (dereferenceable for docs)
- `title` — short, human-readable, stable
- `status` — matches HTTP status
- `detail` — human-readable specific explanation
- `instance` — specific occurrence URI (optional)
- `traceId` — for support / debugging

Extend with domain-specific fields (`fieldErrors`, `balance`, etc.) as needed.

**Never**: inconsistent error shapes across endpoints, stack traces in responses, internal error messages leaked to clients.

---

## 6. Versioning

### 6.1 Options

- **URL path**: `/v1/users` — most popular, most visible, easiest for clients, hardest to keep clean
- **Header**: `Accept: application/vnd.example.v2+json` — cleaner URL, harder to test, invisible in logs
- **Query param**: `?version=2` — simple but mixes with filters; generally avoid
- **Content negotiation**: variation of headers — powerful but rarely used well

**Recommended**: URL path versioning (`/v1/`, `/v2/`). It's ugly but universally understood and easy to test with curl.

### 6.2 Versioning policy

- **No breaking changes** within a version. Ever.
- **Breaking change** = removing a field, renaming, changing a type, changing validation, changing status codes.
- **Non-breaking change** = adding a new optional field, adding a new endpoint, adding a new enum value (sometimes controversial — coerce unknown to "other").

### 6.3 Deprecation

- Announce via `Deprecation` header, with `Sunset` header for the planned removal date
- Minimum window: 6 months for public APIs, 12 months for enterprise
- Communicate via changelog, email, docs
- Monitor usage and reach out to top users individually

### 6.4 When to bump major version

Only when you have breaking changes that can't be expressed non-breakingly. Adding new endpoints and fields does NOT require a version bump.

---

## 7. Pagination

### 7.1 Offset pagination

```
GET /items?offset=100&limit=20
```

**Pros**: simple, supports jumping to page N.
**Cons**: unstable (rows shift), slow on large offsets (DB scans), inconsistent if data mutates.

**Use for**: small datasets, admin tables, things that don't mutate.

### 7.2 Cursor pagination (recommended for scale)

```
GET /items?limit=20&cursor=eyJpZCI6MTIzNDV9
```

Cursor is an opaque token (usually base64-encoded JSON with the last-seen values). The server decodes it and uses it as a WHERE clause.

**Pros**: stable under mutation, O(1) per page regardless of depth, efficient for large datasets.
**Cons**: can't jump to page N, cursors must be opaque (clients shouldn't parse them).

Response:
```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTIzNjV9",
    "has_more": true
  }
}
```

**Use for**: feeds, logs, analytics, anything with > 1000 rows.

### 7.3 Keyset pagination

Variant of cursor that uses domain keys directly (`?after_id=12345`). Same benefits, less opaque. Good when the ordering key is deterministic.

### 7.4 Page size

Always cap. Default `limit=20`, maximum `limit=100` (or less). Reject requests exceeding the cap.

---

## 8. Filtering, Sorting, Searching

### 8.1 Filtering

Simple equality:
```
GET /users?status=active&role=admin
```

Ranges:
```
GET /orders?created_after=2026-01-01&created_before=2026-02-01
GET /orders?amount_gte=100&amount_lte=500
```

Complex filtering — two philosophies:

**RSQL / FIQL** (standardized but niche):
```
GET /users?filter=status==active;age=gt=18
```

**Nested JSON in query** (Stripe style):
```
GET /orders?status[in]=paid,shipped
```

Both work. Pick one and document it. Don't let filter syntax grow organically.

### 8.2 Sorting

```
GET /items?sort=-created_at,name
```

Minus for descending, comma-separated for multi-sort. Whitelist the fields that can be sorted (never allow arbitrary SQL column access).

### 8.3 Full-text search

- Simple: `?q=term`
- Advanced: delegate to a search engine (Postgres FTS, Elasticsearch, Meilisearch, Algolia)
- Don't mix search with filter unless the semantics are clear

---

## 9. Field Selection (Sparse Fieldsets)

Let clients request only the fields they need:
```
GET /users/{id}?fields=id,name,email
```

Saves bandwidth, reduces server work. Common in GraphQL by default, optional in REST.

**Cost**: caching becomes harder (cache key includes fields). Use sparingly for REST.

---

## 10. Caching

### 10.1 HTTP caching headers

| Header | Purpose |
|---|---|
| `Cache-Control` | Max age, private/public, must-revalidate |
| `ETag` | Version identifier; client sends `If-None-Match` for conditional GET |
| `Last-Modified` | Timestamp; client sends `If-Modified-Since` |
| `Vary` | Which request headers affect the response (critical for auth'd caches) |

**Typical pattern for a user resource**:
```
Cache-Control: private, max-age=60
ETag: "abc123"
Vary: Authorization
```

### 10.2 Cache layers

- **CDN** (public GETs only, short TTL)
- **Edge cache** (API gateway, regional)
- **Application cache** (Redis/Memcached)
- **DB query cache** (built into many ORMs)

### 10.3 Cache invalidation

The hard problem. Two main patterns:
- **TTL** — cache for N seconds, accept stale data
- **Event-driven** — on write, publish an event, consumers invalidate their caches

Tag-based invalidation (group cache keys under tags, invalidate by tag) is the best practical tradeoff.

---

## 11. Idempotency Keys (deeper)

For POST and PATCH endpoints where accidental duplication is bad.

### 11.1 Client flow

```
POST /payments
Idempotency-Key: uuid-v4-from-client
```

### 11.2 Server flow

1. Receive request. Extract `Idempotency-Key`.
2. Check store: has this key been seen?
   - Yes → return the stored response (even if the request body is slightly different — flag it)
   - No → process the request, store `(key → response)` atomically, return.
3. TTL the store (usually 24h).

### 11.3 Where to store

- Redis with TTL (simple, fast)
- Postgres table with unique constraint on key (durable, transactional)

**Required** for: payments, order creation, user creation, anything with financial or safety impact.

---

## 12. Rate Limiting (design perspective)

Covered in depth in `scalability.md`. Design-level rules:

- Always return `429 Too Many Requests` when exceeded
- Include headers: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`, `Retry-After`
- Document the limits in your API docs
- Different limits for different auth levels (anonymous < authenticated < paid tier)

---

## 13. Contracts & OpenAPI

### 13.1 Contract-first vs code-first

- **Contract-first**: write OpenAPI spec → generate server stubs + client SDKs → implement. Best for teams > 3 and public APIs.
- **Code-first**: write code → generate OpenAPI from annotations. Faster for solo projects and internal APIs.

Pick one. Mixing leads to drift.

### 13.2 OpenAPI 3.1 (not 3.0)

- 3.1 aligns with JSON Schema 2020-12 (consistent with most validation libs)
- Better null handling, better oneOf/anyOf
- Examples and schemas are richer

### 13.3 What the spec should include

- Every endpoint with all params, bodies, responses, status codes
- All error responses (especially 4xx)
- Auth schemes and per-endpoint security requirements
- Realistic examples
- Descriptions for every field (not just types)
- Tags to group endpoints
- Server URLs for each environment

### 13.4 Generated artifacts

- SDKs (openapi-generator, Kiota, Stainless)
- Documentation (Redoc, Scalar, Stoplight)
- Mock servers (Prism)
- Contract tests (Dredd, Schemathesis)
- Postman collections

One spec → many artifacts. This is the DX force multiplier.

---

## 14. GraphQL Specific (when you pick it)

- **Pagination**: Relay-style connections (`edges`, `node`, `pageInfo`, `cursor`) — standard and paginated correctly
- **N+1**: always use DataLoader or equivalent batching
- **Depth/complexity limits**: prevent malicious queries (e.g., `graphql-query-complexity`)
- **Persisted queries**: for production, only allow hashes of pre-approved queries (performance + security)
- **Schema-first or code-first**: pick one
- **Error handling**: errors go in the `errors` array, partial success is normal
- **Auth**: per-resolver, not per-endpoint
- **Rate limiting by complexity score**, not request count

---

## 15. gRPC Specific (when you pick it)

- **Proto-first** — .proto files are the contract
- **Streaming** — four types: unary, server, client, bidirectional
- **Deadlines** — every RPC must have a deadline (timeout). Set at call site and propagate through the stack
- **Metadata** — like HTTP headers (auth, tracing)
- **Error codes** — use the standard set (NOT_FOUND, PERMISSION_DENIED, UNAVAILABLE, DEADLINE_EXCEEDED, etc.)
- **HTTP/2 multiplexing** — many RPCs on one connection
- **Backward compatibility** — protobuf is forgiving (add fields with new tag numbers; never reuse tags; never remove required)

---

## 16. Common Anti-Patterns

- Using POST for all operations
- Returning 200 OK with `{error: "..."}` in body
- No pagination on list endpoints
- Inconsistent error shapes across endpoints
- Exposing internal database IDs as primary identifiers (use UUIDs or slugs for public APIs)
- Missing `Location` header on 201 Created
- Nested resources > 2 levels deep
- Returning DB rows directly from the ORM (no DTO layer)
- Business logic in route handlers
- Versioning via breaking changes without deprecation
- No idempotency keys on mutating endpoints
- Offset pagination on large datasets
- No OpenAPI spec
- Inconsistent naming (camelCase mixed with snake_case)
- No rate limiting
- JWT in query params (logged everywhere)
- SQL filter syntax exposed to clients
- Too many endpoints when a filter would suffice
- Too few endpoints (one mega endpoint)
- No clear distinction between 4xx (client's fault) and 5xx (your fault)
