# Information Architecture for Institutional Sites

Reference for designing sitemaps, nav structures, and routing multiple audiences through a corporate site. Sources: Peter Morville + Louis Rosenfeld (*Information Architecture for the Web and Beyond*), Nielsen Norman Group, Donald Norman (*The Design of Everyday Things*), Jared Spool research, real-world IA from Linear, Stripe, Apple, IBM, Notion.

---

## 1. The Core Principle

**IA is about helping each audience find what they came for — fast.**

A well-architected site feels obvious. The visitor never wonders "where do I click?" because the labels, hierarchy, and flow match their mental model.

If you have to explain your IA, it's wrong.

---

## 2. Start with Audiences, Not Org Chart

The #1 mistake: structuring the site like the company org chart.

**Org chart IA** (bad):
```
Home → Products → Services → Engineering → Design → Marketing → HR → Legal
```

**Audience-first IA** (good):
```
Home → [what they do] → [proof] → [why them] → [how to engage]
```

Each audience has a **job-to-be-done** when they land on the site. Map that job to a path. Don't make investors click through "Products" to get to "Investor Relations."

---

## 3. Primary Audiences for Institutional Sites

Typical audiences (pick the ones that apply):

- **Prospective customers** — want to understand what you do and why they should care
- **Existing customers** — want support, docs, login
- **Investors** — want financials, vision, governance, leadership
- **Press / media** — want facts, brand assets, contact, quotes
- **Talent / candidates** — want culture, roles, benefits
- **Partners** — want programs, integration info, legal terms
- **Regulators / compliance** — want disclosures, policies, transparency
- **Community / public** — general awareness, brand

Each audience gets a **clear path** from their most likely entry point to their goal. Often it's the home page; sometimes they land directly (investor Googles "[Company] annual report" and lands on `/investors`).

---

## 4. Sitemap Patterns

### 4.1 Flat hierarchy (preferred)

```
Home
├── About
├── Work
├── Insights
├── Careers
├── Press
└── Contact
```

- Depth: 1 level
- Clicks from home to any page: 1
- Works for: small/medium orgs, agencies, boutique firms

**Rule**: if you can make it flat, make it flat. Every level of depth loses ~50% of visitors.

### 4.2 Hub and spoke

```
Home
├── Products
│   ├── Product A
│   ├── Product B
│   └── Product C
├── Solutions (by industry / role)
├── Customers
├── Resources
│   ├── Blog
│   ├── Docs
│   └── Guides
└── Company
    ├── About
    ├── Careers
    ├── Press
    └── Contact
```

- Depth: 2 levels
- Home → category → item
- Works for: B2B SaaS with multiple products, mid-to-large orgs

### 4.3 Audience-routed hub

```
Home (routes audiences)
├── For Founders → [dedicated path]
├── For Enterprises → [dedicated path]
├── For Developers → [dedicated path]
└── Company
```

- Works for: products with very different audiences (Stripe does this well)
- Risk: confuses visitors who don't self-identify

### 4.4 Deep hierarchy (usually bad)

```
Home → Solutions → Industries → Healthcare → Providers → Enterprise → Features → Compliance → HIPAA
```

Depth > 3 levels almost always signals bad IA. Flatten.

---

## 5. The Home Page's Job in IA

The home page is **not a destination** — it's a **router**. Its job is to:

1. Tell the visitor what this organization is (in 5 seconds)
2. Route each audience to their next step
3. Provide proof that what they're about to invest time in is worth it

It should NOT try to tell the full story. That's what the rest of the site is for.

### 5.1 Home page structure (standard)

1. **Hero** — what you do, who you're for, visual
2. **Social proof bar** — client logos or "trusted by" count
3. **Value / services overview** — 3-5 blocks linking to deeper pages
4. **Featured work / case / proof** — tangible
5. **Thought leadership or differentiator** — why you
6. **Press / awards** (if applicable)
7. **CTA band** — contact, book a call, see work
8. **Footer** — second navigation, legal, social

Each block is a route. Each route ends at a dedicated page that goes deep.

---

## 6. Primary Nav — The 5-7 Rule

### 6.1 How many items

- **Max 7 items** (Miller's Law — working memory)
- **Preferred 5-6** including a CTA button on the right
- **< 5 feels empty** for anything bigger than a portfolio

### 6.2 What belongs in primary nav

- The top ~5 most-frequently-needed destinations
- One primary CTA on the right (Contact / Book a call / Start free / Login)
- Nothing else

### 6.3 What does NOT belong

- **Footer-only content** — Privacy, Terms, Cookies, Sitemap
- **Rarely visited pages** — Press (usually footer), Investor Relations (usually footer unless you're public)
- **Meta pages** — 404, search results
- **Social links** — footer
- **Language switcher** — usually top-right or footer, not primary nav

### 6.4 Standard patterns

**Agency / studio**:
```
Work · Services · About · Insights · Contact
```

**B2B SaaS**:
```
Product · Solutions · Customers · Pricing · Resources · [Contact Sales] [Login]
```

**Enterprise**:
```
What we do · Who we serve · Insights · About · Careers · [Contact]
```

**Personal brand**:
```
About · Writing · Speaking · Newsletter · Contact
```

**Law firm**:
```
Practice Areas · People · Insights · Careers · Contact
```

**VC**:
```
Portfolio · Approach · People · Insights · Contact
```

### 6.5 Drop-downs (mega menu) — use sparingly

Use when:
- You have 8+ pages that logically group (B2B SaaS with many products/solutions)
- Each item has a clear category

Avoid when:
- You have < 8 pages (just use flat nav)
- Categories don't cleanly separate
- Mobile experience becomes a mess

Mega menus work on desktop but collapse awkwardly on mobile. Always design mobile-first for nav.

---

## 7. The Footer — Your Second Navigation

Footers are where visitors go when they're lost. A good footer is a rescue system.

### 7.1 Footer content — grouped

**Company**
- About · Team · Careers · Press · Contact

**[Work / Products]**
- Case studies · Services · Portfolio · Pricing

**Resources**
- Blog · Newsletter · Docs · FAQ · Support

**Legal**
- Privacy · Terms · Cookies · Accessibility · Security

**Connect**
- LinkedIn · X · YouTube · GitHub · Email signup

### 7.2 Rules

- **Group with headers** — not a wall of links
- **Order by importance** — Company / Work first
- **Legal always bottom or right** — visitors know where to find it
- **Contact method in footer** — email + address + phone if applicable
- **Copyright + company name**
- **Newsletter signup** — if you have one
- **Certifications / awards** — badges for trust (if relevant)
- **Language / region switcher** — if multilingual

### 7.3 Footer DON'Ts

- Wall of 30+ links with no grouping
- Hidden contact info
- Missing legal pages (GDPR / regulated industries)
- Social icons so tiny they're unclickable
- No visual hierarchy

---

## 8. Breadcrumbs

Use when the site has > 2 levels of depth. They help visitors orient and improve SEO.

```
Home > Practice Areas > Corporate > M&A
```

- Always start with Home
- Show the current page (usually not clickable)
- Match the exact nav hierarchy (never inventive breadcrumbs)

Don't use for flat sites — they add clutter.

---

## 9. Multi-Audience Routing Patterns

When the site serves multiple distinct audiences, you have three options:

### 9.1 Unified site (recommended default)

One site, one nav. Every audience shares the same path through the same pages. Works when audiences share interest in the same content.

**Good for**: small-to-medium orgs, single-product companies, agencies.

### 9.2 Audience-specific landing pages

Primary nav contains "For [Audience]" entries. Each routes to a tailored landing.

```
Home
├── For Founders
├── For Enterprises
└── For Developers
```

**Good for**: B2B products with very different buyers (Stripe, Twilio, AWS).

**Risk**: confuses visitors who don't self-identify.

### 9.3 Subdomain / subsite per audience

```
careers.company.com  (for talent)
investors.company.com (for investors)
developers.company.com (for devs)
```

**Good for**: large enterprises, regulated industries, huge content sets.

**Cost**: SEO fragmentation, maintenance overhead, brand consistency becomes a challenge.

---

## 10. Card Sorting — How to Design the IA

When you're unsure how to organize content:

1. **List every piece of content** — pages, sections, features
2. **Card sort** — put each on a card (physical or digital: OptimalSort, Miro)
3. **Ask 5-10 representative users** to group them naturally
4. **Look for patterns** — groupings that appear across multiple users
5. **Name the groupings** with the labels users used (not internal jargon)

Users' categories are almost never your categories. Use their words.

### 10.1 Open vs closed card sort

- **Open** — users create their own groupings + labels (exploratory)
- **Closed** — users sort into predefined groupings (validation)

Start open. Validate with closed.

---

## 11. Taxonomy & Labeling

### 11.1 Use the user's language

- "Our approach" is better than "Methodology"
- "What we do" is better than "Services"
- "Who we are" is better than "About"
- "Work" is better than "Portfolio" (unless the user calls it portfolio)
- "Get in touch" is better than "Contact Us" (slightly — context matters)

### 11.2 Be specific

Bad: "Solutions"
Good: "For small teams" / "For enterprise"

Bad: "Resources"
Good: "Guides" or "Blog" or "Docs" depending on content

### 11.3 Test labels

Show the label to a user and ask *"What would you expect to find if you clicked this?"* If they can't guess, rewrite.

---

## 12. URL Structure

Clean URLs reflect the IA and help SEO.

- `/about` not `/about-us.html`
- `/work/acme-redesign` not `/case-study?id=123`
- `/insights/how-to-pick-a-crm` not `/blog/post.php?p=456`
- `/careers/senior-engineer` not `/jobs.asp?id=42`

### 12.1 Rules

- **Lowercase**
- **Hyphens** (not underscores)
- **No file extensions** (`.html`, `.php`)
- **No query strings** for content (only filters/search)
- **Max 3-4 levels deep**
- **Stable** — never rename URLs without a 301 redirect

### 12.2 Slugs

- Short, descriptive
- Match the page title (roughly)
- No stop words unless needed (`/how-to-X` is fine)

---

## 13. Responsive Nav (Mobile)

Primary nav must work on mobile first.

### 13.1 Patterns

- **Hamburger menu** — universal, space-efficient, slight discoverability cost (test)
- **Bottom tab bar** — app-like, great for product sites with frequent nav
- **Horizontal scrolling pills** — works for short nav, risky (users miss items)
- **Drawer / slide-over** — good for complex nav

### 13.2 Mobile nav rules

- **Sticky on scroll** (or hide-on-scroll-down, show-on-scroll-up)
- **Tap targets ≥ 44×44px**
- **Logo links to home** (always)
- **CTA button visible or easily accessible**
- **Close button always visible** in open state
- **No hover** — everything must work on tap

### 13.3 The hamburger debate

Some research suggests hamburger icons reduce nav discoverability. Counter-arguments: users are now trained. Reality: test your specific audience. For public institutional sites, hamburgers are fine.

---

## 14. Search (optional but powerful)

### 14.1 When to add search

- The site has > 50 pages
- Content is long-tail (blog, docs, cases, press)
- Visitors likely know what they're looking for (by name)

### 14.2 When NOT to add search

- Small sites (< 20 pages) — nav is faster
- Content is visual/exploratory — browsing is better
- You can't invest in good search (bad search is worse than none)

### 14.3 Tools

- **Algolia** / **Meilisearch** / **Typesense** — hosted, great DX
- **Pagefind** — static site search, no server needed
- **ElasticSearch** — self-hosted, more control

---

## 15. Pagination & Archives

For blog / insights / cases pages:

- **Numbered pagination** — works for archives
- **Load more button** — friendlier for scrolling
- **Infinite scroll** — good for feeds, bad for footers (footer becomes unreachable)
- **Category filters** — if you have > 20 items
- **Tag clouds** — outdated, avoid
- **Date archives** — only for time-sensitive content

---

## 16. Accessibility in IA

- **Skip to main content** link (first focusable element)
- **Semantic landmarks**: `<nav>`, `<main>`, `<footer>`, `<aside>`
- **ARIA labels** for each nav (`aria-label="Primary navigation"`, `"Footer navigation"`)
- **Focus visible** on all interactive elements
- **Nav reachable by keyboard** (Tab through)
- **Dropdowns operable by keyboard** (Enter, Escape, arrow keys)

---

## 17. Common IA Anti-Patterns

- **Org chart IA** — sitemap mirrors departments
- **Deep hierarchy** — 4+ levels, multiple clicks to reach any content
- **Primary nav with 10+ items** — cognitive overload
- **Generic labels** — "Resources", "Solutions", "Offerings"
- **Missing contact / contact buried**
- **Footer with 50+ ungrouped links**
- **Audience-routed nav for small sites** — overkill
- **Mega menus that are unnavigable on mobile**
- **Breadcrumbs on flat sites** — clutter
- **Internal jargon as labels** — "Go-to-market platform" instead of "How it works"
- **Rename without redirects** — SEO collapse
- **Nav that doesn't match footer structure** — visitors lost
- **No search on large content sites**
- **Hiding the logo** — logo always links home
- **Sticky banners that hide the nav**
- **Dropdowns that open on hover and close before you can click**

---

## 18. IA Checklist

- [ ] Audience map — every audience has a primary path
- [ ] Sitemap — flat preferred, max 3 levels
- [ ] Primary nav 5-7 items
- [ ] Primary CTA in header
- [ ] Footer grouped and comprehensive
- [ ] Breadcrumbs if > 2 levels deep
- [ ] URL structure clean and stable
- [ ] Mobile nav works on tap
- [ ] Search if > 50 pages
- [ ] Accessibility landmarks and skip links
- [ ] Every label tested against user language
- [ ] No internal jargon
- [ ] Every page reachable in ≤ 3 clicks from home
- [ ] Legal pages in footer
- [ ] Contact obvious from anywhere
