---
name: brand-identity
description: Define and enforce brand identity systems including color palettes, typography, spacing, and UX principles. Use when (1) starting a new project that needs visual identity, (2) ensuring consistency across components, (3) the premium-frontend-design skill needs clear brand guidelines, or (4) reviewing designs for brand compliance. Prevents Claude from improvising colors or typography — everything follows the established system.
---

# Brand Identity System

Create cohesive visual identities that feel intentional and premium. Every design decision traces back to defined principles.

## Philosophy: Systematic Restraint

Great brands are **systems, not collections**. Every color, font, and spacing value exists for a reason. When in doubt:
- Fewer options, more consistency
- Neutral foundation, minimal accent
- Let content breathe
- Question every decoration

---

## Process: New Project Identity

When starting a new project without defined brand guidelines:

### 1. Gather Context
Ask the client/user:
- **Name**: What's the product/brand called?
- **Domain**: What problem does it solve? For whom?
- **Personality**: 3 adjectives that describe the brand
- **References**: Brands or sites they admire (or want to avoid)
- **Constraints**: Existing colors, fonts, or assets to incorporate

### 2. Select Foundation
Based on context, choose from established palettes in `references/color-system.md`:
- **Neutral base**: Warm, cool, or pure grays
- **Primary accent**: Single vibrant color for CTAs and highlights
- **Semantic colors**: Success, warning, error (muted versions)

### 3. Define Typography
Select pairing from `references/typography-guide.md`:
- **Display**: Headlines, hero text
- **Body**: Paragraphs, UI text
- **Mono**: Code, data (optional)

### 4. Document in Project
Create a `brand.md` or `BRAND_GUIDELINES.md` in the project with:
- Color tokens (hex, HSL, CSS variables)
- Font stack with fallbacks
- Spacing scale
- Component-specific rules

---

## Core Elements

### Color System
See `references/color-system.md` for complete palettes.

**Principles**:
- Maximum 5 colors in primary palette (1 primary, 1-2 neutrals, 1-2 semantic)
- Dark mode is not inverted light mode — design separately
- Accent color usage: <10% of visual surface
- Never pure black (#000) or pure white (#fff) — always slightly tinted
- Test contrast ratios: 4.5:1 minimum for text

**Apple-Style Neutral Foundation**:
```css
--background: #000000;      /* True black for OLED */
--surface: #1c1c1e;         /* Elevated surface */
--surface-secondary: #2c2c2e;
--text-primary: #f5f5f7;    /* Not pure white */
--text-secondary: #86868b;
--border: rgba(255,255,255,0.1);
```

### Typography System
See `references/typography-guide.md` for pairings and scales.

**Principles**:
- One display + one body font maximum
- Headlines: Tight tracking (-0.02em to -0.05em)
- Body: Normal to slightly loose tracking
- Scale ratio: 1.25 (major third) or 1.333 (perfect fourth)
- Responsive: Reduce sizes 20-30% on mobile

**Approved Font Stacks** (Premium/Tech):
| Use | Primary | Fallback |
|-----|---------|----------|
| Display | SF Pro Display, Geist, Satoshi | system-ui |
| Body | SF Pro Text, Inter, DM Sans | system-ui |
| Mono | SF Mono, Geist Mono, JetBrains | monospace |

### Spacing System
8-point grid baseline. Every spacing value is a multiple of 8.

```css
--space-1: 4px;   /* Tight: icon padding */
--space-2: 8px;   /* Compact: inline elements */
--space-3: 12px;  /* Default: button padding */
--space-4: 16px;  /* Comfortable: card padding */
--space-5: 24px;  /* Loose: section gaps */
--space-6: 32px;  /* Spacious: component gaps */
--space-8: 48px;  /* Generous: section padding */
--space-12: 64px; /* Dramatic: hero spacing */
--space-16: 80px; /* Massive: page sections */
```

---

## UX Principles

See `references/ux-principles.md` for detailed guidelines.

### Hierarchy
1. **One focal point per view** — Eyes should land somewhere specific
2. **Progressive disclosure** — Show only what's needed now
3. **Contrast creates hierarchy** — Size, weight, color, space

### Interaction
1. **Immediate feedback** — Every action acknowledged within 100ms
2. **Predictable outcomes** — Same action = same result
3. **Reversible actions** — Undo should be possible
4. **Clear affordances** — Clickable things look clickable

### Accessibility (Non-negotiable)
1. **Color contrast**: 4.5:1 for normal text, 3:1 for large text
2. **Touch targets**: Minimum 44x44px
3. **Focus states**: Visible keyboard navigation
4. **Motion**: Respect prefers-reduced-motion
5. **Labels**: All interactive elements labeled

### Mobile-First
1. **Content priority**: What matters most on small screens?
2. **Thumb zones**: Primary actions in easy reach
3. **Reduce, don't shrink**: Simplify layouts, don't miniaturize
4. **Performance**: Mobile users often have slower connections

---

## Integration with Premium Frontend

When using with `premium-frontend-design`:

1. **Load brand-identity first** to establish guidelines
2. **Reference defined tokens** — never improvise colors
3. **Verify against brand** before finalizing any component
4. **Question effects**: Does this glass/gradient serve the brand?

The premium-frontend skill provides techniques; this skill provides constraints.

---

## Anti-Patterns

**NEVER**:
- Pick colors by gut feeling — use the system
- Mix warm and cool grays without intention
- Use more than one accent color prominently
- Ignore contrast ratios "because it looks good"
- Skip mobile considerations
- Assume dark = premium (design must still be intentional)
- Use decorative elements without purpose

**ALWAYS ASK**:
- "Is this color in our defined palette?"
- "Does this typography follow our scale?"
- "Would removing this element hurt the design?"

---

## Reference Files

Load as needed:
- `references/color-system.md` — Complete palettes with hex/HSL values
- `references/typography-guide.md` — Font pairings, scales, loading
- `references/ux-principles.md` — Detailed UX/UI criteria and patterns
