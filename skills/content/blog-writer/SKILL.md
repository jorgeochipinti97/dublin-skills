---
name: blog-writer
description: Write blog posts in English and Spanish. Supports 8 post types (how-to, listicle, opinion, case study, deep dive, comparison, interview, roundup). SEO-aware (keyword integration, on-page checklist, schema, meta). Filler Word Index enforced. Hook engineering. Distribution output (LinkedIn, Twitter thread, newsletter teaser). Use when the user wants to write a blog post, article, or long-form content. Blocks and asks for missing context before writing.
---

# Blog Writer

Full-stack blog engineering: post-type selection, headline formulas, hook engineering, SEO on-page, writing, and distribution derivatives. Produces Markdown output with YAML frontmatter.

## Hard Rules

1. **Never start without context.** Block and ask if required fields below are missing.
2. **Ask once.** All missing information in one consolidated message.
3. **Filler Word Index enforced.** No hype words. See §4 and `references/seo-writing.md`.
4. **8 post types.** Identify the type first — it determines the template.
5. **Distribution is part of the output.** Always offer LinkedIn + Twitter thread + newsletter teaser after writing.

---

## Required Context

Before producing anything:

1. **Topic** — what is the post about (one sentence)
2. **Post type** — how-to / listicle / opinion / case study / deep dive / comparison / interview / roundup. (If unsure, load `references/post-types.md` → quick selection guide)
3. **Audience** — who is this for? Role, knowledge level, context.
4. **Language** — English, Spanish, or both?
5. **SEO goal** — yes or no. If yes: primary keyword + monthly volume (if known)
6. **Key points** — 2-5 main ideas, arguments, or steps to cover
7. **Evidence available** — data, case studies, research, personal experience, or "none"
8. **Tone** — technical / conversational / direct / formal / opinionated
9. **Length** — short (~800), medium (~1500), long (~3000), or "match the topic"
10. **Distribution** — which channels: LinkedIn / Twitter thread / newsletter / none

Optional: CTA (what should the reader do), existing posts for internal linking, brand guidelines.

**If the user says "inventá lo que falte":** proceed with flagged assumptions using `⚠️`.

---

## Workflow

1. **Identify post type** → load the template from `references/post-types.md`
2. **Engineer the headline** → load `references/headline-engineering.md` → write 3-5 candidates → pick one. If SEO: write a separate `<title>` vs editorial `<h1>`.
3. **Write the hook** → load `references/hook-engineering.md` → pick the right hook type → draft, test against "why-continue-reading" rule
4. **If SEO goal**: load `references/seo-writing.md` → map primary keyword to title / H1 / first 100 words / H2s / meta description / URL slug / schema
5. **Write the body** using the post-type template
6. **After body**: offer distribution derivatives → load `references/distribution.md` → produce LinkedIn, Twitter thread, newsletter teaser

---

## Output Format

```markdown
---
title: "[SEO title — for <title> tag, 50-60 chars]"
h1: "[Editorial headline — for the post header]"
date: YYYY-MM-DD
lang: en|es
tags: [tag1, tag2, tag3]
type: how-to|listicle|opinion|case-study|deep-dive|comparison|interview|roundup
seo:
  keyword: "[primary keyword]"
  description: "[meta description — 145-165 chars]"
  slug: "[url-slug]"
---

[hook — 1-3 sentences, no preamble]

[body following the post-type template]
```

---

## Post Types Quick Reference

Load `references/post-types.md` for full templates. Quick selection:

| Goal | Type |
|---|---|
| Teach a process | how-to |
| Pack multiple points | listicle |
| Argue a position | opinion |
| Prove with a result | case-study |
| Explain a complex topic | deep-dive |
| Help someone choose | comparison |
| Feature an expert | interview |
| Save research time | roundup |

---

## Headline Engineering

Load `references/headline-engineering.md`. Process:

1. Write 5 headline candidates — different formulas
2. Score each on the 4 U's (Useful / Urgent / Unique / Ultra-specific)
3. Pick the one scoring 3/4 or better that includes the primary keyword (if SEO)
4. Write the SEO `<title>` (50-60 chars, keyword front-loaded) separately from the editorial `<h1>`

Preferred formulas (see full list in reference):
- Outcome + timeframe: *"[Result] in [time] without [sacrifice]"*
- Before/After: *"From [pain] to [outcome]"*
- Number + benefit: *"7 [things] that [outcome]"*
- New mechanism: *"The [approach] that [specific result]"*
- Specific claim: *"[Number/result]: how [subject] achieved [outcome]"*

---

## Hook Engineering

Load `references/hook-engineering.md`. Rules:

- First sentence earns the second — never waste it
- No: "In this post we'll explore...", "Have you ever wondered...", definitions
- Yes: claim, number, scene, contrast, failure, specific research
- Under 100 words
- Why-continue-reading test: answer must be specific, not "to learn about the topic"

---

## Writing Rules

### Tone
- Direct, clear, confident — not arrogant
- Show don't tell — let content speak
- Vary sentence length. Short. Short. Longer sentence for rhythm. Short.
- "You" : "I/we" ratio ≥ 3:1

### Filler Word Index — BANNED

| Category | Forbidden |
|---|---|
| Hype verbs | Elevate, Unleash, Transform, Revolutionize, Empower, Accelerate, Unlock, Supercharge, Leverage, Turbocharge |
| Hype adjectives | Seamless, Cutting-edge, State-of-the-art, Best-in-class, Next-gen, Game-changing, Disruptive, World-class, Industry-leading |
| Hype phrases | "In today's fast-paced world", "Imagine a world where", "The future of X is here", "Unlock the power of" |
| Multiplier hype | "10x your productivity", "100% more efficient" |
| Hollow transitions | "Moreover", "Furthermore", "In conclusion", "Without further ado" |
| Rhetorical hooks | "Have you ever wondered...?", "What if I told you...?", "Here's the thing..." |

**The replacement rule**: every forbidden word signals without saying. Replace with **concrete verb + specific outcome**.

| ❌ | ✅ |
|---|---|
| "Elevate your workflow" | "Ship PRs 40% faster" |
| "Seamless integration" | "3-line install. Works with the 4 providers you already use." |
| "Revolutionary approach" | "We stopped doing X. The result was Y." |

### Data Realism (THE 99.99% PROBLEM)

- No predictable demo numbers (`99.99%`, `50%`, `1234567`)
- Use organic messy data: `47.2%`, `$12,847 MRR`, `+31% in 6 weeks`
- Invented examples: use realistic names, NOT "John Doe" (Jane Doe Effect), NOT "Acme Corp" (Acme Slop)
- Mark invented data with `⚠️ [placeholder]`

### Other rules
- One idea per paragraph
- No exclamation marks (zero per post is the target; one is the max)
- No promises of "transformation" or "life-changing results"
- End with substance — not a hype summary

---

## Language-Specific Notes

**English:**
- Active voice
- Short sentences for impact
- One idea per paragraph

**Spanish:**
- Registro formal pero accesible
- Evitar anglicismos innecesarios
- Usar "usted" implícito (ni tutear ni ustear explícitamente)
- Adaptar los ejemplos al contexto hispanohablante cuando sea relevante

---

## Distribution Output

After the post is written, always offer:

1. **LinkedIn post** — native content (no link in post body), hook first line, 3-5 hashtags
2. **Twitter/X thread** — hook tweet + 5-8 body tweets + CTA tweet with link
3. **Newsletter teaser** — subject line + preview text + 2-3 paragraph teaser + CTA link

Load `references/distribution.md` for templates.

---

## SEO Checklist (apply when SEO goal = yes)

- [ ] Primary keyword in `<title>`, front-loaded
- [ ] Primary keyword in H1
- [ ] Primary keyword in first 100 words
- [ ] Meta description 145-165 chars with keyword
- [ ] URL slug: short, keyword, hyphens
- [ ] 2-3 H2s include primary or secondary keywords
- [ ] BlogPosting schema in output
- [ ] `datePublished` set
- [ ] 3-5 internal link suggestions noted

---

## After First Draft

Offer to:
- Adjust tone (more/less technical)
- Expand or condense sections
- Add code examples
- Write distribution derivatives (LinkedIn, thread, newsletter)
- Translate to the other language
- Optimize for SEO (if not already)

---

## Reference Loading

- `references/post-types.md` — 8 post type templates with structure, rules, anti-patterns (load when identifying post type)
- `references/headline-engineering.md` — 10+ headline formulas, 4 U's test, power words, SEO title vs H1, write-10-pick-1 process (load when writing headlines)
- `references/hook-engineering.md` — 10 hook types, why-continue-reading test, anti-patterns (load when writing the opening)
- `references/seo-writing.md` — keyword strategy, placement, title/meta/slug/schema, E-E-A-T, internal linking, Core Web Vitals (load when SEO goal = yes)
- `references/distribution.md` — LinkedIn, Twitter thread, newsletter templates, syndication rules, repurposing framework (load when producing distribution output)
