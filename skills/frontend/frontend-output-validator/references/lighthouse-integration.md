# Lighthouse Integration (Layer 2)

Static patterns catch ~70%. Lighthouse catches the dynamic ones — actual CLS, computed contrast, mobile viewport rendering, image sizing in practice.

---

## When to add Lighthouse

- After Layer 1 static checks pass (no point running Lighthouse if obvious failures exist)
- On every PR that touches > 1 route
- Pre-merge gate (block merge on regression)

Skip Lighthouse on:
- Component-only changes (no route affected)
- Backend / config / docs

---

## Setup with `lhci` (Lighthouse CI)

```bash
pnpm add -D @lhci/cli
```

`lighthouserc.json`:

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/", "http://localhost:3000/pricing"],
      "startServerCommand": "pnpm start",
      "numberOfRuns": 3,
      "settings": {
        "preset": "desktop",
        "throttlingMethod": "simulate"
      }
    },
    "assert": {
      "assertions": {
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.05 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "total-blocking-time": ["warn", { "maxNumericValue": 200 }],
        "color-contrast": "error",
        "tap-targets": "error",
        "viewport": "error",
        "image-aspect-ratio": "error",
        "image-size-responsive": "warn",
        "uses-rel-preconnect": "warn",
        "font-display": "error"
      }
    },
    "upload": { "target": "temporary-public-storage" }
  }
}
```

Run mobile separately:

```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000/", "http://localhost:3000/pricing"],
      "settings": {
        "preset": "mobile",
        "screenEmulation": { "mobile": true, "width": 360, "height": 800 }
      }
    }
  }
}
```

---

## Critical audits to assert

| Lighthouse audit | Maps to | Threshold |
|---|---|---|
| `cumulative-layout-shift` | CLS Zero | < 0.05 |
| `largest-contentful-paint` | LCP | < 2.5s |
| `color-contrast` | Contrast (WCAG) | pass |
| `tap-targets` | Touch targets | pass |
| `viewport` | Viewport meta | pass |
| `image-aspect-ratio` | CLS image | pass |
| `font-display` | CLS font | pass |
| `unused-css-rules` | Bundle | warn only |
| `unminified-css` / `unminified-javascript` | Build | warn |

---

## Run on PR (GitHub Actions)

`.github/workflows/lighthouse.yml`:

```yaml
name: Lighthouse
on: [pull_request]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with: { node-version: 20, cache: pnpm }
      - run: pnpm install
      - run: pnpm build
      - run: pnpm lhci autorun
      - if: failure()
        run: echo "Lighthouse failed — check artifact for details"
```

---

## Per-route content priority verification

The validator can also use Lighthouse to verify mobile content priority is respected:

1. Open the route at 360×800 viewport
2. Capture viewport screenshot (above fold)
3. Detect text content in viewport (DOM scan)
4. Compare against `DESIGN.md` `contentPriority.<route>.critical`

If a "critical" element is NOT in the above-fold viewport on mobile, fail the check.

```ts
// Pseudocode
const critical = designMd.contentPriority['pricing'].critical;
const aboveFoldText = await page.evaluate(() =>
  Array.from(document.querySelectorAll('h1, h2, h3, button, a'))
    .filter(el => el.getBoundingClientRect().top < window.innerHeight)
    .map(el => el.textContent?.trim())
);
for (const item of critical) {
  if (!aboveFoldText.some(t => t?.includes(item))) {
    fail(`critical content "${item}" not above fold on mobile`);
  }
}
```

---

## Combining Layer 1 + Layer 2

```bash
# Layer 1 — static checks (fast)
pnpm validate:design && pnpm validate:frontend

# Layer 2 — Lighthouse (slow, but catches dynamic issues)
pnpm lhci autorun

# Combined gate
pnpm validate && pnpm lhci autorun
```

`package.json`:

```jsonc
{
  "scripts": {
    "validate:design": "tsx scripts/validate-design.ts",
    "validate:frontend": "tsx skills/frontend-output-validator/scripts/validate-frontend.ts",
    "validate": "pnpm validate:design && pnpm validate:frontend",
    "ci": "pnpm validate && pnpm lhci autorun"
  }
}
```

---

## Optional: Layer 3 — Visual regression (Playwright screenshots)

For premium products where visual regressions are unacceptable:

```ts
// e2e/visual.spec.ts
import { test, expect } from '@playwright/test';

const VIEWPORTS = [
  { name: 'mobile', width: 360, height: 800 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1280, height: 800 },
];

for (const vp of VIEWPORTS) {
  for (const route of ['/', '/pricing', '/about']) {
    test(`${route} ${vp.name}`, async ({ page }) => {
      await page.setViewportSize({ width: vp.width, height: vp.height });
      await page.goto(route);
      await page.waitForLoadState('networkidle');
      await expect(page).toHaveScreenshot(`${route.replace('/', 'home')}-${vp.name}.png`, {
        maxDiffPixelRatio: 0.01,
      });
    });
  }
}
```

This is expensive (snapshot maintenance) — only worth it for premium / consumer-facing products. Skip for internal tools.
