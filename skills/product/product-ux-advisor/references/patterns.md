# UX Patterns Catalog

## Criticality Rules

A pattern is **Critical** when:
- Without it, users can't discover or reach the core value
- Users will feel lost, confused, or give up before the "aha moment"
- It handles a state that every new user will encounter (empty state, first action)

A pattern is **Recommended** when:
- It significantly reduces friction or increases activation rate
- Power users will notice its absence
- It handles a common but not universal scenario

A pattern is **Polish** when:
- It improves delight or perceived quality
- Its absence doesn't block any task
- Users can work around it

---

## Onboarding Patterns

### Welcome / Product Tour
**Critical for**: B2B SaaS, tools with non-obvious UI, products with many features
**Skip when**: single-purpose tools with obvious UI (e.g. a calculator)
**What it is**: guided introduction shown on first login — can be a modal, an overlay, or a step-by-step coach
**Anti-pattern**: a 10-slide carousel nobody reads. Keep it to 3-4 steps max, action-oriented
**Real example**: Linear's "here's your first issue" guided creation

### Activation Checklist / Progress Bar
**Critical for**: products where value requires setup (connect integration, invite team, create first X)
**Skip when**: the product delivers immediate value without setup
**What it is**: visible checklist of key setup steps with completion state
**Why it works**: Zeigarnik effect — incomplete tasks create psychological pull to finish
**Real example**: Notion's "Get started" sidebar checklist, HubSpot's setup wizard

### Wizard / Multi-step Flow
**Critical for**: complex setup, onboarding with multiple inputs, checkout, any flow with >3 required fields
**Skip when**: a single form is sufficient
**What it is**: step-by-step guided flow with progress indicator, one task per step
**Key details**: show step X of Y, allow going back, save progress between steps
**Real example**: Vercel's project import wizard, Stripe Connect onboarding

### Role/Persona Selector
**Recommended for**: products serving multiple user types with different workflows
**What it is**: early question ("I'm a...") that customizes the subsequent experience
**Real example**: Notion's "How will you use Notion?" on signup

---

## Empty State Patterns

### First Empty State (Zero State)
**Critical for**: every product with a list, dashboard, or data view
**What it is**: what the user sees before they've created anything — should guide first action
**Anti-pattern**: a blank page or "No items found" with no call to action
**Components**: illustration (optional), headline ("No projects yet"), subtext (benefit), primary CTA ("Create your first project")
**Real example**: Linear's empty issues view, GitHub's empty repo

### Search Empty State
**Recommended for**: any product with search
**What it is**: helpful message when search returns nothing — suggest alternatives or corrections

### Error Empty State
**Recommended for**: data-fetching products
**What it is**: what to show when data fails to load — with retry action

---

## Guidance Patterns

### Tooltip / Feature Spotlight
**Recommended for**: products with non-obvious features or keyboard shortcuts
**What it is**: contextual tooltip attached to a specific UI element, shown once
**Anti-pattern**: too many tooltips shown at once (tooltip fatigue)
**When to show**: on first encounter with the feature, not every visit

### Inline Help / Contextual Hints
**Recommended for**: complex forms, settings with non-obvious impact
**What it is**: small helper text, info icons, or collapsible explanations inline in the UI
**Real example**: Stripe's inline descriptions on API key settings

### Command Palette / Quick Actions
**Recommended for**: power-user tools, products used daily
**Critical for**: developer tools, productivity apps
**What it is**: keyboard-triggered search over all actions (⌘K)
**Real example**: Linear, Vercel, Raycast

### Breadcrumbs / Wayfinding
**Recommended for**: products with deep navigation hierarchy (>2 levels)
**What it is**: path indicator showing where the user is

---

## Engagement & Retention Patterns

### Success State / Celebration
**Recommended for**: any product where completing a key action is meaningful
**What it is**: positive feedback after first key action — can be subtle (green checkmark) or expressive (confetti)
**When to use**: first project created, first payment received, first deploy — not every action
**Real example**: Vercel's deployment success, Stripe's first payment

### Upgrade / Paywall Pattern
**Critical for**: freemium products
**What it is**: contextual prompt to upgrade when user hits a limit or tries a pro feature
**Anti-pattern**: blocking the whole UI with a paywall modal before the user has seen value
**Pattern**: show the feature, grey it out slightly, explain benefit, offer upgrade CTA
**Real example**: Linear's workspace limit prompt, Notion's block limit

### Notification / Activity Feed
**Recommended for**: collaborative products, products with async events
**What it is**: in-app notification center showing relevant activity
**Critical for**: multi-user products (team collaboration, approvals, comments)

### Re-engagement / "Where you left off"
**Recommended for**: products with ongoing work or sessions
**What it is**: on return visit, surface what the user was last working on
**Real example**: Figma's recent files, Notion's recently visited pages

---

## Trust & Conversion Patterns

### Social Proof / Logos
**Recommended for**: landing pages, signup flows for B2B
**What it is**: customer logos, testimonials, user count
**When critical**: when the product is new or unknown

### Progress Indicator
**Critical for**: any multi-step flow (wizard, checkout, form)
**What it is**: shows user how far along they are and what's coming
**Anti-pattern**: hiding progress — users abandon flows when they don't know how long they'll take

### Confirmation / Review Step
**Recommended for**: destructive actions, purchases, irreversible operations
**What it is**: summary of what's about to happen before confirming

---

## Product Type → Critical Patterns Matrix

| Product Type | Critical Patterns |
|---|---|
| B2B SaaS (team tool) | Activation checklist, team invite flow, empty state, role selector |
| Developer tool / API | Empty state, quick start guide, code snippet copy, command palette |
| AI as a Service platform | Wizard (API key setup), usage dashboard, empty state, upgrade paywall |
| Marketplace | Trust signals, onboarding for both sides, empty state per role |
| Consumer app | Welcome tour, success states, re-engagement pattern |
| Freemium product | Upgrade pattern, feature teaser, usage limits visibility |
