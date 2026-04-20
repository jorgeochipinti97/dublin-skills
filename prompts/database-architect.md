# database-architect

## Activation Prompts

```
Design the schema for [domain]
```

```
Write a zero-downtime migration to rename a column
```

```
Audit this database for missing indexes and N+1 queries
```

```
Set up multi-tenant Postgres with RLS
```

```
Explain this query plan and suggest indexes
```

```
Choose between Prisma, Drizzle, and Kysely for this project
```

## Example Use Cases

- Initial schema for a new product (users, sessions, audit logs)
- Multi-tenant table design with tenant_id + RLS
- Safe migrations on large tables (CONCURRENTLY, NOT VALID + VALIDATE)
- Fixing slow queries (indexes, covering indexes, partial indexes)
- N+1 detection and remediation
- Queue pattern with SELECT FOR UPDATE SKIP LOCKED
- Connection pooling (PgBouncer, Supavisor)

## Pairs With

- `domain-modeler` (schema reflects the domain model)
- `hexagonal-architect` (repository layer reads the schema)
- `auth-architect` (user/session tables)
