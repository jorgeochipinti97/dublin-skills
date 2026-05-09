# Check Catalog

Every check the validator runs, with rule name, severity, and example failure message.

Severity:
- **🔴 fail** — blocks merge
- **🟡 warn** — review before merge
- **🟢 info** — surfaced in report, no block

---

## Contrast (WCAG)

| Rule | Severity | Example failure |
|---|---|---|
| `contrast.body` | 🔴 | Body text `#6c7278` on `#f4f4f5` = 3.2:1 (need 4.5:1) — `src/components/ui/typography.tsx:12` |
| `contrast.large-text` | 🔴 | Headline `text-foreground/40` ≈ 2.8:1 on `--background` (need 3:1 for ≥18pt) — `src/app/page.tsx:8` |
| `contrast.ui-component` | 🔴 | Border `--border` on `--card` = 1.4:1 (need 3:1) — `tokens.css:34` |
| `contrast.dark-mode` | 🔴 | Tokens valid in light mode, fail in dark mode — `--muted-foreground-dark` on `--background-dark` = 3.9:1 |

How to fix → `frontend-foundation/references/theming.md` (contrast rules)

---

## CLS sources

| Rule | Severity | Example failure |
|---|---|---|
| `cls.image-no-dims` | 🔴 | `<img src="/hero.jpg">` missing width/height/aspect-ratio — `src/app/page.tsx:34` |
| `cls.iframe-no-wrapper` | 🔴 | `<iframe src="https://youtube...">` not wrapped in aspect-ratio container — `src/components/embed.tsx:18` |
| `cls.font-no-fallback` | 🔴 | Geist `@font-face` has no `size-adjust` fallback — `src/app/globals.css:42` |
| `cls.font-no-preload` | 🟡 | Primary font not preloaded (`<link rel="preload" as="font">`) — `src/app/layout.tsx` |
| `cls.banner-in-flow` | 🔴 | Cookie banner in normal document flow (pushes content) — `src/app/layout.tsx:24` |
| `cls.height-auto-animation` | 🔴 | `transition-[height]` with `height: auto` = broken animation — `src/components/accordion.tsx:30` |
| `cls.skeleton-mismatch` | 🟡 | Skeleton heights don't match real component heights (heuristic) |
| `cls.dynamic-no-min-height` | 🟡 | `<Suspense>` without `min-h-*` on parent — `src/components/lazy-section.tsx:5` |

How to fix → `frontend-foundation/references/cls-zero.md`

---

## Icon budget

| Rule | Severity | Example failure |
|---|---|---|
| `icon.budget.nav` | 🔴 | Top nav has 7 icons (DESIGN.md `iconBudget.topNav: 5`) — `src/components/layout/nav.tsx:12-26` |
| `icon.budget.hero` | 🟡 | Hero section has 3 icons (max 1) — `src/app/page.tsx:8-22` |
| `icon.budget.card` | 🟡 | Card has 3 icons (max 2) — `src/components/feature-card.tsx:14-30` |
| `icon.budget.button` | 🔴 | Button has 2 icons + text (max 1) — `src/components/ui/button.tsx:48` |
| `icon.budget.form-field` | 🔴 | Input has leading + trailing icon (pick one) — `src/components/ui/input.tsx:22` |
| `icon.budget.footer-social` | 🟡 | Footer has 7 social icons (max 3) — `src/components/layout/footer.tsx:40` |

How to fix → `frontend-foundation/references/icon-budget.md`

---

## Icon library consistency

| Rule | Severity | Example failure |
|---|---|---|
| `icon.library.mixed` | 🔴 | Multiple icon libraries detected: `lucide-react` (12 imports), `@phosphor-icons/react` (3 imports). Pick one. |
| `icon.stroke.inconsistent` | 🟡 | `strokeWidth={1.5}` and `strokeWidth={2}` both present — pick one globally |

---

## Touch targets

| Rule | Severity | Example failure |
|---|---|---|
| `touch.target.size` | 🔴 | `<button class="size-8">` = 32×32 (min 44×44) — `src/components/ui/icon-button.tsx:18` |
| `touch.target.spacing` | 🟡 | Adjacent buttons with `gap-1` (4px) — min 8px between targets — `src/components/toolbar.tsx:12` |

How to fix → `frontend-foundation/references/mobile-first.md`

---

## Mobile-first

| Rule | Severity | Example failure |
|---|---|---|
| `mobile.viewport.meta` | 🔴 | Viewport meta missing or has `user-scalable=no` — `src/app/layout.tsx:8` |
| `mobile.viewport.fit` | 🟡 | Missing `viewport-fit=cover` (needed for safe-area-inset) |
| `mobile.dvh` | 🔴 | `min-h-screen` / `min-h-[100vh]` used — replace with `min-h-[100dvh]` — `src/app/page.tsx:5` |
| `mobile.body-size` | 🔴 | Body text `text-sm` (14px) — iOS auto-zooms on focus, use `text-base` (16px) — `src/components/form/input.tsx:30` |
| `mobile.safe-area` | 🟡 | Fixed bottom nav without `pb-[env(safe-area-inset-bottom)]` — `src/components/layout/bottom-nav.tsx:8` |
| `mobile.hover-only` | 🟡 | `:hover` interaction without `:focus-visible` or persistent state — `src/components/menu.tsx:14` |
| `mobile.content-priority` | 🟡 | Route present but `DESIGN.md` `contentPriority` block missing this route — `/pricing` |
| `mobile.input-mode` | 🟡 | `<input type="email">` without `inputMode="email"` — `src/components/form/email.tsx:8` |
| `mobile.vvw-trap` | 🟡 | `width: 100vw` / `w-screen` / `w-[100vw]` includes scrollbar — overflow on Android Chrome — `src/components/banner.tsx:5` |
| `mobile.overflow-runtime` | 🟡 | Runtime check (Lighthouse / Playwright at 360px): `document.documentElement.scrollWidth > window.innerWidth` — see Layer 2 / Layer 3 |

---

## Forbidden tokens (AI Tells)

| Rule | Severity | Example failure |
|---|---|---|
| `aitell.pure-black` | 🔴 | `#000` / `#fff` literal in component — `src/components/...:12` (use semantic token) |
| `aitell.lila-ban` | 🟡 | `bg-gradient-to-r from-purple-* to-blue-*` matches LILA BAN — `src/components/cta.tsx:5` |
| `aitell.inter-tell` | 🟡 | Default `Inter` without customization detected (no `font-feature-settings`, no display pairing) |
| `aitell.gradient-headline` | 🟡 | `text-transparent bg-clip-text` on `<h1>`/`<h2>` — `src/app/page.tsx:14` |
| `aitell.raw-hex-component` | 🟡 | Hex literal in component (`bg-[#0a0a0a]`) — should be semantic token |

---

## Forbidden content (AI Tells)

| Rule | Severity | Example failure |
|---|---|---|
| `content.jane-doe` | 🟡 | "John Doe" in demo data — `src/data/users.ts:4` |
| `content.acme-slop` | 🟡 | "Acme Corp" / "Nexus AI" / "FlowAI" in copy |
| `content.99.99` | 🟡 | "99.99%" / "100%" / "1234567" predictable demo numbers |
| `content.filler-word` | 🟡 | "Elevate" / "Unleash" / "Seamless" / "Next-gen" / "Revolutionize" / "Transform your workflow" / "Cutting-edge" |
| `content.unsplash-link` | 🟡 | `https://unsplash.com/...` raw link (link rot) |
| `content.lorem-ipsum` | 🔴 | "Lorem ipsum" in shipped strings |

---

## Interactive states completeness

| Rule | Severity | Example failure |
|---|---|---|
| `state.loading` | 🟡 | Component fetches data but no loading UI detected — `src/components/users-list.tsx` |
| `state.empty` | 🟡 | List/grid component without empty state — `src/components/orders-table.tsx` |
| `state.error` | 🔴 | Fetch without error UI — `src/components/dashboard.tsx:18` |
| `state.active-feedback` | 🟡 | `<button>` without `:active`/`active:` styling |
| `state.disabled` | 🟡 | `<button>` without `disabled:` styling |

---

## Animation hygiene

| Rule | Severity | Example failure |
|---|---|---|
| `anim.bad-property` | 🔴 | `transition-[width]` / `transition-[height]` / `transition-all` with layout-affecting properties — `src/components/...:20` |
| `anim.scroll-listener` | 🔴 | `window.addEventListener('scroll', ...)` — use IntersectionObserver or Framer's `useScroll` |
| `anim.usestate-hover` | 🟡 | `useState` driving continuous hover animation on `motion.*` — use `useMotionValue` |
| `anim.linear-easing` | 🟡 | `ease-linear` on hover/transition — use `cubic-bezier(0.16, 1, 0.3, 1)` |

---

## DESIGN.md compliance

| Rule | Severity | Example failure |
|---|---|---|
| `design.exists` | 🔴 | `DESIGN.md` not found at repo root |
| `design.yaml.parse` | 🔴 | `DESIGN.md` frontmatter doesn't parse as YAML |
| `design.required-keys` | 🔴 | Missing required keys: `breakpoints`, `iconBudget`, `cls.target` |
| `design.token.drift` | 🟡 | Color `--accent: #b8422e` declared in DESIGN.md, code uses `#b94530` — drift detected |
| `design.aitells.empty` | 🟡 | `aiTellsEnforced` array empty or missing — at least 5 expected |
| `design.cls.target` | 🟡 | `cls.target > 0.05` — Dublin standard is < 0.05 (Core Web Vitals "Good" is < 0.1) |

---

## How to read the report

1. **Failures first** — fix all 🔴 before merging
2. **Warnings next** — review every 🟡, decide: fix or document the exception in DESIGN.md
3. **Passed checks** — confidence signal that the rule was actually verified, not just assumed

If 🔴 count > 0, the build/PR check fails.
If 🟡 count > 5, the validator suggests a `claude-md-keeper` review (systemic drift).
