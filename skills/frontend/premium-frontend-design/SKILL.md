---
name: premium-frontend-design
description: Create luxury, Apple/Framer-quality frontend interfaces with liquid glass effects, mesh gradients, aurora backgrounds, and sophisticated micro-interactions. Use when building premium UI components, landing pages, dashboards, or any React/Next.js interface requiring high-end visual polish. Avoids generic AI aesthetics (v0-style), emphasizing editorial quality, intentional whitespace, and museum-grade craftsmanship. Invoke AFTER frontend-foundation (which owns tokens, theme, spacing, component system).
---

# Premium Frontend Design

Create interfaces that feel like Apple keynote or Framer showcase quality.

## Design Philosophy: "Quiet Luxury"

**Restrained opulence** — expensive-looking without being loud.
Inspirations: Apple (breathing room, subtle depth), Linear (dark elegance), Vercel (clean gradients, confident whitespace).

**NOT**: v0 defaults, uncustomized shadcn, generic purple gradients, icon-heavy UIs, cramped layouts.

---

## 1. Parameter Dials (tune output to the project)

Set these 3 dials at the start. They drive every decision below. Defaults shown; the user can override in chat ("set MOTION_INTENSITY to 9").

```
DESIGN_VARIANCE  = 8   (1 = perfect symmetry, 10 = artsy chaos)
MOTION_INTENSITY = 6   (1 = static, 10 = cinematic magic physics)
VISUAL_DENSITY   = 4   (1 = art gallery airy, 10 = pilot cockpit packed)
```

### DESIGN_VARIANCE

| Range | Behavior |
|---|---|
| 1-3 (Predictable) | `justify-center`, strict 12-col symmetrical grids, equal paddings |
| 4-7 (Offset) | `margin-top: -2rem` overlaps, varied aspect ratios (4:3 next to 16:9), left-aligned headers over centered data |
| 8-10 (Asymmetric) | Masonry, `grid-template-columns: 2fr 1fr 1fr`, massive empty zones (`padding-left: 20vw`) |

**Mobile override:** Levels 4-10 MUST collapse to strict single-column (`w-full px-4 py-8`) below `md:` to prevent horizontal scroll.

### MOTION_INTENSITY

| Range | Behavior |
|---|---|
| 1-3 (Static) | No auto-animations. CSS `:hover` / `:active` only. |
| 4-7 (Fluid CSS) | `transition: all .3s cubic-bezier(0.16, 1, 0.3, 1)`, animation-delay cascades, strictly `transform` + `opacity` |
| 8-10 (Choreographed) | Scroll-triggered reveals, parallax, Framer hooks. **Never** `window.addEventListener('scroll')` — use Framer's scroll hooks. |

### VISUAL_DENSITY

| Range | Behavior |
|---|---|
| 1-3 (Art Gallery) | Massive whitespace, huge section gaps, expensive feel |
| 4-7 (Daily App) | Normal SaaS spacing |
| 8-10 (Cockpit) | Tiny paddings, no cards — `border-t` / `divide-y` instead. Mandatory `font-mono` for numbers. |

---

## 2. Design Engineering (bias correction)

LLMs have strong statistical biases toward generic UI clichés. These rules exist specifically to counter them.

### Typography
- **Headlines default:** `text-4xl md:text-6xl tracking-tighter leading-none`
- **Body default:** `text-base text-foreground/70 leading-relaxed max-w-[65ch]`
- **Font choice:** prefer `Geist`, `Outfit`, `Cabinet Grotesk`, `Satoshi` over Inter
- **Dashboard/SaaS UI:** Sans only. Pairings: `Geist + Geist Mono`, `Satoshi + JetBrains Mono`. **Serif is BANNED on dashboards.**
- **No oversized H1s.** Control hierarchy with weight + color, not only scale.

### Color Calibration
- **Max 1 accent.** Saturation < 80%.
- Absolute neutral bases (Zinc/Slate) + single high-contrast accent (Emerald, Electric Blue, Deep Rose).
- One palette per project. Never fluctuate warm/cool grays in the same UI.
- **Never** pure `#000000` — use `#0a0a0a`, `zinc-950`, `#09090b`.

### Materiality (Anti-Card Overuse)
- **`VISUAL_DENSITY > 7`**: generic card containers BANNED. Group with `border-t`, `divide-y`, or pure negative space.
- Cards ONLY when elevation communicates hierarchy.
- Shadows: **tint to background hue**, never neutral black.

### Layout Diversification
- **`DESIGN_VARIANCE > 4`**: centered hero/H1 BANNED. Force split-screen 50/50, left-aligned text + right-aligned asset, or asymmetric whitespace.
- **3-column equal card grid BANNED.** Use 2-col zig-zag, asymmetric grid, or horizontal scroll instead.

### Interactive States (MANDATORY per component)
LLMs generate only "happy success" states. You must implement all four:
- **Loading** — skeletal loaders matching layout sizes. No generic circular spinners.
- **Empty** — beautifully composed empty state showing how to populate data.
- **Error** — inline, clear, next-step-oriented (no raw messages).
- **Tactile on `:active`** — `-translate-y-[1px]` or `scale-[0.98]` for physical push feedback.

---

## 3. AI Tells — Forbidden Patterns with Names

Memorable names so the patterns are easy to flag in review.

### THE LILA BAN
No "AI purple/blue" aesthetic. No purple button glows, no neon gradients. Pull accent from Emerald / Electric Blue / Deep Rose / Amber.

### THE JANE DOE EFFECT
No "John Doe", "Sarah Chan", "Jack Su" in demo content. Use creative, realistic-sounding names. No generic SVG "egg" avatars or Lucide user icons — use believable photo placeholders (`picsum.photos/seed/{random}/800/600`) or custom monogram avatars.

### ACME STARTUP SLOP
No "Acme", "Nexus", "SmartFlow", "FlowAI". Invent premium contextual brand names. No generic logos (circle with gradient) — use a wordmark or distinctive monogram.

### THE 99.99% PROBLEM
No predictable numbers: `99.99%`, `50%`, `1234567`. Use organic messy data: `47.2%`, `+1 (312) 847-1928`, `$12,847`, dates like `Apr 3, 2025`.

### FILLER WORD INDEX (copy)
Forbidden AI copywriting clichés:
- "Elevate", "Unleash", "Seamless", "Next-gen", "Revolutionize", "Game-changing"
- "Empowering", "Transform your workflow", "Unlock the power of"
- "Cutting-edge", "State-of-the-art", "Best-in-class"

Replace with concrete verbs and specific outcomes. "Ship faster" > "Accelerate your workflow".

### THE INTER TELL
Default `Inter` without heavy customization = instant AI tell. Pick a more distinctive sans (Geist, Satoshi, Cabinet Grotesk, Outfit) or pair Inter with a serif/display for contrast.

### PURE BLACK TELL
`#000000` + `#FFFFFF` is lazy. Use `zinc-950` / `#0a0a0a` on dark, `zinc-50` / `#fafafa` on light.

### GENERIC 3-CARD ROW
"Hero → 3 feature cards → CTA" is the AI default. Force variation: zig-zag layout, bento grid, horizontal scroll row, asymmetric 2-col.

### UNSPLASH LINK ROT
No raw Unsplash links (they break). Use `https://picsum.photos/seed/{string}/800/600` or UI-Avatars for avatars.

### GRADIENT TEXT HEADLINE
Gradient text on large headers = early-2020s AI look. Use solid color + subtle tracking/weight for emphasis.

### CUSTOM MOUSE CURSOR
Outdated, breaks accessibility, ruins mobile. Never generate these.

### ICON SOUP
Icons everywhere = visual noise, no information gain. The "AI dashboard" tell.

**The pattern**: every nav item has an icon, every card has an icon, every list item has an icon, every button has an icon, every form field has a leading icon AND a trailing icon. Six icons in a row in six brand colors.

**The fix**: enforce the icon budget from `frontend-foundation` (Pillar 6). One library only. Icons earn their place by adding information the label doesn't carry. If deleting an icon doesn't change the user's understanding, delete it.

**Hard limits per region:** nav ≤ 5, hero ≤ 1, card ≤ 2, button ≤ 1, form field ≤ 1, footer social ≤ 3. See `frontend-foundation/references/icon-budget.md`.

### MOBILE AFTERTHOUGHT
"Responsive later" = mobile becomes shrunk-desktop. Premium does not happen by accident on mobile — it happens by starting at 360px.

**The pattern**: design completed on a 1440px frame, then `md:` breakpoint variants pasted over. Touch targets too small. Hover-only interactions. Sidebar-shrunk-to-drawer instead of bottom-tab-bar. Modal dialog instead of bottom sheet. Multi-column grid stacked on top of itself.

**The fix**: content priority worksheet from `frontend-foundation` Pillar 4 + the mobile pattern swap table. See `frontend-foundation/references/mobile-first.md`.

### LAYOUT SHIFT SLOPPY
CLS > 0.05 = the page jumps as it loads. Premium products do not jump.

**The pattern**: images without dimensions, web fonts swapping mid-paint, banner inserted in normal flow pushing content down, accordion animating `height: auto`, skeleton dimensions don't match the loaded content.

**The fix**: every image gets `width`+`height` or `aspect-ratio`. Web fonts use `font-display: swap` + size-adjust fallback + preload. Banners are layered (`fixed`), never inline. Skeletons match real dimensions. See `frontend-foundation/references/cls-zero.md`.

---

## 4. Dependency Verification Mandate

**Before importing ANY third-party library**, grep `package.json`. If missing, output the install command BEFORE the code:

```bash
pnpm add framer-motion  # example when framer-motion is absent
```

Libraries that trigger this check: `framer-motion`, `gsap`, `three`, `@phosphor-icons/react`, `@radix-ui/*`, `@base-ui-components/react`, `class-variance-authority`, `clsx`, `tailwind-merge`, `next-themes`, `react-hook-form`, `zod`.

Never assume a library exists. Never invent imports.

---

## 5. Motion Rules

- **200-400ms** micro-interactions
- **600-800ms** reveals
- Default easing: `cubic-bezier(0.16, 1, 0.3, 1)` (out-expo) for reveals
- **Spring physics** on all interactive elements: `{ type: "spring", stiffness: 100, damping: 20 }`. No linear easing on interactive feedback.
- **Layout transitions:** Framer `layout` / `layoutId` for smooth reorder + shared-element transitions
- **Staggered orchestration:** `staggerChildren` in Framer or CSS `animation-delay: calc(var(--index) * 100ms)`. Parent variants + children must be in the same Client Component tree.

### Liquid Glass (beyond backdrop-blur)
```css
.liquid-glass {
  background: rgb(255 255 255 / 0.03);
  backdrop-filter: blur(24px);
  border: 1px solid rgb(255 255 255 / 0.08);
  box-shadow: inset 0 1px 0 rgb(255 255 255 / 0.1), 0 8px 30px rgb(0 0 0 / 0.35);
}
```

### Magnetic Buttons (if `MOTION_INTENSITY > 5`)
Never use `useState` for continuous hover animations — the re-render cost collapses mobile performance. Use Framer's `useMotionValue` + `useTransform`:

```tsx
const x = useMotionValue(0);
const y = useMotionValue(0);
const handleMove = (e: React.MouseEvent<HTMLButtonElement>) => {
  const rect = e.currentTarget.getBoundingClientRect();
  x.set((e.clientX - rect.left - rect.width / 2) * 0.2);
  y.set((e.clientY - rect.top - rect.height / 2) * 0.2);
};
```

---

## 6. Performance Guardrails

- Animate **only** `transform` and `opacity`. Never `top`, `left`, `width`, `height`.
- Grain/noise overlays: apply to `fixed inset-0 z-50 pointer-events-none` pseudo-element only — never on scrolling containers.
- `will-change: transform` sparingly (only on elements actively animating)
- No mixing GSAP + Framer in the same component tree. Framer for UI; GSAP/Three.js only for isolated scrolltelling / canvas backgrounds with strict `useEffect` cleanup.

---

## 7. Viewport Stability

- **Never** `h-screen` for hero sections — iOS Safari breaks layout catastrophically
- Always `min-h-[100dvh]` for full-height
- Never complex flex math (`w-[calc(33%-1rem)]`) — use CSS Grid (`grid grid-cols-1 md:grid-cols-3 gap-6`)

---

## 8. Shadcn Customization

`shadcn/ui` allowed, but **never** in default state. You must customize radii, colors, and shadows to match the project aesthetic. Own the `components/ui/` layer — shadcn is a starting point, not the destination.

---

## Tech Stack

React 18+ / Next.js 14+, Tailwind CSS, Framer Motion, TypeScript, variable fonts, icons from `@phosphor-icons/react` or `@radix-ui/react-icons` (never mix icon libraries).

---

## Anti-Patterns (consolidated forbidden list)

| Anti-pattern | Name |
|---|---|
| Purple-to-blue gradient accents | THE LILA BAN |
| `#000000` / `#ffffff` raw | Pure Black Tell |
| Inter with zero customization | The Inter Tell |
| "John Doe" / generic egg avatars | Jane Doe Effect |
| "Acme" / "Nexus" brand names | Acme Slop |
| `99.99%`, `50%`, `1234567` | 99.99% Problem |
| "Elevate / Unleash / Seamless" copy | Filler Word Index |
| 3-column equal feature cards | Generic 3-Card Row |
| Gradient text on headlines | Gradient Headline |
| Custom mouse cursor | Cursor Anti-pattern |
| Unsplash links | Unsplash Link Rot |
| `h-screen` on hero | iOS Safari Killer |
| Animating `width`/`height` | Layout Thrash |
| `useState` for magnetic hover | Mobile Collapse |
| `shadcn/ui` default state | Off-the-shelf Tell |
| Icons everywhere, no budget | Icon Soup |
| Mixed icon libraries | Icon Library Mix |
| Designed on desktop, mobile retrofitted | Mobile Afterthought |
| Touch targets < 44px | Tap Target Tell |
| CLS > 0.05 (page jumps on load) | Layout Shift Sloppy |
| `<img>` without dimensions | CLS Image Source |

**Test:** "Would a designer at Apple review this favorably?"

---

## Reference Files

Load as needed during implementation:
- `references/effects-library.md` — CSS/React code for glass, gradients, backgrounds, micro-interactions
- `references/typography-system.md` — Font loading, responsive scales, pairing rules
- `references/motion-patterns.md` — Framer Motion configs, CSS keyframes, easing
- `references/anti-patterns.md` — Visual examples of what to avoid

## Output Standards

- State the 3 dials at the start of any generation (confirmed or overridden)
- Be CONCISE — lead with code, minimize explanations
- Complete, runnable code (no placeholders)
- TypeScript + Tailwind with semantic tokens (consumed from `frontend-foundation`)
- Include responsive breakpoints
- Verify `package.json` before importing any library
- Implement ALL interactive states (loading / empty / error / active)
