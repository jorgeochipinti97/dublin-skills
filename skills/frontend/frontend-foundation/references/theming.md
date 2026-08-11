# Theming — Dark + Light from Day 0

Ready-to-copy setup for Next.js 15 + Tailwind v4 with dual theme.

## Theme setup por framework

### Next.js (App Router)
Usar `next-themes` con `ThemeProvider` en el root layout.

### Vite + React / Astro / SvelteKit
`next-themes` requiere Next.js. Para otros frameworks, usar una implementación propia liviana:

```tsx
// src/providers/ThemeProvider.tsx
import { createContext, useContext, useEffect, useState } from 'react'

type Theme = 'light' | 'dark' | 'system'

const ThemeContext = createContext<{
  theme: Theme
  setTheme: (t: Theme) => void
}>({ theme: 'system', setTheme: () => {} })

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setThemeState] = useState<Theme>('system')

  const setTheme = (t: Theme) => {
    setThemeState(t)
    localStorage.setItem('theme', t)
    applyTheme(t)
  }

  useEffect(() => {
    const saved = (localStorage.getItem('theme') as Theme) ?? 'system'
    setThemeState(saved)
    applyTheme(saved)
  }, [])

  return <ThemeContext.Provider value={{ theme, setTheme }}>{children}</ThemeContext.Provider>
}

function applyTheme(t: Theme) {
  const isDark = t === 'dark' || (t === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)
  document.startViewTransition?.(() => {
    document.documentElement.classList.toggle('dark', isDark)
  }) ?? document.documentElement.classList.toggle('dark', isDark)
}

export const useTheme = () => useContext(ThemeContext)
```

El `document.startViewTransition` ya aplica la S-curve de Pillar 1. Para Astro, wrappear en un componente con `client:load`.

## 1. Install dependencies

```bash
# Next.js
pnpm add next-themes

# Vite / Astro / SvelteKit: sin dependencias — usar el ThemeProvider de arriba
```

## 2. Define tokens (`app/globals.css`)

```css
@import "tailwindcss";

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-success: var(--success);
  --color-warning: var(--warning);
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
}

:root {
  --radius: 0.625rem;
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.145 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.145 0 0);
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);
  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);
  --destructive: oklch(0.577 0.245 27.325);
  --destructive-foreground: oklch(0.985 0 0);
  --success: oklch(0.7 0.17 152);
  --warning: oklch(0.8 0.17 80);
  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --card: oklch(0.185 0 0);
  --card-foreground: oklch(0.985 0 0);
  --popover: oklch(0.185 0 0);
  --popover-foreground: oklch(0.985 0 0);
  --primary: oklch(0.985 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --accent: oklch(0.269 0 0);
  --accent-foreground: oklch(0.985 0 0);
  --destructive: oklch(0.704 0.191 22.216);
  --destructive-foreground: oklch(0.985 0 0);
  --success: oklch(0.75 0.17 152);
  --warning: oklch(0.85 0.17 80);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);
}

body {
  background: var(--background);
  color: var(--foreground);
}
```

**Why OKLCH:** perceptually uniform, better interpolation, same visual contrast across hues. Use `oklch()` for anything new; convert HSL/HEX at the token layer only.

## 3. ThemeProvider (Next.js App Router)

```tsx
// components/theme-provider.tsx
"use client";
import { ThemeProvider as NextThemesProvider } from "next-themes";
import type { ComponentProps } from "react";

export function ThemeProvider({ children, ...props }: ComponentProps<typeof NextThemesProvider>) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>;
}
```

```tsx
// app/layout.tsx
import { ThemeProvider } from "@/components/theme-provider";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

`suppressHydrationWarning` on `<html>` is required — `next-themes` mutates the class before hydration.

## 4. Theme toggle — with View Transitions API (required)

**Rule:** Theme transitions must use the **View Transitions API** — it runs on the browser compositor thread (off main thread), so the whole UI cross-fades without blocking React or JS work. Combined with a slow-fast-slow ease, it feels premium, not jumpy.

The ease curve is deliberately an S-curve (slow → fast → slow): eases in smoothly, accelerates through the middle where the user's eye tracks most, decelerates at the end. Never linear, never ease-in or ease-out alone.

```css
/* app/globals.css — add to the end */

/* View Transitions: slow-fast-slow S-curve */
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 500ms;
  animation-timing-function: cubic-bezier(0.65, 0, 0.35, 1);
  /* cubic-bezier(0.65, 0, 0.35, 1) = ease-in-out-cubic — slow, fast, slow.
     For a MORE pronounced S-curve use cubic-bezier(0.83, 0, 0.17, 1). */
}

/* Crossfade old and new simultaneously (default is old-on-top) */
::view-transition-old(root) {
  animation-name: theme-fade-out;
}
::view-transition-new(root) {
  animation-name: theme-fade-in;
}

@keyframes theme-fade-out {
  to { opacity: 0; }
}
@keyframes theme-fade-in {
  from { opacity: 0; }
}

/* Respect reduced motion */
@media (prefers-reduced-motion: reduce) {
  ::view-transition-old(root),
  ::view-transition-new(root) {
    animation-duration: 1ms;
  }
}
```

```tsx
// components/theme-toggle.tsx
"use client";
import { Moon, Sun } from "lucide-react";
import { useTheme } from "next-themes";
import { Button } from "@/components/ui/button";
import { flushSync } from "react-dom";

export function ThemeToggle() {
  const { resolvedTheme, setTheme } = useTheme();

  function toggle() {
    const next = resolvedTheme === "dark" ? "light" : "dark";

    // Fallback for browsers without View Transitions (Firefox < 129, older Safari)
    if (!document.startViewTransition) {
      setTheme(next);
      return;
    }

    document.startViewTransition(() => {
      // flushSync forces React to apply the class change synchronously
      // BEFORE the browser captures the "new" state for the transition
      flushSync(() => setTheme(next));
    });
  }

  return (
    <Button variant="ghost" size="icon" aria-label="Toggle theme" onClick={toggle}>
      <Sun className="size-4 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute size-4 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
    </Button>
  );
}
```

### Why the slow-fast-slow ease (S-curve)?

| Curve | Feel |
|---|---|
| `linear` | Mechanical, robotic, cheap |
| `ease-out` | Good for entrances, weak for crossfades |
| `ease-in-out` (default) | OK but too symmetric and flat through the middle |
| **`cubic-bezier(0.65, 0, 0.35, 1)`** | **Slow-fast-slow, reads as premium — like macOS dock scaling** |
| `cubic-bezier(0.83, 0, 0.17, 1)` | Same shape, MORE pronounced — use for dramatic transitions |
| `cubic-bezier(0.87, 0, 0.13, 1)` | Most extreme S — reserve for signature moments |

### Radial reveal from the toggle (premium detail, optional)

For a "theme ripples out from the toggle" effect, override the transition with a CSS clip-path animation:

```css
::view-transition-new(root) {
  animation: reveal 600ms cubic-bezier(0.65, 0, 0.35, 1);
}
::view-transition-old(root) {
  animation: none;
  z-index: -1;
}

@keyframes reveal {
  from { clip-path: circle(0% at var(--x, 50%) var(--y, 50%)); }
  to   { clip-path: circle(150% at var(--x, 50%) var(--y, 50%)); }
}
```

```tsx
function toggle(e: React.MouseEvent<HTMLButtonElement>) {
  const next = resolvedTheme === "dark" ? "light" : "dark";
  if (!document.startViewTransition) { setTheme(next); return; }

  // Capture click coordinates to seed the radial reveal
  const rect = e.currentTarget.getBoundingClientRect();
  const x = rect.left + rect.width / 2;
  const y = rect.top + rect.height / 2;
  document.documentElement.style.setProperty("--x", `${x}px`);
  document.documentElement.style.setProperty("--y", `${y}px`);

  document.startViewTransition(() => flushSync(() => setTheme(next)));
}
```

### Rules for theme transitions

- **Never** use `transition-colors duration-*` on every element to "animate" theme — it's expensive and janky. Let View Transitions handle it.
- **Never** transition off main thread with JS libraries (Framer, GSAP) for theme — the compositor is faster.
- **Always** include `flushSync` — without it, React may batch the class update and the transition snapshot is wrong.
- **Always** provide a no-transition fallback for browsers without `startViewTransition`.
- **Always** honor `prefers-reduced-motion`.

## 5. Glass / gradient dual-theme variants

Glass and gradients **break** if you assume dark. Always provide both variants.

```tsx
// Glass card — works in both themes
<div className="
  rounded-2xl border border-border/50
  bg-card/60 backdrop-blur-xl
  dark:bg-card/40 dark:backdrop-blur-2xl
  shadow-[0_8px_30px_rgb(0_0_0_/0.04)]
  dark:shadow-[0_8px_30px_rgb(0_0_0_/0.35)]
">
```

```tsx
// Aurora/mesh gradient background — per theme
<div className="
  bg-[radial-gradient(ellipse_at_top,oklch(0.97_0.05_240),transparent_70%)]
  dark:bg-[radial-gradient(ellipse_at_top,oklch(0.25_0.08_240),transparent_70%)]
">
```

## 6. Contrast verification (required before merge)

- Body text on background: **≥ 4.5:1** (WCAG AA)
- Large text (≥ 18pt / 14pt bold): **≥ 3:1**
- Interactive UI (buttons, inputs, icons): **≥ 3:1**
- Tools: browser devtools contrast checker, `@axe-core/react`, Lighthouse

Run in BOTH themes. A passing light mode doesn't imply passing dark mode.

## 7. Checklist per component

- [ ] No hardcoded hex / rgb / oklch
- [ ] Consumes semantic tokens only (`bg-background`, `text-foreground`, `border-border`)
- [ ] Tested visually in both themes
- [ ] Focus ring visible in both themes (`--ring`)
- [ ] Disabled state readable in both themes
- [ ] Hover state distinguishable in both themes

## Anti-patterns

```tsx
// ❌ Hardcoded — breaks theming
<div className="bg-white text-black border-gray-200">

// ❌ Dark-only assumption
<div className="bg-black/40 backdrop-blur-xl">

// ❌ Palette import from design tokens (at component level)
import { colors } from "@/tokens";
<div style={{ background: colors.slate[900] }}>

// ✅ Semantic token
<div className="bg-background text-foreground border-border">
```
