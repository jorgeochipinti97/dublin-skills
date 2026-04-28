# Icon Budget — Reference

Icons are decoration. Decoration earns its place. Count icons before shipping.

---

## 1. Budget table (hard limits per region)

| Region | Max | Notes |
|---|---|---|
| Top nav / header | **5** | Logo + 3 nav + user/avatar. Beyond 5 = noise. |
| Bottom tab bar (mobile) | **5** | Apple HIG limit. Beyond 5 → "More" tab. |
| Hero section | **1** | Usually zero. The headline does the work. |
| Section header (above an h2) | **1** | Optional. Often unnecessary. |
| Card | **2** | Usually one (status / category). |
| List item / feature row | **1** | Leading icon OR trailing chevron, not both unless destructive (trash + chevron). |
| Footer | **3 social max** | Brand marks only (X, Instagram, GitHub). No generic icons. |
| Form field | **1** | Leading affordance (mail/lock/search) OR trailing action (clear/show-password). Not both. |
| Button | **0 or 1** | Icon OR icon+text. Never icon+text+trailing-icon. Never two icons. |
| Empty state | **1** | A single illustrative glyph. Never an icon grid. |
| Toast / notification | **1** | Leading status icon (check, info, alert). |
| Breadcrumb separator | **1** style | Pick `/` or `›`. Don't mix. |

If the design exceeds these, the design is the problem, not the budget.

---

## 2. Icon family — pick ONE per project

| Library | Style | When to pick |
|---|---|---|
| `lucide-react` | Stroke (2px), open, friendly | Default for SaaS / dashboards / consumer products |
| `@phosphor-icons/react` | Multi-weight (thin/light/regular/bold/fill/duotone) | Editorial / brand-rich projects |
| `@radix-ui/react-icons` | Stroke, minimal, geometric | Dashboards aligned with shadcn ecosystem |
| `@heroicons/react` | Stroke + solid pair | Tailwind ecosystem default |
| Custom SVG sprite | Brand-specific | Premium projects with bespoke iconography |

**Hard rule:** **never** mix two icon libraries in the same project. Mismatched stroke weights / corner radii / metric grids read as broken design.

```tsx
// ❌ BAD — Lucide nav, Phosphor cards, Heroicons footer
import { Search } from 'lucide-react';
import { Heart } from '@phosphor-icons/react';
import { ShareIcon } from '@heroicons/react/24/outline';

// ✅ GOOD — one library, the whole way through
import { Search, Heart, Share2 } from 'lucide-react';
```

---

## 3. Sizing scale (pick from this list)

```ts
// Tailwind sizing
size-3.5  // 14px — inline within text
size-4    // 16px — list items, form affordances
size-5    // 20px — buttons, nav
size-6    // 24px — cards, section icons
size-8    // 32px — empty state hero
size-10   // 40px — empty state hero (large)
```

**Hard rule:** stroke weight stays constant within a project. Lucide default is 2. Choose 1.5 OR 2 globally — never both.

```tsx
// Set globally for Lucide
import { LucideProps, createLucideIcon } from 'lucide-react';

// In your icon wrapper:
<Icon strokeWidth={1.75} className="size-5" />
```

---

## 4. Color: `currentColor` always

```tsx
// ✅ GOOD — icon inherits text color
<button className="text-foreground hover:text-primary">
  <Search className="size-5" />  {/* uses currentColor */}
</button>

// ❌ BAD — bespoke icon color, becomes unmanageable
<Search className="size-5 text-[#7c3aed]" />

// ✅ EXCEPTION — semantic status colors
<CheckCircle className="size-5 text-success" />  {/* status communicates meaning */}
<AlertTriangle className="size-5 text-warning" />
<XCircle className="size-5 text-destructive" />
```

---

## 5. Accessibility (mandatory)

```tsx
// ✅ Decorative icon next to text — hide from AT
<button className="inline-flex gap-2 items-center">
  <Plus aria-hidden className="size-4" />
  Add item
</button>

// ✅ Icon-only button — needs accessible label
<button aria-label="Close dialog">
  <X aria-hidden className="size-5" />
</button>

// ✅ Icon-only link — same rule
<a href="/settings" aria-label="Settings">
  <Settings aria-hidden className="size-5" />
</a>

// ❌ BAD — icon-only button with no label, screen reader says nothing
<button>
  <X className="size-5" />
</button>
```

Rule: **every icon either has `aria-hidden` (decorative) OR is accompanied by `aria-label` / visible text (functional).** No exceptions.

---

## 6. Icon Soup — what it looks like, how to fix it

### ❌ Icon Soup (dashboard sidebar with icons everywhere)

```tsx
<nav className="flex flex-col gap-1">
  <NavItem icon={Home}>Home</NavItem>
  <NavItem icon={Users}>Customers</NavItem>
  <NavItem icon={Package}>Products</NavItem>
  <NavItem icon={ShoppingCart}>Orders</NavItem>
  <NavItem icon={DollarSign}>Revenue</NavItem>
  <NavItem icon={BarChart}>Analytics</NavItem>
  <NavItem icon={Settings}>Settings</NavItem>
  <NavItem icon={Bell}>Notifications</NavItem>
  <NavItem icon={LifeBuoy}>Support</NavItem>
  <NavItem icon={LogOut}>Sign out</NavItem>
</nav>
```

This is fine ONLY if it's a collapsed icon-rail. If labels are visible, the icons are decorative duplication. Cut to one per group, or remove entirely:

### ✅ Editorial nav (groups, no icons within group)

```tsx
<nav className="flex flex-col gap-6">
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
    <NavItem icon={LogOut}>Sign out</NavItem>  {/* only destructive earns icon */}
  </Group>
</nav>
```

### ❌ Card with icon + title saying the same thing

```tsx
<Card>
  <Calendar className="size-6" />
  <h3>Calendar</h3>
  <p>Schedule meetings...</p>
</Card>
```

### ✅ Pick one — typography OR icon

```tsx
<Card>
  <span className="text-xs uppercase tracking-widest text-muted-foreground">01</span>
  <h3 className="text-2xl mt-2">Calendar</h3>
  <p>Schedule meetings...</p>
</Card>
```

### ❌ Feature grid: 6 cards, 6 icons in 6 brand colors

```tsx
<div className="grid grid-cols-3">
  <Feature icon={<Zap className="text-yellow-400" />} />
  <Feature icon={<Shield className="text-blue-400" />} />
  <Feature icon={<Heart className="text-pink-400" />} />
  <Feature icon={<Sparkles className="text-purple-400" />} />
  <Feature icon={<Rocket className="text-orange-400" />} />
  <Feature icon={<Star className="text-emerald-400" />} />
</div>
```

This is "sticker sheet" syndrome — reads as Stripe-knockoff. Fix:
- Same accent color for all (or `currentColor`)
- Or no icons, use numbered/lettered prefixes
- Or asymmetric layout (zig-zag, bento) so icons aren't in a grid

---

## 7. Decision flow

```
Need an icon?
├── Is it functional (icon-only button, status indicator, navigation)?
│   ├── Yes → use it, with aria-label or visible text equivalent
│   └── No  → it's decorative
│             ├── Does it add information the label doesn't have?
│             │   ├── Yes → use it sparingly, aria-hidden
│             │   └── No  → cut it
└── Is it the same library as the rest of the project?
    ├── Yes → fine
    └── No  → swap for the project's library
```

---

## 8. Icon budget enforcement

### Manual review (every PR)
Count icons per region against the budget table. If over budget → cut.

### Automated (optional)
The `frontend-output-validator` skill includes a script that greps for icon imports and counts usage per file/region. Wire it into CI to block merges on budget violations.

---

## 9. The "If I deleted every icon, would the UI still work?" test

Apply mentally:
- Top nav with 5 icons → if you delete them, can the user still navigate? **Yes** (labels remain). Icons are decorative — keep only the ones that aid scanning.
- Icon-only "close" button → if you delete the icon, the button is empty. Icon is **functional** — keep with `aria-label`.
- Card with `<Calendar />` + "Calendar" h3 → if you delete the icon, you still have "Calendar". Icon is **decorative duplication** — cut.
- Status badge with `<CheckCircle />` + "Active" → the icon adds visual scan-ability for status. Keep.

If the answer is "the UI works the same without it", the icon should not be there.
