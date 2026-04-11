# Chart Selection — The Decision Tree

The core reference. For every business question, pick the chart type that answers it most accurately. Always explain WHY this chart and WHY NOT the obvious alternative.

Based on: Stephen Few, Edward Tufte, Cole Nussbaumer Knaflic, Alberto Cairo, FT Visual Vocabulary.

---

## 1. The Five Questions That Determine the Chart

Before picking anything, answer:

1. **What does the user want to see?** (comparison · trend · composition · distribution · relationship · flow · geography · ranking)
2. **How many categories / data points?**
3. **Is time involved?** (one point · multiple points over time)
4. **Is the magnitude continuous or discrete?**
5. **Is the audience going to compare precisely, or just see the shape?**

The answer to #1 is the primary selector. The others refine the choice.

---

## 2. Decision Tree by Goal

### 2.1 Comparison (values across categories)

**Question**: *"Which is biggest / smallest / how do these stack up?"*

| Situation | Pick | Why |
|---|---|---|
| ≤ 8 categories, short labels | Vertical bar | Easy visual comparison, labels fit |
| > 8 categories or long labels | Horizontal bar | Labels read naturally left-to-right |
| Need sorted ranking | Horizontal bar, sorted descending | Eye runs down the list naturally |
| Comparing 2 groups across categories | Grouped bar (side-by-side) | Direct comparison per category |
| Comparing multiple metrics on different scales | Small multiples (grid of bar charts) | Each chart has its own scale |
| Showing change between two points | Dumbbell / slope chart | Emphasizes the delta, not the values |

**Never use**: pie charts for comparison (humans can't compare angles accurately), 3D bars (distortion).

---

### 2.2 Trend over time

**Question**: *"How is this changing?"*

| Situation | Pick | Why |
|---|---|---|
| One metric over time | Line chart | The fundamental trend viz |
| 2-5 metrics over time | Multi-line chart | Compare trends directly |
| 6+ metrics over time | Small multiples (mini line charts) | Avoids spaghetti |
| Cumulative quantity (volume matters) | Area chart | Fills in the magnitude |
| Composition changing over time | Stacked area or 100% stacked area | Shows parts AND whole |
| Discrete time buckets (week/month/quarter) | Bar chart by period | Emphasizes the period, not continuity |
| Very small trend indicator | Sparkline (inside a KPI card) | Visual at-a-glance |
| Seasonal patterns | Line with year overlays, or heatmap calendar | Reveals repetition |

**Never**: use line charts for non-continuous categories (e.g., line from "Red → Blue → Green" is meaningless).

---

### 2.3 Composition (parts of a whole)

**Question**: *"What makes up this total?"*

| Situation | Pick | Why |
|---|---|---|
| ≤ 4 parts, clear majority | **Donut** (preferred) or pie | Okay when differences are obvious |
| ≤ 5 parts, any distribution | 100% stacked bar | More accurate than pie for close values |
| > 5 parts | Horizontal bar (sorted) | Pies fail above 5 slices |
| Parts changing over time | 100% stacked area | Composition + trend in one viz |
| Hierarchical parts | Treemap | Nested proportions in 2D space |
| Nested categories | Sunburst (rare — hard to read) | Only if the hierarchy matters more than values |

**Rule**: if you can't tell which slice is biggest at a glance, pie chart is wrong. Use a sorted bar.

---

### 2.4 Distribution (how values are spread)

**Question**: *"What's the range? Are there outliers?"*

| Situation | Pick | Why |
|---|---|---|
| One variable, many data points | Histogram | Shows frequency across buckets |
| Compare distributions across groups | Box plot | Median, quartiles, outliers visible |
| Large dataset, show density | Violin plot (advanced) | Distribution shape |
| Continuous 2D distribution | Density heatmap | Where points cluster |

**For non-data users**: box plots look intimidating. Use simpler histograms and explain what "normal range" means.

---

### 2.5 Relationship (correlation between variables)

**Question**: *"Does A move with B?"*

| Situation | Pick | Why |
|---|---|---|
| 2 variables | Scatter plot | The fundamental correlation viz |
| 3 variables | Bubble chart (x, y, size) | Adds a dimension without 3D |
| Many variable pairs | Correlation heatmap | Matrix of relationships |
| Cause → effect sequences | Scatter with trend line | Makes the pattern explicit |

**Avoid**: bubble charts with more than ~30 bubbles; use scatter + color coding instead.

---

### 2.6 Single Value (KPI)

**Question**: *"What's the current number?"*

| Situation | Pick | Why |
|---|---|---|
| Primary metric | Big number card | Instant scan, dominant hierarchy |
| Number + trend | Big number + sparkline | Context without clutter |
| Number + goal | Big number + progress bar | Shows achievement vs target |
| Number + variation | Big number + Δ vs last period | Change at a glance |
| Number + multiple dims | Small KPI grid (4-8 cards) | Dashboard top row |

**Never**: use gauges — they waste space and are hard to read. A big number with a delta is always better.

---

### 2.7 Ranking

**Question**: *"Who's #1? Top 10?"*

| Situation | Pick | Why |
|---|---|---|
| Top N list | Sorted horizontal bar | Eye reads down the list |
| Top N with rank changes | Bump chart | Rank over time |
| Podium-style (top 3) | Large KPI cards or vertical bar | Emphasizes winners |

---

### 2.8 Geographic

**Question**: *"Where is this happening?"*

| Situation | Pick | Why |
|---|---|---|
| Regions colored by value | Choropleth map | Classic geographic comparison |
| Point locations | Point / bubble map | When each point matters individually |
| Flow between locations | Flow map (arcs) | Origin-destination patterns |
| Hex/grid aggregation | Hex-bin map | Reduces overplotting of points |

**Warning**: maps exaggerate geographic size. Wyoming looks huge next to Rhode Island even if it has fewer people. Use cartograms or supplement with bar charts.

---

### 2.9 Flow / Process

**Question**: *"How does X move to Y?"*

| Situation | Pick | Why |
|---|---|---|
| Budgets / money flow | Sankey diagram | Proportional flow widths |
| User journey / funnel | Funnel chart | Step-by-step drop-off |
| State transitions | Chord diagram (rare) | Many-to-many flow |

Funnel charts are common for conversion dashboards (visit → signup → trial → paid).

---

### 2.10 When NOT to Visualize

Sometimes the best viz is no viz.

- **One number, no context needed** → just show the number
- **Small table (≤ 10 rows, ≤ 5 cols)** → a table is faster to read than a chart
- **Exact values matter more than shape** → table with sorting
- **Status / state** → a badge, not a chart

---

## 3. KPI Cards — The Dashboard Workhorse

KPI cards sit at the top of most dashboards. The anatomy:

```
┌─────────────────────────────┐
│  Revenue                    │ ← label
│  $48,200                    │ ← big number
│  ↑ 12.4% vs last 7d         │ ← delta (color: green/red with icon)
│  ~~~^~~^~_/~~~_/^~~_/^~_    │ ← sparkline (last 30 days)
└─────────────────────────────┘
```

Rules:
- Number must be the dominant element (2-3× bigger than label)
- Delta always with **period context** ("vs last 7d"), not just "+12%"
- Sparkline shows trend without axes or labels — pure shape
- Max 5 KPI cards in a row (usually 3-4)
- Color the delta, not the number

Never do: no context delta (just "+12%"), gauges, giant icons, background images.

---

## 4. Tables Are Underrated

Modern dashboards use tables for:
- Top N lists with multiple columns (sortable, filterable)
- Activity feeds (event · time · user · action)
- Detail drilldown after clicking a chart
- Raw data export/download

Modern table features:
- Sortable columns
- Sticky header and first column
- Inline mini charts (sparklines, bars inside cells)
- Conditional formatting (color scales, icons)
- Row hover + click-to-detail
- Pagination or virtualization (never load 10k rows into DOM)

Libraries: TanStack Table for headless, AG Grid for enterprise-grade features.

---

## 5. Color Rules for Charts

### Three palette types (pick based on data)

- **Qualitative** (categories with no order) — Tableau10, Set2, category10. Max ~8 colors.
- **Sequential** (ordered values, low → high) — Viridis, Blues, Greens. Single hue.
- **Diverging** (centered around zero, positive/negative) — RdBu, PiYG. Two hues meeting at a neutral.

### Universal rules

- Colorblind-safe palettes (Viridis is the gold standard — perceptually uniform AND colorblind-safe)
- Never red + green alone for good/bad (add icon or shape)
- Max 5 colors in a single chart
- Use brand color for primary metric, neutral gray for comparison/baseline
- Dark mode: desaturate and brighten fills; lighten gridlines

### Semantic colors (state mapping)

- Success → green + ✓
- Warning → amber + ⚠
- Error → red + ✕
- Info → blue + ℹ

Always pair color with an icon or label. Never rely on color alone.

---

## 6. Anti-Patterns (never do this)

- **3D charts** — distortion kills accuracy
- **Pie with > 5 slices** — use sorted bar instead
- **Dual y-axes** — almost always misleading; use small multiples
- **Truncated y-axis** on bar charts — exaggerates differences
- **Starting y-axis above zero** when magnitude matters
- **Rainbow palette** for ordinal data (use sequential like Viridis)
- **Chart junk** — heavy gridlines, backgrounds, logos inside charts, shadows, bevels
- **Meaningless animation** — slow and distracting
- **Labels rotated 45° or 90°** — use horizontal bars instead
- **Legends far from data** — use direct labels when possible
- **Gauges** — waste space vs. a big number
- **Radar/spider charts** — usually unreadable
- **Stacked bar for comparing absolute values** — only use for composition
- **Area charts with > 3 overlapping series** — turns into mud

---

## 7. The Plain-Language WHY Templates

When teaching a non-data user, frame the reason like this:

- **Bar**: *"Bars are the most accurate way to compare values because your eye measures length really well."*
- **Line**: *"Lines show how something is changing — the slope tells you the direction and the speed."*
- **Pie/donut**: *"Pies only work when you have 3-5 parts and one is clearly bigger. Otherwise use a bar."*
- **Scatter**: *"Dots show whether two things move together. If the cloud tilts up-right, they're connected."*
- **Histogram**: *"Shows how a single number is spread out — are most values clustered in one place? Are there outliers?"*
- **Big number card**: *"One number the user checks first. The trend under it gives context without cluttering."*
- **Sparkline**: *"A tiny line next to a number to show the shape of the last 30 days — no axes needed."*
- **Heatmap**: *"A grid colored by value — spots hot and cold zones at a glance."*

---

## 8. Quick Decision Flow

```
Question starts with...
├── "How much?" / "Which is bigger?"   → Bar
├── "How is it changing?"              → Line (or sparkline inside a card)
├── "What makes up the total?"         → Sorted bar (>5 parts) or donut (≤5 parts)
├── "What's normal?" / "Any outliers?" → Histogram or box plot
├── "Do these move together?"          → Scatter
├── "Where is this happening?"         → Map
├── "Top N?"                           → Horizontal bar, sorted
├── "How does X flow to Y?"            → Sankey or funnel
└── "What's the number right now?"     → Big number card + sparkline
```

When in doubt, bar is almost always a safe choice.
