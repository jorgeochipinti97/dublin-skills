# Database — Code Reference

Schema templates, migrations, and setup snippets.

## 1. Baseline Users + Sessions Schema (Postgres)

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email CITEXT UNIQUE NOT NULL,
  email_verified_at TIMESTAMPTZ,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','admin')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_email ON users(email);

CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token_hash TEXT NOT NULL UNIQUE,
  user_agent TEXT,
  ip INET,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_expires ON sessions(expires_at) WHERE revoked_at IS NULL;

-- Updated_at trigger
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();
```

## 2. Multi-Tenant Schema with RLS

```sql
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE memberships (
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner','admin','member')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, user_id)
);

CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES users(id),
  title TEXT NOT NULL,
  content JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Composite index starting with tenant_id (always filter by tenant)
CREATE INDEX idx_documents_tenant_created ON documents(tenant_id, created_at DESC);

-- RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON documents
  USING (tenant_id = current_setting('app.tenant_id')::uuid);

-- App sets the tenant per request:
-- SET LOCAL app.tenant_id = '<tenant-uuid>';
```

## 3. Audit Log Schema

```sql
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  tenant_id UUID,
  actor_id UUID,           -- user who did it (null for system)
  event TEXT NOT NULL,     -- e.g. 'auth.login.success'
  resource_type TEXT,
  resource_id UUID,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  ip INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_tenant_created ON audit_logs(tenant_id, created_at DESC);
CREATE INDEX idx_audit_actor ON audit_logs(actor_id) WHERE actor_id IS NOT NULL;
CREATE INDEX idx_audit_event ON audit_logs(event);
```

## 4. Zero-Downtime Column Rename (3 migrations)

```sql
-- Migration 001: add new column
ALTER TABLE users ADD COLUMN full_name TEXT;

-- App v2: dual-write both columns, read from old
-- Deploy app v2 → wait for 100% rollout

-- Migration 002: backfill
UPDATE users SET full_name = name WHERE full_name IS NULL;
CREATE INDEX CONCURRENTLY idx_users_full_name ON users(full_name);

-- App v3: read from full_name, still write both
-- Deploy app v3 → wait for 100% rollout

-- App v4: only write to full_name
-- Deploy app v4 → wait for 100% rollout

-- Migration 003: drop old column
ALTER TABLE users DROP COLUMN name;
```

## 5. Prisma Setup

```bash
pnpm add -D prisma
pnpm add @prisma/client
pnpm dlx prisma init
```

```prisma
// prisma/schema.prisma
generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["postgresqlExtensions"]
}

datasource db {
  provider   = "postgresql"
  url        = env("DATABASE_URL")
  directUrl  = env("DIRECT_URL")  // for migrations (bypass pooler)
  extensions = [pgcrypto, citext]
}

model User {
  id           String   @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
  email        String   @unique @db.Citext
  passwordHash String
  name         String
  role         Role     @default(USER)
  sessions     Session[]
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt

  @@map("users")
}

enum Role {
  USER
  ADMIN
}
```

```ts
// lib/prisma.ts — singleton for Next.js dev hot reload
import { PrismaClient } from "@prisma/client";

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === "development" ? ["query", "warn", "error"] : ["warn", "error"],
});

if (process.env.NODE_ENV !== "production") globalForPrisma.prisma = prisma;
```

## 6. Drizzle Setup

```bash
pnpm add drizzle-orm postgres
pnpm add -D drizzle-kit
```

```ts
// db/schema.ts
import { pgTable, uuid, text, timestamp, index } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  email: text("email").notNull().unique(),
  passwordHash: text("password_hash").notNull(),
  name: text("name").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
}, (t) => ({
  emailIdx: index("idx_users_email").on(t.email),
}));
```

```ts
// db/client.ts
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";

const client = postgres(process.env.DATABASE_URL!, { max: 10 });
export const db = drizzle(client, { schema });
```

## 7. Connection Pooling (PgBouncer + Prisma)

```
# pgbouncer.ini
[databases]
app = host=localhost dbname=app port=5432

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = scram-sha-256
pool_mode = transaction
default_pool_size = 25
max_client_conn = 1000
```

```
# .env
DATABASE_URL="postgresql://user:pass@pgbouncer:6432/app?pgbouncer=true&connection_limit=1"
DIRECT_URL="postgresql://user:pass@postgres:5432/app"
```

## 8. Queue Pattern (SELECT FOR UPDATE SKIP LOCKED)

```sql
CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  queue TEXT NOT NULL,
  payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','running','done','failed')),
  run_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  attempts INT NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_jobs_poll ON jobs(queue, run_at) WHERE status = 'pending';

-- Worker picks a job atomically
BEGIN;
SELECT * FROM jobs
  WHERE queue = 'email' AND status = 'pending' AND run_at <= now()
  ORDER BY run_at
  LIMIT 1
  FOR UPDATE SKIP LOCKED;
-- Multiple workers never pick the same job
UPDATE jobs SET status = 'running', attempts = attempts + 1 WHERE id = $1;
COMMIT;
```

## 9. Full-Text Search (Postgres native)

```sql
ALTER TABLE documents
  ADD COLUMN search_vector tsvector
  GENERATED ALWAYS AS (to_tsvector('english', title || ' ' || coalesce(content->>'body', ''))) STORED;

CREATE INDEX idx_documents_search ON documents USING GIN (search_vector);

-- Query
SELECT * FROM documents
WHERE search_vector @@ websearch_to_tsquery('english', 'design system')
ORDER BY ts_rank(search_vector, websearch_to_tsquery('english', 'design system')) DESC
LIMIT 20;
```

## 10. Explain Plan Analysis

```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT u.*, count(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.created_at > now() - interval '30 days'
GROUP BY u.id
ORDER BY order_count DESC
LIMIT 50;
```

Look for:
- **Seq Scan** on big tables → missing index
- **High buffers read** → data doesn't fit in cache / too much fetched
- **Nested Loop** with many rows → consider Hash Join / Merge Join
- **Sort** with `external merge` → `work_mem` too low, or add index on ORDER BY column
