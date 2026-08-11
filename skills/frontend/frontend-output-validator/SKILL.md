---
name: frontend-output-validator
description: Non-destructive review gate that runs AFTER any frontend implementation skill (frontend-foundation, premium-frontend-design, forms-and-validation, product-tour, landing-page-architect) to validate output against verifiable design rules. Checks WCAG contrast, icon budget per region, image/video dimensions (CLS), viewport meta, touch target sizing, mobile-first compliance, container queries, hover-only interactions, and forbidden patterns (Pure Black Tell, Inter Tell, Icon Soup, Layout Shift Sloppy). Reads the project's DESIGN.md as source of truth. Emits a pass/fail report with exact file:line references. Use proactively after any UI work touches > 1 component or includes new layout, images, fonts, or icons. Skip on copy-only or type-only changes.
---

# Frontend Output Validator

Verifiable checks that run AFTER frontend implementation. Closes the loop between "the skill said don't do X" and "no one actually checked".

## Why this exists

Skills tell the agent the rules. They do not enforce them. Without a validator, "don't ship Inter default", "icon budget", "CLS < 0.05" remain text. This skill turns text into checks with file:line failures.

This is a **review gate**, like `react-performance` and `backend-performance`. It does not generate UI. It audits UI.

## When to invoke (auto)

Auto-invoke after any of these skills produces React code:
- `frontend-foundation`
- `premium-frontend-design`
- `forms-and-validation`
- `product-tour`
- `landing-page-architect`

**Conditional firing** (skip if none apply):
- New components, layouts, or templates
- New images, videos, iframes, embeds
- New icons or icon library imports
- New fonts or font config
- > 1 component touched
- Hover/focus/active states added or modified

**Skip on:**
- Copy-only changes
- Type-only changes
- README / docs
- Single-line bugfixes

### HARD STOP — React Native projects

**Do not run this skill on a React Native / Expo codebase.** Detect it by an `expo` key in `app.json` / `app.config.{js,ts}`, or `react-native` in `package.json` dependencies.

Every layer of this validator assumes a DOM: Lighthouse cannot profile a native binary, and the Layer 1 patterns look for `className` on DOM elements, `<img>`, viewport meta, and CSS units that do not exist there. Run anyway and it reports **pass without having measured anything** — false confidence, which is worse than no check at all (the `False Green` tell).

Say so and route instead:
- Design-contract review → `mobile-app-foundation` → `references/design-skills-bridge.md`
- Runtime/perf verification → `mobile-app-foundation` → `references/testing-on-device.md` (manual by necessity — native has no Lighthouse equivalent)

## Inputs

- The diff (or list of changed files)
- `DESIGN.md` at the repo root (if present — used as source of truth for budgets/targets)
- `package.json` (to detect icon library, framework, font setup)
- `tailwind.config.*` and global CSS (for token validation)

## Output contract

```markdown
# Frontend Output Validation Report

## Summary
- ✅ Passed: <N> checks
- ⚠️  Warnings: <N>
- ❌ Failed: <N>

## Failures (block merge)
- [contrast] Button text #6c7278 on bg #f4f4f5 = 3.2:1 (WCAG AA wants 4.5:1)
  → src/components/ui/button.tsx:45
- [cls.image] <img src="/hero.jpg"> missing width/height/aspect-ratio
  → src/app/page.tsx:34
- [icon.budget] Top nav has 7 icons (max 5)
  → src/components/layout/nav.tsx:12-26

## Warnings (review before merge)
- [icon.library] Mixed icon libraries: lucide-react + @phosphor-icons/react
  → import locations: src/...
- [touch.target] <button class="size-8"> = 32×32 (min 44×44)
  → src/components/ui/icon-button.tsx:18

## Passed checks
- viewport meta correct
- 100dvh used (not 100vh)
- aspect-ratio on all 4 video embeds
- font-display: swap configured
- DESIGN.md present and valid
- No Inter without customization (1 font detected: Geist)
- No #000 / #fff in components
- No Acme/Nexus brand strings
- ...
```

## The 12 Check Categories

### 1. Contrast (WCAG)
- Body text ≥ 4.5:1 on background
- Large text (18pt+ / 14pt bold+) ≥ 3:1
- UI components (buttons, borders) ≥ 3:1
- Both light AND dark themes verified
- Tools: WCAG contrast formula on token combinations

### 2. CLS sources
- `<img>` / `<Image>` has `width`+`height` OR aspect-ratio
- `<iframe>` / `<video>` wrapped in aspect-ratio container
- Web fonts use `font-display: swap` + size-adjust fallback
- Banners / toasts are layered, not inline
- No `height: auto` animation
- Skeletons declared (presence check)

### 3. Icon budget (per region)
- Counts icon imports usage per file
- Maps to region heuristically (file in `nav/`, `card.tsx`, etc.)
- Compares against `DESIGN.md` `iconBudget` block
- Flags single-library violations

### 4. Icon library consistency
- Detects mixed icon libraries via imports (`lucide-react` + `@phosphor-icons/react` etc.)
- Fail: > 1 icon library imported anywhere in the project

### 5. Touch targets
- All `<button>`, `<a>` with role="button", interactive divs ≥ 44×44 CSS px
- Detected via Tailwind classes (`size-11`+ minimum) or explicit width/height
- 8px minimum spacing between adjacent targets

### 6. Mobile-first
- Viewport meta correct (`width=device-width, initial-scale=1, viewport-fit=cover`)
- No `user-scalable=no`
- `100dvh` used, not `100vh` for full-height
- Body text ≥ 16px (no iOS auto-zoom on focus)
- Safe-area insets on fixed top/bottom bars
- No hover-only interactions (every `:hover` has `:focus-visible` + touch equivalent)
- DESIGN.md `contentPriority` block present for major routes

### 7. Container queries vs media queries
- Components in `components/ui/` should prefer container queries when sized by parent
- Page-level layouts use media queries

### 8. Forbidden tokens (AI Tells)
- No `#000000` or `#FFFFFF` literals in components (Pure Black Tell)
- No raw hex in components (only semantic tokens)
- No `Inter` without `font-feature-settings` or paired display font (Inter Tell)
- No purple → blue gradients matching `bg-gradient-to-r from-purple-* to-blue-*` (LILA BAN)
- No `text-transparent bg-clip-text bg-gradient-*` on `<h1>`/`<h2>` (Gradient Headline)

### 9. Forbidden content (AI Tells)
- No "Acme", "Nexus", "Lorem ipsum", "John Doe", "Jane Doe", "Sarah Chan" in shipped strings
- No `99.99%`, `100%`, `1234567` in demo numbers
- Filler Word Index: scan for "Elevate", "Unleash", "Seamless", "Next-gen", "Revolutionize", "Transform your workflow", "Cutting-edge", "Best-in-class", "Empowering"
- No raw Unsplash links (use `picsum.photos` or hosted assets)

### 10. Interactive states completeness
- Every fetch-using component has Loading / Empty / Error state
- Every interactive element has `:active` feedback (`-translate-y-[1px]` or `scale-[0.98]`)
- Buttons have `disabled` state styling

### 11. Animation hygiene
- Animates only `transform` and `opacity` (grep for `transition-all`, `transition-[height]`, `transition-[width]`)
- No `window.addEventListener('scroll')` (use IntersectionObserver / Framer's `useScroll`)
- `useState` not used for continuous hover animations on `motion.*` components

### 12. DESIGN.md compliance
- File exists at repo root
- YAML frontmatter parses
- Required keys present: `breakpoints`, `colors`, `typography`, `spacing`, `iconBudget`, `cls.target`, `aiTellsEnforced`
- Token values used in code match what `DESIGN.md` declares (no drift)

## Implementation strategies

### Layer 1 — pattern grep (fast, catches 70%)
Static analysis via `rg` / AST grep for the patterns above. Runs in seconds. See `scripts/validate-frontend.ts` for a starting implementation.

### Layer 2 — Lighthouse CI (catches dynamic issues)
Run Lighthouse against `next dev` or `vite preview` for affected routes. Catches actual CLS, LCP, contrast computation, mobile viewport issues.

### Layer 3 — visual regression (optional, expensive)
Playwright screenshot diffs at 360px / 768px / 1280px viewports. Catches the "looks broken" cases that pass static checks.

For most projects, Layer 1 + Layer 2 is enough.

## Output rules

- Lead with FAILURES (block merge)
- Then WARNINGS (review before merge)
- Then PASSED CHECKS (visibility into what was verified)
- Each finding includes `file:line` reference
- Each finding includes the rule name (so the dev can grep for the docs)
- Include a one-line "How to fix" per failure category, link to the relevant reference file (`frontend-foundation/references/icon-budget.md`, etc.)

## Non-goals

- This skill does NOT regenerate UI. It reports.
- This skill does NOT replace `react-performance`. They run together: `react-performance` audits render perf, this audits design contract compliance.
- This skill does NOT enforce business logic, accessibility-beyond-design (keyboard nav, ARIA roles), or test coverage. Pair with `testing-strategy`.

## Pairing with other skills

| Pairs with | When |
|---|---|
| `frontend-foundation` | Reads its 6 pillars as the rules to validate |
| `premium-frontend-design` | Reads its named AI Tells as additional checks |
| `react-performance` | Both run as review gates; complement (perf vs design) |
| `claude-md-keeper` | If validator detects systemic drift, suggests CLAUDE.md update |
| `sdd-workflow` | Run as part of "verify" phase before "archive" |

## Reference Files

- `references/check-catalog.md` — full catalog of every check, with example failure messages
- `references/lighthouse-integration.md` — how to wire Lighthouse CI into the gate
- `references/grep-patterns.md` — exact rg/AST patterns for static checks
- `scripts/validate-frontend.ts` — starting implementation of Layer 1 static checks
