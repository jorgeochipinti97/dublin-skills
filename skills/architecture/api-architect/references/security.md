# API Security — AuthN, AuthZ, OWASP, Hardening

Foundational reference for API security. Sources: OWASP API Security Top 10 (2023), OAuth 2.0 RFC 6749/6750, OAuth 2.1 draft, OIDC Core, NIST SP 800-63, PortSwigger, Stripe/GitHub/Auth0 security practices.

---

## 1. Authentication vs Authorization (different things)

- **Authentication (AuthN)** — who is the caller? (login, identity)
- **Authorization (AuthZ)** — what is the caller allowed to do? (permissions, policies)

Most real-world breaches conflate these. Keep them distinct in your design.

---

## 2. Authentication Mechanisms

### 2.1 Session-based (cookies)

Classic web pattern. Server generates a session ID, stores `(session_id → user)` in Redis/DB, sends it in a cookie. Browser sends it back on every request.

**Pros**: simple, revocable instantly (delete the session), works with browser built-ins, HTTPS + HttpOnly cookies are very hard to steal.
**Cons**: not great for mobile or B2B API integrations (cookies are web-biased), CSRF protection needed, not stateless.

**Use for**: traditional web apps with same-origin API calls.

### 2.2 JWT (JSON Web Tokens)

Client receives a signed token containing claims (`sub`, `exp`, `role`, etc.). Sends it in `Authorization: Bearer <token>`. Server verifies signature, trusts the claims.

**Pros**: stateless (no session store lookup), works everywhere (mobile, SPA, B2B), scales horizontally trivially.
**Cons**: cannot be revoked before expiration (you have to wait, or maintain a blacklist), large (1-4KB), carries sensitive data if misused.

**Critical rules for JWT**:
- **Always verify the signature** — don't use `alg: none`, don't trust `kid` blindly
- **Short access token lifetime** — 5-15 minutes
- **Long refresh token** — 7-30 days, with rotation (new refresh token on every refresh)
- **Never put secrets in claims** — claims are base64-encoded, not encrypted
- **Use `RS256` or `ES256`** (asymmetric) for multi-service setups, `HS256` (symmetric) for single-service
- **Validate `iss`, `aud`, `exp`, `nbf`** on every request
- **Store refresh tokens securely** — HttpOnly cookie or secure device storage (never localStorage for SPAs if you can avoid it)

### 2.3 OAuth 2.0 / OAuth 2.1

OAuth is a **delegation** protocol — it lets a third party act on behalf of a user without sharing the password.

**Four flows you'll actually use**:

| Flow | Use case |
|---|---|
| **Authorization Code + PKCE** | Web apps, mobile apps, SPAs — the default in 2026 |
| **Client Credentials** | Machine-to-machine (no user involved) |
| **Device Authorization** | CLI tools, smart TVs, IoT |
| **Refresh Token** | Rotating access tokens without re-authentication |

**Flows to avoid** (deprecated in OAuth 2.1):
- **Implicit flow** — insecure, leaks tokens via URL fragment
- **Resource Owner Password Credentials** — user's password passes through your app

**OAuth 2.1 = OAuth 2.0 with the bad parts removed.** PKCE is mandatory for all public clients. Implicit and ROPC are dropped.

### 2.4 OIDC (OpenID Connect)

OIDC is OAuth 2.0 + identity. Adds:
- **ID token** (JWT with user profile claims)
- **UserInfo endpoint** (fetch user data)
- **Standard claims** (`sub`, `email`, `name`, `picture`, etc.)

**Use OIDC, not custom login**, when integrating with an identity provider (Auth0, Clerk, Keycloak, Okta, Cognito, Google, Apple).

### 2.5 API Keys

Static secret strings issued to trusted consumers.

**Use for**: server-to-server, webhooks, internal tools, B2B partners.
**Never for**: public clients (SPAs, mobile apps can be reverse-engineered).

**Rules**:
- Generate with CSPRNG, minimum 32 bytes of entropy
- Prefix with an identifier (`sk_live_`, `pk_test_`) for easy rotation and log detection
- Store **hashed** in the DB (just like passwords — never plaintext)
- Show the key ONCE at creation (then only the prefix and last 4)
- Rotate periodically
- Scope keys (what they can do)
- Revoke instantly on compromise
- Rate limit per key

### 2.6 mTLS (Mutual TLS)

Both client and server present certificates. Used for high-security B2B and internal service meshes (Istio, Linkerd).

**Use when**: enterprise integrations, regulated industries, service mesh.

---

## 3. Authorization Models

### 3.1 RBAC (Role-Based Access Control)

Users → roles → permissions.

```
user: alice
roles: [editor]
editor: [posts:read, posts:write, comments:moderate]
```

**Pros**: simple, mature, universally understood.
**Cons**: role explosion in complex domains (every combo becomes a new role).

**Use for**: most B2B SaaS products.

### 3.2 ABAC (Attribute-Based Access Control)

Permissions are evaluated dynamically based on attributes of the user, resource, action, and environment.

```
allow if user.department == resource.department
       AND action == "read"
       AND environment.time.hour BETWEEN 9 AND 17
```

**Pros**: very expressive, handles complex rules.
**Cons**: harder to audit, harder to reason about, needs a policy engine (OPA, Cedar, Casbin).

**Use for**: enterprise, regulated industries, fine-grained access.

### 3.3 ReBAC (Relationship-Based — Google Zanzibar)

Permissions derived from a graph of relationships.

```
document:doc1 -- owner --> user:alice
document:doc1 -- viewer --> group:marketing
group:marketing -- member --> user:bob
```

**Pros**: models real-world sharing (Google Drive, Notion).
**Cons**: needs a specialized system (SpiceDB, OpenFGA, Permify).

**Use for**: collaborative products (docs, files, multi-tenant sharing).

### 3.4 Scopes (OAuth style)

Tokens carry **scopes** (`users:read`, `orders:write`). Each endpoint checks required scope.

**Use**: for third-party API access. Combine with RBAC internally.

### 3.5 When in doubt

- **Startup / early product** → RBAC, 3-5 roles
- **Growing SaaS** → RBAC + scopes for third-party access
- **Collaborative app** → ReBAC (OpenFGA)
- **Enterprise / compliance** → ABAC with a policy engine

---

## 4. Multi-Tenancy

### 4.1 Isolation models

| Model | Tradeoff |
|---|---|
| **Shared DB, shared schema, tenant_id column** | Cheapest, hardest to isolate (one query bug = data leak) |
| **Shared DB, schema-per-tenant** | Middle ground, Postgres supports it well |
| **Database-per-tenant** | Most isolated, highest cost, compliance-friendly |

### 4.2 Row-level security (Postgres)

Postgres has **RLS policies** that enforce tenant isolation at the DB level. Even if a query has a bug, the policy prevents cross-tenant leaks.

```sql
CREATE POLICY tenant_isolation ON orders
  USING (tenant_id = current_setting('app.tenant_id')::uuid);
```

The application sets `app.tenant_id` per request. Forgetting a WHERE clause no longer leaks data.

**Use RLS for any multi-tenant Postgres app.** It's a safety net.

### 4.3 Tenant context propagation

- Extract tenant from token (`tenant_id` claim) on every request
- Attach to request context
- Pass through every service/DB call
- Log tenant_id in every structured log line

---

## 5. OWASP API Security Top 10 (2023)

Memorize this. It's the baseline every API must cover.

### API1:2023 — Broken Object Level Authorization (BOLA)

The #1 API vulnerability. Endpoint trusts the ID in the URL without checking if the caller owns it.

```
GET /orders/123  →  returns someone else's order
```

**Fix**: ALWAYS check `order.user_id == request.user_id` (or tenant_id) inside the handler. Automate with guards/interceptors + RLS.

### API2:2023 — Broken Authentication

Weak passwords, JWT not verified, session fixation, credential stuffing.

**Fix**: strong password policy, MFA, JWT signature validation, rotating refresh tokens, rate-limit auth endpoints, bot detection.

### API3:2023 — Broken Object Property Level Authorization (BOPLA)

Mass assignment — user can update fields they shouldn't (e.g., `is_admin: true`).

```
PATCH /users/123 { "name": "...", "is_admin": true }
```

**Fix**: whitelist fields at the DTO layer. NEVER bind request body directly to DB entities. Use allow-listed DTOs.

### API4:2023 — Unrestricted Resource Consumption

No rate limiting, no payload size limits, no query complexity limits. Leads to DoS or exhaustion attacks.

**Fix**: rate limiting (per IP, per user, per key), payload size limits (e.g., 1MB), timeouts on all external calls, GraphQL depth/complexity limits.

### API5:2023 — Broken Function Level Authorization

Endpoint that should be admin-only is callable by anyone.

```
DELETE /users/123  →  any authenticated user can delete
```

**Fix**: authorization checks on EVERY endpoint, not just authentication. Default deny.

### API6:2023 — Unrestricted Access to Sensitive Business Flows

No bot protection on critical flows (account creation, checkout, password reset). Scrapers, scalpers, credential stuffing.

**Fix**: CAPTCHA, device fingerprinting, anomaly detection, behavioral analysis, WAF rules.

### API7:2023 — Server-Side Request Forgery (SSRF)

Client-provided URLs are fetched by the server (e.g., profile picture import, webhook). Attacker points at internal services.

**Fix**: URL allowlist, block private IP ranges (10.*, 172.16.*, 192.168.*, 169.254.*), block metadata endpoints (169.254.169.254), use egress proxy with ACLs.

### API8:2023 — Security Misconfiguration

Default credentials, verbose errors, missing security headers, open CORS, exposed admin endpoints.

**Fix**: security baseline checklist in CI, minimal error messages in prod, strict CORS, TLS everywhere, security headers (HSTS, X-Content-Type-Options, X-Frame-Options).

### API9:2023 — Improper Inventory Management

Forgotten dev/staging APIs exposed to the internet. Old versions still running.

**Fix**: API inventory, decommission process, subdomain monitoring, certificate transparency monitoring.

### API10:2023 — Unsafe Consumption of APIs

Trusting third-party API responses blindly. Injection attacks via upstream data.

**Fix**: validate and sanitize all incoming data, even from trusted partners. Zero-trust across boundaries.

---

## 6. Input Validation

### 6.1 Validate at the boundary

Every input crossing a trust boundary must be validated BEFORE hitting business logic.

- **Schema validation** (Zod, Joi, JSON Schema, Pydantic, class-validator)
- **Type coercion** — strict: reject unknown types, don't silently coerce
- **Length/range** — max string length, max array length, numeric bounds
- **Format** — email, URL, UUID, ISO date
- **Whitelist** — for enums and fixed values

### 6.2 Never trust client-side validation

Client-side validation is for UX. Server-side is for security. Always both.

### 6.3 Defend in depth

Even with validation, use parameterized queries (no raw SQL concat) and output encoding (no raw HTML echo).

---

## 7. Injection (SQL, NoSQL, Command, LDAP, XML)

### 7.1 SQL injection

Never concatenate user input into SQL. Use parameterized queries or a query builder (Prisma, Drizzle, SQLAlchemy, Ecto).

```
-- VULNERABLE
db.exec("SELECT * FROM users WHERE id = " + userInput)

-- SAFE
db.exec("SELECT * FROM users WHERE id = $1", [userInput])
```

### 7.2 NoSQL injection

MongoDB and others are vulnerable to operator injection:

```js
// VULNERABLE
db.users.find({ email: req.body.email, password: req.body.password })
// Attacker sends: { "email": "admin@example.com", "password": { "$ne": "" } }
```

**Fix**: validate input types before querying. Reject objects when strings are expected.

### 7.3 Command injection

Never pass user input to shell commands. Use language-native libraries instead.

---

## 8. Secrets Management

### 8.1 Rules

- **Never commit secrets** to git. Use `.env` locally (gitignored) and a secrets manager in production.
- **Production secrets**: AWS Secrets Manager, GCP Secret Manager, HashiCorp Vault, Doppler
- **Rotation**: automatic rotation for high-value secrets (DB passwords, API keys)
- **Least privilege**: each service has access only to its own secrets
- **Audit**: log secret access for forensics
- **Scanning**: pre-commit hooks + CI (gitleaks, truffleHog) to catch accidental commits

### 8.2 Detection

If a secret is leaked:
1. Rotate immediately (minutes, not hours)
2. Revoke the old value
3. Check logs for usage during the exposure window
4. Root-cause the leak

---

## 9. Transport Security (TLS)

- **TLS 1.2 minimum**, 1.3 preferred
- **HSTS** (`Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`) to force HTTPS
- **Certificate auto-renewal** (Let's Encrypt + Certbot, or ACM / managed certs)
- **No mixed content** — all subresources over HTTPS
- **HTTP → HTTPS redirect** at the edge
- **Certificate transparency monitoring** to detect rogue certs for your domain

---

## 10. CORS (Cross-Origin Resource Sharing)

### 10.1 The concept

Browsers enforce the **same-origin policy** — JavaScript on `a.com` cannot read responses from `b.com` unless the server opts in via CORS headers.

### 10.2 Correct configuration

- **Whitelist origins** — never use `Access-Control-Allow-Origin: *` for authenticated APIs
- **Credentials mode** — only set `Access-Control-Allow-Credentials: true` if cookies/auth are involved, and pair with a specific origin (never wildcard)
- **Methods & headers** — explicitly list what you allow
- **Preflight caching** — `Access-Control-Max-Age: 3600` to reduce preflight OPTIONS requests

### 10.3 Common mistakes

- Wildcard `*` with credentials (browsers reject this, but some devs force it through)
- Allowing all headers (`Access-Control-Allow-Headers: *`)
- Reflecting `Origin` header without validation (effectively allowing any origin)
- Missing OPTIONS handler (preflight fails)

---

## 11. Security Headers

Set these on every response:

| Header | Purpose |
|---|---|
| `Strict-Transport-Security: max-age=31536000; includeSubDomains` | Force HTTPS |
| `X-Content-Type-Options: nosniff` | Prevent MIME sniffing |
| `X-Frame-Options: DENY` | Prevent clickjacking |
| `Content-Security-Policy: ...` | Restrict resource loading (if serving HTML) |
| `Referrer-Policy: strict-origin-when-cross-origin` | Reduce referrer leakage |
| `Permissions-Policy: ...` | Disable unneeded browser features |
| `Cache-Control: no-store` | For auth responses and sensitive data |

Helmet.js or equivalent handles most of these automatically.

---

## 12. DDoS / Brute Force Protection

### 12.1 Layers

- **Edge / CDN** (Cloudflare, CloudFront) — absorb volumetric attacks
- **WAF** (Cloudflare, AWS WAF) — block malicious patterns
- **API gateway** — rate limit per IP, per key
- **Application** — per-user rate limits, per-endpoint limits, business-rule limits

### 12.2 Rate limit critical endpoints hard

- Login — max 5/min per IP
- Password reset — max 3/hour per email
- Signup — max 3/hour per IP
- Write-heavy endpoints — per-user budget

### 12.3 Bot detection

- CAPTCHA (hCaptcha, Cloudflare Turnstile) on friction points
- Honeypot fields in forms
- Device fingerprinting
- Behavioral analysis (unusual access patterns)

---

## 13. PII & Sensitive Data

### 13.1 Principles

- **Minimize** — only collect what you need
- **Encrypt at rest** — DB-level encryption, bucket encryption
- **Encrypt in transit** — TLS end-to-end
- **Redact in logs** — never log passwords, tokens, CVV, full PAN, SSN
- **Retention** — delete data when no longer needed (GDPR "right to erasure")
- **Access control** — role-based access to sensitive fields
- **Audit** — log every access to sensitive data

### 13.2 Compliance-specific

- **GDPR**: right to access, right to erasure, data portability, consent tracking, DPA
- **HIPAA**: PHI encryption, BAA with vendors, audit logs, breach notification
- **PCI-DSS**: never store CVV, tokenize PAN, scope segmentation, quarterly scans
- **SOC 2**: access controls, change management, incident response, continuous monitoring

---

## 14. Dependency Security

- **SCA tools** (Snyk, Dependabot, Renovate, Socket.dev) — automated vuln detection
- **Lock files** committed — reproducible builds
- **Weekly update cadence** — patch vulns quickly
- **Pin transitive deps** when a critical CVE is found upstream
- **Monitor advisories** — GitHub Security Advisories, NVD, npm audit

---

## 15. Logging (security perspective)

What to log (for forensics):
- Auth events (login, logout, failed attempts, token refresh)
- Authorization failures (403s)
- Rate limit triggers
- Admin actions
- Secret access
- Data exports
- Config changes

What NOT to log:
- Passwords, tokens, secrets, API keys
- Full credit card numbers, CVV
- SSN, passport, health info
- Session IDs (log hashes instead)

Retention: 90 days hot, 1 year cold, longer for compliance.

---

## 16. Incident Response (design for it)

- **Runbook** for common incidents (leaked key, breached account, data exfiltration)
- **Kill switches** for dangerous features (disable signups, disable an endpoint)
- **Observability** tuned for detection (see `observability.md`)
- **On-call rotation** with clear escalation
- **Post-mortems** — blameless, published internally
- **Tabletop exercises** — practice incidents before they happen

---

## 17. Security Checklist (baseline for every API)

- [ ] TLS 1.2+ enforced everywhere
- [ ] Auth mechanism chosen and documented
- [ ] AuthZ (not just AuthN) on every endpoint
- [ ] Input validation at boundary
- [ ] Parameterized queries (no injection)
- [ ] Rate limiting per IP / user / key
- [ ] Idempotency keys on mutating endpoints
- [ ] CORS allowlist (no wildcards for authed APIs)
- [ ] Security headers set
- [ ] Secrets in a vault, never in git
- [ ] Dependencies scanned in CI
- [ ] PII minimized, encrypted, redacted in logs
- [ ] Audit logs for sensitive actions
- [ ] OWASP API Top 10 reviewed
- [ ] Multi-tenancy isolation (RLS or equivalent)
- [ ] Password policy + MFA available
- [ ] Incident runbook exists
