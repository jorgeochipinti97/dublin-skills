# UX Principles Reference

Detailed guidelines for creating premium user experiences.

---

## Visual Hierarchy

### The 60-30-10 Rule
- **60%** - Dominant color (usually background/neutral)
- **30%** - Secondary color (surfaces, cards)
- **10%** - Accent color (CTAs, highlights)

### Creating Focus
Every screen should have ONE clear focal point.

**Techniques:**
1. **Size contrast** - Make the important thing bigger
2. **Color contrast** - Accent color draws attention
3. **Whitespace** - Isolation emphasizes importance
4. **Position** - Center or top-left has natural priority
5. **Motion** - Movement attracts (use sparingly)

### Z-Pattern & F-Pattern
- **Z-Pattern**: Marketing pages, landing pages
  - Eye moves: top-left → top-right → diagonal → bottom-left → bottom-right
- **F-Pattern**: Content-heavy pages, dashboards
  - Eye scans: horizontal top → down-left → horizontal middle → down

Design important elements along these paths.

---

## Spacing & Layout

### The 8-Point Grid
All spacing should be multiples of 8px.

```
4px   - Micro spacing (icon padding)
8px   - Tight spacing (between related elements)
16px  - Default spacing (form elements, list items)
24px  - Comfortable spacing (card padding)
32px  - Section spacing (between groups)
48px  - Large spacing (section gaps)
64px  - Extra large (major sections)
80px  - Hero spacing
120px - Dramatic spacing (section breaks)
```

### Proximity Principle
Related items should be closer together than unrelated items.

```
✓ Good:
[Label]          <- 4px gap
[Input field]
                 <- 24px gap
[Label]
[Input field]

✗ Bad:
[Label]          <- 16px gap
[Input field]    <- 16px gap
[Label]          <- 16px gap
[Input field]
```

### Content Width
- **Body text**: 65-75 characters per line (max-width: 65ch)
- **Headlines**: Can be wider, but still constrained
- **Full-width**: Only for backgrounds, images, nav

```css
.prose { max-width: 65ch; }
.container { max-width: 1200px; }
.container-sm { max-width: 800px; }
.container-lg { max-width: 1400px; }
```

---

## Component Patterns

### Cards
```
Padding: 24-32px
Border-radius: 16-24px (rounded-2xl to rounded-3xl)
Shadow: Subtle, colored (not gray)
Border: 1px transparent or very subtle
Hover: Slight lift (-4px Y), scale(1.01), border glow
```

### Buttons
```
Height: 44-48px (touch-friendly)
Padding: 16-24px horizontal
Border-radius: 8-12px or full (pills)
States: default, hover, active (scale 0.98), disabled, loading
Primary: Solid color + subtle shadow/glow
Secondary: Ghost/outline, gradient border on hover
```

### Inputs
```
Height: 44-48px
Padding: 12-16px
Border-radius: 8-12px
Border: 1px subtle (stronger on focus)
Focus: Ring or glow effect
States: default, focus, error, disabled
Labels: Above input, not inside
```

### Navigation
```
Height: 64-80px
Position: Fixed top, glass background on scroll
Items: 5 max in primary nav
Active indicator: Pill background or underline
Mobile: Full overlay with staggered animation
```

---

## Interaction Design

### Response Times
- **Instant** (0-100ms): Button highlights, hover states
- **Quick** (100-300ms): Animations, transitions
- **Noticeable** (300-1000ms): Page transitions, loading states
- **Long** (1000ms+): Need progress indicator

### Feedback Patterns
Every action needs feedback:

| Action | Feedback |
|--------|----------|
| Hover | Color change, cursor change |
| Click/tap | Scale down (0.98), color shift |
| Form submit | Button loading state → success/error |
| Data loading | Skeleton or spinner |
| Error | Inline message, toast notification |
| Success | Toast, inline confirmation |

### Micro-interactions
Subtle animations that delight:

- **Button press**: `transform: scale(0.98)`
- **Card hover**: `transform: translateY(-4px)`
- **Toggle**: Smooth slide with bounce
- **Checkbox**: Check mark draws in
- **Dropdown**: Items stagger in
- **Modal**: Fade + scale from center

---

## Mobile-First Design

### Breakpoints
```css
/* Mobile first - start with mobile styles */
/* Then add complexity as screen grows */

@media (min-width: 640px) { /* sm - landscape phones */ }
@media (min-width: 768px) { /* md - tablets */ }
@media (min-width: 1024px) { /* lg - laptops */ }
@media (min-width: 1280px) { /* xl - desktops */ }
@media (min-width: 1536px) { /* 2xl - large screens */ }
```

### Touch Targets
- **Minimum**: 44x44px
- **Comfortable**: 48x48px
- **Generous**: 56x56px

### Thumb Zone
On mobile, primary actions should be reachable by thumb:
- **Easy zone**: Bottom center of screen
- **OK zone**: Bottom half, sides
- **Hard zone**: Top of screen

```
┌─────────────────┐
│     HARD        │
│                 │
│   OK   |   OK   │
│                 │
│      EASY       │
└─────────────────┘
```

### Mobile Simplification
Don't shrink desktop to mobile. Simplify:
- **Reduce columns**: 4 → 2 → 1
- **Hide secondary actions**: Behind menus
- **Stack horizontal layouts**: Vertical on mobile
- **Prioritize content**: What matters most?
- **Increase spacing**: Touch needs room

---

## Accessibility (WCAG 2.1 AA)

### Color Contrast
| Element | Minimum Ratio |
|---------|---------------|
| Normal text | 4.5:1 |
| Large text (18px+ or 14px bold) | 3:1 |
| UI components | 3:1 |
| Non-text elements | 3:1 |

### Focus States
Every interactive element must have visible focus:
```css
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
```

### Motion & Animation
Respect user preferences:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Screen Reader Support
- All images need `alt` text
- Form inputs need `<label>` elements
- Use semantic HTML (`<nav>`, `<main>`, `<article>`)
- ARIA labels where HTML semantics aren't enough
- Logical heading hierarchy (h1 → h2 → h3)

### Keyboard Navigation
- All interactions accessible via keyboard
- Logical tab order (visual order = DOM order)
- Skip links for long navigation
- Escape closes modals
- Arrow keys for menus

---

## Content UX

### Writing Guidelines
- **Headlines**: Clear benefit, not clever wordplay
- **Body**: Short sentences, one idea per paragraph
- **CTAs**: Action verbs ("Get started", "See pricing")
- **Errors**: What happened + how to fix it
- **Empty states**: Explain + suggest action

### Information Architecture
1. **Primary actions**: Always visible, prominent
2. **Secondary actions**: Visible but subdued
3. **Tertiary actions**: Behind menus, "more" buttons
4. **Destructive actions**: Require confirmation

### Progressive Disclosure
Show only what's needed now. Reveal complexity gradually.

```
Level 1: Essential information
    └── [Expand] → Level 2: Supporting details
                        └── [Learn more] → Level 3: Full documentation
```

---

## Performance UX

### Perceived Performance
Make things feel fast:
- **Skeleton screens**: Show layout immediately
- **Optimistic updates**: Update UI before server confirms
- **Progressive loading**: Show content as it arrives
- **Preloading**: Anticipate next action

### Loading States
| Duration | Treatment |
|----------|-----------|
| 0-200ms | No indicator needed |
| 200ms-1s | Subtle spinner or pulse |
| 1-3s | Skeleton screen |
| 3s+ | Progress bar + message |

### Image Loading
- Use `loading="lazy"` for below-fold images
- Provide `width` and `height` to prevent layout shift
- Use appropriate formats (WebP, AVIF)
- Serve responsive sizes via `srcset`

---

## Anti-Patterns

**Layout:**
- Centered text for more than 2 lines
- Everything the same size (no hierarchy)
- Cramped spacing on desktop
- Fixed widths that break responsively

**Interaction:**
- No feedback on user actions
- Disabled buttons without explanation
- Form errors only at top of form
- Infinite scroll without way to reach footer

**Mobile:**
- Horizontal scrolling (unintentional)
- Touch targets under 44px
- Tiny text requiring zoom
- Desktop navigation on mobile

**Accessibility:**
- Color as only indicator (red = error)
- Auto-playing video/audio
- Flashing content
- Keyboard traps in modals
- Removing focus outlines without replacement

---

## Checklist Before Launch

### Visual
- [ ] Clear visual hierarchy
- [ ] Consistent spacing (8pt grid)
- [ ] Color contrast verified
- [ ] Typography scale applied
- [ ] Dark mode works (if applicable)

### Interaction
- [ ] All states designed (hover, active, disabled, loading, error)
- [ ] Feedback on all actions
- [ ] Animations feel natural
- [ ] Loading states present

### Mobile
- [ ] Touch targets 44px+
- [ ] Readable without zoom
- [ ] Forms easy to complete
- [ ] Primary actions in thumb zone

### Accessibility
- [ ] Keyboard navigable
- [ ] Focus states visible
- [ ] Screen reader tested
- [ ] Reduced motion respected
- [ ] Alt text on images
