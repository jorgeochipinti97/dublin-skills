---
name: change-safety
description: Snapshot + tested rollback + comms + in-flight check + change window before any production write
metadata:
  type: feedback
---

Before any write to production (DB, store/CMS, deploy, config, infra, DNS,
secrets), run the change-safety protocol: tested snapshot, written rollback
plan, stakeholder + on-call comms, in-flight transaction check, declared
off-peak change window, and second-human approval for medium+ changes.

**Why:** A real incident — a store change with no pre-snapshot left a client
unable to sell. The protocol exists so that never repeats. The backup is only
real if it has been restored to a scratch target.

**How to apply:** On any `ALTER`/`DROP`/`TRUNCATE`/`RENAME`, `UPDATE`/`DELETE`
without `WHERE`, mass batch, prod deploy, catalog/price/stock edit, or
secret/DNS/TLS/IAM change — stop and run the gate before executing. It returns
Go / No-Go; it is not a code generator. Pairs with [[finish-now]] (don't skip it
to "finish faster").
