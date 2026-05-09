# Mobile-Native Patterns

Patterns that exist *because* of mobile. Each entry has when YES, when NO, and a minimal snippet. Pick the right pattern; do not transplant desktop patterns.

> The desktop → mobile swap table lives in `frontend-foundation/references/mobile-first.md` §7. This file goes deeper on the mobile-native ones.

---

## 1. Bottom Tab Bar

The default mobile primary navigation. Lives in the thumb zone, always visible.

**When YES**
- 3 to 5 primary destinations of equal weight (Home, Search, Notifications, Account)
- Frequent switching expected (social, marketplaces, dashboards)
- One-handed use is the dominant scenario

**When NO**
- More than 5 destinations — use a hamburger drawer or a mixed strategy (4 tabs + "More")
- Hierarchical nav with deep sub-sections — bottom tabs are siblings, not parent-child
- One-shot tasks (checkout, onboarding wizard, single-purpose apps)

**Mobile-only** (desktop uses sidebar — see Shrunk Desktop section in SKILL.md).

```tsx
// components/mobile/bottom-tab-bar.tsx
'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, Search, Bell, User } from 'lucide-react';

const tabs = [
  { href: '/', label: 'Inicio', icon: Home },
  { href: '/buscar', label: 'Buscar', icon: Search },
  { href: '/avisos', label: 'Avisos', icon: Bell },
  { href: '/cuenta', label: 'Cuenta', icon: User },
];

export function BottomTabBar() {
  const pathname = usePathname();
  return (
    <nav
      className="md:hidden fixed bottom-0 inset-x-0 z-40 border-t border-border bg-background/95 backdrop-blur"
      style={{ paddingBottom: 'max(0.25rem, env(safe-area-inset-bottom))' }}
      aria-label="Navegación principal"
    >
      <ul className="grid grid-cols-4">
        {tabs.map(({ href, label, icon: Icon }) => {
          const active = pathname === href;
          return (
            <li key={href}>
              <Link
                href={href}
                aria-current={active ? 'page' : undefined}
                className="flex flex-col items-center justify-center gap-0.5 py-2 min-h-[44px] text-[11px] font-medium"
              >
                <Icon className="size-5" aria-hidden />
                <span className={active ? 'text-foreground' : 'text-foreground/60'}>{label}</span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
```

Always: `safe-area-inset-bottom`, `min-h-[44px]` per tap, `aria-current="page"` for screen readers, label visible (icon-only is hostile).

---

## 2. Bottom Sheet

The mobile-native replacement for dropdowns, popovers, side panels, and most modals.

**When YES**
- Filter selections, sort options, account switcher, share menu
- Contextual detail (tap a list item → sheet with actions)
- Forms with ≤ 6 fields where a full-screen sheet would feel heavy
- Anywhere desktop would use a `Popover` or `Select` with > 5 options

**When NO**
- Multi-step wizards — use full-screen sheets per step
- Critical destructive confirmations — use a centered AlertDialog (forces explicit attention)
- Long forms — full-screen sheet, not bottom sheet

**Library: Vaul** (`pnpm add vaul`). It handles drag-to-dismiss, snap points, and safe-area natively.

```tsx
'use client';
import { Drawer } from 'vaul';

export function FilterSheet({ children }: { children: React.ReactNode }) {
  return (
    <Drawer.Root>
      <Drawer.Trigger className="inline-flex items-center gap-2 px-4 py-2 rounded-full border min-h-[44px]">
        Filtrar
      </Drawer.Trigger>
      <Drawer.Portal>
        <Drawer.Overlay className="fixed inset-0 bg-foreground/40" />
        <Drawer.Content
          className="fixed bottom-0 inset-x-0 z-50 mt-24 max-h-[85dvh] rounded-t-2xl border-t bg-background flex flex-col"
          style={{ paddingBottom: 'env(safe-area-inset-bottom)' }}
        >
          <div className="mx-auto my-3 h-1.5 w-10 rounded-full bg-foreground/20" aria-hidden />
          <Drawer.Title className="px-4 text-base font-semibold">Filtros</Drawer.Title>
          <div className="flex-1 overflow-y-auto px-4 pb-4">{children}</div>
        </Drawer.Content>
      </Drawer.Portal>
    </Drawer.Root>
  );
}
```

**Snap points**: use Vaul's `snapPoints={[0.4, 0.85]}` when the sheet has two natural sizes (preview vs detail).

**Scroll inside the sheet, not the page**: `max-h-[85dvh]` on `Drawer.Content` plus `overflow-y-auto` on the inner section. Otherwise the page scrolls underneath and confuses gesture handling.

---

## 3. Floating Action Button (FAB)

A single, persistent primary action that follows the user.

**When YES**
- Exactly one primary action recurs across the screen — "Compose" in mail, "Add" in a list, "New post" in a feed
- The action is the reason the user is on the screen

**When NO**
- More than one primary action — use a bottom bar with multiple buttons
- Read-only screens (analytics, profile, settings)
- The action is rarely used (move it into a menu)

**Mobile-only** typically; on desktop the same action lives in a header button.

```tsx
'use client';
import { Plus } from 'lucide-react';

export function ComposeFab() {
  return (
    <button
      aria-label="Crear nueva nota"
      className="fixed z-30 bottom-[max(1.5rem,calc(env(safe-area-inset-bottom)+1rem))] right-4 md:hidden size-14 rounded-full bg-foreground text-background shadow-lg active:scale-[0.96] transition-transform"
    >
      <Plus className="size-6 mx-auto" aria-hidden />
    </button>
  );
}
```

Position above the bottom tab bar (if present) by adding the tab bar height to the bottom offset, e.g. `bottom-[calc(env(safe-area-inset-bottom)+5rem)]`.

---

## 4. Swipe Actions

Swipe a list item left or right to reveal contextual actions.

**When YES**
- Lists with 1-2 recurring actions per row (Archive, Delete, Mark read, Star)
- Inbox / feed / task list patterns

**When NO**
- More than 2 actions — discoverability collapses; use an explicit "..." menu
- Accidental swipes are catastrophic (irreversible delete without confirmation)
- The list also supports drag-to-reorder (gesture conflict)

Always include a non-swipe equivalent (long-press or "..." menu) for accessibility.

```tsx
'use client';
import { motion, useMotionValue, useTransform } from 'framer-motion';
import { useState } from 'react';

export function SwipeRow({ children, onArchive }: { children: React.ReactNode; onArchive: () => void }) {
  const x = useMotionValue(0);
  const opacity = useTransform(x, [-160, -80, 0], [1, 0.6, 0]);
  const [archived, setArchived] = useState(false);

  return (
    <div className="relative overflow-hidden">
      <motion.div
        className="absolute inset-y-0 right-0 flex items-center pr-6 bg-emerald-700 text-white"
        style={{ opacity }}
      >
        Archivar
      </motion.div>
      <motion.div
        drag="x"
        dragConstraints={{ left: -200, right: 0 }}
        style={{ x }}
        onDragEnd={(_, info) => {
          if (info.offset.x < -120) {
            setArchived(true);
            onArchive();
          }
        }}
        className="bg-background border-b min-h-[64px] px-4 flex items-center"
      >
        {children}
      </motion.div>
    </div>
  );
}
```

Add a visible affordance on first use — a small chevron, an onboarding tooltip, or a one-time auto-peek animation.

---

## 5. Pull-to-Refresh

Pull the top of a scrollable list to refresh.

**When YES**
- Time-sensitive feeds: notifications, social, news, marketplace listings, order status
- Where the user expects "fresh data right now"

**When NO**
- Forms, settings, configuration screens — refreshing destroys input
- Static content (about, terms of service)
- Lists with infinite scroll where the freshest items are auto-prepended

iOS Safari has a native pull-to-refresh on scroll containers; the browser's behavior often suffices. Custom implementations should use `framer-motion` drag and **never** hijack the native gesture on iOS without strong reason.

---

## 6. Sticky Bottom CTA

A persistent CTA pinned to the bottom of the viewport. The most underused conversion lever on mobile.

**When YES**
- Product detail page (Add to cart, Buy now)
- Long-form landing pages (the hero CTA scrolls off-screen — sticky CTA keeps it reachable)
- Multi-step flows where the next step is the obvious action
- Pricing pages (Choose plan)

**When NO**
- Forms with their own submit button (avoid double-CTA)
- Reading experiences where the CTA is not the primary intent
- Screens with a bottom tab bar (do not stack — use one or the other; the tab bar wins for nav, the CTA wins for conversion screens)

```tsx
export function StickyCheckoutBar({ price, onCheckout }: { price: string; onCheckout: () => void }) {
  return (
    <div
      className="md:hidden fixed bottom-0 inset-x-0 z-40 border-t bg-background"
      style={{ paddingBottom: 'max(0.75rem, env(safe-area-inset-bottom))' }}
    >
      <div className="px-4 pt-3 flex items-center gap-3">
        <div className="flex-1">
          <p className="text-xs text-foreground/60">Total</p>
          <p className="text-lg font-semibold tabular-nums">{price}</p>
        </div>
        <button
          onClick={onCheckout}
          className="flex-1 min-h-[48px] px-4 rounded-full bg-foreground text-background font-medium active:scale-[0.98] transition-transform"
        >
          Pagar
        </button>
      </div>
    </div>
  );
}
```

Add `pb-[5rem]` to the page main content so the sticky CTA does not cover it.

---

## 7. Segmented Control

The bar of 2-3 mutually exclusive options.

**When YES**
- 2 or 3 mutually exclusive views of the same data: "Lista | Mapa", "Día | Semana | Mes"
- Strong visual hierarchy needed (more prominent than tabs)

**When NO**
- 4+ options — use tabs or a select
- Options are not exclusive (e.g. filter combinations) — use checkboxes / chips

```tsx
'use client';
import { useState } from 'react';

export function ViewToggle() {
  const [view, setView] = useState<'list' | 'map'>('list');
  return (
    <div role="tablist" aria-label="Vista" className="inline-flex p-1 rounded-full bg-foreground/5">
      {(['list', 'map'] as const).map((v) => (
        <button
          key={v}
          role="tab"
          aria-selected={view === v}
          onClick={() => setView(v)}
          className={`min-h-[36px] px-4 rounded-full text-sm font-medium transition-colors ${
            view === v ? 'bg-background shadow-sm' : 'text-foreground/60'
          }`}
        >
          {v === 'list' ? 'Lista' : 'Mapa'}
        </button>
      ))}
    </div>
  );
}
```

Note: 36px height is acceptable here because the segmented control is non-critical and the touch target uses padded width. For top-level navigation, use 44px+.

---

## 8. Hamburger Menu — Default to Anti-Pattern

**When YES (rarely)**
- Apps with > 7 destinations and the bottom tab bar would feel arbitrary
- Settings-heavy apps where most navigation is infrequent
- Secondary nav alongside a primary tab bar (e.g. tab bar for top 4, hamburger for the rest)

**When NO (the default)**
- Any product where < 5 destinations exist — use the bottom tab bar
- Discovery-heavy products (commerce, social) — hidden nav kills exploration

The cost: every destination behind a hamburger drops engagement ~50% vs. a visible tab. Designers reach for it because it is "clean"; users do not find what they cannot see.

---

## 9. Full-Screen Modal Sheet

Mobile replacement for desktop centered modal dialogs.

**When YES**
- Any form longer than 3 fields
- Multi-step flows where each step needs context
- Image / video viewers
- Any content where a centered dialog at 90% width would feel cramped

**When NO**
- Yes/No confirmations — use a small AlertDialog (centered, requires explicit decision)
- Quick previews — use a bottom sheet instead

```tsx
'use client';
import * as Dialog from '@base-ui-components/react/dialog';
import { X } from 'lucide-react';

export function FullScreenSheet({ children, title }: { children: React.ReactNode; title: string }) {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Abrir</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Backdrop className="fixed inset-0 bg-foreground/30" />
        <Dialog.Popup
          className="fixed inset-0 md:inset-auto md:left-1/2 md:top-1/2 md:-translate-x-1/2 md:-translate-y-1/2 md:max-w-lg md:rounded-2xl bg-background flex flex-col"
          style={{ paddingTop: 'env(safe-area-inset-top)', paddingBottom: 'env(safe-area-inset-bottom)' }}
        >
          <header className="flex items-center justify-between px-4 py-3 border-b">
            <Dialog.Title className="text-base font-semibold">{title}</Dialog.Title>
            <Dialog.Close className="size-11 -mr-2 inline-flex items-center justify-center" aria-label="Cerrar">
              <X className="size-5" aria-hidden />
            </Dialog.Close>
          </header>
          <div className="flex-1 overflow-y-auto px-4 py-4">{children}</div>
        </Dialog.Popup>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

Mobile: `inset-0` (full-screen). Desktop: centered card via `md:` overrides. Same component, two layouts.

---

## Pattern Selection Matrix

| User intent | Mobile pattern | Desktop equivalent |
|---|---|---|
| Switch primary section | Bottom tab bar | Sidebar |
| Pick from 5+ options | Bottom sheet | Popover / Select |
| Pick from 2-3 mutually exclusive | Segmented control | Tabs / Radio group |
| One persistent primary action | FAB | Header button |
| Per-row contextual action | Swipe action + ... menu | Hover menu |
| Refresh feed | Pull-to-refresh | Refresh button |
| Confirm conversion | Sticky bottom CTA | Inline button |
| Long form | Full-screen sheet | Centered modal (md+) |
| Filter / sort | Bottom sheet behind "Filter" button | Sidebar filters |
| Drill into detail | Push to new screen | Side panel / drawer |
