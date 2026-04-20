# Product Tour — Implementation Examples

## Step Definition Pattern

```typescript
// lib/tour-steps.ts
import type { DriveStep } from "driver.js";

export const dashboardTour: DriveStep[] = [
  {
    element: '[data-tour="sidebar"]',
    popover: {
      title: "Navigation",
      description: "Browse your projects and settings from here.",
      side: "right",
      align: "start",
    },
  },
  {
    element: '[data-tour="create-btn"]',
    popover: {
      title: "Create a Project",
      description: "Click here to start your first project.",
      side: "bottom",
    },
  },
  {
    // No element = centered modal step
    popover: {
      title: "You're all set!",
      description: "Explore on your own or revisit this tour from Settings.",
    },
  },
];
```

## useProductTour Hook

```tsx
"use client";
import { useCallback } from "react";

interface UseProductTourOptions {
  steps: import("driver.js").DriveStep[];
  onComplete?: () => void;
  onSkip?: () => void;
  showProgress?: boolean;
}

export function useProductTour({ steps, onComplete, onSkip, showProgress = true }: UseProductTourOptions) {
  const start = useCallback(async () => {
    const { driver } = await import("driver.js");
    await import("driver.js/dist/driver.css");

    const driverObj = driver({
      showProgress,
      steps,
      animate: true,
      overlayColor: "rgba(0, 0, 0, 0.5)",
      popoverClass: "product-tour-popover",
      onDestroyStarted: () => {
        if (!driverObj.hasNextStep()) {
          onComplete?.();
        } else {
          onSkip?.();
        }
        driverObj.destroy();
      },
    });

    driverObj.drive();
  }, [steps, onComplete, onSkip, showProgress]);

  return { start };
}
```

## ProductTour Wrapper Component

```tsx
// components/onboarding/ProductTour.tsx
"use client";
import { useEffect } from "react";
import { useProductTour } from "@/hooks/useProductTour";
import { useOnboardingProgress } from "@/hooks/useOnboardingProgress";
import { dashboardTour } from "@/lib/tour-steps";

export function ProductTour() {
  const { completeStep, completedSteps } = useOnboardingProgress();
  const hasSeenTour = completedSteps.includes("dashboard-tour");

  const { start } = useProductTour({
    steps: dashboardTour,
    onComplete: () => completeStep("dashboard-tour"),
    onSkip: () => completeStep("dashboard-tour"),
  });

  useEffect(() => {
    if (!hasSeenTour) {
      const timer = setTimeout(start, 500);
      return () => clearTimeout(timer);
    }
  }, [hasSeenTour, start]);

  return null;
}
```

## Action-Gated Steps

For tours involving file uploads, form fills, or navigation:

```typescript
// Wait for user action before advancing
{
  element: '[data-tour="file-upload"]',
  popover: {
    title: "Upload Your File",
    description: "Drag a file here or click to browse. The tour will continue after you upload.",
    side: "bottom",
    showButtons: ["close"],
  },
}

// In upload handler:
function handleUploadComplete() {
  driverObj.moveNext(); // Advance tour programmatically
}
```

**Pattern for action-gated steps:**
1. Show the step with next button disabled or hidden
2. Listen for the user action (upload complete, form submitted, etc.)
3. Call `driverObj.moveNext()` programmatically
4. Provide a "Skip" option so users are never stuck

## Styling Driver.js Popovers

```css
.product-tour-popover {
  --driver-overlay-color: rgba(0, 0, 0, 0.5);
  background: hsl(var(--background));
  color: hsl(var(--foreground));
  border: 1px solid hsl(var(--border));
  border-radius: 12px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  padding: 1.25rem;
}

.product-tour-popover .driver-popover-title {
  font-size: 0.9375rem;
  font-weight: 600;
  letter-spacing: -0.01em;
}

.product-tour-popover .driver-popover-description {
  font-size: 0.875rem;
  color: hsl(var(--muted-foreground));
  margin-top: 0.25rem;
}

.product-tour-popover .driver-popover-progress-text {
  font-size: 0.75rem;
  color: hsl(var(--muted-foreground));
}

.product-tour-popover button.driver-popover-next-btn {
  background: hsl(var(--primary));
  color: hsl(var(--primary-foreground));
  border-radius: 8px;
  padding: 0.375rem 0.75rem;
  font-size: 0.8125rem;
  font-weight: 500;
}

@media (prefers-reduced-motion: reduce) {
  .driver-overlay,
  .driver-popover {
    animation: none !important;
    transition: none !important;
  }
}
```
