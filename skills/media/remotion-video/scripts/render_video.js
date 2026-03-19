#!/usr/bin/env node
/**
 * Render a Remotion composition to mp4
 *
 * Usage:
 *   node render_video.js <compositionId> [options]
 *
 * Options:
 *   --output, -o    Output file path (default: output.mp4)
 *   --format, -f    Format: landscape, vertical, square
 *   --fps           Frames per second (default: 30)
 *   --duration, -d  Duration in seconds
 *   --crf           Quality (0-51, lower=better, default: 18)
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const args = process.argv.slice(2);

if (args.length === 0 || args.includes('--help') || args.includes('-h')) {
  console.log(`
Usage: node render_video.js <compositionId> [options]

Options:
  --output, -o    Output file path (default: output.mp4)
  --format, -f    Format: landscape, vertical, square
  --fps           Frames per second (default: 30)
  --duration, -d  Duration in seconds (overrides composition duration)
  --crf           Quality (0-51, lower=better, default: 18)
  --entry         Entry file (default: src/remotion/index.ts)

Examples:
  node render_video.js Promo
  node render_video.js Promo -o promo.mp4 -f vertical
  node render_video.js Promo --fps=60 --crf=15
`);
  process.exit(0);
}

// Parse arguments
const compositionId = args[0];
let output = 'output.mp4';
let format = null;
let fps = 30;
let duration = null;
let crf = 18;
let entry = 'src/remotion/index.ts';

for (let i = 1; i < args.length; i++) {
  const arg = args[i];

  if (arg === '-o' || arg === '--output') {
    output = args[++i];
  } else if (arg.startsWith('--output=')) {
    output = arg.split('=')[1];
  } else if (arg === '-f' || arg === '--format') {
    format = args[++i];
  } else if (arg.startsWith('--format=')) {
    format = arg.split('=')[1];
  } else if (arg === '--fps') {
    fps = parseInt(args[++i]);
  } else if (arg.startsWith('--fps=')) {
    fps = parseInt(arg.split('=')[1]);
  } else if (arg === '-d' || arg === '--duration') {
    duration = parseFloat(args[++i]);
  } else if (arg.startsWith('--duration=')) {
    duration = parseFloat(arg.split('=')[1]);
  } else if (arg === '--crf') {
    crf = parseInt(args[++i]);
  } else if (arg.startsWith('--crf=')) {
    crf = parseInt(arg.split('=')[1]);
  } else if (arg === '--entry') {
    entry = args[++i];
  } else if (arg.startsWith('--entry=')) {
    entry = arg.split('=')[1];
  }
}

// Validate entry file exists
if (!fs.existsSync(entry)) {
  console.error(`Error: Entry file not found: ${entry}`);
  console.error('Run setup_remotion.sh first or specify --entry');
  process.exit(1);
}

// Build command
const cmdParts = [
  'npx remotion render',
  entry,
  compositionId,
  output,
  `--codec=h264`,
  `--crf=${crf}`,
];

// Add format-specific dimensions
if (format) {
  const formats = {
    landscape: { width: 1920, height: 1080 },
    vertical: { width: 1080, height: 1920 },
    square: { width: 1080, height: 1080 },
  };

  if (!formats[format]) {
    console.error(`Invalid format: ${format}. Use: landscape, vertical, square`);
    process.exit(1);
  }

  cmdParts.push(`--width=${formats[format].width}`);
  cmdParts.push(`--height=${formats[format].height}`);
}

// Add fps if specified
if (fps !== 30) {
  cmdParts.push(`--fps=${fps}`);
}

// Add duration if specified (convert to frames)
if (duration) {
  const frames = Math.ceil(duration * fps);
  cmdParts.push(`--frames=0-${frames}`);
}

const cmd = cmdParts.join(' ');

console.log(`Rendering ${compositionId}...`);
console.log(`Command: ${cmd}\n`);

try {
  execSync(cmd, { stdio: 'inherit' });
  console.log(`\nDone! Output: ${output}`);
} catch (error) {
  console.error('Render failed');
  process.exit(1);
}
