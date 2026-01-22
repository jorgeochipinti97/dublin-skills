---
name: premium-frontend-design
description: Create luxury, Apple/Framer-quality frontend interfaces with liquid glass effects, mesh gradients, aurora backgrounds, and sophisticated micro-interactions. Use when building premium UI components, landing pages, dashboards, or any React/Next.js interface requiring high-end visual polish. Avoids generic AI aesthetics (v0-style), emphasizing editorial quality, intentional whitespace, and museum-grade craftsmanship.
---

# Premium Frontend Design Skill

Create interfaces that feel like they belong in an Apple keynote or Framer showcase. Every component should look like it took weeks to craft.

## Design Philosophy: "Quiet Luxury"

The aesthetic is **restrained opulence** — expensive-looking without being loud. Think:
- Apple's product pages (massive typography, breathing room, subtle depth)
- Framer's templates (fluid motion, glass layers, gradient meshes)
- Linear's interface (dark elegance, precision, purposeful animation)
- Vercel's marketing (clean gradients, sharp typography, confident whitespace)

**NOT**: v0's default output, shadcn without customization, generic purple gradients, icon-heavy UIs, cramped layouts.

---

## Core Principles

### 1. Typography First
Typography carries 60% of the visual weight. Before any effects:
- Use **large, confident type** (48-96px for headlines on desktop)
- Pair a distinctive display font with a refined body font
- Letter-spacing adjustments are mandatory (-0.02em to -0.05em for headlines)
- Line-height should breathe (1.1-1.2 for headlines, 1.6-1.8 for body)

**Approved Font Pairings** (load via Google Fonts or CDN):
| Display | Body | Vibe |
|---------|------|------|
| SF Pro Display | SF Pro Text | Apple native |
| Geist | Geist Mono | Vercel-esque |
| Satoshi | Inter (sparingly) | Modern startup |
| Instrument Serif | Instrument Sans | Editorial luxury |
| Playfair Display | Source Sans 3 | Classic elegance |
| Space Grotesk | DM Sans | Tech-forward |
| Syne | Work Sans | Bold creative |
| Bricolage Grotesque | IBM Plex Sans | Sophisticated |
| Manrope | Manrope | Clean geometric |
| Plus Jakarta Sans | Plus Jakarta Sans | Friendly premium |

### 2. Whitespace as Design Element
Negative space is not empty — it's structural.
- Minimum padding: 24px (mobile), 48px (tablet), 80-120px (desktop)
- Section spacing: 120-200px between major sections
- Let single elements breathe in vast space
- Asymmetric layouts create visual interest

### 3. Color with Restraint
Maximum 3-4 colors. One dominant, one accent, rest neutral.
- **Dark mode default** (easier to achieve luxury feel)
- Background: Never pure black (#000). Use #0a0a0a, #09090b, #030303, #0c0c0c
- Grays with subtle hue shifts (warm grays, cool grays with blue/purple tint)
- Accent colors: vibrant but used sparingly (buttons, highlights, glows)
- Gradients: subtle, multi-stop, with noise texture overlay

### 4. Depth Through Layering
Create hierarchy with:
- Glass morphism (backdrop-filter: blur + transparency)
- Subtle shadows (large blur radius, low opacity, colored shadows)
- Border gradients (1px borders with gradient backgrounds via pseudo-elements)
- Overlapping elements with considered z-index

### 5. Motion with Purpose
Animation should feel:
- **Inevitable** — like it couldn't move any other way
- **Swift** — 200-400ms for micro-interactions, 600-800ms for reveals
- **Eased** — cubic-bezier(0.16, 1, 0.3, 1) for smooth deceleration
- Use Framer Motion for React, CSS for simple hover states

---

## Effects Reference

Load `references/effects-library.md` for complete code implementations.

### Glass Effects Hierarchy
1. **Frosted Glass** — Subtle blur, light transparency
2. **Liquid Glass** — Animated shimmer, gradient overlay, refraction
3. **Crystal Glass** — Sharp reflections, rainbow edge highlights
4. **Smoke Glass** — Dark, deep blur, gradient edge fade
5. **Holographic Glass** — Iridescent color shift on angle

### Gradient Systems
1. **Mesh Gradients** — Multi-point color interpolation
2. **Aurora Backgrounds** — Animated flowing color waves
3. **Radial Glow** — Soft light emanation from focal points
4. **Gradient Borders** — 1px gradient stroke via pseudo-elements
5. **Conic Gradients** — Rotational color for badges/loaders

### Background Treatments
1. **Noise Texture** — SVG/CSS noise at 3-8% opacity
2. **Dot Grid** — Subtle pattern for spatial depth
3. **Gradient Orbs** — Large blurred color circles
4. **Light Leak** — Diagonal gradients simulating light
5. **Grain Film** — Animated noise for texture

### Micro-interactions
1. **Magnetic Hover** — Element attracted to cursor
2. **Tilt Perspective** — 3D rotation following mouse
3. **Glow Trail** — Gradient following cursor path
4. **Reveal Blur** — Elements emerge from blur
5. **Stagger Cascade** — Sequential element entrance

---

## Component Architecture

### Hero Sections
```
Layout: Full viewport (min-h-screen), centered content
Typography: 64-96px headline, -0.03em tracking, 600-700 weight
Subheading: 20-24px, 60% opacity, max-w-2xl
CTA: Single primary button with glow, optional secondary text link
Background: Mesh gradient OR aurora OR gradient orbs
Depth: Floating glass elements, subtle parallax
```

### Cards
```
Container: rounded-2xl or rounded-3xl (20-24px)
Background: Glass with noise texture overlay
Border: 1px white/10 with optional gradient on hover
Shadow: 0 25px 50px -12px with color tint
Hover: translateY(-4px), scale(1.01), border glow
Padding: 24-32px internal spacing
```

### Navigation
```
Position: Fixed, glass background after scroll threshold
Height: 64-80px with centered content
Links: Minimal (5 max), pill indicator for active
Transition: Background opacity/blur on scroll
Mobile: Full overlay with staggered item animation
```

### Buttons
```
Primary: Gradient background, glow shadow, scale(0.98) on press
Secondary: Glass/ghost with gradient border on hover
Size: Minimum 44px height, 16-24px horizontal padding
Radius: rounded-xl (12px) or rounded-full for pills
States: Hover glow, active scale, focus ring
```

---

## Implementation Standards

### Tech Stack
- **Framework**: React 18+ / Next.js 14+
- **Styling**: Tailwind CSS (extended config)
- **Animation**: Framer Motion
- **Types**: TypeScript always
- **Fonts**: Variable fonts when available

### Code Patterns
```tsx
// Always use CSS custom properties for theming
const styles = {
  '--glow-color': 'rgba(124, 58, 237, 0.5)',
  '--glass-bg': 'rgba(255, 255, 255, 0.05)',
} as React.CSSProperties;

// Prefer composition for complex effects
<GlassCard>
  <NoiseOverlay opacity={0.04} />
  <GradientBorder />
  <Content />
</GlassCard>
```

### Quality Checklist
Before completion, verify:
- [ ] Typography: Distinctive fonts, proper tracking/leading
- [ ] Colors: 3-4 max, dark mode polished
- [ ] Space: Generous padding, breathing room
- [ ] Depth: Glass, shadows, or layering present
- [ ] Motion: Hover states, transitions, entrance animations
- [ ] Noise: Texture overlay where appropriate
- [ ] Responsive: Scales gracefully to mobile
- [ ] Final test: Would Framer/Apple/Linear ship this?

---

## Anti-Patterns (Forbidden)

See `references/anti-patterns.md` for visual examples.

**NEVER DO**:
- Purple-to-blue gradients on white (v0 signature)
- Uniform 8px border-radius everywhere
- Icon grids with description text
- Everything centered with equal spacing
- Gray borders (#e5e5e5) on white cards
- Inter font without heavy customization
- Hard-edged shadows
- Cramped padding (<16px on desktop)
- Stock illustrations or generic icons
- "Hero → Features Grid → CTA" without variation

**ALWAYS ASK**: "Would a designer at Apple review this favorably?"

---

## Reference Files

When implementing, load these as needed:
- `references/effects-library.md` — Complete CSS/React code for all effects
- `references/typography-system.md` — Font loading, responsive scales, pairing rules
- `references/motion-patterns.md` — Framer Motion configs, CSS keyframes, easing
- `references/anti-patterns.md` — Visual examples of what to avoid

---

## Output Standards

All generated code must:
1. Be complete and runnable (no placeholders)
2. Include TypeScript types
3. Import required dependencies (Framer Motion, fonts)
4. Use Tailwind with custom values where needed
5. Include responsive breakpoints
6. Have comments explaining non-obvious techniques
7. Provide CSS custom properties for easy theming
