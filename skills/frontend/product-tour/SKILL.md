---
name: product-tour
description: "Build interactive product tours, guided walkthroughs, and onboarding flows in Next.js applications. Use when: (1) Creating step-by-step guided tours that highlight UI elements with tooltips/popovers, (2) Building onboarding experiences (welcome modals, activation checklists, progress tracking), (3) Guiding users through complex flows like file uploads, form wizards, or multi-page setup, (4) Adding contextual help or feature discovery to an existing app. Covers library selection (Driver.js, NextStep.js), tour state management, accessibility, and patterns from Linear/Notion/Figma/Vercel."
---

# Product Tour & Onboarding

Build guided product tours and onboarding flows for Next.js App Router.

## Library Selection

| Need | Library |
|------|---------|
| Single-page tour / feature highlight | **Driver.js** (5KB, zero deps, MIT) |
| Multi-page tour with route navigation | **NextStep.js** (App Router native) |
| Headless state machine (100% custom UI) | **OnboardJS** |

**Avoid**: React Joyride (React 19 broken), Shepherd.js (commercial), Intro.js (AGPL + dead wrapper).

## Architecture

```
components/onboarding/
  ProductTour.tsx           # Driver.js wrapper
  WelcomeModal.tsx          # First-run experience
  ActivationChecklist.tsx   # Getting started checklist
hooks/
  useProductTour.ts         # Tour trigger + lifecycle
  useOnboardingProgress.ts  # Progress persistence
lib/
  tour-steps.ts             # Step definitions (separate from components)
  onboarding-config.ts      # Feature flags, conditions
```

## Implementation Workflow

1. Define steps in a separate config file (not inline)
2. Add `data-tour` attributes to target elements (not CSS selectors)
3. Create tour wrapper as `"use client"` + dynamic import
4. Add progress persistence via `useOnboardingProgress`
5. Wire trigger conditions (first visit, feature flag, manual)
6. Test accessibility (keyboard, screen reader, reduced motion)

## Key Patterns

- **Step definitions**: Separate file, use `data-tour` selectors, typed as `DriveStep[]`
- **Driver.js in Next.js**: Dynamic import inside `useCallback` to avoid SSR issues
- **Action-gated steps**: Hide "Next", listen for user action, call `driverObj.moveNext()` programmatically, always provide "Skip"
- **Progress persistence**: Track completed steps in localStorage/DB, check before showing tour

## Anti-Patterns

- Never auto-advance steps — let users control pace
- Never block app without escape hatch (Escape key, Skip button)
- Never show 15-step tours on first visit — max 3-5 steps, use checklists for rest
- Never use CSS class selectors for targets — use `data-tour` attributes
- Never import Driver.js at build time — always dynamic import
- Never force tours — allow skip/dismiss, persist that choice
- Never re-show dismissed tours unless user requests it

## Reference Files

- `references/implementation-examples.md` — Complete code: useProductTour hook, wrapper component, step definitions, action-gated steps, CSS styling
- `references/onboarding-patterns.md` — Activation checklists, welcome modals, progress tracking, empty states, feature beacons
- `references/accessibility.md` — WCAG, focus traps, ARIA patterns, reduced motion, accessible popover

## Output Standards

- Be CONCISE — lead with working code, minimal explanations
- Complete, runnable TypeScript
- Always include `data-tour` attributes on target elements
- Include CSS for popover customization
