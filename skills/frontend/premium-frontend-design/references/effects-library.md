# Effects Library

Complete code implementations for premium visual effects.

---

## 1. Glass Effects

### Frosted Glass (Basic)
```tsx
// Tailwind classes
className="backdrop-blur-xl bg-white/5 border border-white/10 rounded-2xl"

// CSS equivalent
.frosted-glass {
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 16px;
}
```

### Liquid Glass (Animated Shimmer)
```tsx
// React Component
const LiquidGlass = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <div className={`relative overflow-hidden rounded-3xl ${className}`}>
    {/* Base glass */}
    <div className="absolute inset-0 backdrop-blur-2xl bg-white/[0.02]" />
    
    {/* Animated gradient shimmer */}
    <div 
      className="absolute inset-0 opacity-30"
      style={{
        background: 'linear-gradient(120deg, transparent 30%, rgba(255,255,255,0.1) 50%, transparent 70%)',
        animation: 'shimmer 3s ease-in-out infinite',
      }}
    />
    
    {/* Refraction edge */}
    <div 
      className="absolute inset-0 rounded-3xl"
      style={{
        background: 'linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 50%, rgba(255,255,255,0.05) 100%)',
      }}
    />
    
    {/* Border */}
    <div className="absolute inset-0 rounded-3xl border border-white/20" />
    
    {/* Content */}
    <div className="relative z-10">{children}</div>
  </div>
);

// Required keyframes (add to global CSS)
@keyframes shimmer {
  0%, 100% { transform: translateX(-100%); }
  50% { transform: translateX(100%); }
}
```

### Crystal Glass (Prismatic Refraction)
```tsx
const CrystalGlass = ({ children }: { children: React.ReactNode }) => (
  <div className="relative group">
    {/* Rainbow refraction on edges */}
    <div 
      className="absolute -inset-[1px] rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500"
      style={{
        background: 'conic-gradient(from 180deg, #ff0080, #7928ca, #0070f3, #00dfd8, #ff0080)',
        filter: 'blur(8px)',
      }}
    />
    
    {/* Main glass container */}
    <div className="relative backdrop-blur-2xl bg-black/40 rounded-3xl border border-white/10 overflow-hidden">
      {/* Top highlight */}
      <div 
        className="absolute inset-x-0 top-0 h-px"
        style={{ background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent)' }}
      />
      
      {/* Corner highlights */}
      <div className="absolute top-0 left-0 w-32 h-32 bg-gradient-radial from-white/10 to-transparent" />
      
      {children}
    </div>
  </div>
);
```

### Smoke Glass (Deep Dark)
```tsx
const SmokeGlass = ({ children }: { children: React.ReactNode }) => (
  <div className="relative rounded-3xl overflow-hidden">
    {/* Deep blur base */}
    <div className="absolute inset-0 backdrop-blur-3xl bg-black/60" />
    
    {/* Gradient fade edges */}
    <div 
      className="absolute inset-0"
      style={{
        background: `
          radial-gradient(ellipse at top, transparent 0%, rgba(0,0,0,0.4) 70%),
          radial-gradient(ellipse at bottom, transparent 0%, rgba(0,0,0,0.4) 70%)
        `,
      }}
    />
    
    {/* Subtle border */}
    <div className="absolute inset-0 rounded-3xl border border-white/5" />
    
    <div className="relative z-10">{children}</div>
  </div>
);
```

---

## 2. Gradient Systems

### Mesh Gradient Background
```tsx
// CSS-only mesh gradient
const MeshGradientBg = () => (
  <div 
    className="fixed inset-0 -z-10"
    style={{
      background: `
        radial-gradient(at 0% 0%, rgba(124, 58, 237, 0.3) 0%, transparent 50%),
        radial-gradient(at 100% 0%, rgba(236, 72, 153, 0.3) 0%, transparent 50%),
        radial-gradient(at 100% 100%, rgba(59, 130, 246, 0.3) 0%, transparent 50%),
        radial-gradient(at 0% 100%, rgba(16, 185, 129, 0.2) 0%, transparent 50%),
        #030303
      `,
    }}
  />
);

// Animated mesh with Framer Motion
import { motion } from 'framer-motion';

const AnimatedMesh = () => (
  <div className="fixed inset-0 -z-10 overflow-hidden bg-[#030303]">
    <motion.div
      className="absolute w-[800px] h-[800px] rounded-full blur-[120px] opacity-40"
      style={{ background: 'radial-gradient(circle, #7c3aed 0%, transparent 70%)' }}
      animate={{
        x: ['-20%', '20%', '-20%'],
        y: ['-10%', '30%', '-10%'],
      }}
      transition={{ duration: 20, repeat: Infinity, ease: 'easeInOut' }}
    />
    <motion.div
      className="absolute right-0 w-[600px] h-[600px] rounded-full blur-[100px] opacity-30"
      style={{ background: 'radial-gradient(circle, #ec4899 0%, transparent 70%)' }}
      animate={{
        x: ['20%', '-20%', '20%'],
        y: ['30%', '-10%', '30%'],
      }}
      transition={{ duration: 15, repeat: Infinity, ease: 'easeInOut' }}
    />
  </div>
);
```

### Aurora Background
```tsx
const AuroraBackground = () => (
  <div className="fixed inset-0 -z-10 overflow-hidden bg-[#0a0a0a]">
    {/* Aurora layers */}
    <div 
      className="absolute inset-0 opacity-50"
      style={{
        background: `
          linear-gradient(
            to right,
            transparent,
            rgba(120, 119, 198, 0.3),
            rgba(74, 222, 128, 0.2),
            rgba(56, 189, 248, 0.3),
            transparent
          )
        `,
        filter: 'blur(80px)',
        animation: 'aurora 15s ease-in-out infinite',
      }}
    />
    <div 
      className="absolute inset-0 opacity-30"
      style={{
        background: `
          linear-gradient(
            to left,
            transparent,
            rgba(232, 121, 249, 0.3),
            rgba(167, 139, 250, 0.2),
            transparent
          )
        `,
        filter: 'blur(100px)',
        animation: 'aurora 20s ease-in-out infinite reverse',
      }}
    />
  </div>
);

// Keyframes
@keyframes aurora {
  0%, 100% {
    transform: translateY(0) rotate(0deg);
  }
  33% {
    transform: translateY(-20px) rotate(2deg);
  }
  66% {
    transform: translateY(20px) rotate(-2deg);
  }
}
```

### Gradient Border
```tsx
const GradientBorder = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <div className={`relative p-[1px] rounded-2xl ${className}`}>
    {/* Gradient border layer */}
    <div 
      className="absolute inset-0 rounded-2xl"
      style={{
        background: 'linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 50%, rgba(255,255,255,0.1) 100%)',
      }}
    />
    
    {/* Content with solid background */}
    <div className="relative bg-[#0a0a0a] rounded-2xl">
      {children}
    </div>
  </div>
);

// Animated gradient border (hover effect)
const AnimatedGradientBorder = ({ children }: { children: React.ReactNode }) => (
  <div className="relative group p-[1px] rounded-2xl">
    <div 
      className="absolute inset-0 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-500"
      style={{
        background: 'linear-gradient(90deg, #7c3aed, #ec4899, #3b82f6, #7c3aed)',
        backgroundSize: '300% 100%',
        animation: 'gradient-shift 3s linear infinite',
      }}
    />
    <div 
      className="absolute inset-0 rounded-2xl"
      style={{
        background: 'linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 100%)',
      }}
    />
    <div className="relative bg-[#0a0a0a] rounded-2xl">{children}</div>
  </div>
);

@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  100% { background-position: 300% 50%; }
}
```

### Radial Glow
```tsx
// Glow behind element
const GlowWrapper = ({ children, color = '#7c3aed' }: { children: React.ReactNode; color?: string }) => (
  <div className="relative">
    <div 
      className="absolute inset-0 blur-3xl opacity-40 -z-10 scale-150"
      style={{ backgroundColor: color }}
    />
    {children}
  </div>
);

// Button with glow
const GlowButton = ({ children }: { children: React.ReactNode }) => (
  <button className="relative group px-8 py-4 rounded-xl font-medium">
    {/* Glow layer */}
    <div 
      className="absolute inset-0 rounded-xl bg-violet-600 blur-xl opacity-40 group-hover:opacity-60 transition-opacity"
    />
    
    {/* Button surface */}
    <div className="relative bg-gradient-to-b from-violet-500 to-violet-600 rounded-xl px-8 py-4 text-white">
      {children}
    </div>
  </button>
);
```

---

## 3. Background Treatments

### Noise Texture Overlay
```tsx
// SVG noise (inline, no external file needed)
const NoiseOverlay = ({ opacity = 0.04 }: { opacity?: number }) => (
  <div 
    className="pointer-events-none absolute inset-0 z-50"
    style={{ opacity }}
  >
    <svg className="w-full h-full">
      <filter id="noise">
        <feTurbulence type="fractalNoise" baseFrequency="0.8" numOctaves="4" stitchTiles="stitch" />
        <feColorMatrix type="saturate" values="0" />
      </filter>
      <rect width="100%" height="100%" filter="url(#noise)" />
    </svg>
  </div>
);

// CSS-only noise (using base64 encoded SVG)
.noise-overlay::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  opacity: 0.04;
  pointer-events: none;
  z-index: 100;
}
```

### Dot Grid Pattern
```tsx
const DotGrid = () => (
  <div 
    className="absolute inset-0 -z-10"
    style={{
      backgroundImage: `radial-gradient(rgba(255,255,255,0.1) 1px, transparent 1px)`,
      backgroundSize: '32px 32px',
    }}
  />
);

// Fading dot grid
const FadingDotGrid = () => (
  <div className="absolute inset-0 -z-10">
    <div 
      style={{
        backgroundImage: `radial-gradient(rgba(255,255,255,0.15) 1px, transparent 1px)`,
        backgroundSize: '24px 24px',
        maskImage: 'radial-gradient(ellipse at center, black 20%, transparent 70%)',
        WebkitMaskImage: 'radial-gradient(ellipse at center, black 20%, transparent 70%)',
      }}
      className="absolute inset-0"
    />
  </div>
);
```

### Gradient Orbs
```tsx
const GradientOrbs = () => (
  <div className="fixed inset-0 -z-10 overflow-hidden">
    {/* Top left orb */}
    <div 
      className="absolute -top-1/4 -left-1/4 w-1/2 h-1/2 rounded-full blur-[120px]"
      style={{ background: 'radial-gradient(circle, rgba(124,58,237,0.4) 0%, transparent 70%)' }}
    />
    
    {/* Bottom right orb */}
    <div 
      className="absolute -bottom-1/4 -right-1/4 w-1/2 h-1/2 rounded-full blur-[120px]"
      style={{ background: 'radial-gradient(circle, rgba(59,130,246,0.3) 0%, transparent 70%)' }}
    />
    
    {/* Center accent */}
    <div 
      className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-1/3 h-1/3 rounded-full blur-[100px]"
      style={{ background: 'radial-gradient(circle, rgba(236,72,153,0.2) 0%, transparent 70%)' }}
    />
  </div>
);
```

---

## 4. Micro-interactions

### Magnetic Button (Framer Motion)
```tsx
import { motion, useMotionValue, useSpring, useTransform } from 'framer-motion';
import { useRef } from 'react';

const MagneticButton = ({ children }: { children: React.ReactNode }) => {
  const ref = useRef<HTMLButtonElement>(null);
  const x = useMotionValue(0);
  const y = useMotionValue(0);
  
  const springConfig = { damping: 15, stiffness: 150 };
  const xSpring = useSpring(x, springConfig);
  const ySpring = useSpring(y, springConfig);

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    
    x.set((e.clientX - centerX) * 0.3);
    y.set((e.clientY - centerY) * 0.3);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      ref={ref}
      style={{ x: xSpring, y: ySpring }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="px-8 py-4 bg-white text-black rounded-full font-medium"
      whileTap={{ scale: 0.95 }}
    >
      {children}
    </motion.button>
  );
};
```

### Tilt Card (3D Perspective)
```tsx
import { motion, useMotionValue, useSpring, useTransform } from 'framer-motion';

const TiltCard = ({ children }: { children: React.ReactNode }) => {
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const rotateX = useSpring(useTransform(y, [-0.5, 0.5], [10, -10]), { damping: 20 });
  const rotateY = useSpring(useTransform(x, [-0.5, 0.5], [-10, 10]), { damping: 20 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    x.set((e.clientX - rect.left) / rect.width - 0.5);
    y.set((e.clientY - rect.top) / rect.height - 0.5);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.div
      style={{ rotateX, rotateY, transformStyle: 'preserve-3d' }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="relative"
    >
      {/* Reflection/glow layer */}
      <motion.div
        className="absolute inset-0 rounded-3xl bg-gradient-to-br from-white/20 to-transparent opacity-0 transition-opacity"
        style={{
          transform: 'translateZ(20px)',
          opacity: useTransform([x, y], ([latestX, latestY]) => 
            Math.abs(latestX as number) + Math.abs(latestY as number)
          ),
        }}
      />
      
      <div style={{ transform: 'translateZ(40px)' }}>
        {children}
      </div>
    </motion.div>
  );
};
```

### Stagger Reveal Animation
```tsx
import { motion } from 'framer-motion';

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 20, filter: 'blur(10px)' },
  show: { 
    opacity: 1, 
    y: 0, 
    filter: 'blur(0px)',
    transition: {
      duration: 0.5,
      ease: [0.16, 1, 0.3, 1],
    },
  },
};

const StaggerList = ({ items }: { items: string[] }) => (
  <motion.ul
    variants={container}
    initial="hidden"
    animate="show"
    className="space-y-4"
  >
    {items.map((text, i) => (
      <motion.li key={i} variants={item}>
        {text}
      </motion.li>
    ))}
  </motion.ul>
);
```

### Cursor Glow Trail
```tsx
import { motion, useMotionValue, useSpring } from 'framer-motion';
import { useEffect } from 'react';

const CursorGlow = () => {
  const cursorX = useMotionValue(-100);
  const cursorY = useMotionValue(-100);
  
  const springConfig = { damping: 25, stiffness: 200 };
  const x = useSpring(cursorX, springConfig);
  const y = useSpring(cursorY, springConfig);

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      cursorX.set(e.clientX);
      cursorY.set(e.clientY);
    };
    
    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  return (
    <motion.div
      className="pointer-events-none fixed w-96 h-96 rounded-full -z-10"
      style={{
        x,
        y,
        translateX: '-50%',
        translateY: '-50%',
        background: 'radial-gradient(circle, rgba(124,58,237,0.15) 0%, transparent 70%)',
        filter: 'blur(40px)',
      }}
    />
  );
};
```

---

## 5. Complete Component Examples

### Premium Button
```tsx
const PremiumButton = ({ children, variant = 'primary' }: { children: React.ReactNode; variant?: 'primary' | 'secondary' }) => {
  if (variant === 'primary') {
    return (
      <motion.button
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        className="relative group px-8 py-4 rounded-2xl font-medium text-white overflow-hidden"
      >
        {/* Glow */}
        <div className="absolute inset-0 bg-gradient-to-r from-violet-600 to-fuchsia-600 blur-xl opacity-50 group-hover:opacity-70 transition-opacity" />
        
        {/* Surface */}
        <div className="absolute inset-0 bg-gradient-to-r from-violet-600 to-fuchsia-600 rounded-2xl" />
        
        {/* Shine */}
        <div className="absolute inset-0 bg-gradient-to-b from-white/20 to-transparent rounded-2xl" />
        
        {/* Content */}
        <span className="relative">{children}</span>
      </motion.button>
    );
  }

  return (
    <motion.button
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className="relative group px-8 py-4 rounded-2xl font-medium text-white"
    >
      {/* Gradient border on hover */}
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-r from-violet-600 to-fuchsia-600 opacity-0 group-hover:opacity-100 transition-opacity" />
      
      {/* Inner background */}
      <div className="absolute inset-[1px] rounded-2xl bg-[#0a0a0a]" />
      
      {/* Default border */}
      <div className="absolute inset-0 rounded-2xl border border-white/10 group-hover:border-transparent transition-colors" />
      
      <span className="relative">{children}</span>
    </motion.button>
  );
};
```

### Glass Card
```tsx
const GlassCard = ({ children, className }: { children: React.ReactNode; className?: string }) => (
  <motion.div
    whileHover={{ y: -4, scale: 1.01 }}
    transition={{ duration: 0.2, ease: [0.16, 1, 0.3, 1] }}
    className={`relative group rounded-3xl overflow-hidden ${className}`}
  >
    {/* Gradient border on hover */}
    <div className="absolute inset-0 rounded-3xl bg-gradient-to-br from-white/20 via-white/5 to-white/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
    
    {/* Glass background */}
    <div className="absolute inset-[1px] rounded-3xl backdrop-blur-xl bg-white/[0.03]" />
    
    {/* Default border */}
    <div className="absolute inset-0 rounded-3xl border border-white/10" />
    
    {/* Noise texture */}
    <NoiseOverlay opacity={0.03} />
    
    {/* Top highlight */}
    <div className="absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-white/20 to-transparent" />
    
    {/* Content */}
    <div className="relative p-8">{children}</div>
  </motion.div>
);
```
