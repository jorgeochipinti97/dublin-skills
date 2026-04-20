# auth-architect

## Activation Prompts

```
Design the auth system for [product]
```

```
Audit this codebase for auth vulnerabilities
```

```
Set up Better-Auth / Clerk / Supabase Auth for a Next.js app
```

```
Implement refresh token rotation in NestJS
```

```
Add RBAC with roles [admin, editor, viewer]
```

```
Migrate from JWT-in-localStorage to httpOnly cookies
```

## Example Use Cases

- B2C signup/login with email verification + passkeys
- B2B SaaS with SSO (SAML/OIDC) and SCIM
- Multi-tenant auth with RLS in Postgres
- Auth audit: session fixation, CSRF, IDOR, mass assignment
- Password reset flow that's safe (single-use, 15min TTL)
- OAuth 2.0 / OIDC integration with Google/Microsoft

## Pairs With

- `database-architect` (user/session schema)
- `error-handling` (auth error taxonomy, no enum leak)
- `forms-and-validation` (signup/login forms)
