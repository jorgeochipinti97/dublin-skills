# Typography System

Premium typography implementation for luxury frontend interfaces.

---

## Font Loading

### Google Fonts (Recommended for Quick Start)
```tsx
// In Next.js app/layout.tsx or _app.tsx
import { Plus_Jakarta_Sans, Instrument_Serif, Geist, Geist_Mono } from 'next/font/google';

// Display font (headlines)
const displayFont = Instrument_Serif({
  subsets: ['latin'],
  weight: ['400'],
  variable: '--font-display',
  display: 'swap',
});

// Body font
const bodyFont = Plus_Jakarta_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700'],
  variable: '--font-body',
  display: 'swap',
});

// Mono font (code, numbers)
const monoFont = Geist_Mono({
  subsets: ['latin'],
  variable: '--font-mono',
  display: 'swap',
});

// Apply in layout
<html className={`${displayFont.variable} ${bodyFont.variable} ${monoFont.variable}`}>
```

### CDN Loading (For Artifacts/Standalone)
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&family=Instrument+Serif&display=swap" rel="stylesheet">

<style>
  :root {
    --font-display: 'Instrument Serif', serif;
    --font-body: 'Plus Jakarta Sans', sans-serif;
  }
</style>
```

### Fontsource (Self-hosted, Best Performance)
```bash
npm install @fontsource-variable/plus-jakarta-sans @fontsource/instrument-serif
```

```tsx
import '@fontsource-variable/plus-jakarta-sans';
import '@fontsource/instrument-serif';
```

---

## Premium Font Pairings

### Pairing 1: Editorial Luxury
```css
:root {
  --font-display: 'Instrument Serif', 'Times New Roman', serif;
  --font-body: 'Instrument Sans', 'Helvetica Neue', sans-serif;
}
```
**Use for**: Fashion, luxury products, editorial content, portfolios

### Pairing 2: Modern Tech
```css
:root {
  --font-display: 'Geist', system-ui, sans-serif;
  --font-body: 'Geist', system-ui, sans-serif;
  --font-mono: 'Geist Mono', monospace;
}
```
**Use for**: SaaS, developer tools, dashboards, Vercel-style

### Pairing 3: Warm Professional
```css
:root {
  --font-display: 'Bricolage Grotesque', sans-serif;
  --font-body: 'Plus Jakarta Sans', sans-serif;
}
```
**Use for**: Startups, apps, friendly professional tone

### Pairing 4: Bold Creative
```css
:root {
  --font-display: 'Syne', sans-serif;
  --font-body: 'Work Sans', sans-serif;
}
```
**Use for**: Creative agencies, portfolios, bold statements

### Pairing 5: Classic Elegance
```css
:root {
  --font-display: 'Playfair Display', serif;
  --font-body: 'Source Sans 3', sans-serif;
}
```
**Use for**: Luxury brands, hotels, high-end services

### Pairing 6: Clean Geometric
```css
:root {
  --font-display: 'Manrope', sans-serif;
  --font-body: 'Manrope', sans-serif;
}
```
**Use for**: Fintech, healthcare, clean professional apps

---

## Type Scale

### Fluid Typography (Recommended)
```css
:root {
  /* Base size: 16px at 320px viewport, 18px at 1920px viewport */
  --text-base: clamp(1rem, 0.5vw + 0.875rem, 1.125rem);
  
  /* Scale using perfect fourth (1.333) at small, major third (1.25) at large */
  --text-xs: clamp(0.75rem, 0.5vw + 0.625rem, 0.875rem);
  --text-sm: clamp(0.875rem, 0.5vw + 0.75rem, 1rem);
  --text-lg: clamp(1.125rem, 0.75vw + 0.9rem, 1.25rem);
  --text-xl: clamp(1.25rem, 1vw + 0.9rem, 1.5rem);
  --text-2xl: clamp(1.5rem, 1.5vw + 1rem, 2rem);
  --text-3xl: clamp(1.875rem, 2vw + 1rem, 2.5rem);
  --text-4xl: clamp(2.25rem, 3vw + 1rem, 3.5rem);
  --text-5xl: clamp(3rem, 4vw + 1rem, 4.5rem);
  --text-6xl: clamp(3.75rem, 5vw + 1rem, 6rem);
  --text-7xl: clamp(4.5rem, 6vw + 1rem, 8rem);
}
```

### Tailwind Extension
```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontSize: {
        '7xl': ['clamp(4.5rem, 6vw + 1rem, 8rem)', { lineHeight: '1.1' }],
        '8xl': ['clamp(6rem, 8vw + 1rem, 10rem)', { lineHeight: '1' }],
        '9xl': ['clamp(8rem, 10vw + 1rem, 14rem)', { lineHeight: '0.95' }],
      },
    },
  },
};
```

---

## Typography Tokens

### Letter Spacing (Tracking)
```css
:root {
  --tracking-tighter: -0.05em;   /* Display headlines */
  --tracking-tight: -0.025em;    /* Large text */
  --tracking-normal: 0;          /* Body text */
  --tracking-wide: 0.025em;      /* Small caps, labels */
  --tracking-wider: 0.05em;      /* Uppercase text */
}

/* Usage */
.headline { letter-spacing: var(--tracking-tighter); }
.label { letter-spacing: var(--tracking-wider); text-transform: uppercase; }
```

### Line Height (Leading)
```css
:root {
  --leading-none: 1;        /* Massive display text */
  --leading-tight: 1.15;    /* Headlines */
  --leading-snug: 1.375;    /* Subheadings */
  --leading-normal: 1.5;    /* Short body text */
  --leading-relaxed: 1.7;   /* Long-form reading */
  --leading-loose: 2;       /* Spacious body */
}
```

### Font Weights
```css
:root {
  --weight-normal: 400;
  --weight-medium: 500;
  --weight-semibold: 600;
  --weight-bold: 700;
}
```

---

## Typography Components

### Headline Component
```tsx
interface HeadlineProps {
  as?: 'h1' | 'h2' | 'h3' | 'h4';
  size?: 'xl' | '2xl' | '3xl' | '4xl' | '5xl' | '6xl' | '7xl';
  children: React.ReactNode;
  className?: string;
}

const Headline = ({ as: Tag = 'h1', size = '5xl', children, className }: HeadlineProps) => {
  const sizes = {
    xl: 'text-xl md:text-2xl',
    '2xl': 'text-2xl md:text-3xl',
    '3xl': 'text-3xl md:text-4xl',
    '4xl': 'text-4xl md:text-5xl',
    '5xl': 'text-4xl md:text-5xl lg:text-6xl',
    '6xl': 'text-5xl md:text-6xl lg:text-7xl',
    '7xl': 'text-6xl md:text-7xl lg:text-8xl',
  };

  return (
    <Tag 
      className={`
        font-display font-normal
        tracking-tight
        leading-[1.1]
        text-white
        ${sizes[size]}
        ${className}
      `}
    >
      {children}
    </Tag>
  );
};
```

### Body Text Component
```tsx
interface TextProps {
  size?: 'sm' | 'base' | 'lg' | 'xl';
  muted?: boolean;
  children: React.ReactNode;
  className?: string;
}

const Text = ({ size = 'base', muted = false, children, className }: TextProps) => {
  const sizes = {
    sm: 'text-sm',
    base: 'text-base md:text-lg',
    lg: 'text-lg md:text-xl',
    xl: 'text-xl md:text-2xl',
  };

  return (
    <p 
      className={`
        font-body
        leading-relaxed
        ${sizes[size]}
        ${muted ? 'text-white/60' : 'text-white/90'}
        ${className}
      `}
    >
      {children}
    </p>
  );
};
```

### Label Component (All Caps)
```tsx
const Label = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <span 
    className={`
      font-body font-medium
      text-xs tracking-widest uppercase
      text-white/50
      ${className}
    `}
  >
    {children}
  </span>
);
```

---

## Typography Patterns

### Hero Typography
```tsx
<div className="max-w-4xl mx-auto text-center">
  <Label className="mb-4">Introducing</Label>
  
  <h1 className="font-display text-5xl md:text-6xl lg:text-7xl tracking-tight leading-[1.1] text-white mb-6">
    Beautiful interfaces,<br />
    <span className="text-white/60">crafted with precision</span>
  </h1>
  
  <p className="text-lg md:text-xl text-white/60 max-w-2xl mx-auto leading-relaxed">
    Create stunning visual experiences that feel premium and refined.
  </p>
</div>
```

### Gradient Text
```tsx
const GradientText = ({ children }: { children: React.ReactNode }) => (
  <span 
    className="bg-clip-text text-transparent"
    style={{
      backgroundImage: 'linear-gradient(135deg, #fff 0%, rgba(255,255,255,0.6) 100%)',
    }}
  >
    {children}
  </span>
);

// With color
const ColorGradientText = ({ children }: { children: React.ReactNode }) => (
  <span 
    className="bg-clip-text text-transparent bg-gradient-to-r from-violet-400 via-fuchsia-400 to-pink-400"
  >
    {children}
  </span>
);
```

### Animated Text Reveal
```tsx
import { motion } from 'framer-motion';

const AnimatedHeadline = ({ text }: { text: string }) => {
  const words = text.split(' ');
  
  return (
    <h1 className="font-display text-6xl tracking-tight leading-[1.1]">
      {words.map((word, i) => (
        <motion.span
          key={i}
          initial={{ opacity: 0, y: 20, filter: 'blur(10px)' }}
          animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
          transition={{
            duration: 0.5,
            delay: i * 0.1,
            ease: [0.16, 1, 0.3, 1],
          }}
          className="inline-block mr-[0.25em]"
        >
          {word}
        </motion.span>
      ))}
    </h1>
  );
};
```

---

## Anti-Patterns

### Don't Do This
```css
/* ❌ Bad: Default Inter without customization */
font-family: 'Inter', sans-serif;
font-size: 16px;
line-height: 1.5;

/* ❌ Bad: No tracking adjustment on headlines */
.headline {
  font-size: 48px;
  /* Missing letter-spacing! */
}

/* ❌ Bad: Uniform line height everywhere */
h1, h2, h3, p { line-height: 1.6; }
```

### Do This Instead
```css
/* ✅ Good: Intentional font pairing */
font-family: var(--font-body);
font-size: var(--text-base);
line-height: var(--leading-relaxed);

/* ✅ Good: Proper tracking on headlines */
.headline {
  font-family: var(--font-display);
  font-size: var(--text-6xl);
  letter-spacing: var(--tracking-tight);
  line-height: var(--leading-tight);
}

/* ✅ Good: Appropriate line heights per context */
h1, h2 { line-height: var(--leading-tight); }
h3, h4 { line-height: var(--leading-snug); }
p { line-height: var(--leading-relaxed); }
```
