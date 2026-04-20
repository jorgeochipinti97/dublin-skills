# Auth Patterns — Code Reference

Copy-pasteable snippets for the most sensitive auth flows.

## 1. Better-Auth (Next.js App Router) — Day-0 Setup

```bash
pnpm add better-auth
```

```ts
// lib/auth.ts
import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";
import { prisma } from "@/lib/prisma";

export const auth = betterAuth({
  database: prismaAdapter(prisma, { provider: "postgresql" }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    minPasswordLength: 12,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
  session: {
    expiresIn: 60 * 60 * 24 * 7,     // 7 days
    updateAge: 60 * 60 * 24,          // rotate daily
    cookieCache: { enabled: true, maxAge: 5 * 60 },
  },
  advanced: {
    cookiePrefix: "app",
    useSecureCookies: process.env.NODE_ENV === "production",
  },
});

export type Session = typeof auth.$Infer.Session;
```

```ts
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth";
import { toNextJsHandler } from "better-auth/next-js";
export const { GET, POST } = toNextJsHandler(auth);
```

```ts
// middleware.ts — protect routes
import { NextResponse, type NextRequest } from "next/server";
import { getSessionCookie } from "better-auth/cookies";

const PROTECTED = ["/dashboard", "/settings"];

export function middleware(req: NextRequest) {
  const session = getSessionCookie(req);
  const isProtected = PROTECTED.some(p => req.nextUrl.pathname.startsWith(p));
  if (isProtected && !session) {
    return NextResponse.redirect(new URL("/login", req.url));
  }
  return NextResponse.next();
}

export const config = { matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"] };
```

## 2. NestJS — JWT + Refresh Token Rotation

```ts
// auth/auth.service.ts
@Injectable()
export class AuthService {
  constructor(
    private users: UsersService,
    private jwt: JwtService,
    private sessions: SessionsRepository,
  ) {}

  async login(email: string, password: string, ua: string, ip: string) {
    const user = await this.users.findByEmail(email);
    if (!user || !(await argon2.verify(user.passwordHash, password))) {
      // Same response whether user exists or not — prevents enumeration
      await this.constantTimeDelay();
      throw new UnauthorizedException("Invalid credentials");
    }
    return this.issueTokens(user.id, ua, ip);
  }

  async refresh(refreshToken: string, ua: string, ip: string) {
    const session = await this.sessions.findByToken(hash(refreshToken));
    if (!session || session.revokedAt || session.expiresAt < new Date()) {
      // Stale or reused token — possible theft. Revoke ALL sessions for the user.
      if (session) await this.sessions.revokeAllForUser(session.userId);
      throw new UnauthorizedException();
    }
    // Rotate: revoke the used refresh token and issue a new one
    await this.sessions.revoke(session.id);
    return this.issueTokens(session.userId, ua, ip);
  }

  private async issueTokens(userId: string, ua: string, ip: string) {
    const accessToken = await this.jwt.signAsync(
      { sub: userId },
      { expiresIn: "15m", secret: process.env.JWT_ACCESS_SECRET },
    );
    const refreshToken = crypto.randomBytes(64).toString("base64url");
    await this.sessions.create({
      userId,
      tokenHash: hash(refreshToken),
      userAgent: ua,
      ip,
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    });
    return { accessToken, refreshToken };
  }

  async logout(refreshToken: string) {
    await this.sessions.revokeByToken(hash(refreshToken));
  }
}
```

## 3. Password Reset (safe)

```ts
async requestReset(email: string) {
  const user = await this.users.findByEmail(email);
  // Always return success — do not leak whether email exists
  if (!user) return { ok: true };

  const token = crypto.randomBytes(32).toString("base64url");
  await this.resets.create({
    userId: user.id,
    tokenHash: hash(token),
    expiresAt: new Date(Date.now() + 15 * 60 * 1000), // 15 min
  });
  await this.mail.sendPasswordReset(user.email, token);
  return { ok: true };
}

async confirmReset(token: string, newPassword: string) {
  const reset = await this.resets.findByTokenHash(hash(token));
  if (!reset || reset.usedAt || reset.expiresAt < new Date()) {
    throw new BadRequestException("Invalid or expired token");
  }
  await this.users.updatePassword(reset.userId, await argon2.hash(newPassword));
  await this.resets.markUsed(reset.id);
  // Revoke all existing sessions — if this was an attacker, kick them out
  await this.sessions.revokeAllForUser(reset.userId);
}
```

## 4. RBAC Guard (NestJS)

```ts
// roles.decorator.ts
export const Roles = (...roles: Role[]) => SetMetadata("roles", roles);

// roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}
  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.get<Role[]>("roles", ctx.getHandler());
    if (!required) return true;
    const { user } = ctx.switchToHttp().getRequest();
    return required.some(r => user.roles?.includes(r));
  }
}

// usage
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles("admin")
@Delete(":id")
remove(@Param("id") id: string) { /* ... */ }
```

## 5. ABAC with CASL (ownership + role)

```ts
import { AbilityBuilder, createMongoAbility } from "@casl/ability";

export function defineAbilitiesFor(user: User) {
  const { can, cannot, build } = new AbilityBuilder(createMongoAbility);

  if (user.role === "admin") {
    can("manage", "all");
    return build();
  }

  can("read", "Document");
  can("update", "Document", { ownerId: user.id });
  can("delete", "Document", { ownerId: user.id, status: "draft" });
  cannot("delete", "Document", { status: "published" });

  return build();
}

// in handler
if (!ability.can("update", document)) throw new ForbiddenException();
```

## 6. Rate Limiting (login, reset)

```ts
// nestjs with @nestjs/throttler
@Module({
  imports: [
    ThrottlerModule.forRoot([
      { name: "short", ttl: 60_000, limit: 10 },        // 10/min global
      { name: "auth",  ttl: 900_000, limit: 5 },        // 5 / 15min for auth
    ]),
  ],
})

@Throttle({ auth: { limit: 5, ttl: 900_000 } })
@Post("login")
login() { /* ... */ }
```

## 7. Session Fixation Protection

```ts
// After successful login, always rotate session ID
await req.session.regenerate();
req.session.userId = user.id;
```

## 8. CSRF (cookie-based auth)

- **SameSite=Lax** cookie blocks most CSRF by default
- For state-changing requests that must allow cross-site (rare), use a **double-submit CSRF token**
- **Never** bypass CSRF for "APIs" if the same origin sends cookies

```ts
// next.js - verify origin header on mutation routes
export async function POST(req: Request) {
  const origin = req.headers.get("origin");
  if (origin !== process.env.APP_URL) return new Response("Forbidden", { status: 403 });
  // ...
}
```

## 9. Audit Log

Log these events (never log tokens or passwords):

- `auth.login.success` / `auth.login.failed`
- `auth.logout`
- `auth.password.reset_requested` / `.reset_completed`
- `auth.password.changed`
- `auth.mfa.enabled` / `.disabled` / `.challenge_failed`
- `auth.session.revoked` (and who revoked it)
- `authz.permission.granted` / `.revoked` (admin actions)

Include: `userId`, `ip`, `userAgent`, `timestamp`, `result`. Store ≥ 90 days.
