# Overflow Killers

The "se sale de pantalla" bug is almost always one of nine causes. Find the source. Do not paper over it.

---

## The Golden Rule

> `body { overflow-x: hidden }` is a **band-aid**, never the cure.

It hides the symptom and lets the offending element keep pushing the layout. On Android Chrome it sometimes still scrolls. On iOS Safari it can break sticky positioning. **Find the source first.** Use the band-aid only as a defensive last layer once the offender is fixed.

---

## 1. `width: 100vw` — the Vee-Vee-Dub Trap

`100vw` includes the vertical scrollbar width on desktop and on some Android browsers, so a `100vw` element is wider than the viewport's usable area. Add any horizontal padding and you overflow.

```css
/* ❌ BAD — includes scrollbar, overflows by ~15px */
.banner { width: 100vw; }

/* ✅ GOOD — fills the parent, never the scrollbar */
.banner { width: 100%; }

/* ✅ GOOD — when you actually need viewport width (full-bleed image), clip overflow on the wrapper */
.full-bleed-wrapper { overflow-x: clip; }
.full-bleed { width: 100vw; margin-left: calc(50% - 50vw); }
```

---

## 2. `min-width` on children of a flex/grid

A child with `min-width: 320px` inside a 360px container with horizontal padding overflows by exactly the padding amount. Common with stat cards, code blocks, and tables.

```tsx
// ❌ BAD
<div className="px-6">
  <div className="grid grid-cols-2 gap-4">
    <Stat className="min-w-[180px]" />
    <Stat className="min-w-[180px]" /> {/* overflows on 360px */}
  </div>
</div>

// ✅ GOOD — let grid decide, or use minmax
<div className="px-4">
  <div className="grid grid-cols-[repeat(auto-fit,minmax(0,1fr))] gap-4">
    <Stat />
    <Stat />
  </div>
</div>
```

The `minmax(0, 1fr)` trick is critical — `minmax(180px, 1fr)` will overflow, `minmax(0, 1fr)` will not.

---

## 3. Long words / URLs / emails — the Wrap Trap

A long unbroken string (URL, email, hash, code) renders as a single token and pushes the parent wider than the viewport.

```css
/* ✅ Apply to any container that holds user-generated text */
.user-content {
  overflow-wrap: anywhere; /* breaks anywhere as last resort */
  word-break: normal;       /* keep words intact when possible */
}

/* For pre/code blocks specifically */
pre, code {
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
```

```tsx
// Tailwind
<p className="break-words [overflow-wrap:anywhere]">
  Tomás compartió: https://docs.example.com/very/long/path/that/breaks?param=value&other=thing
</p>
```

---

## 4. Images without `max-width: 100%`

A 1200px-wide image inside a 360px container pushes the layout 840px wide.

```css
/* ✅ Global default — set this once and forget */
img, video, iframe, embed, object {
  max-width: 100%;
  height: auto;
}
```

```tsx
// ✅ Next.js Image — already responsive when sized correctly
<Image src="/hero.jpg" alt="" width={1200} height={800} className="w-full h-auto" />
```

Pair with `aspect-ratio` to also avoid CLS — see `frontend-foundation/references/cls-zero.md`.

---

## 5. Tables without a scroll wrapper

Tables expand to their content width by default. Five columns × 100px each = 500px. That is wider than 360px.

```tsx
// ❌ BAD
<table>{...}</table>

// ✅ GOOD — wrap in horizontal scroll, with shadow hint
<div className="overflow-x-auto -mx-4 px-4">
  <table className="min-w-[640px] w-full">{...}</table>
</div>

// ✅ BETTER on mobile — convert to card list
<ul className="md:hidden divide-y">
  {rows.map((r) => (
    <li key={r.id} className="py-3">
      <p className="font-medium">{r.name}</p>
      <p className="text-sm text-foreground/70">{r.email} · {r.role}</p>
    </li>
  ))}
</ul>
<table className="hidden md:table w-full">{...}</table>
```

---

## 6. Code blocks without `overflow-x: auto`

```css
pre {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch; /* momentum scroll on iOS */
}
```

Tailwind: `<pre className="overflow-x-auto">`

---

## 7. Padding that adds up beyond the viewport

`px-8` (32px each side = 64px) on a 360px screen leaves 296px for content. Three `gap-6` columns of `min-w-[120px]` = 360 + 48 = 408px → overflow.

```tsx
// ❌ BAD
<section className="px-8">
  <div className="grid grid-cols-3 gap-6 min-w-[120px]">{...}</div>
</section>

// ✅ GOOD — tighten padding on mobile, expand at md
<section className="px-4 md:px-8">
  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6">{...}</div>
</section>
```

Mobile padding default: `px-4` (16px). Anything more requires a reason.

---

## 8. Headlines too big — Headline Bomb

`text-7xl` (4.5rem = 72px) on a 360px screen with one long word ("Internacionalización") will overflow. Use `clamp()` for fluid type.

```css
/* ❌ BAD — fixed huge size */
h1 { font-size: 4.5rem; }

/* ✅ GOOD — fluid */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  letter-spacing: -0.025em;
  line-height: 1.05;
  overflow-wrap: anywhere; /* defensive — long words still wrap */
}
```

Tailwind: `<h1 className="text-[clamp(2rem,5vw+1rem,4rem)] tracking-tight leading-[1.05]">`.

---

## 9. Grid with too many columns at 360px

A `grid-cols-4` on mobile gives each column 90px minus gaps — content that does not fit pushes the column wider than its track.

```tsx
// ❌ BAD — 4 columns at 360px
<div className="grid grid-cols-4 gap-4">{...}</div>

// ✅ GOOD — single column on mobile, scale up
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">{...}</div>

// ✅ GOOD — auto-fit with hard min of 0
<div className="grid grid-cols-[repeat(auto-fit,minmax(0,1fr))] gap-4">{...}</div>
```

`grid-template-columns: repeat(N, min-content)` is a common offender — `min-content` lets cells expand to the widest atom inside.

---

## Debug Recipe (in this order)

### Step 1 — Outline everything

Paste in DevTools console or temp `<style>` block:

```css
* { outline: 1px solid red !important; }
```

The element with the red outline that extends past the viewport is the culprit. Walk up the tree if the outermost is fine.

### Step 2 — Find the widest element programmatically

Paste in the browser console:

```js
(() => {
  const vw = document.documentElement.clientWidth;
  const offenders = [];
  document.querySelectorAll('*').forEach((el) => {
    const rect = el.getBoundingClientRect();
    if (rect.right > vw + 1 || rect.left < -1) {
      offenders.push({
        el,
        right: Math.round(rect.right),
        width: Math.round(rect.width),
        tag: el.tagName,
        cls: el.className?.toString().slice(0, 60) || '',
      });
    }
  });
  console.table(offenders.slice(0, 20));
  return offenders[0]?.el; // returns first offender for inspection
})();
```

This prints every element extending past the viewport. The first row is usually the root cause; the rest are children inheriting the overflow.

### Step 3 — Runtime guard (development only)

Add to the app shell to fail loudly during development:

```tsx
// app/components/overflow-guard.tsx
'use client';
import { useEffect } from 'react';

export function OverflowGuard() {
  useEffect(() => {
    if (process.env.NODE_ENV !== 'development') return;
    const check = () => {
      const html = document.documentElement;
      if (html.scrollWidth > window.innerWidth + 1) {
        console.warn(
          `[OverflowGuard] Horizontal overflow detected: scrollWidth=${html.scrollWidth} viewport=${window.innerWidth}`,
        );
      }
    };
    check();
    window.addEventListener('resize', check);
    return () => window.removeEventListener('resize', check);
  }, []);
  return null;
}
```

### Step 4 — Last resort, defensive only

```css
html, body { overflow-x: clip; } /* `clip` is preferred over `hidden` — does not create a scroll container */
```

Use `overflow-x: clip` after the source is fixed, as a safety net for user-generated content.

---

## Quick Audit Checklist

Run this on every screen at 360px width:

- [ ] No `width: 100vw` in components (use `100%`)
- [ ] No `min-width` on grid/flex children that exceeds (viewport − padding) ÷ columns
- [ ] All user-generated text containers have `overflow-wrap: anywhere`
- [ ] `img, video, iframe { max-width: 100% }` global rule present
- [ ] All tables wrapped in `overflow-x-auto` OR converted to card list on mobile
- [ ] All `<pre>` / `<code>` have `overflow-x: auto`
- [ ] Mobile padding ≤ `px-4` unless justified
- [ ] Headlines use `clamp()`, not fixed `text-7xl`
- [ ] No `grid-cols-3+` at 360px without `auto-fit, minmax(0, 1fr)`
- [ ] Runtime check: `document.documentElement.scrollWidth <= window.innerWidth`
