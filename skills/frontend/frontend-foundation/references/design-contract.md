# Design Contract — `DESIGN.md` per Project

Every project ships a `DESIGN.md` at the repo root. The agent reads it at the start of every session. Without it, drift is guaranteed.

This format borrows from [Google Labs `DESIGN.md`](https://github.com/google-labs-code/design.md) (YAML tokens + markdown rationale) and extends it with Dublin-specific dimensions:

- `breakpoints` — explicit, mobile-first
- `motion` — durations + eases (Google's spec doesn't cover motion)
- `iconBudget` — counted, per region
- `contentPriority` — per screen, what's critical/primary/secondary/tertiary
- `aiTellsEnforced` — list of named anti-patterns the project explicitly forbids

---

## Why this exists

Skills tell the agent *how* to design. The Design Contract tells the agent *what this specific project's design is*. Without it, every session re-derives tokens from prose and drifts.

The contract is the project's source of truth — Tailwind config, CSS variables, component variants, and any AI prompts ALL flow from it.

---

## Full template

Save as `DESIGN.md` at the repo root.

```markdown
---
version: alpha-dublin
name: "Heritage"
description: "Architectural minimalism meets journalistic gravitas. Premium matte finish."

breakpoints:
  mobile: 360px       # design starts here, never below
  sm: 640px
  md: 768px
  lg: 1024px
  xl: 1280px
  2xl: 1440px

colors:
  # Light theme
  background-light: "#fafafa"
  foreground-light: "#0a0a0a"
  muted-light: "#f4f4f5"
  muted-foreground-light: "#71717a"
  border-light: "#e4e4e7"
  primary-light: "#1a1c1e"
  primary-foreground-light: "#fafafa"
  accent-light: "#b8422e"
  accent-foreground-light: "#fafafa"
  destructive-light: "#dc2626"
  success-light: "#16a34a"
  warning-light: "#d97706"
  # Dark theme
  background-dark: "#09090b"
  foreground-dark: "#fafafa"
  muted-dark: "#18181b"
  muted-foreground-dark: "#a1a1aa"
  border-dark: "#27272a"
  primary-dark: "#fafafa"
  primary-foreground-dark: "#09090b"
  accent-dark: "#d97757"
  accent-foreground-dark: "#09090b"
  destructive-dark: "#ef4444"
  success-dark: "#22c55e"
  warning-dark: "#eab308"

typography:
  display:
    fontFamily: "Geist"
    fontSize: "clamp(3rem, 8vw, 6rem)"
    fontWeight: 600
    lineHeight: 1.0
    letterSpacing: "-0.04em"
  h1:
    fontFamily: "Geist"
    fontSize: "clamp(2rem, 5vw + 1rem, 4rem)"
    fontWeight: 600
    lineHeight: 1.05
    letterSpacing: "-0.025em"
  h2:
    fontFamily: "Geist"
    fontSize: "clamp(1.5rem, 3vw + 0.5rem, 2.5rem)"
    fontWeight: 600
    lineHeight: 1.15
    letterSpacing: "-0.02em"
  body:
    fontFamily: "Geist"
    fontSize: "clamp(1rem, 0.5vw + 0.9rem, 1.125rem)"
    fontWeight: 400
    lineHeight: 1.6
  body-sm:
    fontFamily: "Geist"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.5
  caption:
    fontFamily: "Geist Mono"
    fontSize: "0.75rem"
    fontWeight: 500
    lineHeight: 1
    letterSpacing: "0.08em"

spacing:
  scale: [0, 4, 8, 12, 16, 24, 32, 48, 64, 80, 96, 128]
  container-max: 1280px
  section-py-mobile: 48px
  section-py-tablet: 80px
  section-py-desktop: 128px

rounded:
  none: 0
  sm: 4px
  md: 8px
  lg: 12px
  xl: 20px
  2xl: 28px
  full: 9999px

motion:
  duration:
    instant: 100ms
    fast: 150ms
    base: 250ms
    slow: 400ms
    deliberate: 600ms
  ease:
    default: "cubic-bezier(0.16, 1, 0.3, 1)"      # out-expo, hover/reveals
    enter: "cubic-bezier(0.16, 1, 0.3, 1)"
    exit: "cubic-bezier(0.4, 0, 1, 1)"
    themeToggle: "cubic-bezier(0.65, 0, 0.35, 1)" # S-curve, slow-fast-slow
    spring-soft: { type: "spring", stiffness: 100, damping: 20 }
    spring-snappy: { type: "spring", stiffness: 300, damping: 30 }

iconLibrary: "lucide-react"  # never mix
iconStrokeWidth: 2
iconBudget:
  topNav: 5
  bottomTab: 5
  hero: 1
  sectionHeader: 1
  card: 2
  listItem: 1
  footer: 3
  formField: 1
  button: 1
  emptyState: 1

contentPriority:
  homepage:
    critical: ["headline", "subheadline", "primary-CTA"]
    primary: ["3 value props", "social-proof logo strip"]
    secondary: ["pricing teaser", "testimonials"]
    tertiary: ["full footer nav", "blog teaser"]
  pricing:
    critical: ["plan names", "monthly price", "primary CTA per plan"]
    primary: ["top 5 features per plan"]
    secondary: ["full feature comparison table"]
    tertiary: ["FAQ", "footer"]
  product-detail:
    critical: ["product image", "name", "price", "add-to-cart CTA"]
    primary: ["variants", "key spec list"]
    secondary: ["reviews summary", "related products"]
    tertiary: ["full reviews list", "shipping info"]

cls:
  target: 0.05            # < 0.1 is "Good"; we aim better
  imagesNeed: ["width", "height"]  # OR aspect-ratio
  fontsNeed: ["display=swap", "size-adjust fallback", "preload"]

touchTargets:
  min: 44px               # Apple HIG / WCAG 2.5.5 AAA
  spacing: 8px            # min between adjacent targets

aiTellsEnforced:
  - "LILA BAN"            # no purple/blue AI gradients
  - "Pure Black Tell"     # no #000 / #fff
  - "Inter Tell"          # no default Inter
  - "Jane Doe Effect"     # no John Doe / Sarah Chan demo names
  - "Acme Slop"           # no Acme / Nexus brand names
  - "99.99% Problem"      # no predictable demo numbers
  - "Filler Word Index"   # no Elevate / Unleash / Seamless
  - "Generic 3-Card Row"  # no centered hero → 3 equal cards → CTA
  - "Icon Soup"           # icon budget enforced
  - "Mobile Afterthought" # mobile-first content priority required
  - "Layout Shift Sloppy" # CLS < 0.05 mandatory
---

## Brand & Style

This product is **Heritage** — a premium reading experience for a long-form journalism platform.

The voice is institutional, considered, never breathless. The visual language is matte ink on warm paper. Restraint is the core rule: every element earns its place.

## Colors

The palette is rooted in high-contrast neutrals with a single warm accent.

- **Background (#fafafa light / #09090b dark):** Warm off-white / deep ink. Never pure `#fff` or `#000` (Pure Black Tell).
- **Foreground (#0a0a0a / #fafafa):** Maximum readability for long-form text.
- **Accent — Boston Clay (#b8422e):** Single interaction driver. Used exclusively for primary actions and key links. Saturation < 80%.
- **Status colors** are systemic; never used decoratively.

## Typography

Geist (variable) for everything. Geist Mono for technical metadata, captions, timestamps.

Headlines: heavy negative tracking (`-0.025em`+), tight line-height (1.0–1.15). Body: relaxed line-height (1.6) at fluid `clamp()` scale. Captions: uppercase, wide tracking (0.08em).

**Banned:** Inter without heavy customization (Inter Tell). Default font weights without contrast. Gradient text on headlines.

## Layout & Spacing

Fluid grid mobile, max-width 1280px desktop. 8px-based spacing scale, no arbitrary values.

Sections breathe: `48px` mobile → `80px` tablet → `128px` desktop top/bottom padding. Major section spacing 96–128px.

All interactive components ≥ 44×44 CSS px tap targets, 8px between adjacent targets.

## Motion

Restrained. Default ease is out-expo (slow-fast). Theme toggle is the rare exception — uses S-curve `cubic-bezier(0.65, 0, 0.35, 1)` (slow-fast-slow) via View Transitions API.

No magnetic buttons unless `MOTION_INTENSITY ≥ 7`. No scroll parallax on body content (causes CLS, breaks reduced-motion).

## Icons

`lucide-react` only. Stroke 2. Sizes from the scale (14/16/20/24/32/40 px).

Budget per region is non-negotiable (see YAML). Icon Soup is a fail.

## Content Priority

Mobile-first. The `contentPriority` block in YAML is the source of truth — every layout PR is reviewed against it.

If a screen isn't in the YAML, the screen is undesigned.

## CLS Discipline

Target < 0.05. Every PR runs Lighthouse on the diff'd routes. If CLS regresses, the PR is blocked.

## Forbidden (AI Tells)

The `aiTellsEnforced` list is enforced in code review. Any of these ship = revert.
```

---

## How to enforce in CI

### Lightweight: validate the YAML at build time

```ts
// scripts/validate-design.ts
import fs from 'node:fs';
import matter from 'gray-matter';
import { z } from 'zod';

const DesignSchema = z.object({
  breakpoints: z.object({
    mobile: z.string(),
    sm: z.string(),
    md: z.string(),
    lg: z.string(),
    xl: z.string(),
  }),
  colors: z.record(z.string(), z.string()),
  iconBudget: z.record(z.string(), z.number()),
  cls: z.object({ target: z.number().max(0.1) }),
  touchTargets: z.object({ min: z.string(), spacing: z.string() }),
  aiTellsEnforced: z.array(z.string()).min(5),
  contentPriority: z.record(z.string(), z.object({
    critical: z.array(z.string()),
    primary: z.array(z.string()),
  })),
});

const raw = fs.readFileSync('DESIGN.md', 'utf-8');
const { data } = matter(raw);
const parsed = DesignSchema.safeParse(data);

if (!parsed.success) {
  console.error('DESIGN.md validation failed:');
  console.error(parsed.error.flatten());
  process.exit(1);
}

console.log('✓ DESIGN.md valid');
```

```jsonc
// package.json
{
  "scripts": {
    "validate:design": "tsx scripts/validate-design.ts",
    "prebuild": "pnpm validate:design"
  }
}
```

### Heavier: use Google's CLI for contrast + diff

```bash
# Validate contrast ratios, broken token refs, structural issues
npx @google/design.md lint DESIGN.md

# Diff against the previous version (regression detection)
npx @google/design.md diff DESIGN.md DESIGN.previous.md
```

If you want to use Google's CLI, mirror your DESIGN.md frontmatter to be schema-compatible (drop the Dublin-specific keys before linting, or use a separate `tokens.yaml` for the Google-compatible subset).

---

## Workflow per project

1. **Project init** — copy template above to `DESIGN.md`, fill in the project-specific values, **before any UI code**
2. **CI** — `pnpm validate:design` runs on every push (blocks merge if YAML invalid)
3. **Every session** — agent reads `DESIGN.md` at the start (auto-loaded as context)
4. **Updates** — when tokens change, update `DESIGN.md` first, then regenerate Tailwind config / CSS vars from it
5. **Review gate** — `frontend-output-validator` skill checks generated UI against the contract (icon counts, contrast, mobile-first compliance)

---

## How this works with `frontend-foundation` and `premium-frontend-design`

- `frontend-foundation` reads `DESIGN.md` to know the project's tokens, breakpoints, icon library
- `premium-frontend-design` reads `DESIGN.md` to know which AI Tells are explicitly enforced + the motion dials
- `frontend-output-validator` reads `DESIGN.md` to know the budgets/targets it must enforce

The contract is the project's design system. The skills are the methodology. The agent applies the methodology against the contract.
