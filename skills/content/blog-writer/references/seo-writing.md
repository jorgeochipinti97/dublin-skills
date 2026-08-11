# SEO Writing

On-page SEO for blog posts. The goal: rank for the primary keyword, satisfy search intent, and build topical authority. Not all posts need this (opinion/thought leadership often doesn't). Apply when the post has an explicit ranking objective.

---

## 1. Search Intent — First Principle

Before keywords, understand intent. Google classifies every query by intent. Your post must match.

| Intent | What the searcher wants | Post types that match |
|---|---|---|
| **Informational** | Understand a topic | Deep Dive, Explainer, Opinion, How-To |
| **Navigational** | Reach a specific page | (not a blog post) |
| **Commercial investigation** | Research before buying | Comparison, Roundup, Case Study |
| **Transactional** | Buy / sign up | Landing page (not blog) |

**Test**: Google your target keyword. Look at the first 3-5 results. What format are they? If they're all comparison pages, a How-To won't rank on intent mismatch.

---

## 2. Keyword Strategy

### 2.1 Primary keyword
- One target keyword per post
- Check monthly search volume: tools like Ahrefs, SEMrush, or free alternatives (Google Search Console, Ubersuggest)
- Difficulty consideration: new domains → < 30 KD; established → up to 60+
- The keyword should match the core topic, not a forced stretch

### 2.2 Secondary keywords
- 2-5 related terms that support the primary
- Often appear naturally when you write thoroughly
- Sources: Google autocomplete, "People Also Ask", "Related searches" at the bottom of results

### 2.3 Semantic keywords (LSI)
- Concepts that should appear in a complete treatment of the topic
- Don't stuff — write naturally; a well-written post includes them organically
- Tool: InLinks, Clearscope, or just scan what the top-ranking articles cover

### 2.4 Keyword placement

| Location | How |
|---|---|
| `<title>` tag | Primary keyword, front-loaded, 50-60 chars |
| `<h1>` | Primary keyword (can be slightly different from title) |
| First 100 words | Primary keyword, naturally placed |
| 2-3 `<h2>` headings | Include primary or secondary keywords |
| Meta description | Primary keyword, naturally written |
| Image alt attributes | Describe the image; include keyword if relevant |
| Body | Primary: 1-2% density (not a hard rule — write naturally); secondary: once each |
| URL slug | Primary keyword, hyphens, no stopwords, concise |

**Never**: keyword stuffing. Google penalizes it; readers hate it. Write for humans.

---

## 3. Title Tag

The title tag (`<title>`) is the single most important on-page SEO element.

### Formula
```
[Primary keyword]: [clarifying phrase or benefit] | [Brand name]
```

Examples:
- `React Server Components: Setup Guide for Next.js 14 | Acme Blog`
- `Postgres Full-Text Search: Performance Tips for Large Tables`
- `Cold Email Best Practices: 47 Tests, One Framework`

### Rules
- 50-60 characters (Google truncates at ~580px width)
- Primary keyword in first 3-5 words
- Include the year if the content is time-sensitive ("(2026)" or "in 2026")
- No clickbait — must accurately represent the content
- Brand name at end (optional for smaller sites; include for brand recognition)

---

## 4. Meta Description

Not a direct ranking factor, but controls click-through rate from search results.

### Formula
```
[Primary keyword in first sentence]. [What you'll get / benefit]. [Optional: CTA or differentiator]. ~155 characters.
```

Examples:
- *"PostgreSQL full-text search lets you query millions of rows in milliseconds. Learn the indexes, rank functions, and performance settings that matter — with real benchmarks."*
- *"7 cold email frameworks tested across 2,400 sequences. The structure, timing, and subject lines that drive 35%+ reply rates without sounding like a template."*

### Rules
- 145-165 characters (Google truncates; preview in SERP simulators)
- Include primary keyword naturally
- Active voice, specific benefit
- No quotes (they get cut in SERPs sometimes)
- Don't duplicate the title

---

## 5. URL Slug

```
/blog/primary-keyword-descriptive
```

Rules:
- Hyphens, not underscores
- Lowercase
- No file extensions, no query strings
- Remove stopwords if they add no meaning: `how-to` is fine, `the-ultimate-guide-to` is not
- Keep it under 60 characters
- Never change once published without a 301 redirect

Good: `/blog/postgres-full-text-search`
Bad: `/blog/2026/01/15/the-complete-and-ultimate-guide-to-postgresql-full-text-search-in-2026`

---

## 6. Header Hierarchy

Headings communicate structure to search engines and readers.

```
H1 (once): The article headline — primary keyword
  H2: Major sections
    H3: Subsections within an H2
      H4: (use sparingly — rarely needed in blog posts)
```

Rules:
- One H1 per page, always
- H2s should scan as a standalone outline of the post
- Include primary or secondary keywords in 2-3 H2s naturally
- Don't skip levels (H1 → H3 without an H2)
- Question H2s work well for "People Also Ask" inclusion

---

## 7. Content Depth Signals

Google's Helpful Content system assesses whether content demonstrates real expertise.

### E-E-A-T signals (Experience, Expertise, Authoritativeness, Trustworthiness)

| Signal | How to express it |
|---|---|
| **Experience** | First-person account, specific numbers, what failed before the solution |
| **Expertise** | Accurate technical depth, correct terminology, acknowledgment of edge cases |
| **Authoritativeness** | Author bio with credentials, cites authoritative sources, is cited by others |
| **Trustworthiness** | Transparent about limitations, real sources cited, no fabricated data |

Practical implications:
- Write with a named author, not "the team"
- Include a short author bio with relevant credentials
- Cite real sources with links to the original
- Acknowledge what you don't cover and why
- Date the post and update it when content goes stale

---

## 8. Internal Linking

Internal links pass authority and help readers navigate. They're often neglected.

### Rules
- Link to 3-5 related posts per article
- Link with descriptive anchor text (not "click here" or "this post")
- Link from high-traffic posts to newer posts that need authority
- Keep links contextually relevant — don't force them

### Strategy
- **Hub and spoke**: a pillar page (long, comprehensive) links to cluster posts (deep on subtopics); cluster posts link back to the pillar
- **Sequential series**: post 1 links to post 2 links to post 3
- **Update older posts**: add links to newer posts from older ones that rank well

---

## 9. Image SEO

- **Alt text**: describe the image accurately; include keyword if it's genuinely relevant (`alt="PostgreSQL EXPLAIN output showing sequential scan"`)
- **File names**: descriptive, hyphenated (`postgres-explain-output.webp`, not `IMG_0047.jpg`)
- **Format**: WebP or AVIF for photos; SVG for diagrams
- **Size**: compress before upload; target < 100KB for most images
- **Lazy loading**: `loading="lazy"` for images below the fold
- **Width/height attributes**: set explicitly to prevent CLS

---

## 10. Schema Markup — Article

Add structured data for better SERP features (rich snippets, "Read more" carousels).

Minimum `BlogPosting` schema:

```json
{
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "headline": "Title of the post",
  "description": "Meta description text",
  "author": {
    "@type": "Person",
    "name": "Author Name",
    "url": "https://example.com/authors/name"
  },
  "datePublished": "2026-01-15",
  "dateModified": "2026-06-01",
  "image": "https://example.com/og-image.webp",
  "publisher": {
    "@type": "Organization",
    "name": "Blog Name",
    "logo": {"@type": "ImageObject", "url": "https://example.com/logo.png"}
  }
}
```

For how-tos, add `HowTo` schema. For FAQs, add `FAQPage`. These unlock rich results.

---

## 11. Post Freshness

Content freshness matters for:
- Time-sensitive topics (software versions, market data, regulations)
- Evergreen posts that accumulate authority and need maintenance

### Signals Google reads
- `dateModified` in schema
- Explicit "Updated: [date]" in post
- Changed content (not just date)

### Update triggers
- Primary keyword SERP shifts (you drop)
- New data available (old stats are cited)
- The topic itself changed (new version, new law, new standard)
- Bouncing due to outdated recommendations

Never update the date without actually updating the content — Google notices.

---

## 12. Core Web Vitals in Blog Context

SEO is a ranking factor, but page experience factors matter too.

| Metric | Target | Blog-specific culprit |
|---|---|---|
| LCP < 2.5s | Hero image too large; unoptimized web fonts |
| INP < 200ms | Comment widgets, analytics bloat, share buttons |
| CLS < 0.1 | Images without dimensions, late-loading fonts, injected ads |

In the blueprint, flag:
- Images: require WebP + explicit dimensions
- Fonts: preload + `font-display: swap` + size-adjust fallback
- Third-party scripts: defer or async; lazy-load social share

---

## 13. Content Length Guidelines

Content length should match the topic's depth, not a target word count.

| Post type | Typical length | Why |
|---|---|---|
| Opinion | 600-1200 words | Argument, not comprehensiveness |
| Listicle | 800-2000 words | Depth per item matters |
| How-To | 1000-3000 words | Steps need room |
| Case Study | 1000-3000 words | Story + proof + lesson |
| Comparison | 1000-2500 words | Criteria need depth |
| Deep Dive | 2000-5000 words | Covering a topic thoroughly |
| Roundup | 800-2000 words | Annotated, not exhaustive |

Longer ≠ better. A 4000-word post padded to rank beats a 1500-word post that's genuinely complete only if the padding is real substance. Avoid:
- Adding a "related topics" section to hit a word count
- Summarizing every section at the end
- Long intros that delay the content

---

## 14. SEO Checklist (per post)

- [ ] Primary keyword identified, intent mapped
- [ ] Keyword appears in title tag (front-loaded)?
- [ ] H1 includes primary keyword?
- [ ] Primary keyword in first 100 words?
- [ ] Meta description: 145-165 chars, keyword included?
- [ ] URL slug: short, keyword, hyphens only?
- [ ] 2-3 H2s include primary or secondary keywords?
- [ ] Images: alt text, WebP, explicit dimensions?
- [ ] Internal links: 3-5 contextual links?
- [ ] Author bio with credentials?
- [ ] Schema markup: BlogPosting (minimum)?
- [ ] `datePublished` + `dateModified` set?
- [ ] Content freshness plan for time-sensitive claims?
