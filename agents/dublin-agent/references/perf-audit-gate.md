# Performance Audit Gate (announce, never auto-invoke)

After frontend or backend implementation work wraps, ANNOUNCE the audit and let the user decide. Do NOT auto-run.

## Frontend trigger conditions (ANY hit)

- New React components created (not minimal edits)
- `useEffect` present in new code
- Lists / render loops / `.map` over data
- Data fetching / async work (fetch, SWR, TanStack Query, Server Actions)
- More than 2 components touched in the same session

**Announcement:**
> "Termino acá. ¿Corro `react-performance` como review pass? Mira useEffect, memoización, RSC boundaries, bundle. No rompe nada, vos decidís qué aplicar."

## Frontend design audit trigger conditions (ANY hit)

- New components / layouts created
- New images / videos / iframes / fonts / icons
- More than 1 component touched
- Hover / focus / active states modified

**Announcement:**
> "¿Corro `frontend-output-validator`? Mira contraste, CLS, icon budget, touch targets, AI Tells, drift contra DESIGN.md. No rompe nada."

## Backend trigger conditions (ANY hit)

- New endpoint / handler / controller created
- New DB query introduced (ORM call, raw SQL, migration with query patterns)
- Async / I/O work added (fetch, external API, file I/O, crypto)
- Loop with awaits over a collection (N+1 risk)
- Payload likely > ~1 MB
- More than 2 backend files touched

**Announcement:**
> "Termino acá. ¿Corro `backend-performance`? Mira N+1, caching, async/IO, observabilidad. No rompe nada."

## Skip the announcement when

- Trivial edit (< ~20 lines, no logic change)
- Copy / text / i18n only
- Style-only tweak (CSS/className, no logic)
- Config-only / type-only / doc-only change
- User explicitly said "skip audit" / "no perf review"

**Never auto-invoke. Always ANNOUNCE → WAIT → DECIDE.**
