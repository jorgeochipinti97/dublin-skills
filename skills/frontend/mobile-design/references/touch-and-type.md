# Touch & Type

How fingers and eyes interact with mobile screens. Thumb zones, target sizes, fluid type, form ergonomics, safe areas, image strategy.

---

## 1. Thumb Zones (Hoo's Map)

A held phone has three reach zones for the dominant thumb. On a 6.7" device (~167mm tall):

```
┌────────────────────┐  ◄  HARD (top corners, opposite-side edge)
│  HARD                  │      Reaching here requires shifting grip
│   ┌────────────┐    │      → Use for: brand mark, secondary nav,
│   │   STRETCH      │    │        non-frequent settings icon
│   │                       │    │      → Avoid: primary actions, CTAs,
│   │      NATURAL  │    │        critical buttons
│   │                       │    │
│   └────────────┘    │  ◄  STRETCH (top half of screen,
│                                │       middle band)
│                                │      → Use for: nav back, secondary
│                                │        actions, content
│                                │
│         NATURAL          │  ◄  NATURAL (bottom third)
│                                │      → Use for: primary CTAs,
│                                │        bottom tab bar, FAB,
└────────────────────┘        sticky checkout
```

**Implications**:

- **Bottom third = primary actions.** Tab bar, FAB, "Buy now", "Continue".
- **Top corners = non-frequent only.** Brand mark (left), settings/profile icon (right). Acceptable because users tap them rarely.
- **Top-right is the worst spot for a primary CTA.** This is the #1 mobile usability bug after horizontal overflow.

If your "Sign up" button is in the top-right header, you are working against the hand. Move it to a sticky bottom CTA or to the natural zone.

---

## 2. Touch Targets

### Minimums

| Source | Min size | Min spacing |
|---|---|---|
| Apple HIG | 44 × 44 pt | 8 pt |
| Material Design | 48 × 48 dp | 8 dp |
| WCAG 2.5.5 (AAA) | 44 × 44 CSS px | — |
| **Dublin standard** | **44 × 44 CSS px** | **8 px** |

### Hit slop pattern (target larger than visible)

When the visible icon is small (e.g. 16px close icon), expand the touchable area without expanding the visible footprint.

```tsx
// ✅ 16px icon, 44px hit area via padding
<button
  aria-label="Cerrar"
  className="inline-flex size-11 items-center justify-center -m-3"
>
  <X className="size-4" aria-hidden />
</button>
```

The `-m-3` neutralizes the layout cost so the visible spacing stays tight while the hit slop is generous.

### Spacing between targets

```tsx
// ❌ Adjacent buttons, 0px between hit zones — fat-finger errors
<div className="flex">
  <button className="size-11">A</button>
  <button className="size-11">B</button>
</div>

// ✅ 8px minimum
<div className="flex gap-2">
  <button className="size-11">A</button>
  <button className="size-11">B</button>
</div>
```

For **destructive vs primary** actions side-by-side, use 16px+ spacing — accidental destructive taps are the highest cost.

---

## 3. Fluid Type with `clamp()`

Fixed-step typography (`text-2xl md:text-4xl lg:text-6xl`) jumps at breakpoints and looks dated. `clamp()` is the modern default.

```css
/* Headline: 2rem at 360px, scales fluidly to 4rem at 1280px+ */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
  line-height: 1.05;
  letter-spacing: -0.025em;
}

h2 {
  font-size: clamp(1.5rem, 3vw + 0.8rem, 2.5rem);
  line-height: 1.15;
  letter-spacing: -0.02em;
}

p {
  font-size: clamp(1rem, 0.5vw + 0.9rem, 1.125rem);
  line-height: 1.6;
}
```

### Mobile vs Desktop ratios

Body text on mobile reads at arm's length (~30cm); desktop at ~50-60cm. The ratio shifts:

| Element | Mobile (360px) | Desktop (1280px) | Ratio |
|---|---|---|---|
| Body | 16px | 18px | 1.13× |
| H3 | 18px | 24px | 1.33× |
| H2 | 24px | 40px | 1.67× |
| H1 | 32px | 64px | 2.0× |

Bigger steps on bigger screens. Mobile body should never go below 16px (legibility + iOS auto-zoom).

### Line height

| Element | Mobile | Why |
|---|---|---|
| Body | 1.5 - 1.6 | Easier vertical scan, more breathing room than desktop's 1.4 |
| Headline | 1.05 - 1.15 | Tight headlines feel premium; long mobile lines need slightly more room than desktop |

Tailwind: `leading-relaxed` (1.625) for body, `leading-[1.05]` for h1.

---

## 4. Forms on Mobile

Forms are where mobile UX collapses fastest. Each input gets four pieces of metadata.

### `inputMode` — the soft keyboard

`inputMode` chooses which on-screen keyboard appears. Use it on every input, even when `type` already implies a keyboard (browsers honor it more reliably).

| Field | `inputMode` | `type` | `autoComplete` |
|---|---|---|---|
| Email | `email` | `email` | `email` |
| Phone | `tel` | `tel` | `tel` |
| One-time code (SMS) | `numeric` | `text` | `one-time-code` |
| Postal code (AR/MX) | `numeric` | `text` | `postal-code` |
| CBU / CVU (AR) | `numeric` | `text` | `off` |
| Credit card number | `numeric` | `text` | `cc-number` |
| Credit card expiry | `numeric` | `text` | `cc-exp` |
| CVC | `numeric` | `text` | `cc-csc` |
| Name on card | `text` | `text` | `cc-name` |
| Search | `search` | `search` | `off` |
| URL | `url` | `url` | `url` |
| Decimal (price, weight) | `decimal` | `text` | `off` |
| Plain text | `text` (default) | `text` | varies |

```tsx
// ✅ Phone — Argentine mobile
<input
  type="tel"
  inputMode="tel"
  autoComplete="tel"
  placeholder="+54 11 4823-1947"
  className="text-base min-h-[44px] w-full rounded-md border px-3"
/>

// ✅ One-time code from SMS
<input
  type="text"
  inputMode="numeric"
  autoComplete="one-time-code"
  pattern="[0-9]{6}"
  maxLength={6}
  className="text-base min-h-[44px] w-full"
/>

// ✅ Email
<input
  type="email"
  inputMode="email"
  autoComplete="email"
  className="text-base min-h-[44px] w-full"
/>
```

### `font-size: 16px` minimum on inputs (iOS Auto-Zoom)

iOS Safari zooms into any input with `font-size < 16px` on focus. The page is now horizontally scrolled. The user is angry.

```tsx
// ❌ BAD — iOS zooms on focus
<input className="text-sm px-3 py-2" />

// ✅ GOOD
<input className="text-base px-3 py-3" />
```

Tailwind `text-base` = 16px exactly. Anything `text-sm` (14px) on inputs triggers the zoom.

This applies to `<input>`, `<textarea>`, and `<select>`.

### Viewport meta — say it once, say it right

```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1, viewport-fit=cover"
/>
```

- `viewport-fit=cover` — required for `env(safe-area-inset-*)` to work on iPhone notch / home-indicator devices
- **Never** `user-scalable=no` or `maximum-scale=1` — these break accessibility (low-vision users need to zoom)

In Next.js (App Router):

```tsx
// app/layout.tsx
export const viewport = {
  width: 'device-width',
  initialScale: 1,
  viewportFit: 'cover',
};
```

### Field label and error placement

```tsx
<div>
  <label htmlFor="email" className="text-sm font-medium block mb-1">
    Email
  </label>
  <input
    id="email"
    type="email"
    inputMode="email"
    autoComplete="email"
    aria-invalid={hasError}
    aria-describedby={hasError ? 'email-error' : undefined}
    className="text-base min-h-[44px] w-full rounded-md border px-3"
  />
  {hasError && (
    <p id="email-error" role="alert" className="text-sm text-destructive mt-1">
      Ingresá un email válido (ejemplo: camila@empresa.com.ar)
    </p>
  )}
</div>
```

**Label above input**, not floating, not placeholder-as-label (placeholders disappear on input and break recall).

---

## 5. Safe Area Insets

iPhone notch (top), home indicator (bottom), and the dynamic island all need padding to keep content out of unsafe zones.

### CSS environment variables

```css
/* Bottom tab bar / sticky CTA */
.bottom-bar {
  padding-bottom: max(1rem, env(safe-area-inset-bottom));
}

/* Top header below dynamic island */
.top-bar {
  padding-top: max(0.5rem, env(safe-area-inset-top));
}

/* Modal sheet that goes edge-to-edge */
.full-sheet {
  padding-top: env(safe-area-inset-top);
  padding-bottom: env(safe-area-inset-bottom);
}
```

`max(fallback, env(...))` ensures non-iOS devices get at least the fallback padding.

### Tailwind v4 with arbitrary values

```tsx
<nav className="fixed bottom-0 inset-x-0 pb-[max(1rem,env(safe-area-inset-bottom))]">
```

Or define utilities in `tailwind.config`:

```js
// theme.extend.padding
'safe-bottom': 'max(1rem, env(safe-area-inset-bottom))',
'safe-top': 'max(0.5rem, env(safe-area-inset-top))',
```

Then `<nav className="fixed bottom-0 inset-x-0 pb-safe-bottom">`.

### Required for `viewport-fit=cover`

Without `viewport-fit=cover` in the viewport meta, `env(safe-area-inset-*)` returns 0 on iOS. Both pieces are required together.

---

## 6. Image Strategy

Mobile bandwidth + small viewports + retina displays = images need real care.

### Responsive `<picture>` for art direction

When the mobile crop differs from desktop (square hero on mobile, wide on desktop):

```tsx
<picture>
  <source media="(min-width: 1024px)" srcSet="/hero-wide.avif" type="image/avif" />
  <source media="(min-width: 1024px)" srcSet="/hero-wide.webp" type="image/webp" />
  <source srcSet="/hero-square.avif" type="image/avif" />
  <source srcSet="/hero-square.webp" type="image/webp" />
  <img src="/hero-square.jpg" alt="Café Tortoni en Avenida de Mayo" width={1080} height={1080} />
</picture>
```

### `srcset` + `sizes` for resolution switching

When the same crop just needs different resolutions:

```tsx
<img
  src="/product-800.jpg"
  srcSet="/product-400.jpg 400w, /product-800.jpg 800w, /product-1600.jpg 1600w"
  sizes="(min-width: 1024px) 800px, 100vw"
  alt="Tomás Arias preparando café de especialidad"
  width={800}
  height={600}
  loading="lazy"
  className="w-full h-auto"
/>
```

The `sizes` attribute tells the browser the rendered size at each breakpoint, so it picks the right `srcset` candidate.

### Format chain (best to worst)

1. **AVIF** — best compression, ~50% smaller than JPG, 95%+ browser support in 2026
2. **WebP** — 30% smaller than JPG, 99%+ support
3. **JPG / PNG** — universal fallback

### Next.js Image component

`next/image` does most of this automatically with the `sizes` prop:

```tsx
import Image from 'next/image';

<Image
  src="/product.jpg"
  alt="Sofía Bianchi presentando la nueva colección"
  width={800}
  height={600}
  sizes="(min-width: 1024px) 800px, 100vw"
  priority={isAboveFold}
/>;
```

Always: `width` + `height` (CLS), `alt` describing the image content, `sizes` matching layout, `priority` only for above-fold hero images.

---

## 7. Quick Reference Card

| Concern | Rule |
|---|---|
| Primary action position | Bottom third of screen |
| Touch target | ≥ 44 × 44 CSS px |
| Tap target spacing | ≥ 8 px |
| Body text | ≥ 16 px (`text-base`) |
| Input font-size | ≥ 16 px (iOS auto-zoom prevention) |
| Line height (body) | 1.5 - 1.6 |
| Headline tracking | -0.02em to -0.025em |
| Type scale | `clamp(min, preferred, max)` — not breakpoint steps |
| Viewport meta | `width=device-width, initial-scale=1, viewport-fit=cover` |
| Forbidden viewport | `user-scalable=no`, `maximum-scale=1` |
| Full-height | `100dvh`, never `100vh` |
| Safe area bottom | `pb-[max(1rem,env(safe-area-inset-bottom))]` |
| Image format chain | AVIF → WebP → JPG |
| Images: dims | Always `width` + `height` (or `aspect-ratio`) |
| `<input>` keyboard | `inputMode` always set, even with `type` |
| `<input>` autofill | `autoComplete` always set (or `off`) |
