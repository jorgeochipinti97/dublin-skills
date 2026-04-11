# Data From API — Fetching, Shape, Aggregation

How to think about the path from an API response to the chart on screen. For React/Next.js stacks primarily.

---

## 1. The Three Questions You Must Answer

For every chart in the blueprint:

1. **Where does the data come from?** (endpoint, query, or derived)
2. **Where is it aggregated?** (database / server / client)
3. **How fresh does it need to be?** (real-time / seconds / minutes / hours / on-demand)

The answers determine the fetching strategy.

---

## 2. Understanding Data Shape

### 2.1 Wide vs long format

Charting libraries usually want **long format** (one row per observation).

**Wide** (human-friendly):
```json
[
  { "month": "Jan", "revenue": 1000, "cost": 400 },
  { "month": "Feb", "revenue": 1200, "cost": 450 }
]
```

**Long** (chart-friendly):
```json
[
  { "month": "Jan", "metric": "revenue", "value": 1000 },
  { "month": "Jan", "metric": "cost",    "value": 400 },
  { "month": "Feb", "metric": "revenue", "value": 1200 },
  { "month": "Feb", "metric": "cost",    "value": 450 }
]
```

Most chart libs (Recharts, Nivo, Visx, ECharts) handle wide format for multi-series charts, but converting to long is always safe for grouping/faceting.

### 2.2 Dimensions vs measures

Every record has two kinds of fields:

- **Dimensions** (categorical): what you group/slice BY — `date`, `product`, `region`, `user_id`
- **Measures** (numerical): what you aggregate — `revenue`, `count`, `duration`, `clicks`

The user's "slicing needs" map to dimensions. The "metrics that matter" are the measures.

### 2.3 Timestamps

- Always **ISO 8601** strings: `2026-04-11T14:00:00Z`
- Always **UTC on the wire**, convert to user timezone in the UI
- Aggregation buckets: `day` (00:00 → 23:59 in user TZ), `week` (locale-dependent), `month` (calendar)
- Watch for DST transitions in daily/hourly aggregations

---

## 3. Aggregation Location

### 3.1 Rule of thumb

**Always aggregate as deep in the stack as possible.**

| Level | When | Performance |
|---|---|---|
| **Database** (pre-aggregated or query-time) | Any production dashboard | Fastest, cached |
| **Backend/API** | When DB can't (e.g., calling a 3rd-party API) | Medium |
| **Server components** (Next.js) | Static-ish dashboards | Medium — cacheable |
| **Client** | Exploratory, small datasets (< 1000 rows) | Slowest, flexible |

### 3.2 When client-side aggregation is okay

- Small datasets (< 1000 rows total)
- Exploratory tools where filters change frequently
- The raw data is already needed on the client for another reason

### 3.3 When it's NOT okay

- Any dataset over ~5000 rows (DOM bloat, slow filter changes)
- Sensitive data that shouldn't leave the server
- When every filter change means reprocessing the full dataset

---

## 4. Fetching Strategy (React / Next.js)

### 4.1 The options

| Strategy | Use case | Caching |
|---|---|---|
| **Server Components + `fetch`** | Static dashboards, SSR-first | Next.js `cache()`, `revalidate` |
| **`unstable_cache` / `revalidateTag`** | Dashboards with known refresh intervals | Tag-based invalidation |
| **ISR** (Incremental Static Regeneration) | Near-real-time, high traffic | Edge-cached, background refresh |
| **React Query / TanStack Query** | Client-side with optimistic updates | Per-query cache + SWR |
| **SWR** | Lightweight client fetching | Simple SWR |
| **WebSocket / Socket.IO** | Real-time push (< 1s updates) | Client subscription |
| **SSE (Server-Sent Events)** | One-way real-time (metrics streams) | HTTP-based, simpler than WS |
| **Polling** | Real-time without push infra | Interval-based |

### 4.2 The decision tree

```
Is the data updated < 1s apart?
├── Yes → WebSocket or SSE
└── No
    └── Is it updated < 1 min apart?
        ├── Yes → Polling every 5-30s (React Query with refetchInterval)
        └── No
            └── Is it mostly static?
                ├── Yes → Server Components + revalidate
                └── No → React Query / SWR with staleTime
```

### 4.3 What to recommend in the blueprint

For each chart, specify:
- **Endpoint(s) called**
- **Fetch location** (server component vs client)
- **Cache strategy** (revalidate seconds, stale time, tags)
- **Refetch trigger** (on mount, on filter change, on interval, manual)
- **Deduplication** (React.cache for server-side, query key for client-side)

---

## 5. Real-Time Patterns

### 5.1 The three flavors

- **Polling** — client asks "what's new?" every N seconds. Simple, works everywhere. Expensive at scale.
- **SSE** — server pushes updates over HTTP. One-way. Great for metric streams, logs.
- **WebSocket** — bi-directional. Needed for chat, collaborative editing. Overkill for most dashboards.

### 5.2 When real-time is NOT needed

Most dashboards don't need real-time. Users check them every few minutes at most. A 30-second poll or manual refresh is usually fine. Real-time adds infra cost and complexity — justify it.

### 5.3 Performance concerns

- **Backoff on inactive tabs** — pause polling when `document.hidden`
- **Pause on blur** — users in another tab aren't looking
- **Debounce bursts** — if many events arrive quickly, batch renders
- **Animate transitions** subtly — real-time charts shouldn't flash jarringly

---

## 6. Pagination and Large Datasets

### 6.1 Charts with many points

- **Aggregate first** — a line chart rarely needs more than ~200 points. Pre-aggregate on the server by hour/day/week.
- **Downsample** — if you must show raw data, use algorithms like LTTB (Largest-Triangle-Three-Buckets) to reduce points while preserving shape.
- **Canvas rendering** — SVG breaks down over ~1000 points. Use canvas libraries (Plotly, ECharts, uPlot) for > 1k points.

### 6.2 Tables with many rows

- **Server-side pagination** — `?page=1&size=50`
- **Virtualization** — only render visible rows in the DOM (TanStack Virtual, react-window)
- **Infinite scroll** — for activity feeds, not dashboards
- **Server-side search/filter/sort** — don't dump the whole table client-side

---

## 7. Caching Strategies

### 7.1 The patterns

- **No cache** — always fetch fresh. Use only for critical real-time.
- **Cache + TTL** — cache for N seconds. Simple and effective.
- **Stale-while-revalidate (SWR)** — return cached, fetch in background, update on arrival. The best UX default.
- **Tag-based invalidation** — invalidate specific caches on writes. Needed for dashboards where the user can edit data.

### 7.2 Cache keys

The cache key MUST include every parameter that affects the data:
- Endpoint
- Filters (time range, segments, search)
- User ID (if the data is user-scoped)
- Auth state

A wrong cache key causes stale or leaked data across users.

### 7.3 Next.js specifics

- **`fetch(url, { next: { revalidate: 60 } })`** — 60s ISR
- **`fetch(url, { next: { tags: ['metric:revenue'] } })`** — tag-based; invalidate with `revalidateTag('metric:revenue')`
- **`unstable_cache(fn, key, { revalidate, tags })`** — cache arbitrary async functions
- **React.cache(fn)** — dedupe fn calls within a single request

---

## 8. Error, Loading, Empty States

### 8.1 Loading

- Per-chart skeletons, not full-page spinners
- Match the shape and size of the final component
- Shimmer animation subtle, not distracting

### 8.2 Error

- Per-chart error boundaries — one failed chart doesn't crash the dashboard
- Show what failed and how to retry
- Log errors to your observability stack (Sentry, Datadog)

### 8.3 Empty

- New account / no events yet → onboarding CTA
- Filter returned zero rows → suggest widening the filter
- Never show a blank card

### 8.4 Stale

- Show a small "Last updated 2m ago" indicator
- If data is very stale, warn the user
- Pair with a manual refresh button

---

## 9. Schema Validation

User-provided APIs are rarely perfect. In the blueprint, flag:

- **Required fields** per chart (what must be in the response)
- **Type expectations** (number, string, ISO date)
- **Null handling** — what the chart does if a field is missing or null
- **Response shape validation** — use Zod or valibot in the implementation

Untrusted data breaks charts silently (NaN axes, empty bars). Validate at the boundary.

---

## 10. Common API Shapes → Chart Data

### 10.1 Time series endpoint

```json
{
  "data": [
    { "ts": "2026-04-01", "revenue": 1200, "orders": 45 },
    { "ts": "2026-04-02", "revenue": 1350, "orders": 52 }
  ]
}
```

→ Line/area chart. `x: ts`, `y: revenue` or `y: orders`. Multi-line if multiple measures.

### 10.2 Breakdown endpoint

```json
{
  "data": [
    { "product": "A", "revenue": 4800, "units": 120 },
    { "product": "B", "revenue": 3200, "units": 80 }
  ]
}
```

→ Bar chart, sorted by the primary measure. Horizontal if names are long.

### 10.3 Funnel endpoint

```json
{
  "steps": [
    { "name": "Visit",  "count": 10000 },
    { "name": "Signup", "count": 2100 },
    { "name": "Trial",  "count": 840 },
    { "name": "Paid",   "count": 230 }
  ]
}
```

→ Funnel chart or horizontal bars with percentage drop.

### 10.4 Distribution endpoint

```json
{
  "buckets": [
    { "range": "0-10",   "count": 120 },
    { "range": "10-20",  "count": 340 },
    { "range": "20-30",  "count": 890 }
  ]
}
```

→ Histogram (bar chart with contiguous bars).

### 10.5 Paginated list

```json
{
  "data": [...],
  "page": 1,
  "pageSize": 50,
  "totalCount": 1247,
  "hasMore": true
}
```

→ Table with pagination controls. Server-side sort/filter.

---

## 11. What to Write in the Blueprint

For the **Data Flow** section of the output, include:

- **Endpoints called** with purpose (which chart uses which)
- **Aggregation level** — where it happens and why
- **Refresh strategy** — SSR / polling / WebSocket / manual
- **Cache strategy** — revalidate seconds, tags, stale time
- **Pagination** — if tables are involved
- **Loading states** — skeleton shape per chart
- **Empty states** — copy and CTA
- **Error handling** — per-chart boundary, retry, log
- **Schema expectations** — required fields per chart

This tells `premium-frontend-design` exactly what to build.
