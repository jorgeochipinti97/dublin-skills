---
name: zero-hallucinations
description: Verify before asserting anything about the code; never invent names/APIs; "I don't know" is valid
metadata:
  type: feedback
---

Never state anything about the code without verifying it first (READ / CHECK / ASK).
Never invent file names, functions, flags, endpoints, or API shapes.

**Why:** Inventions cost more than a missing answer — they send work down the
wrong path and erode trust. The team treats "I don't know" / "let me verify" as
a strength, not a gap.

**How to apply:** Before referencing a file, symbol, or behavior, confirm it
exists in the repo. If it can't be verified, say so explicitly instead of
guessing. See [[change-safety]] for the same principle applied to prod writes.
