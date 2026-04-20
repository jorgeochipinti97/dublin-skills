---
name: frontend-foundation
description: Day-0 frontend architecture for React/Next.js products. Use when STARTING a new frontend, setting up a design system, or fixing foundational issues (inconsistent spacing, missing dark mode, bespoke components everywhere). Establishes design tokens, dual theme (dark + light) from the start, spacing scale, and a reusable component system built on headless primitives (Base UI, Radix, React Aria) to save tokens and inherit accessibility. Invoke BEFORE premium-frontend-design — aesthetic layers on top of this foundation.
---

# Frontend Foundation

Non-negotiable day-0 setup for any React/Next.js product. Do this before writing any UI component.

## Invoke Order

```
frontend-foundation  →  premium-frontend-design  →  product-tour / react-performance
(tokens, theme,        (aesthetics, motion,        (onboarding, perf)
 component system)      glass, typography)
```

If this skill is skipped, you will end up retrofitting dark mode, rewriting margins, and rebuilding the same Button/Dialog ten times. Non-negotiable.

## Three Pillars

1. **Dual theme from day one** — dark + light, always, via CSS variables + View Transitions for smooth toggling
2. **Spacing system** — one scale, no ad-hoc `mt-[13px]`
3. **Headless component system** — Base UI / Radix / React Aria + a thin branded layer

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

## Stack Recommendation

**Default stack for a new frontend product:**

- Next.js 15 (App Router) + React 19
- TypeScript (strict)
- Tailwind CSS v4 (CSS variables native)
- `next-themes` for theme toggle
- `@base-ui-components/react` for primitives (or Radix if the team prefers)
- `class-variance-authority` + `tailwind-merge` + `clsx` for variants
- `lucide-react` for icons
- Framer Motion only when a component needs it (not globally)

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
