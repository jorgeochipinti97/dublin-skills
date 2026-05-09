#!/usr/bin/env tsx
/**
 * Frontend Output Validator — Layer 1 (static checks)
 *
 * Runs against the source tree and emits a pass/fail report.
 * Designed to run in CI (exit 1 on failures) or locally (exit 0 always, just report).
 *
 * Usage:
 *   tsx scripts/validate-frontend.ts            # report only
 *   tsx scripts/validate-frontend.ts --strict   # exit 1 on any failure
 *
 * Reads DESIGN.md from repo root if present (used as source of truth for budgets).
 */

import { execSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

// ────────────────────────────────────────────────────────────────────────────
// Types
// ────────────────────────────────────────────────────────────────────────────

type Severity = 'fail' | 'warn' | 'info';

interface Finding {
  rule: string;
  severity: Severity;
  message: string;
  location?: string;
}

interface DesignContract {
  iconBudget?: Record<string, number>;
  cls?: { target?: number };
  touchTargets?: { min?: string };
  aiTellsEnforced?: string[];
  contentPriority?: Record<string, { critical: string[]; primary: string[] }>;
}

// ────────────────────────────────────────────────────────────────────────────
// Helpers
// ────────────────────────────────────────────────────────────────────────────

const findings: Finding[] = [];
const ROOT = process.cwd();
const SRC_GLOBS = ['src/', 'app/', 'pages/', 'components/'].filter(p => fs.existsSync(path.join(ROOT, p)));

function rg(pattern: string, opts: string = ''): string[] {
  if (SRC_GLOBS.length === 0) return [];
  try {
    const cmd = `rg --type tsx --type jsx --type ts --type js --type css ${opts} ${JSON.stringify(pattern)} ${SRC_GLOBS.join(' ')}`;
    const out = execSync(cmd, { encoding: 'utf-8', stdio: ['ignore', 'pipe', 'ignore'] });
    return out.trim().split('\n').filter(Boolean);
  } catch {
    return []; // rg returns non-zero when no matches
  }
}

function report(rule: string, severity: Severity, message: string, location?: string) {
  findings.push({ rule, severity, message, location });
}

function loadDesignContract(): DesignContract | null {
  const designPath = path.join(ROOT, 'DESIGN.md');
  if (!fs.existsSync(designPath)) {
    report('design.exists', 'fail', 'DESIGN.md not found at repo root');
    return null;
  }
  try {
    const raw = fs.readFileSync(designPath, 'utf-8');
    const match = raw.match(/^---\n([\s\S]*?)\n---/);
    if (!match) {
      report('design.yaml.parse', 'fail', 'DESIGN.md has no YAML frontmatter');
      return null;
    }
    // Lightweight YAML parse — for production use `yaml` package
    // For this template we expect the consumer to install `yaml` and replace this
    return {} as DesignContract; // placeholder
  } catch (err) {
    report('design.yaml.parse', 'fail', `DESIGN.md parse error: ${err}`);
    return null;
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Checks
// ────────────────────────────────────────────────────────────────────────────

function checkCLS() {
  // Images without dimensions
  const imgsNoDims = rg(`<img\\s+(?![^>]*\\b(width|height|aspect-)\\b)[^>]*src=`);
  for (const line of imgsNoDims) {
    report('cls.image-no-dims', 'fail', 'img tag missing width/height/aspect-ratio', line);
  }

  // 100vh instead of 100dvh
  const vhUsage = rg('\\b(h-screen|min-h-screen|h-\\[100vh\\]|min-h-\\[100vh\\])\\b');
  for (const line of vhUsage) {
    report('mobile.dvh', 'fail', 'use min-h-[100dvh] instead of 100vh / h-screen (iOS Safari)', line);
  }

  // transition-all / transition-[height]
  const badTransitions = rg('transition-(all|\\[height\\]|\\[width\\])');
  for (const line of badTransitions) {
    report('anim.bad-property', 'warn', 'avoid transition-all / [height] / [width] — animate transform/opacity only', line);
  }
}

function checkIconLibraries() {
  const libs = [
    "from 'lucide-react'",
    "from '@phosphor-icons/react'",
    "from '@radix-ui/react-icons'",
    "from '@heroicons/react",
  ];
  const detected = new Set<string>();
  for (const lib of libs) {
    const matches = rg(lib);
    if (matches.length > 0) detected.add(lib);
  }
  if (detected.size > 1) {
    report(
      'icon.library.mixed',
      'fail',
      `Multiple icon libraries detected: ${Array.from(detected).join(', ')}. Pick one.`,
    );
  }
}

function checkPureBlackTell() {
  const matches = rg('#000\\b|#000000\\b|#fff\\b|#ffffff\\b', '--glob "!**/globals.css" --glob "!**/tokens.css"');
  for (const line of matches) {
    report('aitell.pure-black', 'fail', 'Pure Black Tell — use semantic token instead of #000/#fff', line);
  }
}

function checkLilaBan() {
  const matches = rg('from-(purple|violet|indigo)-\\d+\\s+to-(blue|sky|indigo)-\\d+');
  for (const line of matches) {
    report('aitell.lila-ban', 'warn', 'LILA BAN — purple→blue gradient detected', line);
  }
}

function checkGradientHeadline() {
  const matches = rg('text-transparent[^"]*bg-clip-text');
  for (const line of matches) {
    report('aitell.gradient-headline', 'warn', 'Gradient text on headline — use solid color + tracking', line);
  }
}

function checkFillerWords() {
  const banned = [
    '\\bElevate\\b',
    '\\bUnleash\\b',
    '\\bSeamless\\b',
    '\\bNext-gen\\b',
    '\\bRevolutionize\\b',
    '\\bGame-changing\\b',
    '\\bEmpowering\\b',
    '\\bCutting-edge\\b',
    '\\bState-of-the-art\\b',
    '\\bBest-in-class\\b',
  ];
  for (const word of banned) {
    const matches = rg(word, '-i');
    for (const line of matches) {
      report('content.filler-word', 'warn', `Filler Word Index: ${word} detected`, line);
    }
  }
}

function checkJaneDoeAcme() {
  const banned = ['\\bJohn Doe\\b', '\\bJane Doe\\b', '\\bAcme\\b', '\\bNexus\\b', 'lorem ipsum'];
  for (const word of banned) {
    const matches = rg(word, '-i');
    for (const line of matches) {
      report('content.jane-doe', 'warn', `Demo content tell: ${word} detected`, line);
    }
  }
}

function checkUnsplashLinks() {
  const matches = rg('https://(images\\.)?unsplash\\.com');
  for (const line of matches) {
    report('content.unsplash-link', 'warn', 'Raw Unsplash link (link rot risk) — use picsum.photos or hosted asset', line);
  }
}

function checkScrollListener() {
  const matches = rg("addEventListener\\s*\\(\\s*['\"]scroll['\"]");
  for (const line of matches) {
    report('anim.scroll-listener', 'fail', 'Use IntersectionObserver or Framer useScroll instead of addEventListener("scroll")', line);
  }
}

function checkViewportMeta() {
  const layouts = [
    'src/app/layout.tsx',
    'src/app/layout.ts',
    'app/layout.tsx',
    'src/pages/_document.tsx',
    'pages/_document.tsx',
  ];
  let found = false;
  for (const p of layouts) {
    if (fs.existsSync(path.join(ROOT, p))) {
      const content = fs.readFileSync(path.join(ROOT, p), 'utf-8');
      if (/viewport/i.test(content)) {
        found = true;
        if (/user-scalable\s*=\s*no/.test(content)) {
          report('mobile.viewport.meta', 'fail', 'viewport has user-scalable=no — fails accessibility', p);
        }
        if (!/viewport-fit\s*=\s*cover/.test(content)) {
          report('mobile.viewport.fit', 'warn', 'missing viewport-fit=cover (needed for safe-area-inset)', p);
        }
        break;
      }
    }
  }
  if (!found) {
    report('mobile.viewport.meta', 'fail', 'No viewport meta detected in layout');
  }
}

function checkBodyFontSize() {
  const matches = rg('<input[^>]*\\btext-(xs|sm)\\b|<textarea[^>]*\\btext-(xs|sm)\\b');
  for (const line of matches) {
    report('mobile.body-size', 'warn', 'input/textarea < 16px causes iOS auto-zoom on focus — use text-base', line);
  }
}

function checkSafeArea() {
  // Heuristic: classes with 'fixed' + 'bottom-0' but no 'safe-area' / 'env('
  const matches = rg('\\bfixed\\b[^"]*\\bbottom-0\\b');
  for (const line of matches) {
    if (!line.includes('safe-area') && !line.includes('env(safe-area')) {
      report('mobile.safe-area', 'warn', 'fixed bottom bar without safe-area-inset padding', line);
    }
  }
}

function checkVeeVeeDubTrap() {
  // width: 100vw (CSS) and w-screen / w-[100vw] (Tailwind) — overflow risk because 100vw includes scrollbar
  const cssMatches = rg('\\bwidth:\\s*100vw\\b');
  for (const line of cssMatches) {
    report('mobile.vvw-trap', 'warn', 'width: 100vw includes scrollbar — use 100% (or wrap in overflow-x: clip if full-bleed needed)', line);
  }
  const twMatches = rg('\\bw-screen\\b|\\bw-\\[100vw\\]');
  for (const line of twMatches) {
    report('mobile.vvw-trap', 'warn', 'w-screen / w-[100vw] includes scrollbar — use w-full (or wrap full-bleed in overflow-x-clip)', line);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Report
// ────────────────────────────────────────────────────────────────────────────

function printReport() {
  const fails = findings.filter(f => f.severity === 'fail');
  const warns = findings.filter(f => f.severity === 'warn');
  const infos = findings.filter(f => f.severity === 'info');

  console.log('# Frontend Output Validation Report\n');
  console.log('## Summary');
  console.log(`- ✅ Checks run: ${findings.length === 0 ? 'all passed' : `${findings.length} findings`}`);
  console.log(`- ❌ Failures: ${fails.length}`);
  console.log(`- ⚠️  Warnings: ${warns.length}`);
  console.log(`- ℹ️  Info: ${infos.length}\n`);

  if (fails.length > 0) {
    console.log('## ❌ Failures (block merge)\n');
    for (const f of fails) {
      console.log(`- [${f.rule}] ${f.message}`);
      if (f.location) console.log(`  → ${f.location}`);
    }
    console.log();
  }

  if (warns.length > 0) {
    console.log('## ⚠️  Warnings (review before merge)\n');
    for (const f of warns) {
      console.log(`- [${f.rule}] ${f.message}`);
      if (f.location) console.log(`  → ${f.location}`);
    }
    console.log();
  }

  if (warns.length > 5) {
    console.log('## 📋 Action\n');
    console.log('More than 5 warnings — consider running `claude-md-keeper` to detect systemic drift.\n');
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Main
// ────────────────────────────────────────────────────────────────────────────

function main() {
  loadDesignContract();
  checkCLS();
  checkIconLibraries();
  checkPureBlackTell();
  checkLilaBan();
  checkGradientHeadline();
  checkFillerWords();
  checkJaneDoeAcme();
  checkUnsplashLinks();
  checkScrollListener();
  checkViewportMeta();
  checkBodyFontSize();
  checkSafeArea();
  checkVeeVeeDubTrap();

  printReport();

  const strict = process.argv.includes('--strict');
  const failCount = findings.filter(f => f.severity === 'fail').length;
  if (strict && failCount > 0) {
    process.exit(1);
  }
}

main();
