# Mobile-First with Content Priority

How to actually start on mobile, not how to add media queries to a desktop layout.

---

## 0. The Content Priority Worksheet

Fill this out BEFORE any layout code. Every screen, every time.

```
Screen: <name>

Critical (visible without scroll on 360×640):
  1. <element>
  2. <element>
  3. <primary CTA>

Primary (visible after one swipe):
  - <element>
  - <element>

Secondary (collapsed / drawer / bottom-sheet on mobile):
  - <element>
  - <element>

Tertiary (desktop-only OR explicit user action to reveal):
  - <element>
```

If the list does not exist, the layout will be wrong. Period.

---

## 1. Viewport meta (mandatory)

```html
<!-- ✅ Correct -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />

<!-- ❌ Forbidden — disables zoom, fails accessibility -->
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no, maximum-scale=1" />
```

`viewport-fit=cover` is required for `env(safe-area-inset-*)` to work on iOS notch / home-indicator devices.

---

## 2. Touch target sizing (Apple HIG / WCAG 2.5.5)

**Minimum 44×44 CSS pixels** for any interactive element. WCAG AAA wants 44×44, AA wants 24×24 — we use 44.

```tsx
// ✅ Icon button — padding makes it 44×44 even though the icon is 20×20
<button className="p-3 inline-flex items-center justify-center" aria-label="Close">
  <X className="size-5" />
</button>

// ❌ Tiny tap area — 20×20 click box
<button className="inline-flex" aria-label="Close">
  <X className="size-5" />
</button>
```

Tap-target spacing: at least 8px between adjacent interactive elements.

```tsx
// ✅ Spaced row
<div className="flex gap-2">
  <button className="size-11">A</button>
  <button className="size-11">B</button>
</div>

// ❌ Touching tap targets, fat-finger errors
<div className="flex">
  <button className="size-11">A</button>
  <button className="size-11">B</button>
</div>
```

---

## 3. Full-height: `100dvh`, never `100vh`

```css
/* ✅ Adapts to iOS Safari's collapsing address bar */
.hero { min-height: 100dvh; }

/* ❌ Layout breaks when address bar shows/hides */
.hero { min-height: 100vh; }
```

Tailwind: `min-h-[100dvh]`. Never `min-h-screen` for hero / full-bleed sections.

---

## 4. Safe-area insets (iOS notch / home indicator)

```css
/* Bottom tab bar */
.bottom-bar {
  padding-bottom: max(1rem, env(safe-area-inset-bottom));
}

/* Top of screen below dynamic island */
.top-bar {
  padding-top: max(0.5rem, env(safe-area-inset-top));
}
```

Tailwind v4 / arbitrary:
```tsx
<nav className="pb-[max(1rem,env(safe-area-inset-bottom))]">
```

---

## 5. Fluid typography with `clamp()`

```css
/* Hero headline: 2rem on mobile, scales to 4rem on wide screens */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  line-height: 1.05;
  letter-spacing: -0.025em;
}

/* Body */
p {
  font-size: clamp(1rem, 0.5vw + 0.9rem, 1.125rem);
  line-height: 1.6;
}
```

Avoid breakpoint-step typography (`text-2xl md:text-4xl lg:text-6xl`) — it jumps at breakpoints, fluid typography never jumps.

---

## 6. Container queries vs media queries

| Use case | Tool |
|---|---|
| Page layout adapts to viewport | Media query (`@media (min-width: 768px)`) |
| Component adapts to its parent (sidebar vs main, card in different grids) | Container query (`@container (min-width: 32rem)`) |

```css
/* Card adapts based on its container width, not the viewport */
.card-container {
  container-type: inline-size;
  container-name: card;
}

@container card (min-width: 32rem) {
  .card { display: grid; grid-template-columns: 1fr 2fr; }
}
```

Tailwind v4: `@container` + `@sm:`, `@md:` variants.

---

## 7. Mobile pattern swaps (the table)

| Desktop pattern | Mobile equivalent | Notes |
|---|---|---|
| Sidebar nav | Bottom tab bar (3-5 items) OR hamburger drawer | Never shrink the sidebar; tab bar > drawer for primary nav |
| Multi-column grid | Single column, vertical stack | `grid-cols-1 md:grid-cols-3` |
| Hover dropdown | Bottom sheet | Hover doesn't exist on touch |
| Dropdown menu | Bottom sheet with overlay | Larger tap targets, easier to dismiss |
| Modal dialog | Full-screen sheet with safe-area | Especially for forms |
| Dense table | Card list with key fields, expandable | Or horizontal scroll with frozen first column |
| Multi-step horizontal wizard | Vertical stepper / full-screen step-by-step | Each step is its own screen on mobile |
| Tooltip on hover | Long-press OR persistent helper text | Hover doesn't fire on touch |
| Right-click context menu | Long-press OR explicit "..." action button | No right-click on mobile |
| Filters in sidebar | Filter button → bottom sheet | Mobile: filters live behind a button |
| Multi-pane (master/detail) | Stack view: list → tap → detail | Push/pop nav |

---

## 8. Bottom sheet (the most useful mobile primitive)

```tsx
// Use Vaul (vaul.emilkowal.ski) or Base UI Dialog with custom positioning
import { Drawer } from 'vaul';

<Drawer.Root>
  <Drawer.Trigger asChild>
    <Button>Open filters</Button>
  </Drawer.Trigger>
  <Drawer.Portal>
    <Drawer.Overlay className="fixed inset-0 bg-black/40" />
    <Drawer.Content className="fixed bottom-0 inset-x-0 rounded-t-2xl bg-background pb-[env(safe-area-inset-bottom)]">
      <div className="mx-auto h-1.5 w-10 rounded-full bg-muted my-3" />
      {/* sheet content */}
    </Drawer.Content>
  </Drawer.Portal>
</Drawer.Root>
```

Bottom sheets are the mobile-native equivalent of dropdowns, dialogs, and side panels. Default to bottom sheet on mobile.

---

## 9. Form inputs on mobile

```tsx
// ✅ Right keyboard, autocomplete hints, no zoom on focus
<input
  type="email"
  inputMode="email"
  autoComplete="email"
  className="text-base" // ≥ 16px prevents iOS auto-zoom on focus
/>

<input
  type="tel"
  inputMode="tel"
  autoComplete="tel"
  className="text-base"
/>

<input
  type="number"
  inputMode="numeric"
  pattern="[0-9]*"
  className="text-base"
/>

// ❌ iOS zooms in on focus when font-size < 16px
<input type="email" className="text-sm" />
```

`inputMode` is for the soft keyboard; `type` is for validation/semantics. Use both.

---

## 10. Mobile-only checks (run before declaring "done")

- [ ] No horizontal scroll at 360px width (DevTools: device toolbar → 360×800)
- [ ] All text legible without zoom (body ≥ 16px)
- [ ] All interactive elements ≥ 44×44 CSS px
- [ ] Tap targets at least 8px apart
- [ ] Safe-area padding on fixed top/bottom bars
- [ ] `100dvh` on full-height sections (not `100vh`)
- [ ] No hover-only interactions (or has touch equivalent)
- [ ] Forms: correct `inputMode`, `autoComplete`, font-size ≥ 16px
- [ ] Bottom sheet for mobile dropdowns/filters/dialogs (not shrunken desktop ones)
- [ ] Tested on iOS Safari + Android Chrome (real device or emulator)
- [ ] Content priority list written and respected
