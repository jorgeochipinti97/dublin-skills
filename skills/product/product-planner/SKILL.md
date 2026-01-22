---
name: product-planner
description: Plan and define product requirements with user stories, acceptance criteria, and MVP scope. Use when starting a new product, feature, or project. Outputs PRD, user stories in Given/When/Then format, and prioritized backlog.
---

# Product Planner

Transform ideas into actionable product specifications.

## Workflow

### Step 1: Problem Definition
Before any solution, clarify:
- **Problem Statement**: What pain are we solving?
- **Target User**: Who experiences this pain?
- **Current Alternatives**: How do they solve it today?
- **Why Now**: Why is this the right time?

### Step 2: User Stories
Format: `As a [persona], I want [goal], so that [benefit]`

Each story needs:
- **Acceptance Criteria** (Given/When/Then)
- **Priority** (Must/Should/Could/Won't)
- **Estimate** (T-shirt: S/M/L/XL)

### Step 3: MVP Scope
Define the minimum viable product:
- What's the ONE thing that must work?
- What can wait for v2?
- What's the riskiest assumption to test?

### Step 4: Success Metrics
How will we know it worked?
- **North Star Metric**: The ONE number that matters
- **Input Metrics**: What drives the north star?
- **Guardrail Metrics**: What shouldn't get worse?

## Output Templates

### PRD Template
```markdown
# [Product Name]

## Problem
[2-3 sentences]

## Solution
[2-3 sentences]

## Target User
[Persona description]

## User Stories
1. As a... I want... So that...
   - Given... When... Then...

## MVP Scope
### In Scope
- [ ] Feature 1
- [ ] Feature 2

### Out of Scope (v2)
- Feature 3
- Feature 4

## Success Metrics
- North Star: [metric]
- Input: [metrics]

## Timeline
- Phase 1: [date] - [milestone]
```

## Anti-Patterns
- ❌ Solutions before problems
- ❌ Features without user stories
- ❌ User stories without acceptance criteria
- ❌ MVP with 20+ features (that's not minimal)
- ❌ Success metrics added after launch
