# CLS Zero — Layout Stability Reference

Cumulative Layout Shift (CLS) target: **< 0.05** (Core Web Vitals "Good" is 0.1; we aim better).

Every BAD pattern below has a measurable CLS impact. Every GOOD pattern reserves space before content arrives.

---

## 1. Images: explicit dimensions or `aspect-ratio`

```tsx
// ❌ BAD — image jumps in when it loads, pushing everything below
<img src="/hero.jpg" alt="Hero" className="w-full" />

// ✅ GOOD — Next.js Image with explicit dims
import Image from 'next/image';
<Image src="/hero.jpg" alt="Hero" width={1200} height={630} className="w-full h-auto" />

// ✅ GOOD — plain img with aspect-ratio
<img
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={630}
  className="w-full aspect-[1200/630] object-cover"
/>

// ✅ GOOD — fill mode requires sized parent
<div className="relative aspect-[16/9]">
  <Image src="/hero.jpg" alt="Hero" fill className="object-cover" />
</div>
```

Rule: **never** `<img>` without `width`/`height` OR a parent with `aspect-ratio`.

---

## 2. Web fonts: `font-display: swap` + `size-adjust` fallback + preload

```css
/* ❌ BAD — FOIT (invisible text) until font loads, then big shift */
@font-face {
  font-family: 'Geist';
  src: url('/fonts/geist.woff2') format('woff2');
}

/* ✅ GOOD — swap to fallback immediately, fallback sized to match Geist's metrics */
@font-face {
  font-family: 'Geist';
  src: url('/fonts/geist.woff2') format('woff2');
  font-display: swap;
}

@font-face {
  font-family: 'Geist Fallback';
  src: local('Arial');
  size-adjust: 99%;        /* tweak until char widths match the real font */
  ascent-override: 92%;
  descent-override: 24%;
  line-gap-override: 0%;
}

body {
  font-family: 'Geist', 'Geist Fallback', system-ui, sans-serif;
}
```

Generate `size-adjust` values with [Fontaine](https://github.com/unjs/fontaine) or [Fontpie](https://github.com/pixel-point/fontpie).

```html
<!-- Preload primary font for first paint -->
<link rel="preload" href="/fonts/geist.woff2" as="font" type="font/woff2" crossorigin />
```

Next.js `next/font` does most of this automatically:
```tsx
import { Geist } from 'next/font/google';
const geist = Geist({ subsets: ['latin'], display: 'swap' });
```

---

## 3. Iframes / videos / embeds: wrap in aspect-ratio container

```tsx
// ❌ BAD — iframe loads with default height, then YouTube resizes it → CLS
<iframe src="https://www.youtube.com/embed/abc" />

// ✅ GOOD — fixed aspect-ratio wrapper
<div className="relative aspect-video w-full">
  <iframe
    src="https://www.youtube.com/embed/abc"
    className="absolute inset-0 size-full"
    allowFullScreen
  />
</div>

// ✅ GOOD — video element
<video
  src="/promo.mp4"
  className="w-full aspect-video"
  width={1920}
  height={1080}
  poster="/promo-poster.jpg"
  autoPlay muted loop playsInline
/>
```

---

## 4. Skeletons: match real content dimensions exactly

```tsx
// ❌ BAD — skeleton is 60px tall, real card is 180px tall. 120px shift on load.
function Skeleton() { return <div className="h-15 bg-muted animate-pulse rounded" />; }

// ✅ GOOD — skeleton matches the real Card's structure and height
function CardSkeleton() {
  return (
    <div className="rounded-xl border border-border p-6 space-y-3">
      <div className="h-5 w-1/3 bg-muted animate-pulse rounded" />     {/* title row */}
      <div className="h-4 w-full bg-muted animate-pulse rounded" />    {/* line 1 */}
      <div className="h-4 w-3/4 bg-muted animate-pulse rounded" />     {/* line 2 */}
      <div className="h-9 w-24 bg-muted animate-pulse rounded mt-4" /> {/* CTA button */}
    </div>
  );
}
```

If the real card has `padding: 24px` and a 36px CTA at the bottom, the skeleton must too. Total height of skeleton ≈ total height of loaded card.

---

## 5. Accordion / expand-collapse: never `height: auto`

```tsx
// ❌ BAD — animating height: auto doesn't work, height: 0 → height: auto can't transition
<div className="transition-all duration-300" style={{ height: open ? 'auto' : 0 }}>
  ...
</div>

// ✅ GOOD — grid trick: 0fr → 1fr animates the row's content
<div
  className="grid transition-[grid-template-rows] duration-300 ease-out"
  style={{ gridTemplateRows: open ? '1fr' : '0fr' }}
>
  <div className="overflow-hidden">{children}</div>
</div>

// ✅ GOOD — Base UI / Radix Accordion handle this internally
import { Accordion } from '@base-ui-components/react/accordion';
<Accordion.Root>
  <Accordion.Item value="1">
    <Accordion.Trigger>Toggle</Accordion.Trigger>
    <Accordion.Panel>Content</Accordion.Panel>
  </Accordion.Item>
</Accordion.Root>
```

---

## 6. Banners / cookie notices / toasts: overlay, never insert in flow

```tsx
// ❌ BAD — pushes the entire page down 80px when it appears
<>
  <CookieBanner />  {/* normal flow, 80px tall */}
  <Header />
  <main>...</main>
</>

// ✅ GOOD — fixed bottom overlay, doesn't affect document flow
<>
  <Header />
  <main>...</main>
  <CookieBanner className="fixed bottom-0 inset-x-0 z-50 border-t" />
</>

// ✅ GOOD — Toasts: portal to a fixed region, never inline
import { Toaster } from 'sonner';
<Toaster position="bottom-right" />
```

---

## 7. Lazy-loaded sections: reserve `min-height`

```tsx
// ❌ BAD — section appears with content, pushing footer down
<LazySection />

// ✅ GOOD — reserve approximate height while loading
<div className="min-h-[400px]">
  <Suspense fallback={<SectionSkeleton />}>
    <LazySection />
  </Suspense>
</div>
```

---

## 8. Dynamic content (ads, recommendations) — fixed slot

```tsx
// ❌ BAD — ad slot has no dimensions, layout shifts when ad arrives
<div id="ad-slot" />

// ✅ GOOD — reserve the exact slot dimensions for that breakpoint
<div id="ad-slot" className="w-full h-[250px] md:h-[300px] lg:h-[600px] bg-muted/30">
  {/* ad injects here, layout already accounts for it */}
</div>
```

---

## 9. Scroll restoration & autofocus

```tsx
// ❌ BAD — autoFocus on mount scrolls page on mobile
<input autoFocus />

// ✅ GOOD — focus only after layout settles, OR preserve scroll
useEffect(() => {
  const ref = inputRef.current;
  if (ref) ref.focus({ preventScroll: true });
}, []);
```

---

## 10. Measurement & enforcement

### In dev
- Chrome DevTools → **Lighthouse** → measure CLS
- Chrome DevTools → **Performance** → record → "Layout shifts" track
- [Web Vitals extension](https://chromewebstore.google.com/detail/web-vitals/ahfhijdlegdabablpippeagghigmibma) — live CLS in any tab

### In prod
- `web-vitals` package → send `onCLS` to your analytics
- Real User Monitoring (RUM) — Vercel Analytics, Datadog RUM, Sentry, SpeedCurve

```ts
import { onCLS } from 'web-vitals';
onCLS((metric) => {
  navigator.sendBeacon('/analytics/web-vitals', JSON.stringify(metric));
});
```

### Hard rule
If CLS > 0.05 in dev, fix it before merging. The list of likely sources is short — start at the top of this file.

---

## CLS source checklist (run mentally on every UI change)

- [ ] Every `<img>` / `<Image>` has `width`+`height` OR aspect-ratio
- [ ] Every iframe / embed wrapped in aspect-ratio container
- [ ] Web fonts use `font-display: swap` + size-adjust fallback + preload
- [ ] Skeletons match real content dimensions (NOT shorter, NOT taller)
- [ ] Accordions/expand use `grid-template-rows: 0fr → 1fr`
- [ ] Banners / toasts / modals are layered (`fixed`/`absolute`), never inline
- [ ] Lazy sections reserve `min-height`
- [ ] No `autoFocus` triggering scroll on mobile
- [ ] Measured: Lighthouse CLS < 0.05 (NOT < 0.1)
