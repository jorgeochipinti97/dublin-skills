---
name: frontend-foundation
description: Day-0 frontend architecture for React/Next.js products. Use when STARTING a new frontend, setting up a design system, or fixing foundational issues (inconsistent spacing, missing dark mode, broken mobile, layout shift, icon soup, bespoke components everywhere). Establishes design tokens, dual theme (dark + light), spacing scale, mobile-first layout strategy, CLS Zero discipline, icon budget, and a reusable component system on headless primitives (Base UI, Radix, React Aria). Invoke BEFORE premium-frontend-design — aesthetic layers on top of this foundation. Pairs with frontend-output-validator (post-implementation review gate).
---

# Frontend Foundation

Non-negotiable day-0 setup for any React/Next.js product. Do this before writing any UI component.

## Invoke Order

```
frontend-foundation  →  premium-frontend-design  →  product-tour / react-performance
                                                  ↘  frontend-output-validator (review gate)
(tokens, theme,        (aesthetics, motion,        (review: contrast, CLS, mobile, icons,
 spacing, mobile,       glass, typography)          touch targets, viewport stability)
 CLS, icon budget,
 component system)
```

If this skill is skipped, you will end up retrofitting dark mode, rewriting margins, fixing mobile after launch, chasing CLS bugs, deleting random icons, and rebuilding the same Button/Dialog ten times. Non-negotiable.

## Six Pillars

1. **Dual theme from day one** — dark + light, always, via CSS variables + View Transitions for smooth toggling
2. **Spacing system** — one scale, no ad-hoc `mt-[13px]`
3. **Headless component system** — Base UI / Radix / React Aria + a thin branded layer
4. **Mobile-First with Content Priority** — design starts at 360px, content priority decided before breakpoints
5. **CLS Zero** — every image, video, embed, font, and skeleton has reserved space. Cumulative Layout Shift target < 0.05
6. **Icon Budget** — counted, not vibed. Icons earn their place or get cut

## Cross-cutting Mandates (apply to every component)

### Dependency Verification
Before importing ANY third-party library, `grep package.json` first. If missing, output the install command BEFORE the code:

```bash
pnpm add next-themes  # example when next-themes is absent
```

Never assume a library exists. Never invent imports. Applies to: `next-themes`, `@base-ui-components/react`, `@radix-ui/*`, `framer-motion`, `class-variance-authority`, `tailwind-merge`, `lucide-react`, `react-hook-form`, `zod`, everything else.

### Interactive States (mandatory)
Every interactive component must implement all four states:
- **Loading** — skeletal loader matching the final layout (no generic spinners)
- **Empty** — composed empty state showing how to populate data
- **Error** — inline, actionable, next-step-oriented (no raw exceptions)
- **Active feedback** — `:active` state with `-translate-y-[1px]` or `scale-[0.98]` for physical push

### Hardware Acceleration Rules
- Animate **only** `transform` and `opacity`. Never `top`, `left`, `width`, `height`.
- Never `h-screen` for full-height — use `min-h-[100dvh]` (iOS Safari)
- Never complex flex math (`w-[calc(33%-1rem)]`) — use CSS Grid
- `will-change: transform` only on actively-animating elements
- Never `window.addEventListener('scroll')` — use Framer's `useScroll` or IntersectionObserver

---

## Pillar 1 — Dual Theme (Dark + Light)

**Rule:** Adding theming later is massively more expensive than doing it now. Every component built without theme awareness has to be rewritten.

### Required setup

- Use **semantic CSS variables**, never hardcoded colors (`#0a0a0a` is forbidden in components)
- Provide `.dark` and `.light` (or `[data-theme]`) variants for every token
- Use **`next-themes`** (Next.js) or a `ThemeProvider` with `localStorage` + `prefers-color-scheme`
- Verify **WCAG AA contrast** in both modes (4.5:1 body, 3:1 large text)
- Glass morphism, gradients, shadows must have a variant for each theme — never assume dark

### Semantic token taxonomy (minimum)

```
--background           / --foreground
--muted                / --muted-foreground
--card                 / --card-foreground
--popover              / --popover-foreground
--border               / --input / --ring
--primary              / --primary-foreground
--secondary            / --secondary-foreground
--accent               / --accent-foreground
--destructive          / --destructive-foreground
--success / --warning  / --info
```

Components consume semantic names (`bg-background`, `text-foreground`). Colors live in `:root` and `.dark` only.

Full reference + code in `references/theming.md`.

---

## Pillar 2 — Spacing System

**Rule:** One scale, applied consistently. Layout parents own spacing, leaf components don't use margin.

### Required setup

- **Scale:** `0, 1, 2, 3, 4, 6, 8, 12, 16, 20, 24, 32` (in 4px increments → 0/4/8/12/16/24/32/48/64/80/96/128px)
- **Container:** max-widths per breakpoint (e.g. `sm: 640, md: 768, lg: 1024, xl: 1280, 2xl: 1440`)
- **Section padding:** `24px` mobile → `48px` tablet → `80–120px` desktop
- **Section spacing:** `96–200px` between major sections
- **Prefer `gap`** on flex/grid over margin between siblings
- **Never** `margin` on leaf components — the parent layout decides spacing
- **Never** arbitrary Tailwind values (`mt-[13px]`, `p-[22px]`) — if the scale doesn't fit, the scale is wrong

### Layout primitives to build first

- `<Stack>` — vertical flex + gap
- `<Row>` — horizontal flex + gap + align
- `<Grid>` — responsive grid with gap
- `<Section>` — vertical padding + container
- `<Container>` — max-width + horizontal padding

Leaf components (Button, Card, Input) know their internal padding but never their external margin.

Full reference + code in `references/spacing.md`.

---

## Pillar 3 — Component System on Headless Primitives

**Rule:** Do not hand-roll accessible components. Use a headless library, wrap it with brand styling.

### Why headless primitives

- **Token efficiency:** A `<Dialog>` from Base UI is 5–10 lines. A from-scratch accessible dialog is 80+. Every skill invocation benefits.
- **Accessibility is solved:** focus traps, keyboard nav, ARIA roles, screen reader labels — all handled
- **Behavior is battle-tested:** portaling, outside-click, escape key, scroll lock — all handled

### Preferred libraries (pick one per project)

| Library | Package | When |
|---------|---------|------|
| **Base UI** | `@base-ui-components/react` | Default choice (MUI team, modern, minimal API) |
| **Radix UI** | `@radix-ui/react-*` | Mature ecosystem, shadcn uses this |
| **React Aria Components** | `react-aria-components` | Adobe-grade a11y, complex widgets (date picker, virtualized lists) |

**Do not mix primitive libraries** in the same project.

### Project structure

```
components/
├── ui/                    # Branded primitives (Button, Input, Dialog, Select, etc.)
│   ├── button.tsx         # Wraps nothing or Base UI, applies tokens
│   ├── dialog.tsx         # Wraps Base UI Dialog with brand styling
│   └── ...
├── patterns/              # Composed business components (PricingCard, UserMenu)
│   ├── user-menu.tsx      # Uses ui/dropdown-menu.tsx + ui/avatar.tsx
│   └── ...
└── layout/                # Stack, Row, Grid, Section, Container
```

### Rules for the `ui/` layer

- Accepts an `asChild` / `render` prop pattern (from Base UI/Radix) so consumers can compose
- Uses **semantic tokens only** — no hardcoded colors or spacing
- Exports a **single component** per file (plus its subcomponents if compound: `Dialog`, `Dialog.Trigger`)
- Ships with sensible defaults but is overridable via `className`
- Variants via **CVA** (`class-variance-authority`) — never a dozen boolean props

### Minimum primitive set to build first

Button, Input, Textarea, Label, Select, Checkbox, Radio, Switch, Dialog, Popover, Tooltip, Dropdown Menu, Toast, Tabs, Accordion, Card, Avatar, Badge, Separator, Skeleton.

Full reference + code in `references/component-system.md`.

---

## Pillar 4 — Mobile-First with Content Priority

**Rule:** Design starts at 360px width. Decide content priority for mobile BEFORE writing any layout. "Mobile-first" without content priority is just adding media queries — it's still desktop thinking.

### Required setup

- **Viewport meta:** `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />` — never `user-scalable=no`
- **First viewport target:** 360px wide. If it does not work at 360px, it does not work
- **Touch targets:** minimum **44×44 CSS px** (Apple HIG) for any interactive element. `<a>`, `<button>`, icon buttons, switches, checkboxes
- **Tap-target spacing:** at least 8px between adjacent targets
- **Safe areas:** `padding-bottom: max(1rem, env(safe-area-inset-bottom))` for fixed bottom bars (iOS notch / home indicator)
- **`100dvh`** for full-height, never `100vh` (iOS Safari address bar)

### Content priority (decide BEFORE writing layout)

For every screen, write down in order — what is visible above the fold on a 360×640 phone:

1. **Critical** — must be visible without scrolling (headline, primary CTA, key metric)
2. **Primary** — visible after one swipe (secondary content, supporting info)
3. **Secondary** — collapsed/accordion/drawer/bottom-sheet (filters, settings, secondary nav)
4. **Tertiary** — desktop-only OR hidden behind explicit action (table dense view, multi-column grids)

This list drives the layout. Without it, mobile becomes "shrink the desktop and pray".

### Responsive scaling

- **Typography:** `clamp(min, fluid, max)` — `font-size: clamp(2rem, 5vw + 1rem, 4rem)`. Not breakpoint-step font sizes.
- **Container queries** when a component must adapt to its parent regardless of viewport (`@container (min-width: 32rem)`). Media queries when the page itself adapts to the viewport.
- **Spacing scale steps** for sections by breakpoint: `py-12` mobile → `md:py-20` tablet → `lg:py-32` desktop. Same scale, different steps.

### Mobile patterns vs desktop equivalents

| Desktop pattern | Mobile equivalent | When to swap |
|---|---|---|
| Sidebar nav | Bottom tab bar (3-5 items) OR off-canvas drawer | Always — never shrink the sidebar |
| Multi-column grid | Single column, vertical stack | Below `md:` |
| Dropdown menu | Bottom sheet with overlay | Below `md:` |
| Modal dialog | Full-screen sheet with safe-area | Below `sm:` |
| Hover-only interaction | `:active`/long-press OR persistent visible state | Always — hover doesn't exist on touch |
| Dense table | Card list with key fields, "View details" expandable | Below `md:` |
| Multi-step wizard horizontal | Vertical stepper OR full-screen step-by-step | Below `md:` |

### Mobile-only checks (mandatory before declaring "done")

- [ ] No horizontal scroll at 360px
- [ ] All text readable without zoom (min `1rem` body)
- [ ] All interactive elements ≥ 44×44px
- [ ] Tap targets at least 8px apart
- [ ] Safe-area insets applied to fixed top/bottom bars
- [ ] Content priority list written and respected
- [ ] No hover-only interactions
- [ ] Forms tested with iOS Safari + Android Chrome

Full reference + code in `references/mobile-first.md`.

---

## Pillar 5 — CLS Zero (Layout Stability)

**Rule:** Every element that occupies space must reserve that space BEFORE its content loads. Cumulative Layout Shift target: **< 0.05** (Core Web Vitals "Good" is 0.1, we aim better).

### Required setup

- **Images:** explicit `width` + `height` attributes OR `aspect-ratio` CSS. Always one of the two.
- **Videos / iframes:** wrap in container with `aspect-ratio` (`aspect-video`, `aspect-square`, or arbitrary `aspect-[4/3]`)
- **Skeletons:** match the **exact dimensions** of the loaded content. A skeleton that's 80px tall and content that's 120px tall = layout shift
- **Fonts:** `font-display: swap` + **size-adjust fallback** to match metrics of the web font during load
- **Dynamic content (toasts, banners, modals):** layered (`position: fixed/absolute`) — never inserted into normal flow above existing content
- **Lazy-loaded sections:** reserve space with `min-height` based on average content height
- **Web fonts pre-load:** `<link rel="preload" as="font" type="font/woff2" crossorigin>` for primary font

### Common CLS sources (and their fix)

| Source | Fix |
|---|---|
| `<img>` without dims | Add `width`/`height` or `aspect-ratio` |
| Web font swap reflow | `size-adjust` fallback in `@font-face` |
| Embedded iframe (YouTube, Vimeo) | Wrap in `aspect-video` container |
| Banner inserted at top of body | Use overlay (`fixed`) OR pre-reserve space with placeholder |
| Skeleton wrong size | Match real content dimensions exactly |
| Dynamic ad slot | Reserve fixed slot dimensions |
| Auto-expanding accordion | Animate `grid-template-rows: 0fr → 1fr`, not `height: auto` |
| Newsletter modal pop after 2s | Layered overlay, never push content |
| Late-loading hero image | Use `aspect-ratio` + low-quality placeholder (LQIP) of same dimensions |
| Font-loading FOIT/FOUT | `font-display: swap` + size-adjust + preload |

### Hard rules

- **Never** animate `height: auto` — use `grid-template-rows` 0fr → 1fr trick
- **Never** insert content above existing content in normal flow — overlay it
- **Never** let images load without dimensions reserved
- **Always** measure CLS in dev (Lighthouse, Web Vitals extension)

Full reference + BAD/GOOD code in `references/cls-zero.md`.

---

## Pillar 6 — Icon Budget

**Rule:** Icons are decoration. Decoration earns its place. Count icons before shipping. If icons outnumber meaningful elements, the design is decorating itself.

### Budget per region (hard limits)

| Region | Max icons | Notes |
|---|---|---|
| Top nav / header | **5** | Logo + 3 nav + user. More = noise. |
| Bottom tab bar (mobile) | **5** | Apple HIG limit. Beyond 5, use "More" tab. |
| Hero section | **1** | Usually zero. The headline does the work. |
| Section header | **1** | Optional. Often unnecessary. |
| Card | **2** | Usually one (status/category). Two is the ceiling. |
| Feature row / list item | **1** | Leading icon OR trailing chevron, not both unless it's a destructive action |
| Footer | **3 social max** | Icons must be brand marks (X, Instagram, GitHub), not generic |
| Form field | **1** | Leading affordance (mail, lock, search) OR trailing action (clear, show-password). Not both. |
| Button | **0 or 1** | Icon OR icon+text. Never icon+text+trailing-icon. Never two icons. |
| Empty state | **1** | A single illustrative glyph. Never an icon grid. |

### Icon usage rules

- **Functional first:** every icon must answer "what does this DO?". If it answers "what does this LOOK like?" — cut it.
- **Same family:** one library per project (`lucide-react` OR `@phosphor-icons/react` OR `@radix-ui/react-icons`). Never mix.
- **Size scale:** `14px / 16px / 20px / 24px` — pick from the scale, do not freestyle
- **Stroke weight consistency:** all icons same stroke weight (e.g. lucide default 2px). Mixing 1.5 and 2 reads as broken
- **Color via `currentColor`:** icons inherit text color. No bespoke icon colors except brand status (success/error/warning).
- **Accessibility:** decorative icons → `aria-hidden="true"`. Functional icons (icon-only buttons) → `aria-label="..."`.
- **Icon + label, not icon-only** for actions whose meaning is not universal. "🗑️" alone is fine. A custom shape alone is not.
- **No emoji as icons** in production UI. Icons must be from the chosen library.

### Anti-patterns

- **Icon Soup** — every list item, button, card has an icon. Visual noise, no information gain. Cut by 50%.
- **Decorative duplication** — icon next to a label that says the same word ("📅 Calendar"). Pick one.
- **Brand-color icon stack** — five icons in five colors at the top of a marketing page. Reads as a sticker sheet.
- **Mixed libraries** — Lucide nav, Phosphor cards, Heroicons footer. Inconsistent stroke + corner radius = cheap.
- **Icon + chevron + status dot** on the same row — three glyphs competing. Pick one signal.

Full reference in `references/icon-budget.md`.

---

## Design Contract (per-project source of truth)

Every project ships a `DESIGN.md` (or `design-tokens.md`) at the repo root. The agent reads it at the start of every session. Without it, drift is guaranteed.

### Minimum content

```markdown
---
name: "Project Name"
breakpoints:
  mobile: 360px
  sm: 640px
  md: 768px
  lg: 1024px
  xl: 1280px
  2xl: 1440px
colors:
  background: { light: "#fafafa", dark: "#0a0a0a" }
  foreground: { light: "#0a0a0a", dark: "#fafafa" }
  # ...semantic tokens
typography:
  body: { family: "Geist", size: "1rem", lineHeight: "1.6" }
  # ...
spacing: { scale: [0, 4, 8, 12, 16, 24, 32, 48, 64, 80, 96, 128] }
rounded: { sm: 4px, md: 8px, lg: 12px, xl: 20px, full: 9999px }
motion:
  duration: { fast: 150ms, base: 250ms, slow: 400ms }
  ease: { default: "cubic-bezier(0.16, 1, 0.3, 1)", themeToggle: "cubic-bezier(0.65, 0, 0.35, 1)" }
iconBudget: { nav: 5, hero: 1, card: 2, button: 1, formField: 1 }
contentPriority:
  homepage:
    critical: ["headline", "primary CTA"]
    primary: ["value props (3)"]
    secondary: ["pricing teaser", "social proof"]
    tertiary: ["full footer nav"]
---

## Brand voice
- Tone: …
- Forbidden words: (Filler Word Index applies)

## Design rationale
- Why these tokens
- AI Tells to enforce: LILA BAN, Pure Black Tell, Inter Tell, Icon Soup, Jane Doe Effect, Acme Slop, 99.99% Problem
```

The format borrows from [Google Labs `DESIGN.md`](https://github.com/google-labs-code/design.md) (tokens + rationale) and extends it with Dublin specifics (motion, breakpoints, icon budget, content priority, AI Tells).

Reference: `references/design-contract.md` — full template + how to enforce in CI.

---

## Stack Recommendation

**Default: la opción más liviana que cumpla el requerimiento (VPS-first).**

| Necesidad | Stack recomendado |
|---|---|
| SPA / dashboard / app interna | **Vite + React** — bundle estático, sirve nginx |
| Sitio de contenido / marketing / mayormente estático | **Astro** — islands, JS mínimo en cliente |
| Full-stack con SSR real / ISR / RSC / streaming | **Next.js 15 + Turbopack** — App Router, SWC compiler |
| API ultra-liviana / edge-compatible | **Hono** (corre en Node/Bun/Deno) o **Fastify** |

**Común a todos los proyectos frontend:**
- TypeScript (strict), Tailwind CSS v4 (CSS variables native)
- Dual theme desde día 0 — ver Pillar 1 y `theming.md` para la variante correcta según framework
- `@base-ui-components/react` para primitivos headless (o Radix UI)
- `class-variance-authority` + `tailwind-merge` + `clsx`
- `lucide-react` para íconos (una sola librería, budget estricto)
- Framer Motion solo cuando un componente lo necesita explícitamente
- **`pnpm` como package manager** — nunca `npm`/`yarn` en proyectos nuevos

**Antes de elegir Next.js:** ¿nginx + bundle estático alcanza? Next.js con Turbopack ya es más liviano que antes, pero sigue siendo más pesado que Vite/Astro. Justificarlo cuando lo elegís.

---

## Anti-Patterns (Forbidden)

| Anti-pattern | Why it's bad | Fix |
|---|---|---|
| Hardcoded hex in components (`bg-[#0a0a0a]`) | Breaks theming forever | Semantic token (`bg-background`) |
| "We'll add dark mode later" | 10x the cost, always retrofitted | Set up both themes on day 0 |
| `mt-[13px]`, `p-[22px]` arbitrary values | Spacing anarchy | Stick to the scale |
| Margin on leaf components | Leaks layout into components | Parent owns spacing (gap, padding) |
| Copy-pasting shadcn into every project with no abstraction | Drift, inconsistency, bloat | Own a branded `ui/` layer over headless primitives |
| Building Dialog/Dropdown by hand | Inaccessible, buggy, token-expensive | Use Base UI / Radix |
| Boolean prop explosion (`<Button primary large loading rounded>`) | Unmaintainable | CVA variants |
| Importing from barrel files (`import { X } from '@base-ui/react'`) | Bundle bloat | Import from specific path |
| Designing on desktop, "responsive later" | Mobile becomes shrunk-desktop | Start at 360px, content priority first |
| Touch targets < 44px | Fails accessibility, frustrates mobile users | Min 44×44 CSS px on every interactive element |
| `100vh` on mobile | iOS Safari address bar collapses layout | `100dvh` always |
| `<img>` without explicit dimensions | CLS during image load | Always `width`+`height` or `aspect-ratio` |
| Skeleton with wrong dimensions | Layout shift on content swap | Match real content size exactly |
| `height: auto` animation | CLS + jank | `grid-template-rows: 0fr → 1fr` |
| Banner inserted in normal flow | Pushes content, CLS, dismisses focus | Use overlay (`fixed`) |
| Icon Soup (icons everywhere) | Visual noise, no info gain | Enforce icon budget per region |
| Mixing icon libraries | Inconsistent stroke/radius reads as broken | One library per project |
| Hover-only interactions | Invisible on touch | Persistent state OR `:active` equivalent |
| Web font load reflow (FOIT/FOUT) | CLS spike on first paint | `font-display: swap` + size-adjust fallback + preload |

---

## Output Standards

- Be CONCISE — lead with code, minimize prose
- Complete, runnable code (no placeholders)
- TypeScript strict, Tailwind v4 with CSS variables
- Every component respects semantic tokens + spacing scale
- Never generate a component without verifying it works in BOTH themes

## Reference Files

Load as needed during implementation:

- `references/theming.md` — CSS variables, `next-themes` setup, Tailwind config, contrast rules, glass/gradient dual-theme variants
- `references/spacing.md` — Scale definition, layout primitives code, container/section patterns, responsive breakpoints
- `references/component-system.md` — Base UI vs Radix comparison, branded primitive templates (Button, Dialog, Select), CVA patterns, folder structure
- `references/mobile-first.md` — Content priority worksheet, mobile-vs-desktop pattern swaps, touch target sizing, safe-area handling, container queries, `clamp()` typography
- `references/cls-zero.md` — BAD/GOOD pairs for every CLS source: image dims, font swap, iframe wrap, accordion animation, banner insertion, skeleton sizing, web font preload + size-adjust
- `references/icon-budget.md` — Per-region budget enforcement, icon family selection, sizing scale, accessibility (aria-hidden vs aria-label), Icon Soup examples
- `references/design-contract.md` — DESIGN.md template (tokens + rationale), how to reference Google's spec, optional CI lint script (`validate-design.ts`)
