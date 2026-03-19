#!/bin/bash
# Setup Remotion in an existing React/Next.js project

set -e

echo "Setting up Remotion..."

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "Error: package.json not found. Run this from a Node.js project root."
  exit 1
fi

# Detect package manager
if [ -f "pnpm-lock.yaml" ]; then
  PM="pnpm"
elif [ -f "yarn.lock" ]; then
  PM="yarn"
else
  PM="npm"
fi

echo "Using package manager: $PM"

# Install Remotion dependencies
echo "Installing Remotion packages..."
$PM add remotion @remotion/cli @remotion/player

# Create remotion directory structure
echo "Creating directory structure..."
mkdir -p src/remotion/compositions
mkdir -p src/remotion/components

# Create config file
cat > src/remotion/config.ts << 'EOF'
export const VIDEO_CONFIG = {
  landscape: { width: 1920, height: 1080 },
  vertical: { width: 1080, height: 1920 },
  square: { width: 1080, height: 1080 },
} as const;

export const DEFAULT_FPS = 30;
EOF

# Create root index file
cat > src/remotion/index.ts << 'EOF'
import { registerRoot } from 'remotion';
import { RemotionRoot } from './Root';

registerRoot(RemotionRoot);
EOF

# Create Root component
cat > src/remotion/Root.tsx << 'EOF'
import { Composition } from 'remotion';
import { VIDEO_CONFIG, DEFAULT_FPS } from './config';
// Import your compositions here
// import { PromoComposition } from './compositions/Promo';

export const RemotionRoot = () => {
  return (
    <>
      {/* Example composition - replace with your own */}
      {/*
      <Composition
        id="Promo"
        component={PromoComposition}
        durationInFrames={300}
        fps={DEFAULT_FPS}
        width={VIDEO_CONFIG.landscape.width}
        height={VIDEO_CONFIG.landscape.height}
      />
      */}
    </>
  );
};
EOF

# Create example composition
cat > src/remotion/compositions/Example.tsx << 'EOF'
import { useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';

export const ExampleComposition = () => {
  const frame = useCurrentFrame();
  const { fps, width, height } = useVideoConfig();

  const opacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateRight: 'clamp',
  });

  const scale = spring({
    frame,
    fps,
    config: { damping: 12, stiffness: 200 },
  });

  return (
    <div
      style={{
        flex: 1,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#0f0f0f',
        width,
        height,
      }}
    >
      <h1
        style={{
          fontSize: 80,
          fontWeight: 700,
          color: 'white',
          opacity,
          transform: `scale(${scale})`,
        }}
      >
        Hello Remotion
      </h1>
    </div>
  );
};
EOF

# Create remotion.config.ts at project root
cat > remotion.config.ts << 'EOF'
import { Config } from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');
Config.setOverwriteOutput(true);

// Uncomment if using Tailwind
// Config.overrideWebpackConfig((config) => {
//   return {
//     ...config,
//     module: {
//       ...config.module,
//       rules: [
//         ...(config.module?.rules || []),
//         {
//           test: /\.css$/,
//           use: ['style-loader', 'css-loader', 'postcss-loader'],
//         },
//       ],
//     },
//   };
// });
EOF

# Add scripts to package.json
echo "Adding npm scripts..."
if command -v jq &> /dev/null; then
  jq '.scripts["remotion:preview"] = "remotion preview src/remotion/index.ts" |
      .scripts["remotion:render"] = "remotion render src/remotion/index.ts"' \
    package.json > package.json.tmp && mv package.json.tmp package.json
else
  echo ""
  echo "Add these scripts to package.json manually:"
  echo '  "remotion:preview": "remotion preview src/remotion/index.ts"'
  echo '  "remotion:render": "remotion render src/remotion/index.ts"'
fi

echo ""
echo "Remotion setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit src/remotion/Root.tsx to add your compositions"
echo "  2. Run: $PM run remotion:preview"
echo "  3. Render: npx remotion render src/remotion/index.ts CompositionId output.mp4"
