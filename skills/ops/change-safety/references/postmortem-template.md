# Postmortem Template

Blameless. The goal is to fix the system, not the person. If a single human error caused the incident, the question is "what allowed that error to reach prod" — that is the root cause.

Fill within 48 hours of resolution while details are fresh.

---

## Incident: `<short title>`

- **Date / time start (UTC + local)**:
- **Date / time detected**:
- **Date / time mitigated**:
- **Date / time resolved**:
- **Duration of impact**:
- **Severity**: SEV1 (full outage) / SEV2 (major degradation) / SEV3 (partial / minor)
- **Owner**:
- **Responders**:

## Summary (3-5 sentences)

What happened in plain language. A non-engineer should understand it.

## Impact

- **Users affected**: count + segment
- **Business impact**: orders lost, revenue, support load, SLA breach
- **Data impact**: any data lost, corrupted, leaked
- **External impact**: status page entry, customer-facing apology, media

## Timeline

Use absolute timestamps (UTC + local). One bullet per event.

```
14:00 ART  Change started: drop column `legacy_status` on `orders`
14:01 ART  Migration acquired ACCESS EXCLUSIVE lock
14:02 ART  Long-running report query (started 13:55) blocked migration
14:04 ART  Migration timed out, app workers stacked DB connections
14:05 ART  p95 latency spiked from 120ms to 8s
14:06 ART  PagerDuty alert fired
14:08 ART  On-call started rollback: kill blocking query
14:11 ART  Migration completed
14:12 ART  Latency recovered
14:30 ART  Incident closed
```

## Root cause

What in the SYSTEM allowed this. Not "human did X" — "the system permitted human to do X without a check".

GOOD: "The migration runbook did not require checking `pg_stat_activity` for long-running transactions before acquiring `ACCESS EXCLUSIVE`. The 13:55 reporting job is a known weekly process; nothing prevents it from blocking deploys."

BAD: "Engineer forgot to check pg_stat_activity." (true, but the actionable fix is upstream)

## Trigger

The single event that started the incident. Different from the root cause — the trigger is the proximate match, the root cause is the gas.

## Detection

- How was it detected (alert / user report / dashboard / accident)?
- How long from start to detection?
- Was the alert noisy / missing / on the wrong dashboard?

## Mitigation

What stopped the bleeding. Not the same as the fix.

## Resolution

What restored normal operation. The fix.

## What went well

At least three things. Resilience matters as much as failure.

## What went poorly

Be specific. "Communication was bad" is useless. "We had no Slack channel for this incident, so updates were scattered across DMs" is useful.

## Where we got lucky

The accidents that did NOT happen but easily could have. These are tomorrow's incidents.

## Action items

| ID | Action | Owner | Due | Priority | Type |
|---|---|---|---|---|---|
| 1 | Add `pg_stat_activity` check to migration runbook with kill-or-postpone decision tree | @ana | 2026-05-16 | P1 | Process |
| 2 | Add `lock_timeout = '3s'` to all migration scripts | @luis | 2026-05-12 | P1 | Code |
| 3 | Schedule weekly reporting job to a maintenance window | @ana | 2026-05-20 | P2 | Process |
| 4 | Add p95 latency alert routed to on-call channel (currently goes to email only) | @ops | 2026-05-15 | P1 | Tooling |

Each action item must have an owner, a due date, and a tracking issue. "Action items" without those are wishes.

Type one of:
- **Code**: a code change
- **Process**: a runbook / checklist / policy change
- **Tooling**: monitoring, alerting, infrastructure
- **Training**: people need to know X
- **Architecture**: a design change

## Lessons learned

3-5 bullets that generalize beyond this specific incident. These feed the team wiki, onboarding doc, or `feedback` memory.

---

## Examples — GOOD vs BAD

### GOOD postmortem section

> **Root cause**: Production migrations run from engineer laptops with no `lock_timeout`. The reporting query holds an `ACCESS SHARE` lock on `orders` for ~10 minutes weekly. Our migration acquired `ACCESS EXCLUSIVE`, blocked behind the report, and queued every other query. There is no automated check that flags long-running transactions before a destructive migration.
>
> **Action**:
> 1. Migrations must run via CI with `lock_timeout = '3s'` and `statement_timeout = '60s'` set per session.
> 2. CI step: query `pg_stat_activity` for transactions older than 30s; abort migration if any exist.
> 3. Move weekly reporting to a Sunday 04:00 ART maintenance window.

### BAD postmortem section

> **Root cause**: Engineer ran migration at the wrong time and didn't check what else was running. We need to be more careful.
>
> **Action**: Be more careful. Add training.

The BAD version blames a person and prescribes vibes. The GOOD version names the system gap and prescribes mechanism.

---

## Anti-patterns to avoid

- **Blame**: "Engineer X caused this." Replace with: "The system allowed X to happen because Y."
- **Vague action items**: "Improve monitoring." Replace with: "Add alert on metric M with threshold T routed to channel C, owned by P, due D."
- **Action items without owners**: An action item without a name is a wish.
- **Action items without due dates**: An action item without a date is a wish that has been forgotten.
- **One-off fixes**: "We fixed the data." If the gap allows it again next week, you have not fixed anything.
- **Skipping "where we got lucky"**: This section reveals the next incident.
- **Postmortem one month late**: Memory has decayed. Schedule within 48h.
