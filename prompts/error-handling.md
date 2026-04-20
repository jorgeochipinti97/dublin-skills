# error-handling

## Activation Prompts

```
Design the error taxonomy for this app
```

```
Set up Problem Details (RFC 7807) responses in NestJS
```

```
Add Error Boundaries to every route in this Next.js app
```

```
Set up structured logging with correlation IDs
```

```
Audit this codebase for swallowed errors and stack trace leaks
```

```
Add retry with exponential backoff to this external call
```

```
Configure Sentry with sourcemaps
```

## Example Use Cases

- Typed error hierarchy (ValidationError, NotFoundError, ConflictError, etc.)
- Global exception filter (NestJS) with Problem Details output
- Correlation ID middleware + structured JSON logs (Pino)
- React Error Boundary per route + global fallback
- TanStack Query global error handler (toast + Sentry)
- Retry + circuit breaker for external services
- Server Action return-based error pattern

## Pairs With

- `auth-architect` (auth error codes, no enum leak)
- `forms-and-validation` (surfacing server errors inline)
- `api-architect` (consistent error responses)
