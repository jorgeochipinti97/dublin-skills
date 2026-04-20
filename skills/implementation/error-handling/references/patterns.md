# Error Handling — Code Reference

## 1. Typed Error Hierarchy

```ts
// domain/errors.ts
export class DomainError extends Error {
  readonly code: string;
  readonly meta?: Record<string, unknown>;

  constructor(code: string, message: string, meta?: Record<string, unknown>) {
    super(message);
    this.name = new.target.name;
    this.code = code;
    this.meta = meta;
    Object.setPrototypeOf(this, new.target.prototype);
  }

  toJSON() {
    return { code: this.code, message: this.message, meta: this.meta };
  }
}

export class ValidationError extends DomainError {}
export class NotFoundError extends DomainError {}
export class ConflictError extends DomainError {}
export class UnauthorizedError extends DomainError {}
export class ForbiddenError extends DomainError {}
export class RateLimitError extends DomainError {}
export class UpstreamError extends DomainError {}
```

## 2. Correlation ID Middleware (Express/Nest)

```ts
// middleware/correlation.ts
import { randomUUID } from "crypto";
import type { Request, Response, NextFunction } from "express";

export function correlationMiddleware(req: Request, res: Response, next: NextFunction) {
  const id = (req.headers["x-correlation-id"] as string | undefined) ?? randomUUID();
  res.setHeader("x-correlation-id", id);
  (req as any).correlationId = id;
  next();
}
```

## 3. Pino Structured Logger (NestJS)

```bash
pnpm add nestjs-pino pino-http pino
pnpm add -D pino-pretty
```

```ts
// main.ts
import { NestFactory } from "@nestjs/core";
import { Logger } from "nestjs-pino";
import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.useLogger(app.get(Logger));
  await app.listen(3000);
}
bootstrap();
```

```ts
// app.module.ts
import { LoggerModule } from "nestjs-pino";

@Module({
  imports: [
    LoggerModule.forRoot({
      pinoHttp: {
        level: process.env.LOG_LEVEL ?? "info",
        redact: ["req.headers.authorization", "req.headers.cookie", "*.password", "*.token"],
        customProps: (req) => ({ correlationId: (req as any).correlationId }),
        transport: process.env.NODE_ENV !== "production"
          ? { target: "pino-pretty", options: { colorize: true } }
          : undefined,
      },
    }),
  ],
})
export class AppModule {}
```

## 4. Global Exception Filter (NestJS)

```ts
// common/filters/all-exceptions.filter.ts
import { ArgumentsHost, Catch, ExceptionFilter, HttpException } from "@nestjs/common";
import { Logger } from "nestjs-pino";
import type { Request, Response } from "express";
import {
  DomainError, ValidationError, NotFoundError, ConflictError,
  UnauthorizedError, ForbiddenError, RateLimitError, UpstreamError,
} from "@/domain/errors";

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly logger: Logger) {}

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse<Response>();
    const req = ctx.getRequest<Request>();
    const correlationId = (req as any).correlationId ?? "unknown";

    const { status, body } = this.map(exception, req, correlationId);
    const level = status >= 500 ? "error" : "warn";

    this.logger[level]({
      msg: "request_failed",
      status,
      path: req.path,
      method: req.method,
      correlationId,
      userId: (req as any).user?.id,
      error: exception instanceof Error
        ? { name: exception.name, message: exception.message, stack: exception.stack, code: (exception as any).code }
        : { value: String(exception) },
    });

    res.status(status).json(body);
  }

  private map(e: unknown, req: Request, correlationId: string) {
    const base = { instance: req.path, correlationId };

    if (e instanceof ValidationError)    return { status: 422, body: { ...base, type: "urn:problem:validation", title: e.message, status: 422, code: e.code, meta: e.meta } };
    if (e instanceof NotFoundError)      return { status: 404, body: { ...base, type: "urn:problem:not-found", title: e.message, status: 404, code: e.code } };
    if (e instanceof ConflictError)      return { status: 409, body: { ...base, type: "urn:problem:conflict", title: e.message, status: 409, code: e.code } };
    if (e instanceof UnauthorizedError)  return { status: 401, body: { ...base, type: "urn:problem:unauthorized", title: "Unauthorized", status: 401, code: e.code } };
    if (e instanceof ForbiddenError)     return { status: 403, body: { ...base, type: "urn:problem:forbidden", title: "Forbidden", status: 403, code: e.code } };
    if (e instanceof RateLimitError)     return { status: 429, body: { ...base, type: "urn:problem:rate-limit", title: "Too many requests", status: 429, code: e.code } };
    if (e instanceof UpstreamError)      return { status: 502, body: { ...base, type: "urn:problem:upstream", title: "Upstream error", status: 502, code: e.code } };

    if (e instanceof HttpException) {
      const status = e.getStatus();
      return { status, body: { ...base, type: "urn:problem:http", title: e.message, status, code: `HTTP_${status}` } };
    }

    return { status: 500, body: { ...base, type: "urn:problem:internal", title: "Something went wrong", status: 500, code: "INTERNAL_ERROR" } };
  }
}
```

```ts
// main.ts — register
app.useGlobalFilters(new AllExceptionsFilter(app.get(Logger)));
```

## 5. React Error Boundary (class component, only way)

```tsx
// components/error-boundary.tsx
"use client";
import { Component, type ReactNode } from "react";
import * as Sentry from "@sentry/nextjs";

type Props = { fallback: (reset: () => void, error: Error) => ReactNode; children: ReactNode };
type State = { error: Error | null };

export class ErrorBoundary extends Component<Props, State> {
  state: State = { error: null };

  static getDerivedStateFromError(error: Error): State { return { error }; }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    Sentry.captureException(error, { extra: { componentStack: info.componentStack } });
  }

  reset = () => this.setState({ error: null });

  render() {
    if (this.state.error) return this.props.fallback(this.reset, this.state.error);
    return this.props.children;
  }
}
```

## 6. TanStack Query — Global Error Handler

```tsx
// providers/query-provider.tsx
"use client";
import { QueryClient, QueryClientProvider, MutationCache, QueryCache } from "@tanstack/react-query";
import { toast } from "sonner";

function isProblemDetails(e: unknown): e is { code: string; title: string; correlationId?: string } {
  return typeof e === "object" && e !== null && "code" in e;
}

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: (count, err: any) => count < 3 && err.status >= 500 },
    mutations: { retry: false },
  },
  queryCache: new QueryCache({
    onError: (err) => {
      if (isProblemDetails(err)) toast.error(err.title);
    },
  }),
  mutationCache: new MutationCache({
    onError: (err) => {
      if (isProblemDetails(err)) toast.error(err.title);
    },
  }),
});

export function QueryProvider({ children }: { children: React.ReactNode }) {
  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}
```

## 7. Fetch Wrapper that Throws Problem Details

```ts
// lib/api.ts
export class ApiError extends Error {
  readonly status: number;
  readonly code: string;
  readonly correlationId?: string;

  constructor(body: { title: string; code: string; status: number; correlationId?: string }) {
    super(body.title);
    this.name = "ApiError";
    this.status = body.status;
    this.code = body.code;
    this.correlationId = body.correlationId;
  }
}

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(path, {
    ...init,
    headers: { "Content-Type": "application/json", ...init?.headers },
    credentials: "include",
  });
  if (!res.ok) {
    let body;
    try { body = await res.json(); } catch { body = { title: res.statusText, code: "UNKNOWN", status: res.status }; }
    throw new ApiError(body);
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}
```

## 8. Retry with Backoff + Jitter

```ts
export async function withRetry<T>(
  fn: () => Promise<T>,
  opts: { max?: number; baseMs?: number; isRetriable?: (e: unknown) => boolean } = {},
): Promise<T> {
  const max = opts.max ?? 3;
  const baseMs = opts.baseMs ?? 200;
  const isRetriable = opts.isRetriable ?? defaultIsRetriable;

  let lastErr: unknown;
  for (let attempt = 0; attempt < max; attempt++) {
    try {
      return await fn();
    } catch (e) {
      lastErr = e;
      if (!isRetriable(e) || attempt === max - 1) throw e;
      const backoff = baseMs * 2 ** attempt;
      const jitter = Math.random() * baseMs;
      await new Promise(r => setTimeout(r, backoff + jitter));
    }
  }
  throw lastErr;
}

function defaultIsRetriable(e: unknown): boolean {
  if (e instanceof ApiError) return e.status >= 500 || e.status === 429;
  if (e instanceof Error && "code" in e) {
    return ["ETIMEDOUT", "ECONNRESET", "ECONNREFUSED"].includes((e as any).code);
  }
  return false;
}
```

## 9. Sentry Init (Next.js)

```ts
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NEXT_PUBLIC_APP_ENV,
  release: process.env.NEXT_PUBLIC_APP_VERSION,
  tracesSampleRate: 0.1,
  replaysSessionSampleRate: 0,
  replaysOnErrorSampleRate: 1,
  beforeSend(event) {
    // Strip PII
    if (event.user) delete event.user.email;
    return event;
  },
});
```

## 10. Server Action — Return-based Error Pattern

```ts
// app/actions/create-post.ts
"use server";
import { z } from "zod";
import { ValidationError, ConflictError } from "@/domain/errors";

const schema = z.object({ title: z.string().min(1), body: z.string().min(1) });

type State =
  | { ok: true; id: string }
  | { ok: false; error: { code: string; message: string; fieldErrors?: Record<string, string[]> } };

export async function createPost(_: State | null, formData: FormData): Promise<State> {
  const parsed = schema.safeParse(Object.fromEntries(formData));
  if (!parsed.success) {
    return { ok: false, error: { code: "VALIDATION", message: "Check the form", fieldErrors: parsed.error.flatten().fieldErrors as any } };
  }
  try {
    const id = await posts.create(parsed.data);
    return { ok: true, id };
  } catch (e) {
    if (e instanceof ConflictError) return { ok: false, error: { code: e.code, message: e.message } };
    throw e; // unexpected — let Next's error.tsx handle it
  }
}
```
