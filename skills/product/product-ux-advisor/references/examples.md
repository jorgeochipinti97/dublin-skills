# Real-World UX Pattern Examples

Reference these products when explaining patterns to the user — they're best-in-class implementations.

---

## Onboarding

### Linear — Wizard + Activation
- On first login: creates a sample workspace with real issues pre-populated
- Doesn't show an empty state — shows you what the product looks like WITH data
- Subtle "getting started" checklist in the sidebar (not intrusive, easy to dismiss)
- **Lesson**: show the product at its best immediately, don't make users imagine it

### Vercel — Import Wizard
- 3-step wizard: connect Git → select repo → configure → deploy
- Each step has exactly one decision to make
- Shows a live deploy preview before committing
- **Lesson**: reduce cognitive load per step, give immediate feedback

### Stripe — Onboarding Depth
- Progressive onboarding: you can accept payments immediately, deeper features unlocked as you grow
- Activation checklist is persistent in the dashboard until complete
- Each checklist item links directly to the action (not docs)
- **Lesson**: don't gate core value behind full setup — let users win early

### Notion — Role Personalization
- "How are you planning to use Notion?" with clear role options
- Immediately customizes the template gallery and default content
- **Lesson**: one question can make the whole product feel tailored

---

## Empty States

### GitHub — Empty Repository
- Empty repo shows exact git commands to push code
- Zero ambiguity — the empty state IS the instruction
- **Lesson**: empty state should be the fastest path to having content

### Linear — Empty Issues
- Shows a clean illustration + "Create your first issue" CTA
- Adds keyboard shortcut hint (C to create)
- **Lesson**: empty state should teach interaction patterns

### Figma — Empty Files
- Shows recent templates prominently
- "New design file" button is the visual hero
- **Lesson**: reduce friction to first creation by suggesting starting points

---

## Guidance

### Linear — Command Palette (⌘K)
- Available everywhere, searches issues, projects, commands, navigation
- Keyboard shortcut hint visible in the UI
- **Lesson**: power users will discover it; show hints to nudge casual users toward it

### Raycast — Onboarding as the product
- The first run IS the tutorial — you complete actions to learn the tool
- No separate tour — learning happens through doing
- **Lesson**: for power tools, embed learning in the workflow itself

### Intercom — Contextual Tooltips
- Tooltips appear on hover for complex features, not on page load
- Each tooltip has a "Got it" dismiss
- **Lesson**: contextual > proactive — show help when the user is near the feature

---

## Success States

### Vercel — Deployment Success
- Confetti animation + "Your project is live" with preview URL
- Immediate, visual, shareable
- **Lesson**: celebrate the moment the user crosses the finish line

### Stripe — First Payment
- Dashboard shows a congratulatory state after first live payment
- Surfaces next recommended action (set up payouts)
- **Lesson**: success state is a natural moment to guide toward the next step

---

## Freemium / Upgrade

### Linear — Feature Limits
- Pro features are visible but with a subtle lock icon
- Clicking shows a small modal: feature name, benefit, upgrade CTA
- Never blocks the whole UI
- **Lesson**: show the value first, then the gate

### Notion — Block Limit
- "You've reached the free plan limit" appears inline, in context
- Clicking shows a comparison of free vs paid
- **Lesson**: hit the limit at the exact moment of friction — not on the homepage

### GitHub — Actions Minutes
- Usage bar visible in settings showing minutes consumed
- Warning appears at 75% and 100%
- **Lesson**: make limits visible before they become blockers

---

## AI / Developer Product Specific

### Cursor — First Run
- Detects existing VS Code settings and asks to import
- "Getting started" guide is a chat with the AI itself
- **Lesson**: for AI tools, the onboarding medium should BE the product

### Replicate — API Quickstart
- Empty state shows a working curl command to copy-paste
- First success is 30 seconds away
- **Lesson**: for API products, time-to-first-response is the metric that matters

### Anthropic Console — Workbench
- New users land directly in a working prompt environment
- No setup required to start experimenting
- **Lesson**: remove every step between signup and the aha moment
