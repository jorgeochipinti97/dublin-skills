# Rollback Playbook

Per-system rollback commands. Copy the relevant block into the runbook before the change.

> Verify command syntax against your specific provider/version. CLI flags evolve. When in doubt, `<tool> --help` or read the official doc rather than trusting this playbook from memory.

## Postgres

### Snapshot before change

```bash
# Logical dump (per-database, restorable to any version >= source)
pg_dump --format=custom --file=pre_change_$(date +%Y%m%d-%H%M%S).dump \
  --no-owner --no-acl \
  "postgres://user:pass@host:5432/dbname"

# Verify dump opens
pg_restore --list pre_change_*.dump | head
```

For managed Postgres (RDS, Neon, Supabase, Crunchy, Cloud SQL): check that automated PITR / continuous backup is enabled and the most recent backup completed in the last hour. The provider doc names the exact UI / API call. Do not skip the manual `pg_dump` even if PITR is on — PITR restores the whole instance, not one DB.

### Restore (full DB)

```bash
# Drop and recreate target DB (only on a scratch/recovery instance, never on live prod without rename-swap)
dropdb dbname_recovery
createdb dbname_recovery
pg_restore --dbname=dbname_recovery --no-owner --no-acl pre_change_*.dump
```

### Restore (single table)

```bash
# Extract just the table from a custom-format dump
pg_restore --table=orders --data-only --file=orders_only.sql pre_change_*.dump

# Apply to a recovery DB or rename-swap into prod
psql dbname_recovery < orders_only.sql
```

### PITR restore

Provider-specific. The pattern is: pick a timestamp before the bad change, restore to a NEW instance, validate data, then either rename-swap or selectively copy tables back. Never restore in place over a live prod instance — you lose any writes since the bad change.

### In-flight transaction check

```sql
SELECT pid, usename, application_name, state, wait_event, query_start, left(query, 80)
FROM pg_stat_activity
WHERE datname = current_database() AND state != 'idle'
ORDER BY query_start;
```

### Lock-safe migration session

```sql
SET lock_timeout = '3s';
SET statement_timeout = '60s';
SET idle_in_transaction_session_timeout = '60s';

BEGIN;
-- migration here
COMMIT;
```

## MySQL

### Snapshot before change

```bash
mysqldump --single-transaction --routines --triggers --events \
  -u user -p dbname > pre_change_$(date +%Y%m%d-%H%M%S).sql
```

### Restore

```bash
mysql -u user -p dbname_recovery < pre_change_*.sql
```

For managed MySQL (RDS, Cloud SQL, Aiven): use the snapshot UI/API in addition to `mysqldump`.

## MongoDB

### Snapshot before change

```bash
mongodump --uri="mongodb://user:pass@host:27017/dbname" \
  --out=pre_change_$(date +%Y%m%d-%H%M%S)
```

### Restore

```bash
mongorestore --uri="mongodb://user:pass@host:27017/dbname_recovery" \
  pre_change_*/dbname
```

For Atlas: snapshot is the primary mechanism, `mongodump` is the secondary. Use both for high-stakes changes.

## Redis

If Redis is a cache: no rollback needed. Cache regenerates.

If Redis is a primary store (sessions, queues, rate limits, idempotency keys):

```bash
# Trigger a synchronous save before the change
redis-cli -u redis://host:6379 BGSAVE
# Wait for "Background saving terminated with success" in INFO persistence
redis-cli -u redis://host:6379 INFO persistence
```

Snapshot: copy the `dump.rdb` file out (location is in `redis-cli CONFIG GET dir`). For managed Redis, use the provider snapshot.

## Shopify

### Before change

- Export catalog: Admin → Products → Export → All products, CSV
- Export theme: Admin → Online Store → Themes → Actions → Download theme file
- Export pages / blogs: per-resource Export buttons
- Note current payment provider settings: screenshot Settings → Payments

### Rollback

- Catalog: Admin → Products → Import → upload the pre-change CSV. Choose "Overwrite any current products that have the same handle". Test on one SKU first.
- Theme: Admin → Themes → Add theme → Upload zip → Publish
- Bulk price/inventory: Admin → Bulk editor history (only available for some fields)

For Plus stores: use the GraphQL Admin API for scripted rollback. Verify the API version against the [Shopify changelog](https://shopify.dev/docs/api/release-notes) before scripting; do not hardcode an API version that may be deprecated.

## WooCommerce

### Before change

- Full DB dump: WP-CLI `wp db export pre_change_$(date +%Y%m%d-%H%M%S).sql`
- Full file dump: `tar -czf pre_change_files.tar.gz wp-content/`
- Plugin/theme list: `wp plugin list --format=csv > plugins.csv` and `wp theme list --format=csv > themes.csv`

### Rollback

- DB: `wp db import pre_change_*.sql` (overwrites everything)
- Files: extract the tar over `wp-content/`
- Selective product rollback: use a staging clone, restore there, then export the affected products and import via WooCommerce → Products → Import

## Vercel

### Before change

- Note the current production deploy SHA: `vercel ls --scope <team>` or via dashboard
- Confirm the deploy is healthy (no `ERROR` state)

### Rollback

- Dashboard: Deployments → previous green deploy → Promote to Production
- CLI: `vercel rollback <deployment-url>` (requires CLI v32+)
- Confirm the previous deploy works against the current DB schema. If you ran a forward-incompatible migration, rollback alone is not enough — restore the DB too.

## Netlify

### Before change

- Note current published deploy ID: `netlify api listSiteDeploys --data '{"site_id":"<id>"}'` or dashboard

### Rollback

- Dashboard: Deploys → previous deploy → Publish deploy
- CLI: `netlify api rollbackSiteDeploy --data '{"site_id":"<id>","deploy_id":"<id>"}'`

## App config (env vars, secrets)

### Before change

- Export current values to encrypted vault (Doppler, 1Password, AWS Secrets Manager, etc.)
- Diff against expected new values
- For provider-managed env (Vercel, Netlify, Fly): use the provider CLI/API to dump current values

### Rollback

- Restore previous values from vault
- Trigger a redeploy so the running fleet picks up the rollback values
- Watch for stale processes still on old values (`pm2 reload`, `kubectl rollout restart`)

## DNS

### Before change

- Document current records in a text file: type, name, value, TTL
- Lower TTL on affected records ≥ TTL hours before the change (so rollback propagates fast)
- Stage the new value on a test record (`dig _test.example.com`)

### Rollback

- Restore previous values exactly
- Wait for TTL expiry (your low TTL pre-change pays off here)
- Verify with `dig +short example.com @8.8.8.8` and `dig +short example.com @1.1.1.1`

## TLS Cert

- Use ACME (Caddy, certbot, AWS ACM, Cloudflare). Automated renewal is the rollback (re-trigger).
- Manual cert swap rollback: keep the previous cert+key on disk, swap back, reload server.

## S3 / R2 / GCS

### Before change

- Versioning enabled? Confirm: `aws s3api get-bucket-versioning --bucket <name>`
- If yes: list versions of every key you plan to touch:
  ```bash
  aws s3api list-object-versions --bucket <name> --prefix path/to/key --output json > pre_change_versions.json
  ```
- If no: copy keys to a backup prefix or bucket first

### Rollback

- With versioning: `aws s3api delete-object --bucket <name> --key <key> --version-id <bad-version>` (deletes the bad version, the previous version becomes current). Verify the version IDs against your CLI version's syntax.
- Without versioning: re-upload from backup

## IAM / security group

### Before change

- Export current policy/SG: `aws iam get-policy-version` / `aws ec2 describe-security-groups`
- Save JSON to vault entry tagged with the change ID

### Rollback

- Re-apply the saved JSON
- For broadening changes (more permissive): rollback first if any anomaly, ask questions later

## App data (model store, user data)

If the change writes to user data (e.g. mass-update a profile field):

1. Dump the affected rows BEFORE: `COPY (SELECT * FROM users WHERE ...) TO '/tmp/users_pre.csv' CSV HEADER;`
2. Apply the change
3. Rollback: re-import from CSV with explicit `WHERE` to avoid touching unaffected rows

## Cloudflare (Workers, KV, R2, DNS)

- Workers: previous version is the rollback. Dashboard → Workers → previous deploy → Rollback
- KV: no built-in versioning. Backup keys before mass updates: `wrangler kv:bulk get --namespace-id=<id> > pre_change_kv.json`
- R2: same as S3 — use versioning if enabled

## Generic web app deploy

If on bare VPS / Docker / k8s:

- Tag the current image: `docker tag app:current app:rollback-$(date +%Y%m%d)`
- Note the running compose SHA / k8s deployment revision: `kubectl rollout history deployment/app`
- Rollback: `kubectl rollout undo deployment/app` or `docker compose up app:rollback-...`
