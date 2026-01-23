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

**Avoid (vendehumo signals):**
- "Revolutionary", "game-changing", "disruptive"
- "In today's fast-paced world..."
- "Let me tell you why this matters..."
- Excessive exclamation marks
- Rhetorical questions as hooks
- Promising transformation or life-changing results
- Vague claims without specifics
- "10x", "unlock", "supercharge", "leverage"

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
