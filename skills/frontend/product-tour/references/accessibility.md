# Product Tour Accessibility

WCAG-compliant patterns for product tours and onboarding flows.

## Table of Contents
- [Focus Management](#focus-management)
- [Focus Trapping](#focus-trapping)
- [Screen Reader Support](#screen-reader-support)
- [Keyboard Navigation](#keyboard-navigation)
- [Reduced Motion](#reduced-motion)
- [Touch Targets](#touch-targets)
- [Complete Accessible Tour Popover](#complete-accessible-tour-popover)

---

## Focus Management

WCAG 2.4.3 — Focus Order.

When a tour step opens, move focus to the popover. When the tour ends, return focus to the trigger.

```tsx
// Store the element that triggered the tour
const triggerRef = useRef<HTMLElement | null>(null);

function startTour() {
  triggerRef.current = document.activeElement as HTMLElement;
  // ... start tour
}

function endTour() {
  // Return focus to the trigger element
  triggerRef.current?.focus();
  triggerRef.current = null;
}
```

For Driver.js, use the `onPopoverRender` hook:

```tsx
const driverObj = driver({
  steps,
  onPopoverRender: (popover) => {
    // Focus the first button in the popover
    const firstButton = popover.wrapper.querySelector("button");
    firstButton?.focus();
  },
  onDestroyed: () => {
    triggerRef.current?.focus();
  },
});
```

---

## Focus Trapping

WCAG 2.1.2 — No Keyboard Trap. Focus must cycle within the popover while it's open, but Escape always exits.

```tsx
import { useEffect, useRef } from "react";

export function useFocusTrap(active: boolean, onEscape: () => void) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!active || !containerRef.current) return;

    const container = containerRef.current;
    const focusableSelector =
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])';
    const focusableEls = container.querySelectorAll<HTMLElement>(focusableSelector);
    const firstEl = focusableEls[0];
    const lastEl = focusableEls[focusableEls.length - 1];

    // Focus first element
    firstEl?.focus();

    function handleKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") {
        onEscape();
        return;
      }

      if (e.key !== "Tab") return;

      if (e.shiftKey && document.activeElement === firstEl) {
        e.preventDefault();
        lastEl?.focus();
      } else if (!e.shiftKey && document.activeElement === lastEl) {
        e.preventDefault();
        firstEl?.focus();
      }
    }

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [active, onEscape]);

  return containerRef;
}
```

---

## Screen Reader Support

Use proper ARIA roles and live regions to announce step changes.

```tsx
interface TourPopoverProps {
  stepIndex: number;
  totalSteps: number;
  title: string;
  description: string;
  onNext: () => void;
  onPrev: () => void;
  onDismiss: () => void;
  hasPrev: boolean;
  hasNext: boolean;
}

function TourPopover({
  stepIndex, totalSteps, title, description,
  onNext, onPrev, onDismiss, hasPrev, hasNext,
}: TourPopoverProps) {
  const titleId = `tour-title-${stepIndex}`;
  const descId = `tour-desc-${stepIndex}`;

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
      aria-describedby={descId}
    >
      {/* Live region for screen reader announcements */}
      <div aria-live="polite" className="sr-only">
        Step {stepIndex + 1} of {totalSteps}: {title}
      </div>

      <h2 id={titleId}>{title}</h2>
      <p id={descId}>{description}</p>

      <div className="flex gap-2">
        {hasPrev && <button onClick={onPrev}>Previous</button>}
        {hasNext ? (
          <button onClick={onNext}>Next</button>
        ) : (
          <button onClick={onDismiss}>Finish</button>
        )}
        <button onClick={onDismiss} aria-label="Close tour">
          Skip
        </button>
      </div>
    </div>
  );
}
```

**Background content:** Set `aria-hidden="true"` on the main content while a modal overlay is active:

```tsx
useEffect(() => {
  const mainContent = document.getElementById("main-content");
  if (isTourActive && mainContent) {
    mainContent.setAttribute("aria-hidden", "true");
    return () => mainContent.removeAttribute("aria-hidden");
  }
}, [isTourActive]);
```

---

## Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab / Shift+Tab | Cycle through tour controls |
| Escape | Dismiss the tour entirely |
| Enter / Space | Activate focused button |
| Arrow Right (optional) | Next step |
| Arrow Left (optional) | Previous step |

```tsx
function handleTourKeyDown(e: KeyboardEvent) {
  switch (e.key) {
    case "Escape":
      dismissTour();
      break;
    case "ArrowRight":
      if (hasNextStep) nextStep();
      break;
    case "ArrowLeft":
      if (hasPrevStep) prevStep();
      break;
  }
}
```

Ensure all tour buttons have **visible focus indicators**:

```css
.tour-popover button:focus-visible {
  outline: 2px solid hsl(var(--primary));
  outline-offset: 2px;
}
```

---

## Reduced Motion

WCAG 2.3.3 — Respect `prefers-reduced-motion`.

```css
@media (prefers-reduced-motion: reduce) {
  .driver-overlay,
  .driver-popover,
  .tour-popover,
  .beacon-pulse {
    animation: none !important;
    transition: none !important;
  }
}
```

In Framer Motion components:

```tsx
import { useReducedMotion } from "motion/react";

function TourPopover({ children }: { children: React.ReactNode }) {
  const shouldReduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={shouldReduceMotion ? false : { opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={shouldReduceMotion ? { opacity: 0 } : { opacity: 0, y: 8 }}
      transition={shouldReduceMotion ? { duration: 0 } : { duration: 0.2 }}
    >
      {children}
    </motion.div>
  );
}
```

---

## Touch Targets

WCAG 2.5.8 — Minimum 44x44px touch targets.

```css
.tour-popover button {
  min-width: 44px;
  min-height: 44px;
  padding: 0.5rem 1rem;
}

/* Dismiss/close button — often too small by default */
.tour-popover .close-btn {
  min-width: 44px;
  min-height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}
```

---

## Complete Accessible Tour Popover

Full implementation combining all patterns above:

```tsx
"use client";
import { useEffect, useRef, useCallback } from "react";
import { motion, useReducedMotion } from "motion/react";
import { XIcon } from "lucide-react";

interface AccessibleTourPopoverProps {
  stepIndex: number;
  totalSteps: number;
  title: string;
  description: string;
  onNext: () => void;
  onPrev: () => void;
  onDismiss: () => void;
}

export function AccessibleTourPopover({
  stepIndex, totalSteps, title, description,
  onNext, onPrev, onDismiss,
}: AccessibleTourPopoverProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const shouldReduceMotion = useReducedMotion();
  const hasPrev = stepIndex > 0;
  const hasNext = stepIndex < totalSteps - 1;

  // Focus trap
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const focusable = container.querySelectorAll<HTMLElement>("button");
    focusable[0]?.focus();

    function onKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") { onDismiss(); return; }
      if (e.key === "ArrowRight" && hasNext) { onNext(); return; }
      if (e.key === "ArrowLeft" && hasPrev) { onPrev(); return; }

      if (e.key === "Tab") {
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault(); last?.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault(); first?.focus();
        }
      }
    }

    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, [stepIndex, hasNext, hasPrev, onNext, onPrev, onDismiss]);

  const titleId = `tour-title-${stepIndex}`;
  const descId = `tour-desc-${stepIndex}`;

  return (
    <motion.div
      ref={containerRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby={titleId}
      aria-describedby={descId}
      initial={shouldReduceMotion ? false : { opacity: 0, y: 8, scale: 0.96 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      exit={shouldReduceMotion ? { opacity: 0 } : { opacity: 0, y: 8, scale: 0.96 }}
      transition={shouldReduceMotion ? { duration: 0 } : { duration: 0.2, ease: [0.25, 0.46, 0.45, 0.94] }}
      className="w-72 rounded-xl border bg-background p-4 shadow-xl"
    >
      {/* Screen reader announcement */}
      <div aria-live="polite" className="sr-only">
        Step {stepIndex + 1} of {totalSteps}: {title}
      </div>

      {/* Header */}
      <div className="mb-2 flex items-start justify-between">
        <h2 id={titleId} className="text-sm font-semibold pr-6">
          {title}
        </h2>
        <button
          onClick={onDismiss}
          aria-label="Close tour"
          className="flex size-8 shrink-0 items-center justify-center rounded-md hover:bg-muted"
        >
          <XIcon className="size-4" />
        </button>
      </div>

      {/* Description */}
      <p id={descId} className="text-sm text-muted-foreground leading-relaxed">
        {description}
      </p>

      {/* Footer */}
      <div className="mt-4 flex items-center justify-between">
        <span className="text-xs text-muted-foreground">
          {stepIndex + 1} / {totalSteps}
        </span>
        <div className="flex gap-2">
          {hasPrev && (
            <button
              onClick={onPrev}
              className="min-h-[36px] rounded-lg px-3 text-sm text-muted-foreground hover:text-foreground focus-visible:outline-2 focus-visible:outline-primary focus-visible:outline-offset-2"
            >
              Back
            </button>
          )}
          <button
            onClick={hasNext ? onNext : onDismiss}
            className="min-h-[36px] rounded-lg bg-primary px-4 text-sm font-medium text-primary-foreground focus-visible:outline-2 focus-visible:outline-primary focus-visible:outline-offset-2"
          >
            {hasNext ? "Next" : "Done"}
          </button>
        </div>
      </div>
    </motion.div>
  );
}
```
