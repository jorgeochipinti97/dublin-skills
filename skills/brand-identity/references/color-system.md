# Color System Reference

Complete color palettes for brand identity. Choose one neutral foundation + one accent family.

---

## Neutral Foundations

### Pure Neutral (Apple-style)
Best for: Tech products, minimal interfaces, premium SaaS

```css
/* Dark Mode */
--neutral-950: #000000;  /* Background - OLED black */
--neutral-900: #0a0a0a;  /* Background - LCD black */
--neutral-850: #141414;  /* Elevated surface */
--neutral-800: #1c1c1e;  /* Card background */
--neutral-700: #2c2c2e;  /* Secondary surface */
--neutral-600: #3a3a3c;  /* Border strong */
--neutral-500: #48484a;  /* Border default */
--neutral-400: #636366;  /* Placeholder text */
--neutral-300: #86868b;  /* Secondary text */
--neutral-200: #aeaeb2;  /* Tertiary text */
--neutral-100: #e5e5e7;  /* Primary text (light) */
--neutral-50: #f5f5f7;   /* Primary text */

/* Light Mode */
--neutral-light-50: #ffffff;
--neutral-light-100: #f5f5f7;
--neutral-light-200: #e5e5e7;
--neutral-light-300: #d1d1d6;
--neutral-light-400: #c7c7cc;
--neutral-light-500: #aeaeb2;
--neutral-light-600: #8e8e93;
--neutral-light-700: #636366;
--neutral-light-800: #48484a;
--neutral-light-900: #1c1c1e;
```

### Cool Neutral (Linear-style)
Best for: Developer tools, productivity apps, B2B software

```css
/* Dark Mode - subtle blue undertone */
--cool-950: #030712;
--cool-900: #0f172a;
--cool-800: #1e293b;
--cool-700: #334155;
--cool-600: #475569;
--cool-500: #64748b;
--cool-400: #94a3b8;
--cool-300: #cbd5e1;
--cool-200: #e2e8f0;
--cool-100: #f1f5f9;
--cool-50: #f8fafc;
```

### Warm Neutral (Notion-style)
Best for: Content apps, note-taking, creative tools

```css
/* Dark Mode - subtle brown undertone */
--warm-950: #0c0a09;
--warm-900: #1c1917;
--warm-800: #292524;
--warm-700: #44403c;
--warm-600: #57534e;
--warm-500: #78716c;
--warm-400: #a8a29e;
--warm-300: #d6d3d1;
--warm-200: #e7e5e4;
--warm-100: #f5f5f4;
--warm-50: #fafaf9;
```

---

## Accent Palettes

### Electric Blue
Best for: Tech, fintech, enterprise
```css
--accent-50: #eff6ff;
--accent-100: #dbeafe;
--accent-200: #bfdbfe;
--accent-300: #93c5fd;
--accent-400: #60a5fa;
--accent-500: #3b82f6;  /* Primary */
--accent-600: #2563eb;
--accent-700: #1d4ed8;
--accent-800: #1e40af;
--accent-900: #1e3a8a;
--accent-glow: rgba(59, 130, 246, 0.5);
```

### Violet (Refined)
Best for: Creative tools, design software, premium products
```css
--accent-50: #f5f3ff;
--accent-100: #ede9fe;
--accent-200: #ddd6fe;
--accent-300: #c4b5fd;
--accent-400: #a78bfa;
--accent-500: #8b5cf6;  /* Primary */
--accent-600: #7c3aed;
--accent-700: #6d28d9;
--accent-800: #5b21b6;
--accent-900: #4c1d95;
--accent-glow: rgba(139, 92, 246, 0.5);
```

### Emerald
Best for: Finance, health, sustainability
```css
--accent-50: #ecfdf5;
--accent-100: #d1fae5;
--accent-200: #a7f3d0;
--accent-300: #6ee7b7;
--accent-400: #34d399;
--accent-500: #10b981;  /* Primary */
--accent-600: #059669;
--accent-700: #047857;
--accent-800: #065f46;
--accent-900: #064e3b;
--accent-glow: rgba(16, 185, 129, 0.5);
```

### Amber
Best for: Marketplaces, e-commerce, warm brands
```css
--accent-50: #fffbeb;
--accent-100: #fef3c7;
--accent-200: #fde68a;
--accent-300: #fcd34d;
--accent-400: #fbbf24;
--accent-500: #f59e0b;  /* Primary */
--accent-600: #d97706;
--accent-700: #b45309;
--accent-800: #92400e;
--accent-900: #78350f;
--accent-glow: rgba(245, 158, 11, 0.5);
```

### Rose
Best for: Lifestyle, beauty, social apps
```css
--accent-50: #fff1f2;
--accent-100: #ffe4e6;
--accent-200: #fecdd3;
--accent-300: #fda4af;
--accent-400: #fb7185;
--accent-500: #f43f5e;  /* Primary */
--accent-600: #e11d48;
--accent-700: #be123c;
--accent-800: #9f1239;
--accent-900: #881337;
--accent-glow: rgba(244, 63, 94, 0.5);
```

### Cyan
Best for: AI/ML products, data visualization, modern tech
```css
--accent-50: #ecfeff;
--accent-100: #cffafe;
--accent-200: #a5f3fc;
--accent-300: #67e8f9;
--accent-400: #22d3ee;
--accent-500: #06b6d4;  /* Primary */
--accent-600: #0891b2;
--accent-700: #0e7490;
--accent-800: #155e75;
--accent-900: #164e63;
--accent-glow: rgba(6, 182, 212, 0.5);
```

---

## Semantic Colors

Use muted versions that don't compete with brand accent.

```css
/* Success - muted green */
--success-bg: rgba(16, 185, 129, 0.1);
--success-border: rgba(16, 185, 129, 0.2);
--success-text: #34d399;
--success-solid: #10b981;

/* Warning - muted amber */
--warning-bg: rgba(245, 158, 11, 0.1);
--warning-border: rgba(245, 158, 11, 0.2);
--warning-text: #fbbf24;
--warning-solid: #f59e0b;

/* Error - muted red */
--error-bg: rgba(239, 68, 68, 0.1);
--error-border: rgba(239, 68, 68, 0.2);
--error-text: #f87171;
--error-solid: #ef4444;

/* Info - muted blue */
--info-bg: rgba(59, 130, 246, 0.1);
--info-border: rgba(59, 130, 246, 0.2);
--info-text: #60a5fa;
--info-solid: #3b82f6;
```

---

## Glass & Overlay Colors

```css
/* Glass backgrounds */
--glass-light: rgba(255, 255, 255, 0.05);
--glass-medium: rgba(255, 255, 255, 0.08);
--glass-heavy: rgba(255, 255, 255, 0.12);

/* Borders */
--border-subtle: rgba(255, 255, 255, 0.06);
--border-default: rgba(255, 255, 255, 0.1);
--border-strong: rgba(255, 255, 255, 0.15);

/* Shadows (colored for depth) */
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);
--shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
--shadow-xl: 0 25px 50px rgba(0, 0, 0, 0.6);

/* Glow (use accent color) */
--glow-sm: 0 0 20px var(--accent-glow);
--glow-md: 0 0 40px var(--accent-glow);
--glow-lg: 0 0 60px var(--accent-glow);
```

---

## Contrast Checker

Minimum ratios (WCAG 2.1):
- **Normal text**: 4.5:1
- **Large text (18px+ or 14px bold)**: 3:1
- **UI components**: 3:1

**Safe combinations on dark (#0a0a0a):**
| Text Color | Hex | Ratio |
|------------|-----|-------|
| Primary | #f5f5f7 | 18.1:1 |
| Secondary | #86868b | 6.2:1 |
| Tertiary | #636366 | 4.1:1 |
| Quaternary | #48484a | 2.9:1 (large only) |

**Safe combinations on light (#f5f5f7):**
| Text Color | Hex | Ratio |
|------------|-----|-------|
| Primary | #1c1c1e | 15.8:1 |
| Secondary | #636366 | 5.4:1 |
| Tertiary | #86868b | 3.8:1 (large only) |

---

## Complete CSS Variables Template

```css
:root {
  /* Neutral Foundation */
  --background: #0a0a0a;
  --surface: #1c1c1e;
  --surface-elevated: #2c2c2e;

  /* Text */
  --text-primary: #f5f5f7;
  --text-secondary: #86868b;
  --text-tertiary: #636366;

  /* Borders */
  --border: rgba(255, 255, 255, 0.1);
  --border-strong: rgba(255, 255, 255, 0.15);

  /* Accent (choose one palette) */
  --accent: #3b82f6;
  --accent-hover: #2563eb;
  --accent-glow: rgba(59, 130, 246, 0.5);

  /* Semantic */
  --success: #10b981;
  --warning: #f59e0b;
  --error: #ef4444;
}

/* Dark mode is default. Light mode overrides: */
@media (prefers-color-scheme: light) {
  :root {
    --background: #ffffff;
    --surface: #f5f5f7;
    --surface-elevated: #ffffff;
    --text-primary: #1c1c1e;
    --text-secondary: #636366;
    --text-tertiary: #86868b;
    --border: rgba(0, 0, 0, 0.1);
    --border-strong: rgba(0, 0, 0, 0.15);
  }
}
```
