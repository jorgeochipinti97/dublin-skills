# Dashboard Design — Layout, Hierarchy, Interactivity

Principles for designing dashboards that get used. Sources: Stephen Few (*Information Dashboard Design*), Tufte (*Visual Display of Quantitative Information*), Cole Nussbaumer Knaflic, modern refs (Stripe Sigma, Vercel Analytics, Linear Insights, Grafana, Metabase, PostHog, Plausible).

---

## 1. The Core Principle

**A dashboard serves a specific decision.** Not "here's all the data." The designer's job is to help the user make that decision faster.

If you can't answer *"What action does this dashboard prompt?"*, it's not a dashboard — it's a report.

Good dashboard questions:
- *"Should I pause Campaign X?"*
- *"Is the system healthy right now?"*
- *"Which products need reordering?"*
- *"Where is retention dropping?"*

Bad dashboard questions:
- *"Show me all metrics"*
- *"Let's see the data"*

Force the user to name the decision. The answer shapes everything.

---

## 2. The 5-Second Test

Within 5 seconds of opening the dashboard, the user must answer:

1. **Is everything okay?** (status at a glance)
2. **What's the most important number?**
3. **Is it up or down vs. expected?**
4. **Where do I look next if something's wrong?**

If any of these take more than 5 seconds, the hierarchy is broken.

---

## 3. Layout Principles

### 3.1 The 12-column grid

Most modern dashboards use a 12-column grid. Mobile collapses to 1 column.

### 3.2 The standard layout

```
┌─────────────────────────────────────────────────┐
│  [Header / title]               [date range ▾]  │  top bar
├─────────────────────────────────────────────────┤
│  [KPI 1]  [KPI 2]  [KPI 3]  [KPI 4]             │  row 1: KPI cards (always)
├─────────────────────────────────────────────────┤
│                                                 │
│   [PRIMARY CHART — 8 cols]    [aside — 4 cols]  │  row 2: hero chart
│                                                 │
├─────────────────────────────────────────────────┤
│  [chart]    [chart]    [chart]                  │  row 3: supporting charts
├─────────────────────────────────────────────────┤
│  [detail table — 12 cols]                       │  row 4: drilldown
└─────────────────────────────────────────────────┘
```

### 3.3 Rules

- **KPIs always on top.** Non-negotiable. The user checks numbers first.
- **One dominant element per row.** The primary chart is 2-3× the visual weight of its neighbors.
- **Align everything to the grid.** Misalignment reads as chaos.
- **Consistent time windows across all charts.** If KPIs show 7 days, all charts show 7 days. Otherwise mark exceptions clearly.
- **Whitespace is structure.** Cramped dashboards feel overwhelming.
- **Fit on one screen if possible.** Scrolling breaks the "at a glance" promise. If you must scroll, the above-the-fold section must be self-sufficient.

---

## 4. Visual Hierarchy

Three levels:

1. **Dominant** — the thing the user needs to see first (KPI cards, hero chart)
2. **Secondary** — supporting context (breakdowns, trend details)
3. **Tertiary** — drilldown on demand (tables, filters, footnotes)

### How to establish hierarchy

- **Size**: biggest = most important
- **Position**: top-left = most important
- **Contrast**: higher contrast = more important
- **Color**: brand/primary color for the key metric, neutral gray for baselines
- **Whitespace**: more space around = more important

### Common mistakes

- All charts the same size = no hierarchy
- Sidebar full of filters stealing attention from the data
- KPI cards too small
- Brand colors everywhere = nothing stands out
- Logos, headers, or nav taking 30% of the viewport

---

## 5. KPI Cards (the workhorse)

Covered in `chart-selection.md §3` — here's the dashboard-level rule:

- **3-5 cards per row.** More than 5 becomes a blur.
- **Same visual weight** across cards in the same row.
- **Always show delta with context** ("+12% vs last 7d"), never bare deltas.
- **Sparklines** add massive value for ~0 visual cost.
- **Align numbers by decimal point** if cards are side-by-side.

---

## 6. Filtering and Interactivity

A dashboard without filters is a poster. Users need to slice.

### 6.1 Filter bar placement

- **Top of the dashboard** (most common, easiest to find)
- **Left sidebar** for dashboards with many filter dimensions
- **Per-chart filters** only if the filter doesn't apply to other charts

### 6.2 Essential filters

- **Time range selector** — almost always needed (today / 7d / 30d / custom / compare periods)
- **Segment / dimension selector** — by product, region, user type, etc.
- **Search / text filter** — for tables with many rows

### 6.3 Interaction patterns

- **Hover tooltips** — show exact values on every chart
- **Click to drill down** — click a bar → table of detail rows
- **Cross-filtering** — selecting in chart A filters charts B, C, D (powerful, use sparingly — can be confusing)
- **Export** — CSV or PNG for the current view

### 6.4 URL state

Filter state should be in the URL (`?range=30d&segment=pro`). This lets users:
- Share specific views via link
- Bookmark
- Refresh without losing state
- Browser back/forward works

Always. This is not optional for production dashboards.

---

## 7. Loading, Empty, and Error States

Every dashboard is in one of four states at any moment. Design for all four.

### 7.1 Loading

- **Skeleton screens** per card, not full-page spinners
- **Streaming** — KPIs load first, charts after
- **Preserve layout** — the page shouldn't shift when data arrives

### 7.2 Empty

Shown when: no data exists yet (new account, before first event).

- Explain WHY it's empty
- Show what the dashboard will look like (screenshot or illustration)
- Give the user the next action (*"Connect your first source"*, *"Send your first event"*)

### 7.3 Error

- Per-chart error boundaries (one broken chart shouldn't kill the whole dashboard)
- Clear error message
- Retry action
- Link to logs / support for debugging

### 7.4 Partial

Shown when: some data loaded, some is still loading or errored.
- Show what's available
- Don't block the UI on the slow chart

---

## 8. Color & Theming

See `chart-selection.md §5` for palette types. Dashboard-level rules:

- **One brand color** for the primary metric/series. Don't spray brand color across every chart.
- **Neutral grays** for baselines, comparisons, axes, gridlines
- **Semantic colors** (success/warn/error) for states
- **Max 5 colors** in any single chart
- **Dark mode**: invert backgrounds, desaturate fills (-15%), brighten lines (+10%), reduce gridline contrast
- **Consistent palette across charts** — if Q1 is blue in chart A, Q1 is blue in chart B

### Colorblind-safe palettes

- **Viridis** — sequential, perceptually uniform, gold standard
- **Cividis** — colorblind-safe alternative to viridis
- **Tableau10** — qualitative, colorblind-safe
- **ColorBrewer** — complete set for all types (sequential/diverging/qualitative)

Never hand-pick rainbow palettes. Use a tested one.

---

## 9. Typography in Dashboards

- **Sans-serif** for data (Inter, IBM Plex Sans, SF Pro, Geist) — serifs add noise
- **Tabular numerals** for aligned numbers (`font-variant-numeric: tabular-nums`)
- **Number scale**: primary KPIs = 32-48px, secondary = 18-24px, labels = 12-14px
- **Titles**: one size for all chart titles, aligned
- **Avoid all-caps** except for tiny labels
- **Truncate with ellipsis** for overflow, with full text in tooltip

---

## 10. Performance (users won't wait)

Slow dashboards get abandoned. Budget: **first paint < 1s, full data < 3s**.

### What to flag in the blueprint

- **Server-side aggregation** — never ship raw rows to the client when you can pre-aggregate
- **Virtualize tables** with > 100 rows
- **Lazy-load charts below the fold**
- **Debounce filter changes** (300ms) before refetching
- **Cache aggressively** — stale-while-revalidate for most dashboards
- **Progressive rendering** — KPIs first, charts second, tables last
- **Avoid client-side joining** of multiple API responses

See `data-from-api.md` for full fetching strategy.

---

## 11. Mobile & Responsive

Dashboards rarely work well on mobile — but if the audience uses phones, design for it.

- **Stack to 1 column** below 768px
- **Hide secondary charts** on mobile (or collapse behind a tab)
- **Keep KPI cards** visible
- **Use full-width cards**, not grid
- **Touch targets ≥ 44x44px**
- **Sticky filter bar** so users don't scroll to change range

Alternatively: ship a mobile-optimized summary view instead of cramming the desktop version.

---

## 12. Accessibility

- **Semantic HTML** for the layout (not div soup)
- **Chart alt text or ARIA labels** — describe what the chart shows
- **Data tables available** as an alternative to visual charts (hidden but accessible)
- **Keyboard navigation** — every filter and interactive element reachable via Tab
- **Focus rings visible**
- **Color contrast** WCAG AA for text and axis labels (4.5:1)
- **Respect `prefers-reduced-motion`** for chart animations
- **Don't rely on color alone** — add icons or patterns

---

## 13. Modern Dashboard References (for mood)

Point the implementer at these when you want a specific look:

- **Stripe Sigma / Stripe Dashboard** — clean, dense, enterprise-polish
- **Vercel Analytics** — minimal, black & white with subtle accents, fast
- **Linear Insights** — beautiful typography, restrained color, editorial feel
- **Grafana** — classic monitoring density, dark mode native
- **PostHog** — product analytics, friendly and approachable
- **Plausible** — privacy-focused, minimal, one-page dashboard
- **Metabase** — generalist BI, friendly and explorable
- **Amplitude** — product analytics, drill-down heavy
- **Mixpanel** — event-based, funnel-centric
- **Google Analytics 4** — (anti-reference) — good example of what happens when navigation dominates the data

---

## 14. Dashboard Anti-Patterns

- **KPIs below the fold** — users don't scroll before the first read
- **Too many metrics** — if everything is important, nothing is
- **Inconsistent time windows** across charts
- **No time range selector**
- **Cluttered filter bar** stealing attention from data
- **Brand colors everywhere** (no hierarchy)
- **Heavy page weight** — slow dashboards get abandoned
- **Navigation menus bigger than the data area**
- **Lookalike charts** all the same size (no hierarchy)
- **Full-page spinners** instead of skeletons
- **No empty state** (new users see a broken-looking dashboard)
- **Exporting requires 5 clicks**
- **No URL state** (can't share a filtered view)
- **Custom control widgets** where a standard dropdown would do

---

## 15. Quick Design Checklist

Before handing off the blueprint:

- [ ] Named decision the dashboard helps make
- [ ] 5-second test passes (status / main number / direction / next look)
- [ ] KPIs above the fold
- [ ] One dominant chart per row
- [ ] Consistent time window
- [ ] Colorblind-safe palette
- [ ] Max 5 colors per chart
- [ ] Empty / loading / error states designed
- [ ] Filter state in URL
- [ ] Mobile behavior defined
- [ ] Accessibility addressed
- [ ] Modern reference / mood picked
- [ ] Performance considerations flagged
