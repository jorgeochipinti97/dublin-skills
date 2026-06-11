---
name: foundation-first-frontend
description: Every frontend starts with dual theme, spacing system, mobile-first 360px, CLS < 0.05, icon budget — before polish
metadata:
  type: feedback
---

Every frontend starts from the foundation, not the polish: dual theme (dark +
light) from day 1 via semantic CSS variables, one spacing scale, mobile-first
designed at 360px, CLS target < 0.05, and an enforced icon budget. Run
`frontend-foundation` before `premium-frontend-design`.

**Why:** Retrofitting a second theme, a spacing scale, or mobile layout after
the fact is expensive and never as clean. Layout shift and icon soup read as
sloppy on otherwise premium products.

**How to apply:** At project start, establish tokens + theme + spacing +
component system + DESIGN.md before building screens. After implementation, run
`frontend-output-validator` to check contrast, CLS, icon budget, and touch
targets. See [[forbidden-ai-tells]].
