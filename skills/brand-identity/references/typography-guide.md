# Typography System Reference

Complete typography guidelines for premium brand identity.

---

## Font Pairing Matrix

Choose ONE pairing per project. Display + Body + optional Mono.

### Premium Tech (Apple-like)
```css
--font-display: "SF Pro Display", system-ui, sans-serif;
--font-body: "SF Pro Text", system-ui, sans-serif;
--font-mono: "SF Mono", ui-monospace, monospace;
```
**Load**: System fonts, no import needed on Apple devices
**Vibe**: Clean, professional, universally trusted

### Modern Startup (Vercel-like)
```css
--font-display: "Geist", system-ui, sans-serif;
--font-body: "Geist", system-ui, sans-serif;
--font-mono: "Geist Mono", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.cdnfonts.com/css/geist');`
**Vibe**: Contemporary, developer-friendly, sharp

### Geometric Clean
```css
--font-display: "Satoshi", system-ui, sans-serif;
--font-body: "Inter", system-ui, sans-serif;
--font-mono: "JetBrains Mono", ui-monospace, monospace;
```
**Load**:
- Satoshi: fontshare.com
- Inter: `@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');`
**Vibe**: Friendly but professional, startup favorite

### Editorial Luxury
```css
--font-display: "Instrument Serif", Georgia, serif;
--font-body: "Instrument Sans", system-ui, sans-serif;
--font-mono: "IBM Plex Mono", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Instrument+Serif&family=Instrument+Sans:wght@400;500;600&display=swap');`
**Vibe**: Magazine quality, content-first, refined

### Classic Elegance
```css
--font-display: "Playfair Display", Georgia, serif;
--font-body: "Source Sans 3", system-ui, sans-serif;
--font-mono: "Source Code Pro", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Source+Sans+3:wght@400;500;600&display=swap');`
**Vibe**: Traditional luxury, high-end services

### Tech Forward
```css
--font-display: "Space Grotesk", system-ui, sans-serif;
--font-body: "DM Sans", system-ui, sans-serif;
--font-mono: "DM Mono", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=DM+Sans:wght@400;500;600&display=swap');`
**Vibe**: Futuristic, technical, innovative

### Bold Creative
```css
--font-display: "Syne", system-ui, sans-serif;
--font-body: "Work Sans", system-ui, sans-serif;
--font-mono: "Fira Code", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=Work+Sans:wght@400;500;600&display=swap');`
**Vibe**: Creative agency, bold statements, distinctive

### Sophisticated Modern
```css
--font-display: "Bricolage Grotesque", system-ui, sans-serif;
--font-body: "IBM Plex Sans", system-ui, sans-serif;
--font-mono: "IBM Plex Mono", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@400;500;600;700&family=IBM+Plex+Sans:wght@400;500;600&display=swap');`
**Vibe**: Intellectual, thoughtful, enterprise-ready

### Clean Geometric
```css
--font-display: "Manrope", system-ui, sans-serif;
--font-body: "Manrope", system-ui, sans-serif;
--font-mono: "JetBrains Mono", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&display=swap');`
**Vibe**: Balanced, versatile, works everywhere

### Friendly Premium
```css
--font-display: "Plus Jakarta Sans", system-ui, sans-serif;
--font-body: "Plus Jakarta Sans", system-ui, sans-serif;
--font-mono: "Fira Code", ui-monospace, monospace;
```
**Load**: `@import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap');`
**Vibe**: Approachable, modern, consumer-friendly

---

## Type Scale

Use **Major Third (1.25)** or **Perfect Fourth (1.333)** ratio.

### Major Third Scale (1.25)
Subtle, refined progression. Best for content-heavy interfaces.

```css
--text-xs: 0.64rem;    /* 10.24px */
--text-sm: 0.8rem;     /* 12.8px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.25rem;    /* 20px */
--text-xl: 1.563rem;   /* 25px */
--text-2xl: 1.953rem;  /* 31.25px */
--text-3xl: 2.441rem;  /* 39px */
--text-4xl: 3.052rem;  /* 48.8px */
--text-5xl: 3.815rem;  /* 61px */
--text-6xl: 4.768rem;  /* 76.3px */
```

### Perfect Fourth Scale (1.333)
More dramatic jumps. Best for marketing sites, hero sections.

```css
--text-xs: 0.563rem;   /* 9px */
--text-sm: 0.75rem;    /* 12px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.333rem;   /* 21.3px */
--text-xl: 1.777rem;   /* 28.4px */
--text-2xl: 2.369rem;  /* 37.9px */
--text-3xl: 3.157rem;  /* 50.5px */
--text-4xl: 4.209rem;  /* 67.3px */
--text-5xl: 5.61rem;   /* 89.8px */
--text-6xl: 7.478rem;  /* 119.6px */
```

---

## Letter Spacing (Tracking)

Critical for premium feel. Headlines need tighter tracking.

```css
--tracking-tighter: -0.05em;  /* Display headlines */
--tracking-tight: -0.025em;   /* Subheadlines */
--tracking-normal: 0;          /* Body text */
--tracking-wide: 0.025em;      /* All caps labels */
--tracking-wider: 0.05em;      /* Small caps */
--tracking-widest: 0.1em;      /* Spaced letters */
```

**Rules:**
- Headlines (32px+): Always use `-0.02em` to `-0.05em`
- Body text: Leave at `0` or very slight negative
- ALL CAPS text: Always add positive tracking (`0.05em`+)
- Small text: Slightly positive tracking improves readability

---

## Line Height (Leading)

```css
--leading-none: 1;        /* Single line headlines */
--leading-tight: 1.15;    /* Multi-line headlines */
--leading-snug: 1.375;    /* Subheadlines */
--leading-normal: 1.5;    /* Short paragraphs */
--leading-relaxed: 1.625; /* Body text */
--leading-loose: 1.75;    /* Long-form reading */
```

**Rules:**
- Headlines: `1.1` to `1.2`
- Body: `1.5` to `1.75`
- Larger text = tighter leading
- Smaller text = looser leading

---

## Font Weights

Standard weight mapping for variable fonts:

```css
--font-thin: 100;
--font-extralight: 200;
--font-light: 300;
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
--font-extrabold: 800;
--font-black: 900;
```

**Recommended usage:**
- Body text: 400 (normal)
- UI labels: 500 (medium)
- Subheadlines: 500-600
- Headlines: 600-700
- Hero text: 700-800

---

## Responsive Typography

Scale down 20-30% on mobile. Use CSS clamp() for fluid sizing.

```css
/* Fluid headlines */
--text-hero: clamp(2.5rem, 5vw + 1rem, 5rem);
--text-display: clamp(2rem, 4vw + 0.5rem, 3.5rem);
--text-heading: clamp(1.5rem, 3vw + 0.5rem, 2.5rem);
--text-subheading: clamp(1.125rem, 2vw + 0.5rem, 1.5rem);

/* Example usage */
h1 {
  font-size: var(--text-hero);
  font-weight: 700;
  letter-spacing: -0.03em;
  line-height: 1.1;
}
```

---

## Complete CSS Template

```css
/* Font imports - choose your pairing */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
  /* Font families */
  --font-display: "Satoshi", system-ui, sans-serif;
  --font-body: "Inter", system-ui, sans-serif;
  --font-mono: "JetBrains Mono", ui-monospace, monospace;

  /* Type scale (Major Third) */
  --text-xs: 0.64rem;
  --text-sm: 0.8rem;
  --text-base: 1rem;
  --text-lg: 1.25rem;
  --text-xl: 1.563rem;
  --text-2xl: 1.953rem;
  --text-3xl: 2.441rem;
  --text-4xl: 3.052rem;
  --text-5xl: 3.815rem;

  /* Tracking */
  --tracking-tight: -0.025em;
  --tracking-normal: 0;

  /* Leading */
  --leading-tight: 1.15;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
}

/* Base styles */
body {
  font-family: var(--font-body);
  font-size: var(--text-base);
  line-height: var(--leading-relaxed);
  letter-spacing: var(--tracking-normal);
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

h1, h2, h3, h4, h5, h6 {
  font-family: var(--font-display);
  letter-spacing: var(--tracking-tight);
  line-height: var(--leading-tight);
}

code, pre {
  font-family: var(--font-mono);
}
```

---

## Anti-Patterns

**NEVER:**
- Use more than 2 font families (plus mono)
- Skip letter-spacing adjustments on headlines
- Use default line-height (usually too tight)
- Load unnecessary font weights (performance)
- Use Inter without heavy customization
- Set body text below 16px on mobile
- Use light weights (300) for body text on screens

**ALWAYS:**
- Test fonts at actual sizes before committing
- Include proper fallback stacks
- Use `font-display: swap` for web fonts
- Enable font smoothing on dark backgrounds
- Check rendering on Windows (often rougher)
