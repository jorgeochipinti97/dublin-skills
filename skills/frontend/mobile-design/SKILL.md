---
name: mobile-design
description: Mobile-first design with its own identity — not desktop scaled down. Use when the user reports mobile issues ("se sale de pantalla", "no se ve bien en celular", "mobile feels wrong", "responsive problems", "horizontal scroll on mobile"), when designing UX that differs intentionally from desktop (bottom sheets, FAB, swipe actions, sticky CTAs, segmented controls), when planning thumb-zone ergonomics, touch targets, or fluid type, or when an audit flags Shrunk Desktop / Mobile Afterthought. Pairs with frontend-foundation (Pillar 4 owns the baseline rules); this skill owns mobile-as-its-own-medium and the killer of horizontal overflow. Run AFTER frontend-foundation, BEFORE premium-frontend-design polish.
---

# Mobile Design

Mobile is not a smaller desktop. It is a different medium with its own grammar: thumbs instead of mice, vertical context, network jitter, soft keyboards that eat the viewport, and content priority that changes when 360px is all you have.

This skill complements `frontend-foundation` (Pillar 4 — mobile-first) by treating mobile as a **first-class design surface**, not a responsive afterthought.

---

## Philosophy

> **Mobile is not desktop minus features. Mobile is a different product.**

Three principles:

1. **Mobile-native UX** — bottom sheets, FAB, swipe, pull-to-refresh, segmented control. These are not optional polish. They are the language users expect.
2. **Thumb-driven** — primary actions live in the bottom third of the screen. Top-right corners are unreachable for one-handed use on a 6.7" device.
3. **Zero overflow** — horizontal scroll on mobile is the most common, most embarrassing, and most fixable bug in the catalog. There is no excuse.

---

## The Big AI Tell — Shrunk Desktop

A new named anti-pattern, sibling to `Mobile Afterthought` (in `premium-frontend-design`).

### Definition

**Shrunk Desktop** is when mobile UI is the desktop UI compressed into 360px — same layout, same patterns, same affordances, just smaller. Visible signs:

- Sidebar that becomes a tiny vertical strip instead of a bottom tab bar
- Modal dialog centered at 90% width instead of a full-screen sheet
- Hover dropdowns that need a long-press to discover
- Tables that scroll horizontally with frozen columns instead of becoming card lists
- 3-column card grids stacked vertically with desktop padding intact
- CTAs in the top-right corner where the thumb cannot reach
- Filters in a left sidebar instead of behind a "Filter" button → bottom sheet

### BAD (Shrunk Desktop)

```tsx
// Sidebar squeezed onto a 360px screen
<aside className="w-16 md:w-64 fixed left-0 top-0 h-[100dvh]">
  <NavItem icon={<Home />} />  {/* unreadable, no label */}
  <NavItem icon={<Search />} />
  <NavItem icon={<Bell />} />
</aside>
<main className="ml-16 md:ml-64">{children}</main>
```

### GOOD (Mobile-native)

```tsx
// Bottom tab bar on mobile, sidebar on desktop
<>
  {/* Mobile: bottom tab bar in thumb zone */}
  <nav className="md:hidden fixed bottom-0 inset-x-0 border-t bg-background pb-[max(0.5rem,env(safe-area-inset-bottom))]">
    <ul className="grid grid-cols-4">
      <TabItem icon={<Home />} label="Inicio" href="/" />
      <TabItem icon={<Search />} label="Buscar" href="/search" />
      <TabItem icon={<Bell />} label="Avisos" href="/notifications" />
      <TabItem icon={<User />} label="Cuenta" href="/account" />
    </ul>
  </nav>

  {/* Desktop: sidebar */}
  <aside className="hidden md:block fixed left-0 top-0 h-[100dvh] w-64 border-r">
    {/* full sidebar */}
  </aside>

  <main className="pb-[5rem] md:pb-0 md:ml-64">{children}</main>
</>
```

The mobile UI is **not the same component shrunk** — it is a different component made for thumbs.

---

## Non-Negotiable Mandates

These five rules are checked by `frontend-output-validator`. Break them and the gate fails.

1. **Design starts at 360px.** No layout exists until the 360px column flow is defined. Then scale up. Never the reverse.
2. **Touch targets ≥ 44×44 CSS px** with **≥ 8px spacing** between them. Padding is the answer for icon buttons.
3. **Zero horizontal overflow** at 360px width. `body { overflow-x: hidden }` is a band-aid, not a fix. Find the source. See `references/overflow-killers.md`.
4. **`100dvh`, never `100vh`.** iOS Safari's address bar collapses; `vh` does not adapt and breaks hero sections.
5. **Safe-area insets** on every fixed bottom bar, modal, and sticky CTA: `pb-[max(1rem,env(safe-area-inset-bottom))]`. Viewport meta MUST include `viewport-fit=cover` and MUST NOT include `user-scalable=no`.

---

## When This Skill Fires

Triggers (any of these in user input):
- "no se ve bien en celular", "se sale de pantalla", "horizontal scroll", "scroll horizontal"
- "mobile UX", "mobile feels wrong", "shrunk desktop"
- "bottom sheet", "FAB", "tab bar", "swipe action", "pull to refresh", "sticky CTA"
- "thumb zone", "touch target", "tap target"
- "iOS auto-zoom", "input zoom", "viewport meta"
- "safe area", "notch", "home indicator"
- Audit flags: `Shrunk Desktop`, `Mobile Afterthought`, `Tap Target Tell`

---

## Workflow

When invoked:

1. **Read the project's `DESIGN.md`** — pull `breakpoints`, `contentPriority`, `iconBudget`. If `DESIGN.md` is missing, ask `frontend-foundation` to bootstrap it first.
2. **List screens to mobile-design**, prioritized by traffic / conversion impact (landing > checkout > onboarding > dashboard > settings).
3. **For each screen**, fill the Content Priority Worksheet from `frontend-foundation/references/mobile-first.md`. Critical / Primary / Secondary / Tertiary at 360×640.
4. **Pick mobile-native patterns** for each interaction — see `references/mobile-patterns.md`. Map every desktop pattern to its mobile equivalent (the table is in `frontend-foundation/references/mobile-first.md` §7; do not duplicate it here).
5. **Audit thumb zones** — primary actions in the bottom third, destructive in the safe-stretch middle, navigation/back in the top corners (acceptable because they are non-frequent). Reference `references/touch-and-type.md`.
6. **Hunt overflow** — run `references/overflow-killers.md` checklist on every screen at 360px.
7. **Form pass** — every input gets correct `inputMode`, `autoComplete`, `font-size: 16px` (or `text-base`), and the safe viewport meta. See `references/touch-and-type.md` §Forms.
8. **Hand off to `frontend-output-validator`** for runtime checks (overflow detection, viewport audit, touch-target measurement).

---

## Outputs

For each screen, deliver:

- **Mobile blueprint** — content priority list, layout sketch in pseudo-JSX at 360px, breakpoint up-shifts at 768px and 1024px
- **Pattern picks** — bottom sheet vs modal, FAB vs bottom bar, tabs vs segmented control, with the WHY in one line each
- **Touch & type spec** — touch target sizes, type scale (`clamp()`), forms config (`inputMode` per field)
- **Overflow audit** — list of components likely to overflow + fix per item
- **Safe-area map** — which fixed elements need `env(safe-area-inset-*)` padding

---

## Anti-Patterns (in addition to AI Tells from `premium-frontend-design`)

| Anti-pattern | Name |
|---|---|
| Mobile UI = desktop UI compressed into 360px | **Shrunk Desktop** |
| `width: 100vw` (includes scrollbar, causes overflow) | **Vee-Vee-Dub Trap** |
| `body { overflow-x: hidden }` as a "fix" instead of finding the source | **Overflow Coverup** |
| Modal dialog centered on mobile instead of full-screen sheet | **Centered-Modal Trap** |
| Primary CTA in the top-right corner | **Unreachable Corner** |
| Hamburger menu as the default mobile nav for a product with ≤ 5 destinations | **Hamburger Default** |
| `<input>` with `font-size < 16px` (iOS auto-zooms on focus) | **iOS Zoom Tell** |
| `user-scalable=no` in viewport meta | **A11y Block** |
| Filters in a sidebar on mobile | **Sidebar Filter Trap** |
| `100vh` on hero sections | **iOS Safari Killer** (already in premium-frontend-design) |

---

## Tech Stack

- React 18+ / Next.js 14+, Tailwind CSS v4
- **Vaul** for bottom sheets (`vaul.emilkowal.ski`) or **Base UI Dialog** with custom positioning
- **Framer Motion** for swipe gestures and drag-to-dismiss
- Test on real iOS Safari + Android Chrome. DevTools device toolbar is necessary, not sufficient.

---

## Reference Files (load on demand)

- `references/overflow-killers.md` — every cause of "se sale de pantalla" with BAD/GOOD pairs and a runtime detection snippet
- `references/mobile-patterns.md` — bottom sheet, FAB, swipe, pull-to-refresh, sticky CTA, segmented control, full-screen sheet — with when YES / when NO and minimal snippets
- `references/touch-and-type.md` — thumb zones, touch targets, fluid type with `clamp()`, mobile form config (`inputMode`, `autoComplete`, font-size 16px), safe-area, image strategy

---

## Output Standards

- Confirm the 5 mandates are honored on every screen
- Lead with the mobile blueprint, then desktop variations
- Concrete code, no placeholders. Voseo in prose, technical English in code identifiers.
- Names in examples: real Latin contexts (Camila Pereyra, Tomás Arias, Sofía Bianchi), real businesses (Café Tortoni, Despegar, Mercado Libre, Globant), realistic numbers (`+54 11 4823-1947`, `$ 14.760,50`, `47.2%`)
- Verify dependencies (`vaul`, `framer-motion`) before importing
