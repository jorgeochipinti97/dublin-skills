# Onboarding Patterns

Complete component patterns for onboarding flows in Next.js.

## Table of Contents
- [Activation Checklist](#activation-checklist)
- [Welcome Modal](#welcome-modal)
- [Progress Tracking Hook](#progress-tracking-hook)
- [Empty State as Onboarding](#empty-state-as-onboarding)
- [Multi-Page Tour with NextStep.js](#multi-page-tour-with-nextstepjs)
- [Feature Discovery Beacon](#feature-discovery-beacon)

---

## Activation Checklist

Checklist pattern used by Notion, ClickUp, HubSpot. Leverages the Zeigarnik effect (incomplete tasks create psychological pull).

```tsx
"use client";
import { useState } from "react";
import { CheckIcon } from "lucide-react";
import { useOnboardingProgress } from "@/hooks/useOnboardingProgress";

interface ChecklistItem {
  id: string;
  label: string;
  description: string;
  action: () => void;
  estimatedTime?: string; // "2 min" — reduces psychological resistance
}

const ONBOARDING_STEPS: ChecklistItem[] = [
  {
    id: "create-project",
    label: "Create your first project",
    description: "Set up a workspace to organize your work.",
    action: () => {}, // Wire to router.push or modal open
    estimatedTime: "1 min",
  },
  {
    id: "upload-file",
    label: "Upload a file",
    description: "Drag and drop or browse to add your first file.",
    action: () => {},
    estimatedTime: "2 min",
  },
  {
    id: "invite-team",
    label: "Invite a team member",
    description: "Collaborate by inviting someone to your workspace.",
    action: () => {},
    estimatedTime: "1 min",
  },
  {
    id: "customize-settings",
    label: "Customize your settings",
    description: "Set your preferences and notification options.",
    action: () => {},
    estimatedTime: "2 min",
  },
];

export function ActivationChecklist() {
  const { completedSteps, completeStep, dismiss, dismissed, percentage } =
    useOnboardingProgress(ONBOARDING_STEPS.map((s) => s.id));

  if (dismissed) return null;

  const completed = completedSteps.length;
  const total = ONBOARDING_STEPS.length;

  return (
    <div
      role="region"
      aria-label="Getting started checklist"
      className="w-80 rounded-xl border bg-background p-4 shadow-lg"
    >
      {/* Header */}
      <div className="mb-3 flex items-center justify-between">
        <h3 className="text-sm font-semibold">Getting Started</h3>
        <button
          onClick={dismiss}
          className="text-muted-foreground hover:text-foreground text-xs"
          aria-label="Dismiss checklist"
        >
          Dismiss
        </button>
      </div>

      {/* Progress bar */}
      <div className="mb-4">
        <div className="mb-1 flex justify-between text-xs text-muted-foreground">
          <span>
            {completed} of {total} complete
          </span>
          <span>{percentage}%</span>
        </div>
        <div className="h-1.5 overflow-hidden rounded-full bg-muted">
          <div
            className="h-full rounded-full bg-primary transition-all duration-500 ease-out"
            style={{ width: `${percentage}%` }}
            role="progressbar"
            aria-valuenow={percentage}
            aria-valuemin={0}
            aria-valuemax={100}
          />
        </div>
      </div>

      {/* Steps */}
      <ul className="space-y-1" role="list">
        {ONBOARDING_STEPS.map((item) => {
          const isCompleted = completedSteps.includes(item.id);
          return (
            <li key={item.id}>
              <button
                onClick={() => {
                  item.action();
                  if (!isCompleted) completeStep(item.id);
                }}
                className="flex w-full items-start gap-3 rounded-lg p-2 text-left hover:bg-muted/50"
                aria-label={`${isCompleted ? "Completed" : "Todo"}: ${item.label}`}
              >
                <span
                  className={`mt-0.5 flex size-5 shrink-0 items-center justify-center rounded-full border-2 transition-colors ${
                    isCompleted
                      ? "border-primary bg-primary text-primary-foreground"
                      : "border-muted-foreground/40"
                  }`}
                >
                  {isCompleted && <CheckIcon className="size-3" />}
                </span>
                <div className="flex-1 min-w-0">
                  <span
                    className={`text-sm ${
                      isCompleted ? "text-muted-foreground line-through" : "font-medium"
                    }`}
                  >
                    {item.label}
                  </span>
                  {!isCompleted && item.estimatedTime && (
                    <span className="ml-1.5 text-xs text-muted-foreground">
                      · {item.estimatedTime}
                    </span>
                  )}
                </div>
              </button>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
```

**Key principles:**
- Auto-detect steps users completed organically (check DB state, not just tour state)
- Add time estimates to reduce resistance
- Persist in localStorage or backend, keyed by user ID
- Show micro-celebrations on completion (subtle checkmark animation)

---

## Welcome Modal

Multi-step welcome experience for first-time users. Used by Notion, Slack, Vercel.

```tsx
"use client";
import { useState, useCallback } from "react";
import { motion, AnimatePresence } from "motion/react";

interface WelcomeStep {
  title: string;
  description: string;
  illustration: React.ReactNode;
  action?: { label: string; onClick: () => void };
}

interface WelcomeModalProps {
  steps: WelcomeStep[];
  onComplete: () => void;
}

export function WelcomeModal({ steps, onComplete }: WelcomeModalProps) {
  const [current, setCurrent] = useState(0);
  const step = steps[current];
  const isLast = current === steps.length - 1;

  const handleNext = useCallback(() => {
    if (isLast) {
      onComplete();
    } else {
      setCurrent((c) => c + 1);
    }
  }, [isLast, onComplete]);

  const handleKeyDown = useCallback(
    (e: React.KeyboardEvent) => {
      if (e.key === "Escape") onComplete();
      if (e.key === "ArrowRight") handleNext();
      if (e.key === "ArrowLeft" && current > 0) setCurrent((c) => c - 1);
    },
    [current, handleNext, onComplete],
  );

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label="Welcome guide"
      onKeyDown={handleKeyDown}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
    >
      <div className="mx-4 w-full max-w-lg overflow-hidden rounded-2xl bg-background shadow-2xl">
        {/* Skip button */}
        <div className="flex justify-end p-4 pb-0">
          <button
            onClick={onComplete}
            className="text-xs text-muted-foreground hover:text-foreground"
          >
            Skip
          </button>
        </div>

        {/* Content */}
        <AnimatePresence mode="wait">
          <motion.div
            key={current}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            transition={{ duration: 0.2, ease: [0.25, 0.46, 0.45, 0.94] }}
          >
            <div className="px-8 pb-6">
              <div className="mb-6 flex aspect-video items-center justify-center rounded-lg bg-muted">
                {step.illustration}
              </div>
              <h2 className="text-xl font-semibold tracking-tight">{step.title}</h2>
              <p className="mt-2 text-sm text-muted-foreground leading-relaxed">
                {step.description}
              </p>
            </div>
          </motion.div>
        </AnimatePresence>

        {/* Footer */}
        <div className="flex items-center justify-between border-t px-8 py-4">
          {/* Step dots */}
          <div className="flex gap-1.5" role="tablist" aria-label="Welcome steps">
            {steps.map((_, i) => (
              <button
                key={i}
                onClick={() => setCurrent(i)}
                className={`size-2 rounded-full transition-all ${
                  i === current ? "w-6 bg-primary" : "bg-muted-foreground/30"
                }`}
                role="tab"
                aria-selected={i === current}
                aria-label={`Step ${i + 1} of ${steps.length}`}
              />
            ))}
          </div>

          <div className="flex gap-2">
            {current > 0 && (
              <button
                onClick={() => setCurrent((c) => c - 1)}
                className="px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground"
              >
                Back
              </button>
            )}
            <button
              onClick={handleNext}
              className="rounded-lg bg-primary px-4 py-1.5 text-sm font-medium text-primary-foreground"
            >
              {isLast ? "Get Started" : "Next"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
```

**Usage:**
```tsx
const welcomeSteps = [
  {
    title: "Welcome to Acme",
    description: "Your workspace for managing projects, tracking progress, and collaborating with your team.",
    illustration: <AcmeLogo className="size-16" />,
  },
  {
    title: "Upload Your Files",
    description: "Drag and drop files anywhere, or use the upload button. We support PDF, images, and documents up to 50MB.",
    illustration: <UploadIllustration />,
  },
  {
    title: "Invite Your Team",
    description: "Collaboration starts with your team. Share your workspace and start working together.",
    illustration: <TeamIllustration />,
  },
];

<WelcomeModal steps={welcomeSteps} onComplete={() => markWelcomeDone()} />
```

---

## Progress Tracking Hook

Reusable hook for persisting onboarding state across sessions.

```tsx
"use client";
import { useState, useCallback, useEffect } from "react";

interface OnboardingProgress {
  completedSteps: string[];
  dismissed: boolean;
  startedAt: string;
  lastStepAt: string | null;
}

const STORAGE_KEY = "onboarding-progress";

const DEFAULT_PROGRESS: OnboardingProgress = {
  completedSteps: [],
  dismissed: false,
  startedAt: new Date().toISOString(),
  lastStepAt: null,
};

export function useOnboardingProgress(totalStepIds?: string[]) {
  const [progress, setProgress] = useState<OnboardingProgress>(() => {
    if (typeof window === "undefined") return DEFAULT_PROGRESS;
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      return stored ? JSON.parse(stored) : DEFAULT_PROGRESS;
    } catch {
      return DEFAULT_PROGRESS;
    }
  });

  // Persist on change
  useEffect(() => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(progress));
  }, [progress]);

  const completeStep = useCallback((stepId: string) => {
    setProgress((prev) => {
      if (prev.completedSteps.includes(stepId)) return prev;
      return {
        ...prev,
        completedSteps: [...prev.completedSteps, stepId],
        lastStepAt: new Date().toISOString(),
      };
    });
  }, []);

  const dismiss = useCallback(() => {
    setProgress((prev) => ({ ...prev, dismissed: true }));
  }, []);

  const reset = useCallback(() => {
    setProgress({ ...DEFAULT_PROGRESS, startedAt: new Date().toISOString() });
  }, []);

  const total = totalStepIds?.length ?? 1;
  const percentage = Math.round((progress.completedSteps.length / total) * 100);
  const isComplete = totalStepIds
    ? totalStepIds.every((id) => progress.completedSteps.includes(id))
    : false;
  const nextStep = totalStepIds?.find((id) => !progress.completedSteps.includes(id)) ?? null;

  return {
    ...progress,
    completeStep,
    dismiss,
    reset,
    percentage,
    isComplete,
    nextStep,
  };
}
```

**For backend persistence**, replace `localStorage` with an API call:
```tsx
// Replace localStorage with API
const STORAGE_KEY = "onboarding-progress";

async function loadProgress(): Promise<OnboardingProgress> {
  const res = await fetch("/api/onboarding/progress");
  return res.json();
}

async function saveProgress(progress: OnboardingProgress) {
  await fetch("/api/onboarding/progress", {
    method: "PUT",
    body: JSON.stringify(progress),
  });
}
```

---

## Empty State as Onboarding

Empty states ARE the onboarding surface. Pattern from Linear, Notion, Vercel.

```tsx
interface EmptyStateProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  action: { label: string; onClick: () => void };
  secondaryAction?: { label: string; onClick: () => void };
}

export function EmptyState({ icon, title, description, action, secondaryAction }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="mb-4 flex size-12 items-center justify-center rounded-xl bg-muted text-muted-foreground">
        {icon}
      </div>
      <h3 className="text-base font-semibold tracking-tight">{title}</h3>
      <p className="mt-1 max-w-sm text-sm text-muted-foreground">{description}</p>
      <div className="mt-6 flex gap-3">
        <button
          onClick={action.onClick}
          className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground"
        >
          {action.label}
        </button>
        {secondaryAction && (
          <button
            onClick={secondaryAction.onClick}
            className="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
          >
            {secondaryAction.label}
          </button>
        )}
      </div>
    </div>
  );
}

// Usage
<EmptyState
  icon={<FolderIcon className="size-6" />}
  title="No projects yet"
  description="Create your first project to start organizing your work."
  action={{ label: "Create Project", onClick: () => setShowNewProject(true) }}
  secondaryAction={{ label: "Import from GitHub", onClick: () => setShowImport(true) }}
/>
```

---

## Multi-Page Tour with NextStep.js

When a tour needs to navigate between routes:

```tsx
// app/layout.tsx
import { NextStepProvider, NextStep } from "nextstepjs";
import { tourSteps } from "@/lib/tour-steps";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <body>
        <NextStepProvider>
          <NextStep steps={tourSteps}>{children}</NextStep>
        </NextStepProvider>
      </body>
    </html>
  );
}

// lib/tour-steps.ts
import type { Tour } from "nextstepjs";

export const tourSteps: Tour[] = [
  {
    tour: "setup-wizard",
    steps: [
      {
        title: "Welcome to Your Dashboard",
        content: "This is your home base. Let's set things up.",
        selector: '[data-tour="dashboard"]',
        side: "bottom",
      },
      {
        title: "Go to Settings",
        content: "Let's configure your workspace first.",
        selector: '[data-tour="settings-link"]',
        side: "right",
        nextRoute: "/settings", // Navigate before showing next step
      },
      {
        title: "Upload Your Logo",
        content: "Personalize your workspace by uploading a logo.",
        selector: '[data-tour="logo-upload"]',
        side: "bottom",
      },
      {
        title: "Invite Your Team",
        content: "Add team members to collaborate.",
        selector: '[data-tour="invite-section"]',
        side: "left",
        nextRoute: "/settings/team",
      },
    ],
  },
];

// Trigger from any component
"use client";
import { useNextStep } from "nextstepjs";

function StartTourButton() {
  const { startNextStep } = useNextStep();
  return <button onClick={() => startNextStep("setup-wizard")}>Start Tour</button>;
}
```

---

## Feature Discovery Beacon

Pulsing beacon to draw attention to new features (React Joyride-style, built manually):

```tsx
"use client";
import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";

interface BeaconProps {
  children: React.ReactNode;
  tooltip: { title: string; description: string };
  featureId: string;
  onDismiss: (featureId: string) => void;
}

export function FeatureBeacon({ children, tooltip, featureId, onDismiss }: BeaconProps) {
  const [showTooltip, setShowTooltip] = useState(false);

  return (
    <div className="relative inline-flex">
      {children}

      {/* Pulsing beacon */}
      <button
        onClick={() => setShowTooltip(true)}
        className="absolute -right-1 -top-1"
        aria-label={`New feature: ${tooltip.title}`}
      >
        <span className="relative flex size-3">
          <span className="absolute inline-flex size-full animate-ping rounded-full bg-primary/75" />
          <span className="relative inline-flex size-3 rounded-full bg-primary" />
        </span>
      </button>

      {/* Tooltip */}
      <AnimatePresence>
        {showTooltip && (
          <motion.div
            initial={{ opacity: 0, y: 4 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 4 }}
            className="absolute right-0 top-full z-50 mt-2 w-64 rounded-xl border bg-background p-4 shadow-lg"
            role="tooltip"
          >
            <h4 className="text-sm font-semibold">{tooltip.title}</h4>
            <p className="mt-1 text-xs text-muted-foreground">{tooltip.description}</p>
            <button
              onClick={() => {
                setShowTooltip(false);
                onDismiss(featureId);
              }}
              className="mt-3 text-xs font-medium text-primary"
            >
              Got it
            </button>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
```
