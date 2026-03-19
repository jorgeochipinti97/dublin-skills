# Remotion Animation Patterns

## Core Concepts

```tsx
import { useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';

const frame = useCurrentFrame();  // Current frame number (0, 1, 2...)
const { fps } = useVideoConfig(); // Video config (fps, width, height)
```

## Fade Animations

### Fade In

```tsx
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateRight: 'clamp',
});

<div style={{ opacity }}>Content</div>
```

### Fade Out

```tsx
const opacity = interpolate(frame, [60, 90], [1, 0], {
  extrapolateLeft: 'clamp',
});
```

### Fade In Then Out

```tsx
const opacity = interpolate(
  frame,
  [0, 30, 60, 90],
  [0, 1, 1, 0],
  { extrapolateRight: 'clamp' }
);
```

## Slide Animations

### Slide From Left

```tsx
const translateX = interpolate(frame, [0, 30], [-100, 0], {
  extrapolateRight: 'clamp',
});

<div style={{ transform: `translateX(${translateX}%)` }}>Content</div>
```

### Slide From Right

```tsx
const translateX = interpolate(frame, [0, 30], [100, 0], {
  extrapolateRight: 'clamp',
});
```

### Slide From Bottom

```tsx
const translateY = interpolate(frame, [0, 30], [100, 0], {
  extrapolateRight: 'clamp',
});

<div style={{ transform: `translateY(${translateY}%)` }}>Content</div>
```

### Slide + Fade (Common Pattern)

```tsx
const opacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: 'clamp' });
const translateY = interpolate(frame, [0, 30], [50, 0], { extrapolateRight: 'clamp' });

<div style={{ opacity, transform: `translateY(${translateY}px)` }}>
  Content
</div>
```

## Scale Animations

### Zoom In

```tsx
const scale = interpolate(frame, [0, 30], [0.5, 1], {
  extrapolateRight: 'clamp',
});

<div style={{ transform: `scale(${scale})` }}>Content</div>
```

### Pop In (with overshoot)

```tsx
const scale = spring({
  frame,
  fps,
  config: { damping: 10, stiffness: 200 },
});

<div style={{ transform: `scale(${scale})` }}>Content</div>
```

## Spring Physics

Spring creates natural, physics-based motion.

```tsx
import { spring } from 'remotion';

// Basic spring (0 to 1)
const progress = spring({ frame, fps });

// Delayed spring (starts at frame 30)
const progress = spring({ frame: frame - 30, fps });

// Custom spring config
const progress = spring({
  frame,
  fps,
  config: {
    damping: 12,      // Lower = more bouncy (default: 10)
    stiffness: 200,   // Higher = faster (default: 100)
    mass: 1,          // Higher = heavier feel
  },
});
```

### Spring Presets

```tsx
// Snappy (UI elements)
const snappy = { damping: 15, stiffness: 300 };

// Bouncy (playful animations)
const bouncy = { damping: 8, stiffness: 150 };

// Smooth (subtle transitions)
const smooth = { damping: 20, stiffness: 100 };
```

## Staggered Animations

### Items appearing one by one

```tsx
const items = ['First', 'Second', 'Third'];
const staggerDelay = 10; // frames between each item

{items.map((item, index) => {
  const delay = index * staggerDelay;
  const opacity = interpolate(
    frame,
    [delay, delay + 20],
    [0, 1],
    { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
  );
  const translateY = interpolate(
    frame,
    [delay, delay + 20],
    [30, 0],
    { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
  );

  return (
    <div
      key={index}
      style={{ opacity, transform: `translateY(${translateY}px)` }}
    >
      {item}
    </div>
  );
})}
```

### With spring

```tsx
{items.map((item, index) => {
  const delay = index * 8;
  const progress = spring({
    frame: frame - delay,
    fps,
    config: { damping: 12, stiffness: 200 },
  });

  return (
    <div
      key={index}
      style={{
        opacity: progress,
        transform: `translateY(${(1 - progress) * 30}px)`,
      }}
    >
      {item}
    </div>
  );
})}
```

## Text Animations

### Typewriter Effect

```tsx
const text = 'Hello World';
const charsPerFrame = 0.5; // Speed

const visibleChars = Math.floor(frame * charsPerFrame);
const displayText = text.slice(0, visibleChars);

<span>{displayText}</span>
```

### Word by Word

```tsx
const words = ['Build', 'beautiful', 'videos'];
const framesPerWord = 20;

{words.map((word, i) => {
  const start = i * framesPerWord;
  const opacity = interpolate(
    frame,
    [start, start + 10],
    [0, 1],
    { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' }
  );

  return (
    <span key={i} style={{ opacity, marginRight: 10 }}>
      {word}
    </span>
  );
})}
```

### Letter by Letter (staggered)

```tsx
const text = 'HELLO';
const framesPerLetter = 5;

{text.split('').map((char, i) => {
  const delay = i * framesPerLetter;
  const scale = spring({
    frame: frame - delay,
    fps,
    config: { damping: 10, stiffness: 200 },
  });

  return (
    <span
      key={i}
      style={{
        display: 'inline-block',
        transform: `scale(${scale})`,
      }}
    >
      {char}
    </span>
  );
})}
```

## Sequences (Remotion's Sequence Component)

For complex timelines with multiple scenes:

```tsx
import { Sequence, AbsoluteFill } from 'remotion';

export const MyVideo = () => {
  return (
    <AbsoluteFill>
      <Sequence from={0} durationInFrames={60}>
        <IntroScene />
      </Sequence>

      <Sequence from={60} durationInFrames={120}>
        <MainScene />
      </Sequence>

      <Sequence from={180} durationInFrames={60}>
        <OutroScene />
      </Sequence>
    </AbsoluteFill>
  );
};
```

Inside each Sequence, `useCurrentFrame()` resets to 0.

## Easing Functions

For non-linear motion without springs:

```tsx
import { Easing } from 'remotion';

const progress = interpolate(frame, [0, 60], [0, 1], {
  easing: Easing.bezier(0.25, 0.1, 0.25, 1), // CSS ease
  extrapolateRight: 'clamp',
});

// Common easings
Easing.linear
Easing.ease           // Default CSS ease
Easing.inOut(Easing.quad)
Easing.bezier(0.4, 0, 0.2, 1)  // Material Design standard
```

## Loop Animation

```tsx
const loopDuration = 60; // frames
const loopFrame = frame % loopDuration;

const rotation = interpolate(loopFrame, [0, loopDuration], [0, 360]);

<div style={{ transform: `rotate(${rotation}deg)` }}>Spinning</div>
```

## Combining Animations (Utility)

```tsx
// Helper to chain multiple animations
const animate = (frame: number, animations: Array<{
  start: number;
  end: number;
  from: number;
  to: number;
}>) => {
  return animations.reduce((acc, { start, end, from, to }) => {
    if (frame < start) return from;
    if (frame > end) return to;
    return interpolate(frame, [start, end], [from, to], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });
  }, 0);
};
```
