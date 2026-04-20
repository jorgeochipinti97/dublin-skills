---
name: blog-writer
description: Write blog posts in English and Spanish, markdown format. Serious, professional tone without hype or fluff. Use when the user wants to write a blog post, article, or long-form content. The skill asks questions first to understand topic, vocabulary level, key points, and target language before writing.
---

# Blog Writer

Write professional blog posts in English or Spanish. No hype, no fluff, no buzzwords.

## Process

### 1. Gather Information

Before writing, ask the user:

1. **Topic**: What is the post about?
2. **Language**: English, Spanish, or both?
3. **Key points**: What are the 2-4 main ideas to cover?
4. **Vocabulary level**: Technical jargon OK? Keep it simple? Industry-specific terms?
5. **Structure preference**: Problem-solution or narrative?
6. **Length**: Short (~500 words), medium (~1000), or long (~2000)?
7. **Call to action**: What should the reader do/think after reading? (optional)

Ask these in a single, clear message. Do not overwhelm with explanations.

### 2. Write the Post

Output format: Markdown with YAML frontmatter.

```markdown
---
title: "Post Title"
date: YYYY-MM-DD
lang: en|es
tags: [tag1, tag2]
---

Content here...
```

### 3. Writing Rules

**Tone:**
- Direct and clear
- Confident but not arrogant
- Show, don't tell
- Let the content speak for itself

**Filler Word Index — BANNED (instant AI / vendehumo tell):**

| Category | Forbidden |
|---|---|
| Hype verbs | Elevate, Unleash, Transform, Revolutionize, Empower, Accelerate, Unlock, Supercharge, Leverage, Turbocharge |
| Hype adjectives | Seamless, Cutting-edge, State-of-the-art, Best-in-class, Next-gen, Game-changing, Disruptive, Revolutionary, World-class, Industry-leading |
| Hype phrases | "In today's fast-paced world", "Let me tell you why this matters", "Imagine a world where", "The future of X is here", "Unlock the power of" |
| Multiplier hype | "10x your productivity", "100% more efficient", "Game-changing results" |
| Hollow transitions | "Moreover", "Furthermore", "In conclusion", "Without further ado" |
| Rhetorical hooks | "Have you ever wondered...?", "What if I told you...?", "Here's the thing..." |

**The Replacement Rule:**

Every forbidden word exists because it signals without saying. Replace with a **concrete verb + specific outcome**:

| ❌ | ✅ |
|---|---|
| "Elevate your workflow" | "Ship PRs 40% faster" |
| "Unleash the power of X" | "X reduces the query from 800ms to 40ms" |
| "Seamless integration" | "3-line install. Works with the 4 providers you already use." |
| "Revolutionary approach" | "We stopped doing X. The result was Y." |
| "Next-gen platform" | (just describe what it is) |

**Other bans:**

- No excessive exclamation marks (one per post max — usually zero)
- No rhetorical questions as hooks
- No promising "transformation" or "life-changing results"
- No vague claims without numbers/examples

**Do:**
- Start with the point, not a preamble
- Use concrete examples
- Include specific numbers/data when available
- Acknowledge tradeoffs and limitations
- End with substance, not hype

**Structure - Problem-Solution:**
1. State the problem clearly (1-2 paragraphs)
2. Explain why it matters or why existing solutions fail
3. Present your solution/approach
4. Show evidence or examples
5. Conclude with practical takeaway

**Structure - Narrative:**
1. Set the scene with context
2. Describe what happened or what you learned
3. Extract the insight or lesson
4. Connect to broader implications
5. Close with reflection or next steps

### 4. Language-Specific Notes

**English:**
- Prefer active voice
- Short sentences for impact
- One idea per paragraph

**Spanish:**
- Mantener registro formal pero accesible
- Evitar anglicismos innecesarios
- Usar "usted" implícito (no tutear ni ustear explícitamente)

### 5. After First Draft

Offer to:
- Adjust tone (more/less technical)
- Expand or condense sections
- Add code examples (if technical)
- Translate to the other language
