---
name: change-safety
description: Pre-flight guardrail before any write to production. Use when about to ALTER/DROP/UPDATE/DELETE/TRUNCATE in a DB, modify a live store/CMS catalog/pricing/inventory, deploy a feature, change critical config, or touch infra. Forces a snapshot/backup, rollback plan, stakeholder comms, in-flight transaction check, and change window before executing. Pairs with database-architect (zero-downtime migrations), github-safety (non-destructive git), infra-security (security audits).
---

# Change Safety

Touching production without a rollback plan is the difference between a five-minute fix and a postmortem. This skill is the guardrail. Before any write to prod, it forces a checklist, names the rollback path, and flags in-flight risk. If you cannot answer the checklist, you do not execute.

## When This Skill Auto-Invokes

Trigger on ANY of these signals in the planned change:

- DB schema: `ALTER`, `DROP`, `RENAME`, `TRUNCATE`, `CREATE INDEX` (without CONCURRENTLY)
- DB data: `UPDATE` or `DELETE` without `WHERE`, mass `WHERE` over a live table, batch import, restore from external source
- Store / CMS: catalog edit, price change, inventory adjustment, product activation/deactivation, theme swap, payment provider switch
- Deploy: prod release, feature flag flip for paying users, env var rotation, secret rotation
- Config: web server, reverse proxy, DNS, TLS cert, rate limit, CORS, CSP, robots
- Infra: instance resize, autoscaling rule, security group, IAM policy, network ACL, RDS parameter group, S3 bucket policy

If unsure → run the skill. Two minutes of checklist beats two hours of recovery.

## Pre-Flight Protocol (mandatory)

Run in this order. Skip nothing. If you cannot answer a step, stop.

### 1. Define the change in one sentence

`<verb> <object> in <system> at <time-window>`

Examples:
- "Drop column `legacy_status` from `orders` in prod Postgres at Tue 03:00 ART"
- "Bulk-update 4,200 SKUs to new price tier in Shopify at Wed 09:30 ART"
- "Promote feature flag `checkout_v2` to 100% in prod at Fri 14:00 ART"

If you cannot write that sentence, the change is not ready.

### 2. Snapshot / backup verified

Pick the right tool by system. See `references/rollback-playbook.md` for exact commands per system. The rule is: **the backup must be tested, not just taken.**

| System | Snapshot mechanism | Test |
|---|---|---|
| Postgres (managed: RDS, Neon, Supabase) | Automated PITR + manual `pg_dump` before change | Restore the dump to a scratch DB; run smoke query |
| Postgres (self-hosted) | `pg_dump --format=custom` + filesystem snapshot | Same |
| MySQL | `mysqldump --single-transaction` or managed snapshot | Restore to scratch |
| MongoDB | `mongodump` or Atlas snapshot | Restore to scratch |
| Redis (cache only) | None needed if cache. If primary store, RDB+AOF | Confirm replication lag < 1s before |
| Shopify / WooCommerce | Export catalog + theme; if WP, full DB+files dump | Open exports, confirm row count |
| Vercel / Netlify | Previous deploy is the rollback. Confirm last green deploy SHA | `vercel ls` / `netlify deploy --list` shows healthy state |
| App config (env vars) | Export current values to encrypted vault entry | Diff against current |
| S3 / R2 / GCS | Versioning enabled + manifest of touched keys | List versions on a sample key |
| DNS | Document current records (TTL, value, type) | Lower TTL ≥ TTL hours BEFORE change |

If snapshot is "we have backups somewhere", you do not have a backup. Verify it now.

### 3. Rollback plan in writing

Three answers, in the runbook before you start:

- **Trigger**: what observable signal means "rollback now"? (error rate > X, p95 > Y ms, support ticket flood, user-visible 500s on home/checkout)
- **Procedure**: exact commands to undo. Copy-paste ready. No improvisation under pressure.
- **Time-to-restore (RTO)**: how long does rollback take? If > 15 min for a customer-facing system, the plan is too weak.

If the rollback is "git revert and redeploy", confirm:
- The previous deploy still works against the current DB schema
- No data has been written that the old code does not understand
- If those break: you need a forward-fix, not a rollback. Plan that too.

### 4. Stakeholder communication

| Audience | When | What |
|---|---|---|
| Customer (if user-impacting) | T-24h heads-up + T-0 banner | Window + expected impact + status URL |
| Internal ops / support | T-24h + T-0 + T+resolved | What to watch for, escalation path |
| On-call engineer | T-1h | They are awake during the window |
| Owner of dependent system | T-24h | If you break their downstream consumer |

For an internal-only change with zero user impact, stakeholders = your own team. Still announce it. Surprise is the enemy.

### 5. In-flight transaction check

Before mutating live data, you need to know what is in progress.

**Postgres:**
```sql
SELECT pid, usename, application_name, state, wait_event, query_start, left(query, 80)
FROM pg_stat_activity
WHERE datname = current_database() AND state != 'idle'
ORDER BY query_start;
```

If long-running transactions are open against the table you are about to change, your `ALTER` will queue behind them and may take an `ACCESS EXCLUSIVE` lock that blocks every other query. Wait, kill, or postpone.

**Live stores (Shopify/Woo/etc.):**
- Are checkouts in progress? Most stores do not expose this; use a quiet window from analytics (lowest traffic hour by timezone of customer base).
- Bulk price/inventory edits during checkout can corrupt the cart total. Pause writes if the platform supports it.

**Deploys:**
- Are background jobs draining? Long-running workers may hold DB connections or expect old code.
- Is there a queue (BullMQ, SQS, Kafka)? Confirm consumer pause / lag before / after.

### 6. Change window declared

Pick the time. State the duration. Set a hard deadline.

| Context | Window |
|---|---|
| User-facing prod | Off-peak by audience timezone. For Argentina B2C, 03:00-05:00 ART. For B2B, weekend morning |
| Internal tool | Working hours so the team can react |
| Critical infra | Pre-announced maintenance window |

If the change exceeds the window, **abort and rollback**, do not push through. The window exists so the team is awake.

### 7. Approval gate

For destructive changes (DROP, mass DELETE, schema rename, payment provider change), require explicit human "go" from a second person. Pair-execute. One drives, one watches the metrics.

## Decision Tree by Change Type

### DB Schema (ALTER / DROP / RENAME)

1. Read `database-architect` references on zero-downtime migrations (3-step rename, NOT VALID + VALIDATE, CONCURRENTLY)
2. Snapshot: `pg_dump` + verify managed PITR is enabled and recent
3. Test the migration against a snapshot of prod data (volume matters; small dev DB hides problems)
4. In-flight check: long transactions, replication lag, autovacuum on the table
5. Use `lock_timeout` and `statement_timeout` so a lock storm does not freeze the app:
   ```sql
   SET lock_timeout = '3s';
   SET statement_timeout = '60s';
   ```
6. For renames: use the 3-step pattern (add new column → dual-write → backfill → swap reads → drop old). Single-step rename is a deploy-coupling trap.

### DB Data (UPDATE / DELETE / TRUNCATE)

1. Run as `SELECT` first with the same `WHERE`. Count rows. Eyeball a sample.
2. Wrap in a transaction with explicit limit:
   ```sql
   BEGIN;
   UPDATE orders SET status = 'archived' WHERE created_at < '2025-01-01' LIMIT 10000;
   -- inspect, then either COMMIT or ROLLBACK
   ```
3. For batches, use a loop with `RETURNING` to log what changed.
4. Never `DELETE` without a backup row dump first:
   ```sql
   COPY (SELECT * FROM orders WHERE created_at < '2025-01-01')
   TO '/tmp/orders_archive_2025-04.csv' CSV HEADER;
   ```
5. `TRUNCATE` is irreversible without a snapshot. Treat it as a destructive change.

### Store / CMS (Shopify, Woo, Magento, etc.)

1. Export EVERYTHING that the change touches BEFORE editing: catalog CSV, theme zip, pages, blogs, customer notification templates, payment settings.
2. Use the platform's bulk-edit history if available (Shopify has Bulk Editor history; Woo has revisions only on posts/products, not on prices).
3. For pricing: change in a draft channel or staging store first. Push to live only after validating one SKU end-to-end (PDP → cart → checkout → order confirmation email).
4. Inventory mass updates: timestamp the export so you can diff post-change. Preserve original quantities in a column named `qty_pre_change_YYYYMMDD`.
5. Theme changes: use Shopify's theme preview / version history. Never edit the live theme file directly; duplicate, edit on the duplicate, then publish.

### Deploy (feature flag, release, env)

1. Last green deploy SHA recorded. Rollback = `vercel rollback <sha>` / `netlify api rollbackSiteDeploy`.
2. DB migrations and code deploy decoupled: migrate first (backwards-compatible), deploy code second, drop old columns in a future deploy.
3. Feature flags: ramp 1% → 10% → 50% → 100%. Watch error rate at each step.
4. Env var rotation: deploy reads new var name, rotate value, then remove old. Never mutate a key the running fleet still reads.

### Config Critical (nginx, DNS, TLS, IAM, security group)

1. Diff the config before and after. Save both. `nginx -T > before.conf` then edit, then `nginx -T > after.conf`, `diff before.conf after.conf`.
2. For nginx: `nginx -t` MUST pass before `reload`. `reload` not `restart` (preserves connections).
3. For DNS: lower TTL ≥ TTL hours before change. Stage with a low-TTL test record. After change, monitor propagation.
4. For TLS cert renewal: use a tool that handles ACME (Caddy, certbot, AWS ACM). Automate; manual cert swap is a known footgun.
5. IAM / security group: never broaden in prod without justification + audit log. Apply principle of least privilege, log every change.

### Infra (autoscaling, instance resize, RDS param group)

1. Read `infra-security` skill if it exists in the project.
2. RDS parameter group changes: some require reboot, some do not. Read the AWS doc per parameter. `apply_method` matters.
3. Autoscaling: change min/max in low-traffic window. Watch for cooldown traps (scale-up triggers immediately but scale-down has a delay).
4. Instance resize: pre-announce. For DBs, use blue-green or read replica promotion to avoid downtime.

## Postmortem Trigger

If something breaks despite the checklist, fill `references/postmortem-template.md` within 48 hours. Blameless. Root cause not "human error" — root cause is what allowed the human error to reach prod.

## Output Standards

When this skill is invoked, return to the user:

1. **Pre-flight checklist** with each item answered (or marked blocker if unknown). Use the markdown checklist in `references/checklist.md`.
2. **Rollback plan** as a copy-paste runbook block: trigger, procedure, RTO.
3. **Estimated downtime / impact window** in minutes, with confidence (low / med / high).
4. **Go / No-Go** verdict. If No-Go, list exact blockers.
5. **Comms templates** for stakeholders if user-impacting.

Do NOT execute the change. This skill is a gate, not an executor. The user runs the change after the checklist passes.

## Anti-Patterns (forbidden)

- "It is a small change, no backup needed." Small changes corrupt prod constantly.
- "We have backups." Until you have restored one in the last 30 days, you do not.
- "Rollback is git revert." Without checking forward-incompatible writes, this re-breaks prod.
- "We will fix forward." Sometimes valid, but never the default. The default is a tested rollback.
- "Off-peak does not matter for B2B." It does. Pick a window your users are not working.
- "I will be careful." Carefulness is not a control. Snapshot, plan, gate, execute.
- Editing live theme/catalog directly without export. The export is the rollback.
- Running `UPDATE`/`DELETE` without a `SELECT` count first. The count is the sanity check.
- Running migrations on prod from a laptop without `lock_timeout`. One stuck migration locks the table.

## Reference Files

- `references/checklist.md` — Full pre-flight checklist with checkboxes, copy into runbook
- `references/rollback-playbook.md` — Per-system rollback commands (Postgres, MySQL, Mongo, Shopify, WooCommerce, Vercel, Netlify, S3, DNS, app config)
- `references/postmortem-template.md` — Blameless postmortem template with GOOD vs BAD examples

## Pairs With

- `database-architect` — Zero-downtime migration patterns (3-step rename, NOT VALID + VALIDATE, CONCURRENTLY indexes)
- `github-safety` — Non-destructive git operations (no force push, no rebase on pushed branches)
- `infra-security` — Security audits, IAM policy review, WAF rules
- `error-handling` — When a change does cause an error, the error taxonomy and observability tells you fast
