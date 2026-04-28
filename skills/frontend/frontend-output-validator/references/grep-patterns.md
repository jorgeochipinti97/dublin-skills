# Static Check Patterns (`rg` / AST grep)

Layer 1 of the validator: pattern matching. Catches ~70% of issues in seconds.

Use `rg` (ripgrep) for text patterns. For AST-aware checks (e.g. JSX prop counting), use `ast-grep` or a small TypeScript script with `@babel/parser`.

---

## CLS sources

### `<img>` without dimensions

```bash
# Find img tags missing width or height attributes
rg --type tsx --type jsx -U \
  '<img\s+(?![^>]*\b(width|height|aspect-)\b)[^>]*>' \
  src/
```

### Iframe without aspect-ratio wrapper (heuristic)

```bash
# Find iframes whose containing element doesn't include 'aspect-' class
rg --type tsx -B 2 '<iframe' src/ \
  | grep -v 'aspect-' \
  | grep '<iframe'
```

### Web font without size-adjust fallback

```bash
# Find @font-face declarations missing size-adjust
rg -U '@font-face\s*\{[^}]*\}' src/ \
  | grep -v 'size-adjust'
```

### Banner / cookie / toast inserted in body flow

```bash
# Heuristic: components named *Banner / *Notice / Cookie* not using fixed positioning
rg --type tsx 'function\s+(Cookie|Banner|Notice)\w*' src/ \
  | grep -v 'fixed'
```

### `transition-[height]` / `transition-[width]` / `transition-all`

```bash
rg --type tsx -e 'transition-\[height\]' -e 'transition-\[width\]' -e 'transition-all' src/
```

---

## Icon checks

### Mixed icon libraries

```bash
# Detects multiple icon library imports
rg --type tsx -e "from 'lucide-react'" -e "from '@phosphor-icons/react'" -e "from '@radix-ui/react-icons'" -e "from '@heroicons/react" src/ \
  | awk -F"'" '{print $2}' | sort -u
```

If the count > 1 → fail.

### Icons per file (heuristic count)

```bash
# Count icon imports per file
rg --type tsx -c "from '(lucide-react|@phosphor-icons/react|@radix-ui/react-icons|@heroicons/react)" src/
```

For per-region budget enforcement, AST-grep the JSX tree:

```yaml
# ast-grep rule: count icon-element children of a nav element
id: nav-icon-budget
language: tsx
rule:
  pattern: <nav $$>$$$BODY</nav>
  has:
    pattern: <$ICON $$ />
    inside:
      pattern: <nav $$>$$$BODY</nav>
```

Then count `$ICON` matches and compare to `iconBudget.topNav` from `DESIGN.md`.

---

## Touch targets

### Tailwind sizing < 44px on interactive elements

```bash
# Find buttons / interactive elements with size-* < 11 (size-11 = 44px)
rg --type tsx -e '<button[^>]*\bsize-([1-9]|10)\b' src/ \
  -e '<a[^>]*role="button"[^>]*\bsize-([1-9]|10)\b'
```

(Note: this misses padding-based sizing; combine with bbox computation for accuracy.)

---

## Mobile-first

### Viewport meta

```bash
# Verify presence in layout
rg "name=['\"]viewport['\"]" src/app/layout.tsx src/pages/_document.tsx 2>/dev/null

# Reject user-scalable=no
rg "user-scalable\s*=\s*no" src/
```

### `100vh` instead of `100dvh`

```bash
rg --type tsx --type css \
  -e '\bh-screen\b' \
  -e '\bmin-h-screen\b' \
  -e '\bh-\[100vh\]\b' \
  -e '\bmin-h-\[100vh\]\b' \
  -e '\b100vh\b' \
  src/
```

### Body text < 16px

```bash
# Form inputs/textareas with text-sm or smaller
rg --type tsx -e '<input[^>]*\btext-(xs|sm)\b' -e '<textarea[^>]*\btext-(xs|sm)\b' src/
```

### Fixed bottom bar without safe-area

```bash
# Heuristic: classes containing 'fixed bottom' without 'safe-area' or 'env('
rg --type tsx '\bfixed\b[^"]*\bbottom-0\b' src/ \
  | grep -v 'safe-area\|env(safe-area'
```

### Hover-only interactions

```bash
# Find hover: rules without focus-visible: counterpart in same className
rg --type tsx 'hover:' src/ \
  | grep -v 'focus-visible:\|focus:\|active:'
```

---

## Forbidden tokens

### Pure Black Tell

```bash
# Hex literals for pure black/white in components (NOT in tokens.css/globals.css)
rg --type tsx -e '#000\b' -e '#000000\b' -e '#fff\b' -e '#ffffff\b' \
  -e 'bg-\[#000' -e 'bg-\[#fff' \
  src/components/ src/app/
```

### Raw hex in components (should be semantic tokens)

```bash
rg --type tsx 'bg-\[#[0-9a-fA-F]+\]\|text-\[#[0-9a-fA-F]+\]\|border-\[#[0-9a-fA-F]+\]' \
  src/components/ src/app/
```

### LILA BAN (purple-blue gradient)

```bash
rg --type tsx \
  -e 'from-(purple|violet|indigo)-\d+\s+to-(blue|sky|indigo)-\d+' \
  -e 'bg-gradient.*purple.*blue' \
  src/
```

### Gradient text on headline

```bash
rg --type tsx 'text-transparent[^"]*bg-clip-text' src/
```

### Inter Tell

```bash
# Inter without customization (no font-feature-settings, no pairing)
rg --type tsx --type css -e "fontFamily:\s*['\"]Inter" -e "font-family:\s*['\"]Inter" src/ \
  | head
# Then verify globals.css has font-feature-settings or a paired display font
rg --type css 'font-feature-settings' src/
```

---

## Forbidden content

### Generic demo names / brands

```bash
rg -i \
  -e '\bjohn doe\b' -e '\bjane doe\b' -e '\bsarah chan\b' -e '\bjack su\b' \
  -e '\bacme\b' -e '\bnexus\b' -e '\bsmartflow\b' -e '\bflowai\b' \
  -e 'lorem ipsum' \
  src/ public/
```

### Filler Word Index

```bash
rg -i \
  -e '\bElevate\b' -e '\bUnleash\b' -e '\bSeamless\b' -e '\bNext-gen\b' \
  -e '\bRevolutionize\b' -e '\bGame-changing\b' -e '\bEmpowering\b' \
  -e '"Transform your workflow"' -e '\bUnlock the power of\b' \
  -e '\bCutting-edge\b' -e '\bState-of-the-art\b' -e '\bBest-in-class\b' \
  src/ public/
```

### 99.99% Problem (predictable numbers)

```bash
rg -e '\b99\.99%\b' -e '\b100%\b' -e '\b1234567\b' -e '\$9\.99\b' src/ public/
```

### Raw Unsplash links

```bash
rg 'https://(images\.)?unsplash\.com' src/ public/
```

---

## Animations

### `addEventListener('scroll')`

```bash
rg "addEventListener\s*\(\s*['\"]scroll['\"]" src/
```

### `useState` for hover animation (heuristic)

```bash
# Find motion.* with useState in same file (review manually)
rg --files-with-matches 'motion\.(div|button|a)' src/ \
  | xargs rg -l 'useState'
```

### Linear easing

```bash
rg --type tsx --type css 'ease-linear\|transition-timing-function:\s*linear' src/
```

---

## DESIGN.md compliance

### File exists

```bash
test -f DESIGN.md || echo "DESIGN.md missing at repo root"
```

### YAML parses (Node script)

```ts
import fs from 'node:fs';
import matter from 'gray-matter';
const { data } = matter(fs.readFileSync('DESIGN.md', 'utf-8'));
// data is the parsed YAML; throw if missing required keys
```

### Token drift (compare DESIGN.md tokens vs Tailwind config / CSS vars)

```ts
// Pseudocode
const designTokens = parseFrontmatter('DESIGN.md').colors;
const cssTokens = extractCssVars('src/app/globals.css');
for (const [key, value] of Object.entries(designTokens)) {
  if (cssTokens[key] !== value) {
    report(`drift: ${key} = ${value} in DESIGN.md, ${cssTokens[key]} in CSS`);
  }
}
```

---

## Notes on accuracy

These patterns are **heuristics**. They catch the obvious 70%. Combine with:
- Lighthouse for actual computed CLS / contrast
- Playwright screenshot diffs for visual regressions
- Manual review for the 30% the patterns miss

False positives are acceptable for warnings. False negatives on `🔴 fail` rules are not — keep those patterns conservative (lean toward false positives over missed issues).
