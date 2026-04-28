# Anti-Patterns Guide

What NOT to do when creating premium interfaces. These patterns scream "AI-generated" and destroy the luxury aesthetic.

---

## The "v0 Signature" (Most Common Offense)

### ❌ Purple-to-Blue Gradient on White
```css
/* NEVER DO THIS */
.card {
  background: white;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.button {
  background: linear-gradient(to right, #8b5cf6, #3b82f6);
}
```

This combination appears in 90% of AI-generated UIs. It's instantly recognizable.

### ✅ Instead
```css
/* Dark base with intentional accent */
.card {
  background: rgba(255,255,255,0.03);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255,255,255,0.1);
}

.button {
  background: #fff;
  color: #000;
}
```

---

## Typography Anti-Patterns

### ❌ Inter Everywhere Without Customization
```css
/* GENERIC */
font-family: 'Inter', sans-serif;
font-size: 16px;
```

Inter is overused and looks "default" without heavy customization.

### ✅ Instead
```css
/* Distinctive pairing */
font-family: 'Plus Jakarta Sans', sans-serif;
/* Or serif for display */
font-family: 'Instrument Serif', serif;
```

### ❌ No Letter-Spacing on Headlines
```css
/* FLAT */
h1 {
  font-size: 48px;
  font-weight: 700;
  /* Missing tracking! */
}
```

### ✅ Instead
```css
/* POLISHED */
h1 {
  font-size: clamp(48px, 6vw, 72px);
  font-weight: 600;
  letter-spacing: -0.03em;
  line-height: 1.1;
}
```

### ❌ Uniform Line Height
```css
/* LAZY */
* { line-height: 1.5; }
```

### ✅ Instead
```css
/* INTENTIONAL */
h1, h2 { line-height: 1.1; }
h3, h4 { line-height: 1.3; }
p { line-height: 1.7; }
```

---

## Layout Anti-Patterns

### ❌ Everything Centered with Equal Spacing
```html
<!-- BORING -->
<div class="text-center">
  <h1>Title</h1>
  <p>Subtitle</p>
  <button>CTA</button>
</div>

<div class="grid grid-cols-3 gap-8">
  <Card />
  <Card />
  <Card />
</div>
```

This is the default AI layout: centered hero → equal grid → repeat.

### ✅ Instead
```html
<!-- DYNAMIC -->
<div class="max-w-4xl ml-[15%]"> <!-- Asymmetric -->
  <span class="text-xs uppercase tracking-widest">Label</span>
  <h1 class="text-7xl tracking-tight">Title</h1>
  <p class="text-xl text-white/60 max-w-xl mt-6">Subtitle</p>
</div>

<!-- Varying grid -->
<div class="grid grid-cols-12 gap-6">
  <div class="col-span-7"><LargeCard /></div>
  <div class="col-span-5 space-y-6">
    <SmallCard />
    <SmallCard />
  </div>
</div>
```

### ❌ Cramped Padding
```css
/* SUFFOCATING */
.card { padding: 16px; }
.section { padding: 40px 0; }
```

### ✅ Instead
```css
/* BREATHING */
.card { padding: 32px; } /* or more */
.section { padding: 120px 0; } /* generous */
```

---

## Color Anti-Patterns

### ❌ Gray Borders on White Cards
```css
/* FLAT */
.card {
  background: white;
  border: 1px solid #e5e5e5;
  border-radius: 8px;
}
```

This looks like a form element, not a design element.

### ✅ Instead
```css
/* DEPTH */
.card {
  background: rgba(255,255,255,0.02);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 20px;
  backdrop-filter: blur(20px);
}
```

### ❌ Pure Black Background
```css
/* HARSH */
background: #000;
```

### ✅ Instead
```css
/* RICH */
background: #0a0a0a; /* Or even better with tint */
background: #09090b; /* Slight blue-black */
background: #0c0a09; /* Warm black */
```

### ❌ Too Many Colors
```css
/* CHAOTIC */
.primary { color: #8b5cf6; }
.secondary { color: #3b82f6; }
.accent { color: #10b981; }
.highlight { color: #f59e0b; }
.cta { color: #ef4444; }
```

### ✅ Instead
```css
/* COHESIVE */
--accent: #7c3aed;
--text-primary: rgba(255,255,255,0.95);
--text-secondary: rgba(255,255,255,0.60);
--text-muted: rgba(255,255,255,0.40);
/* That's it. Maybe ONE more accent for special cases */
```

---

## Component Anti-Patterns

### ❌ Icon Grids with Descriptions
```html
<!-- SCREAMS AI -->
<div class="grid grid-cols-3 gap-8 text-center">
  <div>
    <Icon />
    <h3>Feature One</h3>
    <p>Description of feature one that explains what it does.</p>
  </div>
  <div>
    <Icon />
    <h3>Feature Two</h3>
    <p>Description of feature two that explains what it does.</p>
  </div>
  <!-- ... -->
</div>
```

This is the most cliché AI layout.

### ✅ Instead
```html
<!-- EDITORIAL -->
<div class="grid grid-cols-2 gap-16">
  <div>
    <h2 class="text-5xl tracking-tight mb-8">
      What makes us different
    </h2>
    <p class="text-xl text-white/60 leading-relaxed">
      Long-form paragraph that actually says something meaningful
      without bullet points or icons.
    </p>
  </div>
  <div class="space-y-12">
    <div>
      <span class="text-violet-400 text-sm font-medium">01</span>
      <h3 class="text-2xl mt-2">Feature Title</h3>
    </div>
    <!-- Numbered, not iconed -->
  </div>
</div>
```

### ❌ Uniform Border Radius
```css
/* REPETITIVE */
.card { border-radius: 8px; }
.button { border-radius: 8px; }
.input { border-radius: 8px; }
.avatar { border-radius: 8px; }
```

### ✅ Instead
```css
/* HIERARCHY */
.card { border-radius: 24px; }      /* Large, prominent */
.button { border-radius: 12px; }    /* Medium */
.input { border-radius: 8px; }      /* Functional */
.avatar { border-radius: 50%; }     /* Circle */
.tag { border-radius: 9999px; }     /* Pill */
```

### ❌ Default Shadows
```css
/* GENERIC */
box-shadow: 0 4px 6px rgba(0,0,0,0.1);
```

### ✅ Instead
```css
/* RICH */
box-shadow: 
  0 0 0 1px rgba(255,255,255,0.05),
  0 25px 50px -12px rgba(0,0,0,0.5),
  0 0 100px -20px rgba(124,58,237,0.3); /* Colored glow */
```

---

## Animation Anti-Patterns

### ❌ Linear Easing
```css
/* ROBOTIC */
transition: all 0.3s linear;
```

### ✅ Instead
```css
/* NATURAL */
transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
```

### ❌ Too Fast or Too Slow
```css
/* JARRING */
transition-duration: 0.1s; /* Too fast */
transition-duration: 1s;   /* Too slow for hover */
```

### ✅ Instead
```css
/* BALANCED */
transition-duration: 0.2s; /* Micro-interactions */
transition-duration: 0.3s; /* Standard hover */
transition-duration: 0.5s; /* Entrance animations */
```

### ❌ Everything Animates the Same
```css
/* MONOTONOUS */
.card:hover { transform: scale(1.05); }
.button:hover { transform: scale(1.05); }
.link:hover { transform: scale(1.05); }
```

### ✅ Instead
```css
/* VARIED */
.card:hover { transform: translateY(-4px); }
.button:hover { filter: brightness(1.1); }
.link:hover { /* underline animation */ }
```

---

## Content Anti-Patterns

### ❌ Generic Placeholder Text
```html
<!-- LAZY -->
<h1>Build something amazing</h1>
<p>We help businesses grow with our innovative solutions.</p>
<button>Get Started</button>
```

This is corporate buzzword soup.

### ✅ Instead
```html
<!-- SPECIFIC -->
<h1>Ship code 10x faster</h1>
<p>AI-powered code review catches bugs before they reach production.</p>
<button>Start free trial</button>
```

### ❌ Stock Illustrations
Using Undraw, Humaaans, or similar generic illustration libraries.

### ✅ Instead
- Custom 3D renders
- Abstract gradient shapes
- High-quality photography
- Bespoke illustrations
- Or just typography and whitespace

---

## The Ultimate Test

Before shipping any component, ask:

1. **Would Apple use this?** If not, why not?
2. **Could this appear on Framer's template showcase?**
3. **Does it look like it took 2 weeks or 2 minutes?**
4. **Would a designer at Linear approve this?**
5. **Is there anything generic about it?**

If you answer "no" to any of these, iterate until you can say "yes."

---

## Quick Reference: What to Avoid

| Category | Avoid | Do Instead |
|----------|-------|------------|
| Colors | Purple-blue gradient, pure black | Rich dark with subtle tints |
| Typography | Inter default, no tracking | Distinctive fonts, -0.02em+ tracking |
| Layout | Centered everything, equal grids | Asymmetry, varied spacing |
| Borders | Gray on white, 8px everywhere | Glass borders, varied radii |
| Shadows | Default shadows | Large blur, colored glows |
| Animation | Linear, uniform | Custom easing, varied effects |
| Content | Icon grids, buzzwords | Editorial, specific copy |
| Effects | None or overdone | Subtle glass, noise, gradients |

---

## The "AI Slop" Checklist

If your design has 3+ of these, it's AI slop:

- [ ] Purple-to-blue gradient
- [ ] Inter font without customization
- [ ] Gray borders on white backgrounds
- [ ] 8px border-radius everywhere
- [ ] Icon + title + description grid
- [ ] Everything perfectly centered
- [ ] "Get Started" or "Learn More" buttons
- [ ] Default shadows
- [ ] No noise or texture
- [ ] Linear animations
- [ ] Generic stock illustrations
- [ ] Icons in every nav item / card / list item / button (Icon Soup)
- [ ] Mixed icon libraries (Lucide + Phosphor + Heroicons in one project)
- [ ] Mobile is "responsive later" (no content priority, hover-only interactions, < 44px tap targets)
- [ ] CLS > 0.05 on first load (images without dims, font swap reflow, banner-in-flow)

**Zero tolerance policy: If something looks like AI made it, redo it.**

---

## Icon Soup (named AI Tell)

The single most common "AI dashboard" tell. Every list item gets an icon, every nav has an icon, every card has an icon, every button has an icon, every form field has a leading icon AND a trailing icon. Six icons in six brand colors at the top of the page.

### ❌ Icon Soup — what it looks like

```tsx
<aside className="flex flex-col gap-1 p-4">
  <NavItem icon={Home}>Home</NavItem>
  <NavItem icon={Users}>Customers</NavItem>
  <NavItem icon={Package}>Products</NavItem>
  <NavItem icon={ShoppingCart}>Orders</NavItem>
  <NavItem icon={DollarSign}>Revenue</NavItem>
  <NavItem icon={BarChart}>Analytics</NavItem>
  <NavItem icon={Calendar}>Schedule</NavItem>
  <NavItem icon={Mail}>Inbox</NavItem>
  <NavItem icon={Settings}>Settings</NavItem>
  <NavItem icon={LifeBuoy}>Help</NavItem>
</aside>

<section className="grid grid-cols-3 gap-6">
  <Card icon={<Zap className="text-yellow-400" />} title="Fast" desc="..." />
  <Card icon={<Shield className="text-blue-400" />} title="Secure" desc="..." />
  <Card icon={<Heart className="text-pink-400" />} title="Loved" desc="..." />
</section>
```

This screams "AI dashboard". Sticker-sheet syndrome. Cut by 50%.

### ✅ Editorial alternative — typography over icons

```tsx
<aside className="flex flex-col gap-8 p-6">
  <Group label="Operate">
    <NavItem>Customers</NavItem>
    <NavItem>Products</NavItem>
    <NavItem>Orders</NavItem>
  </Group>
  <Group label="Analyze">
    <NavItem>Revenue</NavItem>
    <NavItem>Analytics</NavItem>
  </Group>
  <Group label="Account">
    <NavItem>Settings</NavItem>
    <NavItem icon={LogOut}>Sign out</NavItem>  {/* destructive earns icon */}
  </Group>
</aside>

<section className="grid grid-cols-2 gap-16">
  <article>
    <span className="text-xs uppercase tracking-widest text-muted-foreground">01</span>
    <h3 className="text-2xl mt-2">Fast</h3>
    <p className="text-foreground/70 mt-3 leading-relaxed">...</p>
  </article>
  <article>
    <span className="text-xs uppercase tracking-widest text-muted-foreground">02</span>
    <h3 className="text-2xl mt-2">Secure</h3>
    <p className="text-foreground/70 mt-3 leading-relaxed">...</p>
  </article>
</section>
```

### Icon Budget (cite from `frontend-foundation/references/icon-budget.md`)

| Region | Max | Notes |
|---|---|---|
| Top nav | 5 | Logo + 3 nav + user. |
| Hero | 1 | Usually zero. |
| Card | 2 | Usually 1. |
| Button | 1 | Icon OR icon+text. Never icon+text+icon. |
| Form field | 1 | Leading OR trailing. Not both. |
| Footer social | 3 | Brand marks only. |

**Hard rules:**
- One icon library per project (`lucide-react` OR `@phosphor-icons/react` OR `@radix-ui/react-icons`). Never mix.
- One stroke weight globally.
- Color via `currentColor` (status colors are the only exception).
- Decorative icons: `aria-hidden`. Functional icons: `aria-label` or visible text.

### The "delete every icon" test

Mentally remove every icon from the design. Does the UI still work? Then most of those icons were decorative duplication. Keep only the ones that fail the test (icon-only buttons, status indicators, brand marks).

---

## Mobile Afterthought (named AI Tell)

The "we'll do mobile later" pattern. Mobile becomes shrunk desktop, not a designed mobile experience.

### ❌ Mobile Afterthought — symptoms

- Sidebar that shrinks to a thin column on mobile (instead of becoming a bottom tab bar or drawer)
- Multi-column grid that stacks but keeps oversized desktop spacing
- Modal dialogs that don't use safe-area insets
- Hover-only menus (invisible on touch)
- Tap targets < 44px ("the icon is small but the click area is fine") — no it's not
- Body text < 16px (iOS auto-zooms on focus)
- `100vh` on hero (iOS Safari address bar makes it overflow)
- Forms with wrong `inputMode` (number field but text keyboard)

### ✅ Mobile-first done right

- Content priority worksheet written BEFORE layout (see `frontend-foundation/references/mobile-first.md`)
- 360px is the design starting point, not 1440px
- Sidebar → bottom tab bar (3-5 items) OR off-canvas drawer
- Dropdowns / dialogs → bottom sheets (Vaul or Base UI Drawer)
- Touch targets ≥ 44×44 CSS px, 8px apart
- Body text ≥ 16px (`text-base`)
- `min-h-[100dvh]` for full-height
- Safe-area insets on fixed top/bottom bars
- Forms use proper `inputMode` + `autoComplete`
- Hover states have a touch equivalent (persistent active state, not hover-only)

### The "premium on a 360px iPhone" test

Open the site on an iPhone SE 1st gen viewport (320×568) or iPhone 12 mini (360×780). Does it still feel premium? If it feels like a stripped-down version of the desktop site, it's not mobile-designed.

---

## Layout Shift Sloppy (named AI Tell)

CLS > 0.05 — the page jumps as it loads. Apple, Stripe, Linear do not jump. Neither should you.

### ❌ Layout Shift Sloppy — symptoms

```tsx
// Image without dims → jumps in
<img src="/hero.jpg" alt="Hero" />

// Web font swap → text reflows when font loads
@font-face { font-family: 'Geist'; src: url(/geist.woff2); }

// Banner pushed into normal flow → entire page shifts down
<>
  <CookieBanner />
  <Header />
  <main>...</main>
</>

// Accordion animating height: auto → broken animation + CLS
<div style={{ height: open ? 'auto' : 0 }}>...</div>

// Skeleton 60px tall, real card 180px tall → 120px shift
```

### ✅ Layout Shift Sloppy — fix

Refer to `frontend-foundation/references/cls-zero.md` for full BAD/GOOD pairs. Quick rules:

- Every image: `width`+`height` or `aspect-ratio`
- Web fonts: `font-display: swap` + `size-adjust` fallback + `<link rel="preload">`
- Banners / toasts: layered (`fixed`/`absolute`), never inline
- Accordion: `grid-template-rows: 0fr → 1fr`, never `height: auto`
- Skeletons: match real content dimensions exactly

### Target: CLS < 0.05

Measure in dev (Lighthouse), monitor in prod (`web-vitals` package). If CLS > 0.05 on a route, fix before ship.
