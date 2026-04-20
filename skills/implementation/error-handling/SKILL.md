---
name: error-handling
description: Design the error story across an application — what to throw, what to return, where to catch, what to show the user, what to log. Use when designing an error taxonomy, refactoring error handling (exceptions vs Result types), building Error Boundaries (React), setting up structured logging, designing API error responses (Problem Details / RFC 7807), or debugging why errors disappear silently. Pairs with auth-architect (auth error codes), observability (logging pipelines), and forms-and-validation (surfacing server errors inline).
---

# Error Handling

Errors are features. They inform the user, guide recovery, and let operators fix what's broken. Bad error handling hides bugs and degrades UX — treat it with the same rigor as the happy path.

## The Four Audiences of an Error

Every error is read by up to four audiences. Design for each:

| Audience | Needs | Mechanism |
|---|---|---|
| **End user** | What happened, what to do next, in their language | UI toast/inline/page |
| **Developer** | Root cause, stack, context, correlation ID | Structured logs + error tracker |
| **Operator / SRE** | Is this actionable, is it spiking, who's affected | Metrics + alerts |
| **Auditor** | Security-relevant events | Audit log |

A `try/catch` that logs "error occurred" serves none of them.

## Error Taxonomy (design yours before coding)

Classify every error on two axes:

### By cause

| Class | Examples | Action |
|---|---|---|
| **Expected** (domain error) | Invalid email, not found, conflict | Return or throw typed error. Map to user-facing message. |
| **Programmer error** | null dereference, assertion failure | Should NOT be caught locally. Crash, alert, fix. |
| **Transient** | Timeout, 503, rate-limit | Retry with backoff. Surface if persistent. |
| **External dependency failure** | Payment provider down, DB unreachable | Circuit breaker. Fallback or degrade. |

### By audience

| Class | HTTP | User sees | Logged |
|---|---|---|---|
| **User error** | 4xx | Explain + next step | info |
| **System error** | 5xx | Generic apology + correlation ID | error |
| **Security event** | Often 4xx | Generic (no enum leak) | warn + audit |

## Exceptions vs Result Types — Decision

| Pattern | When |
|---|---|
| **Exceptions** | Crossing many layers, exceptional/rare, not part of happy path. Default in NestJS. |
| **Result / Either** | Branching on success/failure locally, FP style, expected outcomes. Common in Rust/TS FP. |
| **Typed errors in exceptions** | Middle ground — throw a `DomainError` subclass that the edge layer catches and maps. |

**Pragmatic default (TS backend):** Typed exceptions. Define a hierarchy (`DomainError`, `ValidationError`, `NotFoundError`, `ConflictError`, `UnauthorizedError`, `ForbiddenError`). Throw in the domain. Catch in the HTTP adapter. Map to HTTP status + Problem Details.

**Frontend:** Handle errors at data-fetching boundaries (TanStack Query's `onError`, Error Boundaries, Server Action return values). Never let them bubble to `window.onerror` unless genuinely unexpected.

## Error Hierarchy (backend)

```ts
// domain/errors.ts
export class DomainError extends Error {
  readonly code: string;
  readonly meta?: Record<string, unknown>;
  constructor(code: string, message: string, meta?: Record<string, unknown>) {
    super(message);
    this.code = code;
    this.meta = meta;
    this.name = new.target.name;
  }
}

export class ValidationError extends DomainError {}
export class NotFoundError extends DomainError {}
export class ConflictError extends DomainError {}
export class UnauthorizedError extends DomainError {}
export class ForbiddenError extends DomainError {}
export class RateLimitError extends DomainError {}

// usage
throw new NotFoundError("USER_NOT_FOUND", "User not found", { userId });
```

## API Error Responses — RFC 7807 (Problem Details)

Standardize responses. Same shape everywhere = frontend writes one error handler.

```json
{
  "type": "https://api.example.com/problems/user-not-found",
  "title": "User not found",
  "status": 404,
  "detail": "No user with ID 123 exists.",
  "instance": "/api/users/123",
  "code": "USER_NOT_FOUND",
  "correlationId": "req_01H9Z..."
}
```

- `code` — stable machine identifier. Frontend branches on this, not on `message`.
- `title` — human summary, safe to show user.
- `detail` — more context. Optional.
- `correlationId` — log-lookup ID. Show to user for support ("mention this ID: ...").
- **Never leak stack traces, SQL, or internal paths** in production responses.

## Global Error Handler (NestJS)

```ts
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private logger: Logger) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();
    const correlationId = req.headers["x-correlation-id"] ?? randomUUID();

    const { status, body } = this.toProblemDetails(exception, correlationId);

    // Log everything 5xx as error, 4xx as warn (or info for validation)
    const logLevel = status >= 500 ? "error" : "warn";
    this.logger[logLevel]({
      msg: "request_failed",
      status,
      path: req.path,
      method: req.method,
      correlationId,
      error: exception instanceof Error
        ? { name: exception.name, message: exception.message, stack: exception.stack }
        : { value: exception },
    });

    res.status(status).json(body);
  }

  private toProblemDetails(exception: unknown, correlationId: string) {
    if (exception instanceof ValidationError) {
      return { status: 422, body: { code: exception.code, title: exception.message, status: 422, correlationId } };
    }
    if (exception instanceof NotFoundError)     return { status: 404, body: { code: exception.code, title: exception.message, status: 404, correlationId } };
    if (exception instanceof ConflictError)     return { status: 409, body: { code: exception.code, title: exception.message, status: 409, correlationId } };
    if (exception instanceof UnauthorizedError) return { status: 401, body: { code: exception.code, title: "Unauthorized", status: 401, correlationId } };
    if (exception instanceof ForbiddenError)    return { status: 403, body: { code: exception.code, title: "Forbidden", status: 403, correlationId } };
    if (exception instanceof RateLimitError)    return { status: 429, body: { code: exception.code, title: "Too many requests", status: 429, correlationId } };

    // Unknown — never leak details
    return {
      status: 500,
      body: { code: "INTERNAL_ERROR", title: "Something went wrong", status: 500, correlationId },
    };
  }
}
```

## React Error Boundaries

- Wrap **every route** in an Error Boundary (Next.js: `error.tsx` per route)
- Wrap **every independent data-fetching island** (Suspense + Error Boundary)
- Global boundary catches "unknown unknowns" — shows a generic page, never a blank screen

```tsx
// app/dashboard/error.tsx (Next.js App Router)
"use client";

export default function Error({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  useEffect(() => {
    // error is already logged server-side in Next; this is for additional context
  }, [error]);

  return (
    <Section size="lg">
      <Container size="sm">
        <Stack gap={4} align="center">
          <h1 className="text-2xl font-semibold">Something went wrong</h1>
          <p className="text-muted-foreground">
            We've been notified. If this keeps happening, reference ID: {error.digest ?? "N/A"}
          </p>
          <Button onClick={reset}>Try again</Button>
        </Stack>
      </Container>
    </Section>
  );
}
```

## User-Facing Error UX

- **4xx**: be specific and actionable ("Email already registered. Try signing in?")
- **5xx**: be generic + honest. Include correlation ID.
- **Toast** for optimistic actions that failed ("Couldn't save. Retrying…")
- **Inline** for form validation
- **Full-page** for route-level errors
- **Never** show raw exception messages to users

## Logging — What Goes Where

Structured logs (JSON) with consistent fields:

```json
{
  "timestamp": "2026-04-19T12:34:56.789Z",
  "level": "error",
  "msg": "payment_failed",
  "correlationId": "req_01H...",
  "userId": "usr_...",
  "tenantId": "ten_...",
  "error": { "name": "PaymentProviderError", "message": "Timeout", "code": "STRIPE_TIMEOUT" },
  "context": { "orderId": "ord_...", "amount": 2999 }
}
```

**Never log:** passwords, tokens, full credit card numbers, personal data beyond what's required.

**Always log:** the event, the correlation ID, the user/tenant ID, actionable context.

## Retry + Circuit Breaker

```ts
// simple retry with exponential backoff + jitter
async function withRetry<T>(fn: () => Promise<T>, opts = { max: 3, baseMs: 200 }): Promise<T> {
  let lastErr: unknown;
  for (let attempt = 0; attempt < opts.max; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastErr = err;
      if (!isRetriable(err)) throw err;
      const delay = opts.baseMs * 2 ** attempt + Math.random() * opts.baseMs;
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw lastErr;
}

function isRetriable(err: unknown): boolean {
  if (err instanceof Error && "code" in err) {
    return ["ETIMEDOUT", "ECONNRESET", "ECONNREFUSED"].includes((err as any).code);
  }
  return false;
}
```

For production: use `cockatiel` or `opossum` for circuit breaker + retry policies.

## Error Tracking

- **Sentry** (hosted) or **GlitchTip** (self-hosted, Sentry-compatible)
- Tag with: `release`, `environment`, `userId`, `tenantId`, `correlationId`
- Group by `code`, not by message (messages vary, codes don't)
- **Sourcemaps** uploaded on build so stack traces are readable

## Checklist (before shipping)

- [ ] Typed error hierarchy exists (ValidationError, NotFoundError, etc.)
- [ ] Global exception filter maps all to Problem Details JSON
- [ ] Correlation ID middleware adds `x-correlation-id` on every request
- [ ] Structured JSON logging with correlation + user/tenant IDs
- [ ] No stack traces / SQL / internal paths in prod responses
- [ ] Error tracker configured (Sentry/GlitchTip) with sourcemaps
- [ ] Error Boundary at every route + global fallback
- [ ] User-facing errors reviewed by someone non-technical (clarity)
- [ ] Retry + backoff for all external calls (never infinite)
- [ ] Circuit breaker on external deps with blast radius
- [ ] No `catch (e) {}` empty catches anywhere in the codebase

## Anti-Patterns

| Anti-pattern | Why bad | Fix |
|---|---|---|
| `catch (e) {}` (swallowing) | Bugs disappear | Log + rethrow OR handle meaningfully |
| `throw new Error("failed")` everywhere | No code, no context, unmapped | Typed error classes with codes |
| Exposing stack traces to users | Security + UX | Problem Details only |
| Branching on error messages | Fragile | Branch on `code` |
| Generic 500 for every failure | Users can't recover | Specific 4xx with next step |
| Retrying 4xx errors | Never succeeds, wastes resources | Retry only transient (5xx, network) |
| Alerting on every error | Alert fatigue | Alert on rates, not events |
| Logging token / password / PII | Compliance disaster | Redaction middleware |
| Error boundary only at root | Whole app dies on leaf failure | Granular boundaries |
| No correlation ID | Can't trace one request across logs | Middleware on entry |

## Output Standards

- Always propose the error taxonomy FIRST (what classes exist, what they mean)
- Always include correlation ID generation and propagation
- API responses use Problem Details (RFC 7807) unless there's a strong reason not to
- Separate domain errors from infrastructure errors — never let a DB constraint error reach the user

## Reference Files

- `references/patterns.md` — Full NestJS filter, typed error hierarchy, correlation middleware, structured logger setup (Pino), React Error Boundary, retry helpers, Sentry init, TanStack Query error hook
