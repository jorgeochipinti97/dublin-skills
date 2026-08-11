# Distribution & Repurposing

Writing the post is 50% of the work. Distribution is the other 50%. Most blog traffic comes from channels other than organic search — especially early in a site's life.

---

## 1. The Repurposing Principle

One post = multiple pieces of content. The blog post is the source of truth; everything else is a derivative.

Do NOT create distribution content from scratch. Derive it from the post. This ensures consistency and saves time.

```
Blog post
├── LinkedIn article / post
├── Twitter/X thread
├── Newsletter issue / teaser
├── Short-form social snippet (quote or stat)
└── Script for video/podcast (optional)
```

---

## 2. LinkedIn Post

LinkedIn rewards native long-form posts. Don't just paste a link.

### Format

```
[Hook — first line must stop the scroll]

[2-3 short paragraphs expanding the core claim]

[The takeaway — what they should do / think differently about]

[Optional: resource link in first comment or last line]

---

#tag1 #tag2 #tag3
```

### Hook formulas for LinkedIn
- Observation: *"Most developers treat logging as an afterthought."*
- Counterintuitive: *"The best onboarding flow I've seen has 3 steps. Most SaaS products have 12."*
- Specific result: *"We reduced time-to-first-value from 8 days to 4 hours. Here's what changed."*
- Question that engineers scroll past: *"Why does your CI pipeline take 18 minutes when it used to take 4?"*

### LinkedIn rules
- First 2 lines = visible before "see more" click — those lines must hook
- No link in the post body (LinkedIn suppresses external links in feed reach)
- Put the link in the first comment and reference it at the end: "Link in comments →"
- 3-5 hashtags max (not 15)
- Bullet lists: hit Enter twice between each bullet — LinkedIn formats them better
- Tag at most 2-3 people/companies if directly relevant

### Adaptation template
```markdown
## LinkedIn Adaptation

**Hook**: [First line — 1 sentence, stops the scroll]

**Body**:
[Core insight from the post, 3-4 short paragraphs, each 1-3 sentences]

**Takeaway**: [Actionable line or decision the reader can make]

**CTA**: "Full post in comments →" or "Link in first comment"

**Tags**: #[topic] #[industry] #[niche]
```

---

## 3. Twitter/X Thread

Threads outperform single tweets for educational/opinion content. Max engagement window: first 30 minutes after posting.

### Structure

```
Tweet 1 (hook): The claim, the result, or the question. 
Must stand alone — many won't click "see more". 1-2 sentences.

Tweet 2-N (body): Each tweet = one idea. Numbers help ("2/7", "3/7").
Short sentences. No walls of text.

Last tweet: The synthesis or takeaway + CTA.
"Full post: [link]" or "Which of these do you use? Reply ↓"
```

### Hook tweet formulas
- Start with a number: *"7 database mistakes I made in 3 years of production systems:"*
- Start with a claim: *"The best teams I've worked with share one habit. It's not standups."*
- Start with a result: *"We went from 4% to 31% trial activation in 6 weeks. The changes were embarrassingly simple."*

### Thread rules
- Tweet 1 must work as a standalone — many platforms show only tweet 1
- Each tweet: one idea, < 280 chars, no wasted words
- Vary length: some short punches, some slightly longer
- Don't summarize in the last tweet — add a genuine final insight
- Engagement in first 30 min matters — post when your audience is online
- Ask a question at the end to drive replies

### Adaptation template
```markdown
## Twitter/X Thread

**Tweet 1 (hook)**: [Claim / number / result — max 2 sentences]

**Tweets 2-[N]**:
2/ [First point — one idea, concise]
3/ [Second point]
...
N/ [Final insight + link to full post]

**Length**: [5-10 tweets recommended; match the depth of the post]
```

---

## 4. Newsletter Issue / Teaser

Two modes:

**Newsletter teaser** (if you have a newsletter): use the post as the main piece or the lead item.

**Stand-alone email** (if distributing to a list): the email summarizes the post's value and drives the click.

### Teaser structure

```
Subject: [Headline variant — email subject, not SEO title]

[1 paragraph: what this post is about and why it matters now]

[The core claim or the most interesting finding — 1-3 sentences]

[→ Read the full post: [link]]
```

### Subject line rules
- Different from the blog post title — optimize for open rate, not SEO
- Under 50 characters (mobile preview)
- Specific over generic: "How we cut churn 38%" > "This month's blog post"
- Test: preview text (the line after the subject) should continue the hook

### Newsletter email template
```markdown
## Newsletter Version

**Subject**: [Max 50 chars — specific, benefit-led]
**Preview text**: [45-90 chars — continues the subject line's hook]

**Body**:
[Hook paragraph — 2-3 sentences. Why this post now?]

[The core insight from the post — 1 paragraph]

[Call to action]
→ [Read time] read: [link]
```

---

## 5. Short-Form Social Snippet

Pull the most shareable line from the post. Use it as a standalone quote post or card.

### Sources within the post
- A counterintuitive claim ("Most developers do X. The ones who ship fast do Y.")
- A specific number ("47.2% of cold emails never get opened because of this")
- A reframing ("This isn't a hiring problem. It's a definition problem.")
- The core lesson in one sentence

### Format options
- **Pull quote**: plain text on LinkedIn/Twitter
- **Image card**: quote + author + blog name (use Canva template or custom design)
- **Story format**: mobile-first, single claim, big type

### When to use
- Best engagement happens 3-7 days after the post goes live
- Space social snippets out — one per platform per day max
- Quote cards work especially well on LinkedIn and Instagram

---

## 6. Syndication

Publishing the same post on other platforms increases reach. Rules:

### Where to syndicate
- **Medium** — good for non-technical general audiences
- **dev.to** — good for technical/developer content
- **Hashnode** — developer blog network
- **LinkedIn Articles** — long-form indexed by LinkedIn

### Rules for syndication
- **Wait 7-14 days** before syndicating (gives Google time to index the original as canonical)
- **Canonical tag**: all syndicated versions must include `<link rel="canonical" href="[original URL]">` — this tells Google the original is the source of truth
- Some platforms (Medium) add canonical automatically when you "import from URL"
- Add a note at the top: *"This post originally appeared on [your blog]."*
- Don't syndicate every post — pick the ones with broad appeal

---

## 7. Cross-Post vs. Syndicate

| | Cross-post | Syndicate |
|---|---|---|
| Same content? | Yes | Yes |
| Canonical tag? | No (original is on that platform) | Yes (points to your blog) |
| When to use | Writing natively for that platform (LinkedIn article) | Reposting from your blog |
| SEO impact | Depends on platform | Safe if canonical is set correctly |

---

## 8. Repurposing Downstream

For high-performing posts (top 10% by traffic or engagement):

| Derivative | When to create |
|---|---|
| Video / loom | When the post has a visual process or demonstration |
| Podcast segment | When the post is argument/opinion-driven |
| Email course | When the post is part of a series or could be a 5-day drip |
| Slide deck | When the post's structure works as a talk or webinar |
| Case study PDF | When the post proves a result a prospect would want to share |
| Updated / expanded post | When the post ranks but content is aging |

Repurposing threshold: only invest if the original performed well. Don't repurpose every post.

---

## 9. Distribution Calendar Template

After publishing a post:

| Time | Action |
|---|---|
| Day 0 (publish) | Share on LinkedIn (native post, link in comment), Twitter thread, newsletter teaser (if same day send) |
| Day 1-3 | Reply to early comments, monitor early analytics |
| Day 7 | Syndicate to relevant platform (if applicable) |
| Day 7-14 | Pull quote / image card for secondary social post |
| Day 30 | Check rankings; if appearing in top 20 on target keyword, optimize on-page |
| Day 90 | Review performance; flag for repurposing if high traffic |

---

## 10. Distribution Checklist

Per post:
- [ ] LinkedIn post drafted (native content, link in first comment)?
- [ ] Twitter thread drafted (hook + 5-10 tweets)?
- [ ] Newsletter teaser drafted?
- [ ] Pull quote identified (most shareable line)?
- [ ] Syndication planned (platform + 7-14 day delay)?
- [ ] Internal links from existing posts pointing to this new post?
- [ ] Social image (OG image) set for link previews?
