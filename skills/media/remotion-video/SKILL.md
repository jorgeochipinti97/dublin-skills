---
name: remotion-video
description: Programmatic video generation with Remotion headless. Use when the user wants to: (1) Create promotional or animated videos, (2) Convert existing React/JSX components into videos, (3) Generate social media content (Instagram, TikTok, YouTube Shorts), (4) Export animations to .mp4, (5) Make intros, outros, or product videos, (6) Animate landing page sections or hero components.
---

# Remotion Video Generator

Generate videos programmatically by reusing existing React components with Remotion headless rendering.

## Quick Reference

### Supported Formats

| Format | Resolution | Use Case |
|--------|-----------|----------|
| landscape | 1920x1080 | YouTube, web embeds |
| vertical | 1080x1920 | Instagram Stories, TikTok, Reels |
| square | 1080x1080 | Instagram feed, LinkedIn |

### FPS Recommendations

- **30 fps** — Standard, smaller files
- **60 fps** — Smooth animations, larger files

### Duration Guidelines

- **5-15 sec** — Intros, outros, quick promos
- **15-30 sec** — Feature showcases, social ads
- **30-60 sec** — Product demos (max recommended for render time)

## Workflow

### 1. Check Remotion Setup

```bash
# Check if remotion is installed
grep -q "remotion" package.json && echo "Remotion installed" || echo "Need setup"
```

If not installed, run `scripts/setup_remotion.sh` from this skill.

### 2. Identify Components to Animate

User specifies existing components (e.g., `HeroSection`, `FeatureCard`, `PricingTable`). Read the component source to understand its props and structure.

### 3. Create Composition

Create a new composition in `src/remotion/` that:
- Imports the target component(s)
- Wraps them with Remotion's `useCurrentFrame()` and `interpolate()`
- Applies animations (fadeIn, slideIn, scale, spring)

Use `assets/base-composition.tsx` as template.

### 4. Render

```bash
npx remotion render src/remotion/index.ts CompositionName output.mp4 \
  --codec=h264 \
  --fps=30
```

## Animation Patterns

See `references/animations.md` for:
- Fade animations
- Slide animations (from any direction)
- Scale/zoom effects
- Spring physics
- Staggered reveals
- Text animations (typewriter, word-by-word)

## Component Adaptation

See `references/component-patterns.md` for:
- Making components "frame-aware"
- Handling Tailwind/CSS in Remotion
- Dealing with external dependencies
- Mocking data and state

## File Structure

After setup, the project should have:

```
src/remotion/
├── index.ts          # Root file with registerRoot()
├── compositions/     # Video compositions
│   └── Promo.tsx
├── components/       # Remotion-specific wrappers
│   └── AnimatedHero.tsx
└── config.ts         # Shared config (fps, dimensions)
```

## Common Compositions

### Promo Video (landscape)

```tsx
import { Composition } from 'remotion';

export const PromoVideo = () => (
  <Composition
    id="Promo"
    component={PromoComposition}
    durationInFrames={300} // 10 sec @ 30fps
    fps={30}
    width={1920}
    height={1080}
  />
);
```

### Instagram Story (vertical)

```tsx
<Composition
  id="Story"
  component={StoryComposition}
  durationInFrames={450} // 15 sec @ 30fps
  fps={30}
  width={1080}
  height={1920}
/>
```

### Square Post

```tsx
<Composition
  id="Post"
  component={PostComposition}
  durationInFrames={300}
  fps={30}
  width={1080}
  height={1080}
/>
```

## Render Commands

```bash
# Preview in browser
npx remotion preview src/remotion/index.ts

# Render to mp4
npx remotion render src/remotion/index.ts CompositionId output.mp4

# Render with quality settings
npx remotion render src/remotion/index.ts CompositionId output.mp4 \
  --codec=h264 \
  --crf=18 \
  --fps=30

# Render specific frame range (for testing)
npx remotion render src/remotion/index.ts CompositionId test.mp4 \
  --frames=0-90
```

## Requirements

- Node.js 18+
- ffmpeg (for encoding)
- Chromium (bundled with Remotion)

## Troubleshooting

### Fonts not loading
Bundle fonts in `public/` and use `@font-face` in a global CSS file imported by the composition.

### Tailwind not working
Import the project's CSS in the composition entry point. Remotion uses its own bundler, so Tailwind must be configured in `remotion.config.ts`.

### External images not loading
Use `staticFile()` for local assets or `delayRender()`/`continueRender()` for remote images.

### Render too slow
- Reduce duration
- Lower resolution for testing
- Use `--concurrency` flag for parallel frame rendering
