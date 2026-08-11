# Headline Engineering

The headline is 80% of the work. Ogilvy: 5× more people read the headline than the body. For search: it determines whether anyone clicks. For social: it determines whether it spreads. Get this wrong and nobody reads the rest.

---

## 1. The Two Jobs of a Headline

1. **Promise** — what the reader will get
2. **Filter** — signal whether this is for them

A headline that tries to be clever at the expense of clarity fails both jobs.

Test: cover the body, read only the headline. Does the reader know (a) what they'll get and (b) whether it's for them?

---

## 2. The 4 U's Test (Sugarman / Copyhackers)

Every headline should score 3/4 or better:

| U | Question |
|---|---|
| **Useful** | Does it promise a concrete benefit or outcome? |
| **Urgent** | Is there a reason to read now (not later)? |
| **Unique** | Is it different from what they've already seen on this topic? |
| **Ultra-specific** | Are there numbers, names, or timeframes that make it concrete? |

Score your headline. If < 3, rewrite. 4/4 is rare and usually over-engineered — don't force it.

---

## 3. Headline Formulas

Write 10 headline candidates, pick one. The first is rarely the best.

### Outcome + timeframe
*"[Result] in [time] — without [sacrifice]"*

Examples:
- "Ship faster in 2 weeks without touching your CI pipeline"
- "Learn SQL in 4 hours — no prior database experience needed"
- "Cut your hosting bill in half before your next billing cycle"

### Before/After identity
*"From [painful state] to [desired state]"*

Examples:
- "From 3-hour deploys to 12-minute deploys"
- "From 5% email open rate to 31% — what changed"
- "From solo freelancer to 6-person agency in 14 months"

### Number + subject
*"[N] [things] that [outcome/contrast]"*

Examples:
- "7 database indexes worth adding today"
- "11 cold email mistakes killing your reply rate"
- "3 ways to reduce React bundle size (without rewriting anything)"

### Question that hits the pain
Use only if the answer isn't obviously "yes":

Good: "Why does your SaaS churn spike in month 3?" (not obvious)
Bad: "Want to grow your business?" (obvious yes — no tension)

### Negative framing
*"Stop [wrong thing] / Why [common advice] is wrong"*

Examples:
- "Stop building features. Build retention loops."
- "Why 'hire slow, fire fast' is destroying your startup culture"
- "The rebase vs merge debate is the wrong question"

### New mechanism
*"The [novel approach/method] that [outcome]"*

Examples:
- "The reverse onboarding flow that doubled our trial activation"
- "The 4-sentence prospecting email that books 30% of cold calls"
- "The single-file architecture that cut our build time by 70%"

### Specific claim
*"[Specific number/result]: how [subject] achieved [outcome]"*

Examples:
- "47% fewer support tickets: how we rewrote our error messages"
- "$12,400 MRR at 3 months — the full breakdown"
- "17,000 users from one blog post: the strategy, not the luck"

### "How I…" (first person)
Works when you have a specific, credible result:

Examples:
- "How I wrote 52 blog posts last year without a content team"
- "How I reduced our API latency from 800ms to 40ms"
- "How I went from 0 to 2,400 newsletter subscribers in 90 days"

### Complete guide / definitive
Use only when you're actually writing the most comprehensive treatment:

Examples:
- "The complete guide to Postgres replication (for application developers)"
- "Hono.js in production: everything nobody told you"
- "PostgreSQL indexing from scratch: concepts, patterns, gotchas"

### Contrast / paradox
*"[Counterintuitive claim]"*

Examples:
- "Write less documentation. Ship better software."
- "Paying more for servers saved us $40,000 per year"
- "The blog post that failed: what I learned from 23 readers"

---

## 4. Power Words by Emotion

Use sparingly — 1-2 per headline max. Power words work because they're charged, not because they're common.

| Emotion | Words |
|---|---|
| **Curiosity** | secret, hidden, unknown, overlooked, rarely, counterintuitive, actually |
| **Urgency / speed** | now, today, instantly, immediately, before, fast, quick |
| **Specificity** | exactly, specific, precise, complete, definitive, ultimate |
| **Pain relief** | fix, solve, end, eliminate, avoid, stop, without |
| **Gain** | get, earn, increase, double, reduce, cut, save |
| **Credibility** | proven, tested, real, data, study, case, result |
| **Exclusivity** | only, never, first, new, rare, advanced |

**Banned** (Filler Word Index): revolutionary, game-changing, ultimate (as preamble), mind-blowing, insane, crazy, unbelievable, epic, crushing it, hack.

---

## 5. SEO Title vs. Editorial Headline

They serve different masters. Know which one you're writing.

| | SEO Title | Editorial Headline |
|---|---|---|
| **Appears in** | Browser tab, search results (`<title>`) | Article header (`<h1>`) |
| **Character limit** | 50-60 chars (Google truncates at ~580px) | No limit |
| **Priority** | Keyword placement (front-loaded) | Reader hook |
| **Tone** | Matches search intent | Can be more provocative |
| **Example** | "React Server Components: Complete Guide (2026)" | "RSC changed how I think about data fetching" |

**Best practice**: write them differently. The SEO title gets your keyword at the front; the H1 can be more human.

In frontmatter:
```yaml
title: "React Server Components: Complete Guide (2026)"  # SEO title → <title> tag
h1: "RSC changed how I think about data fetching"  # Editorial headline
```

---

## 6. Keyword Placement in SEO Titles

Primary keyword: as early in the title as possible without breaking natural grammar.

Good: "PostgreSQL Full-Text Search: Setup and Performance Tips"
Bad: "How to Set Up Full-Text Search in PostgreSQL the Right Way"

Front-loading works because:
- Google truncates; the important part survives
- Eye-tracking studies: first 2-3 words get most fixation
- Ranking signal is stronger at the front

---

## 7. Subheadline's Job (H1 → H2 or deck)

Subheadline picks ONE job:

| Job | Example |
|---|---|
| Clarify who it's for | "For founders who've already tried the usual advice" |
| Add specificity | "Using three open-source tools and no extra infra" |
| Remove an objection | "No redesign required. Works on your existing stack." |
| Create urgency | "Before you write the next sprint's spec" |
| Expand on the claim | "A step-by-step breakdown of what actually changed and why" |

**Never**: restate the headline in different words.

---

## 8. Write 10, Pick 1

The process:
1. Write 10 headlines. Don't filter. Time yourself — 8 minutes max.
2. Eliminate obvious weak ones (< 3 U's, too vague, too clever).
3. Rank the top 3.
4. For the top 3: check keyword fit (is the primary keyword in there?).
5. Pick the one that's most specific and passes the 4 U's test.

The first headline is almost never the best one. The 7th or 8th often is.

---

## 9. Common Mistakes

- **Clever over clear** — a pun that requires context ≠ a good headline. Clarity beats wit.
- **Too long** — if it doesn't fit in a tweet, cut it. 10-12 words max (SEO title: 8-10 words)
- **No keyword** — for any post meant to rank, the primary keyword belongs in the headline
- **All benefit, no specificity** — "Grow your newsletter" vs "Add 500 subscribers in 30 days"
- **All specificity, no benefit** — "37 Marketing Metrics" vs "The 37 metrics that predict churn before it happens"
- **Present-tense passive** — "Best practices for X" → "Why X best practices fail in production" (active, specific, tension)
- **The "ultimate guide" trap** — don't use unless the post is genuinely the most complete resource

---

## 10. Headline Checklist

Before finalizing:
- [ ] Passes 3/4 U's test?
- [ ] Primary keyword included (if SEO)?
- [ ] Specific enough — does it have a number, name, or timeframe?
- [ ] Clear who it's for?
- [ ] Under 12 words (editorial) / 60 chars (SEO title)?
- [ ] No filler words (Filler Word Index)?
- [ ] Does it stand alone? (no body = no context — does it still make sense?)
- [ ] Tested 10 variants before picking?
