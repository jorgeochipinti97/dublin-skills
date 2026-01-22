# Motion Patterns

Animation recipes for premium, Apple/Framer-quality interfaces.

---

## Core Principles

1. **Purposeful**: Every animation serves a function (feedback, hierarchy, delight)
2. **Swift**: Micro-interactions 200-400ms, reveals 400-800ms
3. **Smooth**: Ease-out curves for natural deceleration
4. **Subtle**: Motion enhances, never distracts

---

## Easing Functions

### Recommended Curves
```css
:root {
  /* Default smooth ease-out */
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);
  
  /* Snappy for micro-interactions */
  --ease-snappy: cubic-bezier(0.34, 1.56, 0.64, 1);
  
  /* Gentle for large movements */
  --ease-gentle: cubic-bezier(0.4, 0, 0.2, 1);
  
  /* Spring-like bounce */
  --ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
  
  /* Linear for continuous animations */
  --ease-linear: linear;
}
```

### Framer Motion Equivalents
```tsx
const easings = {
  smooth: [0.16, 1, 0.3, 1],
  snappy: [0.34, 1.56, 0.64, 1],
  gentle: [0.4, 0, 0.2, 1],
};

// Spring configs
const springConfigs = {
  snappy: { stiffness: 400, damping: 30 },
  smooth: { stiffness: 200, damping: 25 },
  bouncy: { stiffness: 300, damping: 15 },
  gentle: { stiffness: 100, damping: 20 },
};
```

---

## Duration Guide

| Interaction Type | Duration | Use Case |
|-----------------|----------|----------|
| Micro | 150-200ms | Button press, toggle |
| Quick | 200-300ms | Hover states, tooltips |
| Normal | 300-400ms | Modals, dropdowns |
| Smooth | 400-600ms | Page transitions |
| Reveal | 600-800ms | Hero animations |
| Slow | 800-1200ms | Complex sequences |

---

## Entrance Animations

### Fade Up (Most Common)
```tsx
// Framer Motion
const fadeUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] },
};

// CSS
@keyframes fade-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-up {
  animation: fade-up 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
```

### Fade Up with Blur (Premium)
```tsx
const fadeUpBlur = {
  initial: { opacity: 0, y: 20, filter: 'blur(10px)' },
  animate: { opacity: 1, y: 0, filter: 'blur(0px)' },
  transition: { duration: 0.6, ease: [0.16, 1, 0.3, 1] },
};

// CSS
@keyframes fade-up-blur {
  from {
    opacity: 0;
    transform: translateY(20px);
    filter: blur(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0px);
  }
}
```

### Scale In
```tsx
const scaleIn = {
  initial: { opacity: 0, scale: 0.95 },
  animate: { opacity: 1, scale: 1 },
  transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] },
};
```

### Slide In from Side
```tsx
const slideInLeft = {
  initial: { opacity: 0, x: -40 },
  animate: { opacity: 1, x: 0 },
  transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] },
};

const slideInRight = {
  initial: { opacity: 0, x: 40 },
  animate: { opacity: 1, x: 0 },
  transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] },
};
```

---

## Stagger Animations

### Container + Children Pattern
```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: [0.16, 1, 0.3, 1],
    },
  },
};

// Usage
<motion.div
  variants={containerVariants}
  initial="hidden"
  animate="visible"
>
  {items.map((item, i) => (
    <motion.div key={i} variants={itemVariants}>
      {item}
    </motion.div>
  ))}
</motion.div>
```

### Custom Stagger with Index
```tsx
const StaggeredList = ({ items }: { items: React.ReactNode[] }) => (
  <div>
    {items.map((item, i) => (
      <motion.div
        key={i}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{
          duration: 0.5,
          delay: i * 0.1,
          ease: [0.16, 1, 0.3, 1],
        }}
      >
        {item}
      </motion.div>
    ))}
  </div>
);
```

### CSS-Only Stagger
```css
.stagger-item {
  opacity: 0;
  animation: fade-up 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

.stagger-item:nth-child(1) { animation-delay: 0ms; }
.stagger-item:nth-child(2) { animation-delay: 100ms; }
.stagger-item:nth-child(3) { animation-delay: 200ms; }
.stagger-item:nth-child(4) { animation-delay: 300ms; }
.stagger-item:nth-child(5) { animation-delay: 400ms; }

/* Or with custom property */
.stagger-item {
  animation-delay: calc(var(--index) * 100ms);
}
```

---

## Hover Interactions

### Scale + Shadow Lift
```tsx
<motion.div
  whileHover={{ y: -4, scale: 1.02 }}
  transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
  className="hover:shadow-2xl transition-shadow"
>
  Card content
</motion.div>
```

### Border Glow
```css
.card {
  position: relative;
  border: 1px solid rgba(255,255,255,0.1);
  transition: border-color 0.3s ease;
}

.card::before {
  content: '';
  position: absolute;
  inset: 0;
  border-radius: inherit;
  background: linear-gradient(135deg, rgba(124,58,237,0.3), rgba(236,72,153,0.3));
  opacity: 0;
  transition: opacity 0.3s ease;
  z-index: -1;
  filter: blur(20px);
}

.card:hover {
  border-color: rgba(255,255,255,0.2);
}

.card:hover::before {
  opacity: 1;
}
```

### Text Underline Animation
```css
.link {
  position: relative;
}

.link::after {
  content: '';
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 100%;
  height: 1px;
  background: currentColor;
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.link:hover::after {
  transform: scaleX(1);
  transform-origin: left;
}
```

### Button Press Effect
```tsx
<motion.button
  whileHover={{ scale: 1.02 }}
  whileTap={{ scale: 0.98 }}
  transition={{ duration: 0.15 }}
>
  Click me
</motion.button>
```

---

## Scroll Animations

### Intersection Observer Hook
```tsx
import { useInView } from 'framer-motion';
import { useRef } from 'react';

const ScrollReveal = ({ children }: { children: React.ReactNode }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
      transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
    >
      {children}
    </motion.div>
  );
};
```

### Parallax Effect
```tsx
import { useScroll, useTransform, motion } from 'framer-motion';

const ParallaxSection = ({ children }: { children: React.ReactNode }) => {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  });

  const y = useTransform(scrollYProgress, [0, 1], [100, -100]);

  return (
    <div ref={ref} className="relative overflow-hidden">
      <motion.div style={{ y }}>
        {children}
      </motion.div>
    </div>
  );
};
```

### Scroll Progress Indicator
```tsx
const ScrollProgress = () => {
  const { scrollYProgress } = useScroll();

  return (
    <motion.div
      className="fixed top-0 left-0 right-0 h-1 bg-violet-500 origin-left z-50"
      style={{ scaleX: scrollYProgress }}
    />
  );
};
```

---

## Page Transitions

### Fade Transition
```tsx
// In Next.js with AnimatePresence
import { AnimatePresence, motion } from 'framer-motion';
import { useRouter } from 'next/router';

const pageVariants = {
  initial: { opacity: 0 },
  enter: { opacity: 1 },
  exit: { opacity: 0 },
};

const PageTransition = ({ children }: { children: React.ReactNode }) => {
  const router = useRouter();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={router.route}
        variants={pageVariants}
        initial="initial"
        animate="enter"
        exit="exit"
        transition={{ duration: 0.3 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
};
```

### Slide Transition
```tsx
const slideVariants = {
  initial: { opacity: 0, x: 20 },
  enter: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: -20 },
};
```

---

## Continuous Animations

### Floating Element
```css
@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

.floating {
  animation: float 4s ease-in-out infinite;
}
```

### Pulse Glow
```css
@keyframes pulse-glow {
  0%, 100% {
    opacity: 0.4;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(1.05);
  }
}

.pulse-glow {
  animation: pulse-glow 3s ease-in-out infinite;
}
```

### Gradient Shift
```css
@keyframes gradient-shift {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.animated-gradient {
  background-size: 200% 200%;
  animation: gradient-shift 8s ease infinite;
}
```

### Rotating Border
```tsx
const RotatingBorder = ({ children }: { children: React.ReactNode }) => (
  <div className="relative p-[2px] rounded-2xl">
    <div 
      className="absolute inset-0 rounded-2xl"
      style={{
        background: 'conic-gradient(from 0deg, #7c3aed, #ec4899, #3b82f6, #7c3aed)',
        animation: 'spin 4s linear infinite',
      }}
    />
    <div className="relative bg-[#0a0a0a] rounded-2xl">
      {children}
    </div>
  </div>
);
```

---

## Loading States

### Skeleton Shimmer
```css
@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

.skeleton {
  background: linear-gradient(
    90deg,
    rgba(255,255,255,0.05) 0%,
    rgba(255,255,255,0.1) 50%,
    rgba(255,255,255,0.05) 100%
  );
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
}
```

### Spinner
```tsx
const Spinner = () => (
  <div className="w-6 h-6 border-2 border-white/20 border-t-white rounded-full animate-spin" />
);
```

### Dots Loading
```tsx
const DotsLoading = () => (
  <div className="flex gap-1">
    {[0, 1, 2].map((i) => (
      <motion.div
        key={i}
        className="w-2 h-2 bg-white rounded-full"
        animate={{ y: [0, -8, 0] }}
        transition={{
          duration: 0.6,
          repeat: Infinity,
          delay: i * 0.1,
        }}
      />
    ))}
  </div>
);
```

---

## Performance Tips

1. **Prefer transform and opacity**: These don't trigger layout
2. **Use will-change sparingly**: Only on elements that will animate
3. **Hardware acceleration**: `transform: translateZ(0)` when needed
4. **Reduce motion**: Respect `prefers-reduced-motion`

```tsx
// Respect user preferences
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

const variants = prefersReducedMotion
  ? { initial: {}, animate: {} }
  : { initial: { opacity: 0 }, animate: { opacity: 1 } };
```

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```
