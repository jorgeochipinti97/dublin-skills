# Hook Engineering — Opening Strategies

The opening paragraph (the hook) determines whether readers continue or bounce. Average session time on most blog posts: under 30 seconds. The hook must earn the next 30 seconds.

One rule: **the first sentence must not be wasted.** No context-setting, no "in this post we'll explore", no defining the term you're about to discuss. Start with the thing itself.

---

## 1. The Hook's Only Job

Give the reader a reason to read the second sentence.

Not: introduce the topic.
Not: set context.
Not: summarize what's coming.

Give them one reason to read further — a question they want answered, a claim they want tested, a pain they recognized, a story they want resolved.

---

## 2. The Why-Continue-Reading Test

After writing the first paragraph, ask: *"Why would a reader in a hurry keep reading?"*

If the answer is: "to understand this topic better" → vague. Rewrite.
If the answer is: "to find out why doing X causes Y" or "to see the numbers" or "to steal that framework" → good.

---

## 3. Hook Types (with examples)

### 3.1 The Claim Hook

Open with your most important claim — the thing the post proves. Then prove it.

*"Most A/B testing wastes time. Not because the tests are wrong, but because the metric being tested doesn't predict revenue. Here's what we test instead."*

Best for: Opinion, Deep Dive, Case Study.
Rule: the claim must be specific enough to be disputed.

---

### 3.2 The Specific Number Hook

Open with a number that creates immediate context and credibility.

*"We ran 47 variations of our pricing page over 8 months. One change moved conversion 19%. It took 4 minutes to implement."*

Best for: Case Study, Opinion, Listicle.
Rule: the number must be real and specific (not round, not vague).

---

### 3.3 The Contrast Hook

Open with a juxtaposition of what's expected vs. what happened.

*"We hired two senior engineers to speed up our deploys. It didn't work. The bottleneck wasn't code — it was how we decided what to deploy and when."*

Best for: Opinion, Case Study.
Rule: the contrast must be genuine, not manufactured.

---

### 3.4 The Scene Hook

Open in the middle of a situation — not a preamble.

*"It's 2:30 PM on a Thursday when the database migration starts dropping rows. Not the migration you planned. The one from six months ago that you forgot to test the rollback for."*

Best for: How-To (particularly with high stakes), Case Study.
Rule: the scene must be recognizable to the target reader. If they don't see themselves in it, it's not a hook.

---

### 3.5 The Question Hook

Ask the one question the reader came to answer. Do not ask a question the answer to is obviously "yes."

Good: *"Why do onboarding flows with fewer steps have lower activation rates?"*
Bad: *"Do you want to grow your business?"*

Best for: Deep Dive, Opinion.
Rule: the question must be non-obvious and the post must answer it directly.

---

### 3.6 The Failure Hook

Open with something that went wrong — yours, someone else's, the conventional wisdom's.

*"The first version of our authentication system was reviewed by three engineers and a security consultant. It had a critical flaw none of them spotted."*

Best for: Case Study, How-To (cautionary), Opinion.
Rule: the failure must be real. Manufactured failure arcs undermine trust.

---

### 3.7 The Counterintuitive Statement Hook

Open by inverting what the reader expects.

*"The fastest way to grow an audience is to publish less."*

Then immediately follow with the proof or the mechanism — otherwise it's clickbait.

Best for: Opinion.
Rule: the post must actually defend the statement. If you can't, pick a different hook.

---

### 3.8 The Research Hook

Open with a finding that reframes the topic.

*"In 2024, NN/g published eye-tracking data on how users read long-form articles. 60% of readers never scroll past the first screen. Most of your post-introduction structure is invisible to most readers."*

Best for: Deep Dive, Opinion, How-To.
Rule: cite real sources. Invented or misattributed research kills credibility permanently.

---

### 3.9 The Direct Address Hook

Speak directly to the reader's situation.

*"If your React app has more than 4 useEffect calls in the same component, this post is about why that's a problem and what to do about it."*

Best for: How-To, Listicle.
Rule: be accurate about who the post is for. False specificity ("if you've ever struggled with productivity") is generic dressed up as specific.

---

### 3.10 The Stakes Hook

Open by naming what's at risk.

*"Every week you run your database without read replicas, you're one large reporting query away from a 30-second site outage."*

Best for: How-To (urgency-driven), Change-safety topics.
Rule: the stakes must be real and proportionate. Exaggerated stakes = FUD = reader distrust.

---

## 4. Hook Length

**Target: 1-3 sentences, under 100 words.**

The hook is not the introduction. The introduction is what follows the hook. The hook earns the right to have an introduction.

For deep-dives and long posts, a TL;DR summary block immediately after the hook serves the reader who wants to triage before committing. This is not the hook — it's a separate block.

---

## 5. Transitions From Hook to Body

After the hook, you need a bridge to the main content. Options:

**The "here's what I'll show you" bridge** (for how-tos, explainers):
*"In this post I'll walk through [specific thing]. By the end you'll have [specific outcome]."*
Keep it to 1-2 sentences. Don't list every section like a table of contents.

**The "here's the context" bridge** (for opinion, case studies):
1-2 sentences on the situation that makes the story or argument relevant.
Not: the full background. Just the minimum to make the rest make sense.

**The direct dive** (for experienced audiences):
No bridge. The hook ends, the first section begins. Works when the audience is expert and the hook signals enough context.

---

## 6. Anti-Patterns

- **The definition opener** — "Microservices are a software architecture pattern where..." → reader already knows; if they don't, that's not the right hook
- **The "in this post we'll..." opener** — tells the reader nothing; every post does something
- **The universal claim** — "Everyone struggles with X" → not true and the reader knows it
- **The philosophical wind-up** — 2 paragraphs of general context before the actual point
- **The rhetorical yes-question** — "Do you want to be more productive?" (Filler Word Index violation)
- **The apology** — "This is a complex topic, but..." → signals incompetence
- **The dictionary definition** — "According to Merriam-Webster, feedback is..." → never
- **The bait-and-switch** — hook promises X, post delivers Y; happens with counterintuitive hooks that can't deliver

---

## 7. Hook Checklist

- [ ] First sentence earns the second sentence?
- [ ] No preamble ("in this post...", "today I want to share...")?
- [ ] No rhetorical yes-question?
- [ ] Specific enough — not generic enough to apply to any topic?
- [ ] Under 100 words?
- [ ] The rest of the post delivers what the hook promises?
- [ ] Why-continue-reading test: is the answer specific?
