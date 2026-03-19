# Adapting React Components for Remotion

## Making Components Frame-Aware

### Pattern 1: Wrapper Component

Wrap existing components without modifying them:

```tsx
// Original component (unchanged)
export const HeroSection = ({ title, subtitle }: Props) => (
  <div className="hero">
    <h1>{title}</h1>
    <p>{subtitle}</p>
  </div>
);

// Remotion wrapper
import { useCurrentFrame, interpolate } from 'remotion';
import { HeroSection } from '@/components/HeroSection';

export const AnimatedHero = () => {
  const frame = useCurrentFrame();

  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const translateY = interpolate(frame, [0, 30], [50, 0], {
    extrapolateRight: 'clamp',
  });

  return (
    <div style={{ opacity, transform: `translateY(${translateY}px)` }}>
      <HeroSection title="Welcome" subtitle="To our product" />
    </div>
  );
};
```

### Pattern 2: Prop Injection

Pass animation values as props:

```tsx
// Modified component (accepts animation props)
interface AnimatedCardProps {
  title: string;
  animationProgress?: number; // 0 to 1
}

export const AnimatedCard = ({ title, animationProgress = 1 }: AnimatedCardProps) => (
  <div
    style={{
      opacity: animationProgress,
      transform: `scale(${0.8 + animationProgress * 0.2})`,
    }}
  >
    <h2>{title}</h2>
  </div>
);

// In Remotion composition
const progress = spring({ frame, fps });
<AnimatedCard title="Feature" animationProgress={progress} />
```

### Pattern 3: Context Provider

For complex components with many animated children:

```tsx
import { createContext, useContext } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';

const AnimationContext = createContext({ frame: 0, fps: 30 });

export const AnimationProvider = ({ children }: { children: React.ReactNode }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <AnimationContext.Provider value={{ frame, fps }}>
      {children}
    </AnimationContext.Provider>
  );
};

export const useAnimation = () => useContext(AnimationContext);

// Usage in any child component
const ChildComponent = () => {
  const { frame, fps } = useAnimation();
  // Use frame for animations
};
```

## Handling Tailwind CSS

### Option 1: Import Project CSS

In your composition entry:

```tsx
// src/remotion/compositions/Promo.tsx
import '../../styles/globals.css'; // Your Tailwind CSS

export const PromoComposition = () => (
  <div className="bg-gradient-to-r from-blue-500 to-purple-600 p-8">
    {/* Tailwind works */}
  </div>
);
```

Configure in `remotion.config.ts`:

```ts
import { Config } from '@remotion/cli/config';

Config.overrideWebpackConfig((config) => ({
  ...config,
  module: {
    ...config.module,
    rules: [
      ...(config.module?.rules || []),
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader', 'postcss-loader'],
      },
    ],
  },
}));
```

### Option 2: Inline Styles (Safest)

Convert Tailwind classes to inline styles for guaranteed consistency:

```tsx
// Instead of
<div className="flex items-center justify-center bg-black">

// Use
<div style={{
  display: 'flex',
  alignItems: 'center',
  justifyContent: 'center',
  backgroundColor: 'black',
}}>
```

### Option 3: Tailwind-to-Style Utility

```tsx
// Simple mapping for common utilities
const tw = {
  'flex': { display: 'flex' },
  'items-center': { alignItems: 'center' },
  'justify-center': { justifyContent: 'center' },
  // Add more as needed
};

const mergeStyles = (...classes: (keyof typeof tw)[]) =>
  classes.reduce((acc, cls) => ({ ...acc, ...tw[cls] }), {});

// Usage
<div style={mergeStyles('flex', 'items-center', 'justify-center')}>
```

## Handling External Dependencies

### Images

```tsx
import { staticFile, Img } from 'remotion';

// Local images (place in public/)
<Img src={staticFile('logo.png')} />

// Remote images (use delayRender)
import { delayRender, continueRender } from 'remotion';

const RemoteImage = ({ src }: { src: string }) => {
  const [handle] = useState(() => delayRender());

  return (
    <img
      src={src}
      onLoad={() => continueRender(handle)}
      onError={() => continueRender(handle)}
    />
  );
};
```

### Fonts

```tsx
// In a global CSS file imported by your composition
@font-face {
  font-family: 'Inter';
  src: url('./fonts/Inter.woff2') format('woff2');
  font-weight: 400 700;
}

// Or use Google Fonts with @remotion/google-fonts
import { loadFont } from '@remotion/google-fonts/Inter';

const { fontFamily } = loadFont();

<div style={{ fontFamily }}>Text</div>
```

### Icons (Lucide, Heroicons, etc.)

Icons work normally if imported as React components:

```tsx
import { ArrowRight } from 'lucide-react';

<ArrowRight size={24} color="white" />
```

## Mocking Data and State

### Static Props

Replace dynamic data with static props for the video:

```tsx
// Original component fetches data
const UserDashboard = () => {
  const { data } = useQuery('users');
  // ...
};

// Remotion version with static data
const UserDashboardVideo = () => {
  const mockData = {
    users: [
      { name: 'John', avatar: staticFile('john.jpg') },
      { name: 'Jane', avatar: staticFile('jane.jpg') },
    ],
  };

  return <UserDashboard data={mockData} />;
};
```

### Input Props (Dynamic)

Pass data at render time:

```tsx
// In composition definition
<Composition
  id="UserVideo"
  component={UserVideoComposition}
  defaultProps={{
    userName: 'Default User',
    theme: 'dark',
  }}
/>

// Render with custom props
npx remotion render src/remotion/index.ts UserVideo out.mp4 \
  --props='{"userName": "John", "theme": "light"}'
```

### Mocking Hooks

```tsx
// Create mock versions for video context
const useVideoMock = () => ({
  isPlaying: true,
  currentTime: useCurrentFrame() / 30,
});

// Replace real hook in video components
const VideoPlayer = ({ useMock = false }) => {
  const state = useMock ? useVideoMock() : useRealVideoState();
  // ...
};
```

## Component Isolation

### Remove Side Effects

Remotion renders each frame independently. Remove:
- `useEffect` with timers/intervals
- Event listeners
- State that depends on user interaction

```tsx
// Bad for Remotion
const Counter = () => {
  const [count, setCount] = useState(0);
  useEffect(() => {
    const interval = setInterval(() => setCount(c => c + 1), 1000);
    return () => clearInterval(interval);
  }, []);
  return <div>{count}</div>;
};

// Good for Remotion
const Counter = () => {
  const frame = useCurrentFrame();
  const count = Math.floor(frame / 30); // Count up every second (30fps)
  return <div>{count}</div>;
};
```

### AbsoluteFill for Full-Screen Components

```tsx
import { AbsoluteFill } from 'remotion';

const Scene = () => (
  <AbsoluteFill style={{ backgroundColor: '#0f0f0f' }}>
    {/* Content fills entire frame */}
  </AbsoluteFill>
);
```

## Common Patterns Summary

| Pattern | Use When |
|---------|----------|
| Wrapper Component | Animating unmodified existing components |
| Prop Injection | Component needs animation values internally |
| Context Provider | Many components need frame/fps |
| Static Props | Replacing API/database data |
| Input Props | Customizing videos at render time |
| AbsoluteFill | Full-screen scenes |
