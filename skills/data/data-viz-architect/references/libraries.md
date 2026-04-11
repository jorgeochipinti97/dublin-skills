# Chart Libraries — Decision Matrix

Which React chart library to recommend based on stack, complexity, and budget. Load this before making a library pick in the blueprint.

---

## 1. Quick Decision

| Situation | Pick |
|---|---|
| Ship a dashboard fast, standard charts, Tailwind stack | **Tremor** or **shadcn/ui charts** |
| Standard charts, non-Tailwind or full control of styling | **Recharts** |
| Beautiful defaults, wide chart variety, moderate bundle okay | **Nivo** |
| Exotic charts (sankey, sunburst, treemap, geo maps) | **Apache ECharts** |
| Fully bespoke / branded / interactive experience | **Visx** (Airbnb) |
| Scientific / 3D / complex / analyst audience | **Plotly** |
| Huge datasets (> 10k points), performance-critical | **uPlot** or **ECharts** (canvas) |
| Exploratory analysis, notebook-style | **Observable Plot** |
| Full control, no library overhead | **D3** (last resort — high code burden) |

---

## 2. The Libraries in Detail

### 2.1 Tremor

**What**: Tailwind-first React dashboard component library. Includes cards, charts, tables, filters.
**Best for**: shipping a modern dashboard fast on a Tailwind/shadcn stack.
**Pros**:
- Beautiful, opinionated defaults
- Dashboard components (KPI cards, metric deltas, progress bars) not just charts
- Integrates with shadcn/ui and Tailwind themes
- Easy to customize via Tailwind classes
- Dark mode built-in
**Cons**:
- Limited to standard chart types (no sankey, no geo)
- Tied to Tailwind (not great if you use styled-components or CSS-in-JS)
- Less flexibility for bespoke interactions
**Charts**: line, bar, area, donut, scatter, funnel, progress, spark
**Bundle**: medium
**SSR-safe**: yes

### 2.2 shadcn/ui charts

**What**: Charts built on top of Recharts, themed with shadcn/ui CSS variables, copy-paste from shadcn registry.
**Best for**: shadcn/ui projects that want consistent theming without adopting a new library.
**Pros**:
- Already themed to match your shadcn setup
- Copy-paste components (you own the code)
- Built on Recharts (stable foundation)
- Dark mode, CSS variable theming
- Great developer experience
**Cons**:
- Limited chart set (same as Recharts)
- You maintain the code yourself
- Requires shadcn/ui as baseline
**Charts**: line, bar, area, pie, radar, radial
**Bundle**: small-medium (tree-shakes well)
**SSR-safe**: yes

### 2.3 Recharts

**What**: The most popular React chart library. Composable components (`<LineChart><XAxis/><Line/></LineChart>`).
**Best for**: standard dashboards, SaaS products, clean data viz without exotic needs.
**Pros**:
- Most popular → lots of tutorials, Stack Overflow answers, AI context
- Composable API feels React-native
- Good TypeScript support
- Easy to customize with props
- SSR-safe
**Cons**:
- Limited to ~15 chart types
- No geo maps, no sankey, no treemap
- Can struggle with large datasets (> 2000 points)
- Animations can be janky on big data
**Charts**: line, bar, area, pie, scatter, radar, radial bar, funnel, sankey (basic), treemap
**Bundle**: medium (~90kb gzipped)
**SSR-safe**: yes

### 2.4 Nivo

**What**: Beautiful defaults, wide chart variety. Built on D3.
**Best for**: dashboards that need polish without hand-crafting, or exotic charts like sankey/chord.
**Pros**:
- Gorgeous out of the box
- Wide chart variety (sankey, chord, sunburst, circle pack, network, geo)
- Animated transitions look great
- Server-side rendering support
- Good TypeScript types
**Cons**:
- Heavier bundle size than Recharts
- More opinionated — customization can be tricky
- Steeper learning curve for non-standard customization
- Some charts are heavy (circle pack, chord)
**Charts**: line, bar, pie, scatter, heatmap, sankey, chord, sunburst, radial bar, calendar, geo, network, circle pack
**Bundle**: large (tree-shakable per chart)
**SSR-safe**: yes (with explicit opt-in)

### 2.5 Apache ECharts

**What**: Battle-tested, massive feature set. Used by financial and enterprise dashboards globally.
**Best for**: exotic charts (sankey, sunburst, graph, geo) or large datasets.
**Pros**:
- Enormous chart variety (including 3D, maps, graph, polar)
- Canvas rendering — handles huge datasets
- Built-in themes
- Battle-tested at scale
- WebGL support for 3D/large data
**Cons**:
- Not React-native — wrap with `echarts-for-react` or similar
- Imperative API inside a config object
- Large bundle if you import everything (tree-shake per chart!)
- Less idiomatic for React devs
**Charts**: everything imaginable
**Bundle**: large (tree-shakable)
**SSR-safe**: needs explicit setup

### 2.6 Visx (Airbnb)

**What**: Low-level React primitives on top of D3. Build your own charts with React components.
**Best for**: bespoke, branded, highly interactive experiences where no library fits.
**Pros**:
- Full control over every pixel
- React-native, composable
- D3's math power without D3's DOM API
- Perfect for custom interactions
- Small bundle (use only what you import)
**Cons**:
- High code burden — you build the chart yourself
- Steep learning curve
- Slow to ship
- Not for "standard dashboard" use cases
**Charts**: you build them
**Bundle**: small-medium (scoped imports)
**SSR-safe**: yes

### 2.7 Plotly

**What**: Scientific charting, heavy-duty, interactive.
**Best for**: scientific/engineering dashboards, 3D, heavy analyst audience.
**Pros**:
- Massive chart variety including 3D and statistical
- Interactive out of the box (zoom, pan, select)
- Jupyter/Python compatibility (same API)
**Cons**:
- Huge bundle (500kb+)
- Overkill for most web dashboards
- Styling is not easy to customize deeply
- Feels dated in modern UIs
**Charts**: 40+ types, 3D, statistical, scientific
**Bundle**: huge
**SSR-safe**: no (client-only typically)

### 2.8 uPlot

**What**: Ultra-fast line/area chart library. Canvas-based.
**Best for**: rendering 10k-1M points fast (monitoring dashboards, financial data, observability).
**Pros**:
- Blazing fast
- Tiny bundle (~40kb)
- Canvas rendering scales
**Cons**:
- Line/area only (limited chart types)
- Imperative API
- Non-React (wrappers exist)
- Minimal styling
**Charts**: line, area, bar, bar stack (limited set)
**Bundle**: tiny
**SSR-safe**: client-only

### 2.9 Observable Plot

**What**: Declarative charting from Observable team (the creators of D3).
**Best for**: exploratory analysis, notebook-style dashboards.
**Pros**:
- Grammar-of-graphics style (very expressive)
- Gorgeous defaults
- D3 under the hood
- Great for fast iteration
**Cons**:
- Client-side only
- Less React-idiomatic
- Smaller community than Recharts/Nivo
**Charts**: grammar-of-graphics marks (dot, line, bar, area, rect, cell, etc.)
**Bundle**: medium
**SSR-safe**: limited

### 2.10 D3

**What**: The foundational data visualization library. Everyone else is built on D3.
**Best for**: when no library fits, or when the chart is the product.
**Pros**:
- Maximum power and flexibility
- Huge ecosystem and learning resources
- Any chart type imaginable
**Cons**:
- Directly manipulates the DOM (clashes with React's virtual DOM)
- Very high code burden
- Long learning curve
- Rarely worth it for a standard dashboard in 2026
**Recommendation**: Use Visx instead if you need D3's math in a React app.

---

## 3. Bundle Size Comparison (rough)

| Library | Gzipped bundle (all) | Notes |
|---|---|---|
| uPlot | ~40kb | Lean |
| shadcn charts | ~90kb | Based on Recharts |
| Recharts | ~90kb | Popular baseline |
| Tremor | ~120kb | Dashboard components included |
| Visx | varies | Small if scoped |
| Nivo | 150-400kb per chart | Tree-shake aggressively |
| ECharts | 150kb-1MB | Tree-shake essential |
| Plotly | 500kb+ | Heavy |

**Tree-shake aggressively.** Importing `from 'nivo'` or `from 'echarts'` without tree-shaking will blow up your bundle.

---

## 4. SSR Compatibility

Next.js App Router / React Server Components matter. Check each library:

| Library | SSR / RSC safe |
|---|---|
| Recharts | Yes |
| Tremor | Yes |
| shadcn charts | Yes |
| Nivo | Yes (opt-in) |
| Visx | Yes |
| ECharts | Requires `'use client'` |
| Plotly | Client-only |
| uPlot | Client-only |
| Observable Plot | Client-only |

Client-only libraries must be wrapped in `'use client'` and optionally dynamic-imported with `ssr: false`. Flag this in the blueprint.

---

## 5. Library Pick Formula

When writing the blueprint recommendation:

1. **Start with Tremor or shadcn charts** if the stack is Tailwind + shadcn
2. **Fall back to Recharts** if standard charts but non-Tailwind stack
3. **Upgrade to Nivo** if you need polish or chart variety
4. **Upgrade to ECharts** if you need sankey/geo/large datasets
5. **Drop to Visx** if the chart is bespoke/branded
6. **Avoid D3 directly** — use Visx instead

---

## 6. What to Write in the Blueprint

```markdown
## Library Recommendation

**Pick**: [library]
**Why**: [1 line — why this fits the stack, chart types needed, bundle budget, theming]
**Fallback**: [alternative if the pick doesn't work out]
**Docs**: [URL]
**Bundle note**: [any tree-shaking or SSR callout]
```

Example:
> **Pick**: Tremor
> **Why**: Tailwind stack, standard charts (bar/line/donut), and we need KPI cards + dashboard primitives out of the box.
> **Fallback**: shadcn/ui charts if the user already has shadcn set up.
> **Docs**: https://tremor.so
> **Bundle note**: Tree-shakes well; ~120kb gzipped for what we need.
