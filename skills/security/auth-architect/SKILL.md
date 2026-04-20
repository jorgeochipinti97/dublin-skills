---
name: auth-architect
description: Design and audit authentication and authorization for web/mobile apps. Use when setting up auth from scratch (OAuth/OIDC, passkeys, email+password, magic links), migrating providers, implementing RBAC/ABAC, debugging session/token issues, or auditing an existing system for vulnerabilities (session fixation, token leakage, CSRF, mass assignment). Covers Next.js, NestJS, Auth.js/Better-Auth/Clerk/Supabase Auth. Pairs with database-architect (user/session tables) and error-handling (auth error taxonomy).
---

# Auth Architect

Authentication = who you are. Authorization = what you can do. Confusing them is the root of most auth bugs.

## Decision Tree — Which Auth Stack?

| Scenario | Recommended |
|---|---|
| B2C product, want fastest path | **Clerk** (hosted, $25/mo at scale) or **Supabase Auth** (if already on Supabase) |
| B2B / enterprise (SSO, SAML, SCIM) | **WorkOS** or **Auth0** |
| Full control + open source | **Better-Auth** (modern, TypeScript-first) or **Auth.js** (NextAuth) |
| Need passkeys + simple | Better-Auth or Clerk (both support WebAuthn) |
| Monolithic NestJS backend | Passport.js + JWT + refresh token rotation, or Better-Auth backend mode |

**Default:** Better-Auth if team wants full control, Clerk if team wants to ship fast.

## JWT vs Sessions

| | Sessions (cookies) | JWT (stateless) |
|---|---|---|
| Revocation | Instant (delete server-side) | Requires denylist or short TTL + refresh |
| Storage | Server (DB/Redis) | Client (cookie, never localStorage) |
| Best for | Web apps | Cross-service, mobile, APIs |
| Default choice | **Web apps** | APIs and mobile only |

**Rule:** For a web app, use **httpOnly secure same-site cookies with session IDs**. Do NOT put JWT in `localStorage`. Never.

## Token Storage (the #1 bug)

```
✅ httpOnly + Secure + SameSite=Lax cookie    (XSS-safe, CSRF-mitigated)
✅ Memory (in-app variable) for access tokens  (XSS risk but no persistence)
❌ localStorage                                (XSS extracts it trivially)
❌ sessionStorage                              (same)
❌ Non-httpOnly cookie                         (XSS extracts it)
```

## Access + Refresh Token Pattern

- **Access token**: short (5-15 min), in memory or httpOnly cookie
- **Refresh token**: long (7-30 days), httpOnly cookie, **rotated on every use** (refresh rotation)
- **On rotation**: invalidate old refresh token in DB. If a stale one is used → user is compromised, revoke all sessions.

## Password Hashing

- **argon2id** (preferred) or **bcrypt** (cost ≥ 12). Never SHA/MD5/raw.
- Pepper (secret app-level salt) optional, in env var
- Rate-limit login (5 attempts / 15 min per account + IP)
- Never return "user not found" vs "wrong password" — same generic error

## RBAC vs ABAC

- **RBAC** (roles): simple, coarse — `admin`, `editor`, `viewer`. Use by default.
- **ABAC** (attributes): fine-grained — "can edit doc IF owner OR team member". Use when RBAC roles explode.
- Library: **CASL** (JS/TS) for ABAC, or roll your own `can(user, action, resource)` helper.

## Multi-tenancy Models

| Model | Schema | When |
|---|---|---|
| Shared DB, `tenant_id` column everywhere | Row-level scope on every query | Default for B2B SaaS |
| Schema per tenant | Postgres schemas | Compliance (healthcare, finance) |
| DB per tenant | Separate Postgres instances | Isolation-critical, big customers |

**Row-level security (RLS)** in Postgres + tenant_id is the safest — DB enforces it even if app forgets.

## Must-Verify Checklist (before shipping auth)

- [ ] HTTPS everywhere. Cookies `Secure` + `httpOnly` + `SameSite=Lax`
- [ ] Password reset tokens: single-use, expire in 15 min, invalidated on use
- [ ] Email verification on signup (prevent account takeover via typo)
- [ ] Rate limiting on login, signup, password reset, MFA
- [ ] CSRF protection on state-changing non-GET requests (if using cookies)
- [ ] Session fixation: regenerate session ID on login
- [ ] Logout clears server-side session AND cookie
- [ ] MFA: TOTP (authenticator apps) — SMS is last resort (SIM swap)
- [ ] Audit log: login, logout, password change, MFA enable/disable, permission change
- [ ] No auth info in logs (no tokens, no passwords, not even hashed)
- [ ] Account enumeration blocked (same response time + message on login/reset)
- [ ] Tokens in URLs forbidden (they leak to logs, analytics, Referer)

## Common Vulnerabilities (audit these)

| Vuln | How it happens | Fix |
|---|---|---|
| Session fixation | Login doesn't rotate session ID | Regenerate on login |
| CSRF | Cookie auth + no CSRF token on POST | SameSite=Lax + CSRF token for sensitive actions |
| IDOR | Endpoint trusts `?userId=` from client | Always derive user from session, never trust client IDs |
| Mass assignment | `User.update(req.body)` — client sends `isAdmin:true` | Whitelist allowed fields |
| Token in URL | Magic links, OAuth redirects logged by proxy | Use POST or consume immediately |
| Missing authz | Route authenticated but not authorized | Check role/ownership on every protected endpoint |
| Open redirect | `redirect_uri=?next=evil.com` | Whitelist allowed hosts |
| Insecure password reset | Reset token logged, long-lived, reusable | Single-use, 15min TTL, deleted on use |

## Output Standards

- Show the stack choice + rationale (why this over alternatives)
- Provide code for the most sensitive parts (session rotation, password reset, middleware)
- Always include rate limiting and audit logging
- Call out every security-critical decision explicitly

## Reference Files

- `references/patterns.md` — Complete code: Better-Auth setup, NestJS guards + passport, refresh token rotation, password reset flow, RBAC middleware, CSRF setup, rate limiter
