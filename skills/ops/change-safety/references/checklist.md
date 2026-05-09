# Pre-Flight Checklist

Copy this into the runbook for the change. Each box checked or the change does not proceed.

## Change Definition

- [ ] **One-sentence description**: `<verb> <object> in <system> at <time-window>`
  - Example: "Drop column `legacy_status` from `orders` in prod Postgres at Tue 03:00 ART"
- [ ] **Why now**: business reason in one line
- [ ] **Risk classification**: low / medium / high / critical
  - low: additive, reversible, no user impact
  - medium: reversible with effort, low user impact
  - high: customer-visible, partial irreversibility (data loss possible)
  - critical: payments, auth, irreversible writes
- [ ] **Owner**: name + Slack/email
- [ ] **Approver**: second human for medium+ changes

## Snapshot / Backup

- [ ] Snapshot taken and timestamp recorded
- [ ] Snapshot tested by restoring to a scratch environment
- [ ] At least one row from the affected scope verified post-restore
- [ ] Snapshot retention confirmed (will it survive the change window + rollback decision)
- [ ] Snapshot location documented (URL, path, vault entry)

## Rollback Plan

- [ ] Rollback trigger defined (observable signal: error rate %, p95 ms, ticket count)
- [ ] Rollback procedure written, copy-paste ready, tested in staging
- [ ] RTO (time-to-restore) estimated and acceptable for the system criticality
- [ ] Forward-fix plan (if rollback would re-break things due to forward writes)
- [ ] Rollback approver named (may differ from change approver)

## Communication

- [ ] Customers notified at T-24h if user-impacting (banner, email, status page)
- [ ] Internal team notified at T-24h
- [ ] Support / ops team briefed on what to watch and how to escalate
- [ ] On-call engineer awake and on the channel at T-0
- [ ] Owner of dependent systems pinged
- [ ] Status page updated at T-0
- [ ] Status page updated post-resolution (success or rollback)

## In-Flight Risk

- [ ] Long-running transactions checked (DB)
- [ ] Background jobs / queue depth checked
- [ ] Replication lag checked (DB read replicas)
- [ ] Cache hit rate baseline recorded (so post-change degradation is visible)
- [ ] Active user sessions estimated (can users see partial state mid-change)
- [ ] Webhooks / outbound integrations confirmed not mid-flight

## Change Window

- [ ] Off-peak time chosen for affected user timezone
- [ ] Hard deadline set (abort and rollback if exceeded)
- [ ] Pre-window verification: dependent systems healthy, no other changes in flight
- [ ] DR / on-call coverage during window confirmed

## Execution Readiness

- [ ] Runbook reviewed by approver
- [ ] All commands copy-paste ready (no improvisation)
- [ ] `lock_timeout` / `statement_timeout` set for DB changes
- [ ] Two humans on the change (driver + observer) for medium+
- [ ] Metrics dashboard open (error rate, p95, queue depth, DB CPU, cache hit, key business metric)
- [ ] Logs streaming open
- [ ] Rollback command pre-typed in a separate terminal, ready

## Post-Execution

- [ ] Smoke test ran end-to-end (the critical path of the system)
- [ ] Metrics watched for at least 30 min
- [ ] Stakeholders updated on success or rollback
- [ ] Snapshot retained for 7 days minimum (or per company policy)
- [ ] Runbook updated with what actually happened (deviations from plan)
- [ ] If anything broke: postmortem scheduled within 48h

## Blockers (any "no" = abort)

- [ ] **NO** snapshot? → ABORT
- [ ] **NO** rollback plan? → ABORT
- [ ] **NO** approver for high/critical? → ABORT
- [ ] **NO** off-peak window for user-facing change? → POSTPONE
- [ ] **NO** dashboard / log visibility during execution? → ABORT
- [ ] Long-running transaction blocking the target? → WAIT or POSTPONE
- [ ] Dependent system in degraded state? → POSTPONE
