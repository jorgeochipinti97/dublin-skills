/**
 * Base Composition Template
 *
 * Copy this file to your project's src/remotion/compositions/ directory
 * and customize for your specific video needs.
 */

import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Sequence,
} from 'remotion';

// Import your existing components here
// import { HeroSection } from '@/components/HeroSection';
// import { FeatureCard } from '@/components/FeatureCard';

/**
 * Video configuration - customize these values
 */
const CONFIG = {
  backgroundColor: '#0a0a0a',
  primaryColor: '#3b82f6',
  textColor: '#ffffff',
  fontFamily: 'Inter, system-ui, sans-serif',
};

/**
 * Scene 1: Intro/Title
 */
const IntroScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const titleProgress = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 200 },
  });

  const subtitleOpacity = interpolate(frame, [20, 40], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: CONFIG.backgroundColor,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily: CONFIG.fontFamily,
      }}
    >
      <h1
        style={{
          fontSize: 72,
          fontWeight: 700,
          color: CONFIG.textColor,
          margin: 0,
          transform: `scale(${titleProgress})`,
        }}
      >
        Your Title Here
      </h1>

      <p
        style={{
          fontSize: 28,
          color: CONFIG.primaryColor,
          marginTop: 20,
          opacity: subtitleOpacity,
        }}
      >
        Your subtitle or tagline
      </p>
    </AbsoluteFill>
  );
};

/**
 * Scene 2: Feature Showcase
 */
const FeatureScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const features = [
    { icon: '⚡', title: 'Feature One', description: 'Brief description' },
    { icon: '🎯', title: 'Feature Two', description: 'Brief description' },
    { icon: '✨', title: 'Feature Three', description: 'Brief description' },
  ];

  return (
    <AbsoluteFill
      style={{
        backgroundColor: CONFIG.backgroundColor,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 40,
        padding: 80,
        fontFamily: CONFIG.fontFamily,
      }}
    >
      {features.map((feature, index) => {
        const delay = index * 10;
        const progress = spring({
          frame: frame - delay,
          fps,
          config: { damping: 12, stiffness: 200 },
        });

        return (
          <div
            key={index}
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              gap: 16,
              opacity: progress,
              transform: `translateY(${(1 - progress) * 30}px)`,
            }}
          >
            <span style={{ fontSize: 64 }}>{feature.icon}</span>
            <h3
              style={{
                fontSize: 24,
                fontWeight: 600,
                color: CONFIG.textColor,
                margin: 0,
              }}
            >
              {feature.title}
            </h3>
            <p
              style={{
                fontSize: 16,
                color: '#a0a0a0',
                margin: 0,
                textAlign: 'center',
              }}
            >
              {feature.description}
            </p>
          </div>
        );
      })}
    </AbsoluteFill>
  );
};

/**
 * Scene 3: Call to Action / Outro
 */
const OutroScene = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const ctaProgress = spring({
    frame,
    fps,
    config: { damping: 10, stiffness: 150 },
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: CONFIG.backgroundColor,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily: CONFIG.fontFamily,
      }}
    >
      <h2
        style={{
          fontSize: 56,
          fontWeight: 700,
          color: CONFIG.textColor,
          margin: 0,
          transform: `scale(${ctaProgress})`,
        }}
      >
        Get Started Today
      </h2>

      <div
        style={{
          marginTop: 40,
          padding: '16px 48px',
          backgroundColor: CONFIG.primaryColor,
          borderRadius: 12,
          opacity: ctaProgress,
          transform: `translateY(${(1 - ctaProgress) * 20}px)`,
        }}
      >
        <span
          style={{
            fontSize: 24,
            fontWeight: 600,
            color: CONFIG.textColor,
          }}
        >
          yoursite.com
        </span>
      </div>
    </AbsoluteFill>
  );
};

/**
 * Main Composition
 *
 * Combines all scenes with Sequence for timeline control.
 * Adjust durationInFrames for each sequence to control timing.
 *
 * At 30fps:
 * - 30 frames = 1 second
 * - 60 frames = 2 seconds
 * - 90 frames = 3 seconds
 */
export const BaseComposition = () => {
  return (
    <AbsoluteFill>
      {/* Scene 1: Intro (0-3 seconds) */}
      <Sequence from={0} durationInFrames={90}>
        <IntroScene />
      </Sequence>

      {/* Scene 2: Features (3-7 seconds) */}
      <Sequence from={90} durationInFrames={120}>
        <FeatureScene />
      </Sequence>

      {/* Scene 3: Outro (7-10 seconds) */}
      <Sequence from={210} durationInFrames={90}>
        <OutroScene />
      </Sequence>
    </AbsoluteFill>
  );
};

/**
 * Export for use in Root.tsx:
 *
 * import { BaseComposition } from './compositions/BaseComposition';
 *
 * <Composition
 *   id="Promo"
 *   component={BaseComposition}
 *   durationInFrames={300}  // 10 seconds @ 30fps
 *   fps={30}
 *   width={1920}
 *   height={1080}
 * />
 */
