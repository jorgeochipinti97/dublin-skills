# Organization Type Playbooks

Per-org-type playbooks. Each one has a different audience mix, trust strategy, positioning, and standard sitemap. Load the relevant section for the user's org type.

---

## 1. B2B SaaS (Product Company)

### Primary audiences
Prospective customers, existing customers, investors, talent, partners.

### Primary job of the site
Convert qualified leads into trial signups or demo bookings, plus serve existing customers and attract talent.

### Standard sitemap

```
Home
├── Product
│   ├── Features (or per-product pages)
│   ├── Integrations
│   └── Changelog
├── Solutions
│   ├── By use case
│   └── By industry
├── Pricing
├── Customers (cases)
├── Resources
│   ├── Blog / Insights
│   ├── Docs / Help
│   ├── Guides / Templates
│   └── Webinars
├── Company
│   ├── About
│   ├── Careers
│   ├── Security / Trust
│   └── Contact
└── [Login] [Start free / Book demo]
```

### Home page must have

- Hero with outcome headline + product screenshot
- Logos bar of customers
- 3-4 feature blocks with benefits
- Featured case study with numbers
- Pricing preview (or "see pricing" CTA)
- Thought leadership teaser
- Final CTA (trial + demo)

### Trust strategy
Logos → case studies → G2/Capterra ratings → SOC 2 badge → pricing transparency.

### Voice
Confident, precise, technical-when-needed, warm. Stripe is the north star.

### Anti-patterns
- Hiding pricing
- "Solutions" that are just feature lists with different labels
- Missing security/trust page for enterprise
- Docs separated from marketing so searchers bounce
- Generic "For Enterprise" pages with zero specificity

### Reference sites
Linear, Stripe, Vercel, Notion, Loom, Railway, Supabase.

---

## 2. Agency / Studio (Design, Development, Marketing, Strategy)

### Primary audiences
Prospective clients, talent, press, community.

### Primary job of the site
Make prospective clients want to work with you by showing your work.

### Standard sitemap

```
Home
├── Work (the portfolio — deep)
│   └── [Per-case pages]
├── Services (what you do)
├── About (team + story + philosophy)
│   └── Team
├── Insights (blog, thought leadership)
├── Careers
└── Contact
```

### Home page must have

- Hero with positioning + bold visual
- Featured case studies (3-6, visually strong)
- Services overview (short)
- Selected clients bar
- About teaser
- Contact CTA

### Trust strategy
The **work IS the trust signal**. Case studies are the center of gravity. Logos of known clients. Team credentials. Press and awards.

### Voice
Distinctive. Agencies win on voice as much as work. Options:
- **Editorial** (Pentagram, Collins, Instrument)
- **Minimal technical** (Basement Studio, Ueno)
- **Playful bold** (Mercury, Hoodzpah)
- **Warm conversational** (Ritual Motion, Koto)

Pick one lane and commit.

### Anti-patterns
- Small case studies with no depth
- Generic services names ("Strategy", "Design", "Development")
- No team (for agencies, hiding the team = hiding the value)
- Stock photos anywhere
- Laundry list of every client ever (pick the best 10)
- "Contact Us for a quote" without process transparency

### Reference sites
Pentagram, Collins, Instrument, Basement, Frontside, &Walsh, Koto, Area17.

---

## 3. Law Firm / Legal Practice

### Primary audiences
Prospective clients (individuals or corporates), talent (associate recruiting), press, referral sources, judiciary.

### Primary job of the site
Establish authority and lead to a consultation.

### Standard sitemap

```
Home
├── Practice Areas
│   ├── Corporate
│   ├── Litigation
│   ├── IP
│   └── [...]
├── People (lawyers, partners)
│   └── [Per-lawyer profile]
├── Insights (articles, alerts, commentary)
├── Careers
├── About the Firm
├── Offices
└── Contact
```

### Home page must have

- Hero with calm, confident headline (never bombastic)
- Practice area overview
- Featured people / partners
- Recent insights / client alerts
- Offices locations
- Contact

### Trust strategy
**People are the product.** Lawyer profiles are critical. Credentials (JD school, bar admissions, notable cases, publications, speaking engagements). Firm longevity. Awards (Chambers, Legal 500). Press.

### Voice
Formal but clear. Authoritative. Never salesy. Precision matters. Avoid:
- Corporate-speak jargon
- Direct-response sales language
- Overpromising
- Guarantee language (usually prohibited by bar associations)

### Per-lawyer profile must have

- Photo (professional, consistent across firm)
- Full name + title
- Practice areas
- Bar admissions
- Education
- Notable matters / representative work
- Publications
- Speaking engagements
- Languages
- Contact (direct email + phone)
- Vcard / download

### Anti-patterns
- Generic lawyer stock photos
- "Winning" language (bar association violations in many jurisdictions)
- No bios for partners
- Vague practice areas
- Missing office addresses
- No client alerts / thought leadership
- Corporate templates that feel interchangeable
- Dark patterns in contact flow

### Compliance callouts
Lawyer advertising is heavily regulated. Check local bar rules before writing. Common rules:
- No "expert" or "specialist" claims without certification
- No guaranteed outcomes
- Required disclaimers
- Prior results disclaimer ("Prior results do not guarantee similar outcomes")

### Reference sites
Latham & Watkins, Kirkland & Ellis, Wilson Sonsini, Cooley, Davis Polk, Sullivan & Cromwell. Mid-tier: Fenwick, Gunderson Dettmer.

---

## 4. Venture Capital Firm

### Primary audiences
Founders (looking for funding), LPs (existing and prospective), portfolio companies, press, co-investors, talent.

### Primary job of the site
Signal thesis, credibility, portfolio, and make founders want to pitch you.

### Standard sitemap

```
Home
├── Thesis / Approach
├── Portfolio
│   └── [Per-company or grouped]
├── Team (partners)
│   └── [Per-partner profile]
├── Insights / Writing
├── For Founders (how to pitch)
├── News
└── Contact
```

### Home page must have

- Hero with thesis in one line
- Portfolio logos
- Partners / team
- Recent writing / insights
- CTA to pitch or contact

### Trust strategy
**Portfolio is the proof.** Known logos. Notable exits. Partner credentials (prior work, exits, notable investments). Thesis clarity. Writing that shows thinking. LP caliber (if disclosed).

### Voice
Thoughtful, specific, with a clear point of view. Avoid:
- Generic "we invest in passionate founders" copy
- Vague thesis ("we back ambitious teams")
- List of every investment ever (curate)
- Corporate finance jargon

### Per-partner profile
- Photo
- Name + role
- Focus areas
- Notable investments (with context)
- Prior experience
- Writing and speaking
- Contact (direct email — founders need to reach partners)

### Anti-patterns
- No clear thesis
- Portfolio without context
- Hidden partners
- Vague "how to pitch" (or missing entirely)
- Corporate-speak
- No writing / no POV

### Reference sites
Andreessen Horowitz (a16z), First Round, Sequoia, Benchmark, Accel, Point Nine, Homebrew, Acrew.

---

## 5. Enterprise / Large Corporate Website

### Primary audiences
Customers (enterprise and SMB), investors, analysts, press, partners, regulators, talent, community.

### Primary job of the site
Serve multiple audiences simultaneously. Requires clear audience routing.

### Standard sitemap

```
Home
├── Products / Solutions
│   ├── By industry
│   ├── By role
│   └── By size
├── Customers
├── Partners
├── Resources
├── Company
│   ├── About
│   ├── Leadership
│   ├── Sustainability / ESG
│   ├── Diversity & Inclusion
│   ├── Careers
│   ├── Newsroom / Press
│   └── Investor Relations
└── Contact / Support
```

### Home page must have

- Clear audience routing (can be implicit or explicit)
- Featured solution or news
- Customer logos and proof
- Quick links to audience-specific paths
- Thought leadership
- Clear search

### Trust strategy
Scale proof (revenue, employees, customers, countries). Investor confidence (stock performance if public). Compliance breadth. Analyst recognition (Gartner Magic Quadrant, Forrester Wave). Sustainability reporting. Leadership credentials.

### Voice
Measured, clear, internationally accessible. Avoid:
- American-only idioms if global
- Over-confident claims (regulators watching)
- Political statements (unless it's the brand)
- Inconsistent voice across divisions

### Governance considerations

- Multiple content owners (product, marketing, PR, IR, HR, legal)
- Clear governance model
- Design system / brand guidelines
- Accessibility compliance mandatory
- Translation / localization processes
- Legal review workflows

### Anti-patterns
- Org chart IA (reflects internal structure, confuses users)
- Inconsistent experiences across divisions
- Buried investor info
- Missing sustainability / ESG
- No clear careers path
- Terrible internal search
- Pop-up "chat with sales" on every page
- Marketing overriding legal with consequences

### Reference sites
IBM, Microsoft, SAP, Salesforce, Accenture, Deloitte, Unilever, Patagonia.

---

## 6. Nonprofit / Foundation / NGO

### Primary audiences
Donors, beneficiaries, volunteers, press, partners, board, government, researchers.

### Primary job of the site
Communicate mission, drive donations/volunteering, show impact.

### Standard sitemap

```
Home
├── Mission / What We Do
├── Impact (programs + outcomes)
│   └── [Per-program pages]
├── Stories (beneficiary + volunteer stories)
├── About
│   ├── Team + Board
│   ├── Financials / Transparency
│   ├── Reports
│   └── Partners
├── Get Involved
│   ├── Donate
│   ├── Volunteer
│   ├── Fundraise
│   └── Advocate
├── News / Blog
├── Careers
└── Contact
```

### Home page must have

- Mission in one line
- Urgency or current focus
- Impact numbers
- One powerful story (beneficiary, volunteer, or donor)
- Donate CTA (prominent)
- How your money is used (transparency)

### Trust strategy
Transparency is the currency. Financial reports, impact numbers, beneficiary stories, board credentials, third-party ratings (Charity Navigator, GiveWell, GuideStar). Partners and funders list.

### Voice
Warm, direct, specific. Avoid:
- Saviorism language
- Generic "making a difference" copy
- Inflated stats without sources
- Emotional manipulation without proof

### Impact reporting

Critical to an institutional nonprofit site:
- **Program outcomes** — what did the money do?
- **Financial breakdown** — where did the money go? (% to programs, admin, fundraising)
- **Annual report** — downloadable, comprehensive
- **Theory of change** — how your work leads to impact
- **Transparency page** — board, financials, policies

### Anti-patterns
- No financial transparency
- Beneficiary photos without consent / dignity
- "Help us help them" without specifics
- Donate button without context
- No board or leadership info
- Vague programs
- Missing impact measurement

### Reference sites
charity: water, GiveDirectly, Watsi, Effective Altruism Foundation, American Red Cross, Save the Children.

---

## 7. Personal Brand (Author, Speaker, Founder, Creator)

### Primary audiences
Readers, event organizers, press, clients, followers.

### Primary job of the site
Build personal authority, convert to an email list or book a speaking engagement or sell a product.

### Standard sitemap

```
Home
├── About
├── Writing (books, articles, blog)
├── Speaking
├── [Podcast | Newsletter | Course]
├── Now (what you're working on)
└── Contact
```

### Home page must have

- Photo of you (editorial, not LinkedIn corporate)
- One-sentence positioning (*"I write about [X] for [audience]"*)
- Latest work
- What you're known for
- CTA (subscribe, buy book, book talk)

### Trust strategy
**You are the product.** Credentials, publications, prior work, speaking history, press, testimonials from known peers. Consistency of output.

### Voice
Distinctly yours. This is where voice is most critical — impersonal copy kills personal brands.

### Standard elements

- **"Now" page** — what you're working on (Derek Sivers invented this)
- **Newsletter signup** — the #1 conversion on most personal sites
- **Speaking request form** — if you speak
- **Media kit** — photo, bio, topics, past talks
- **Press mentions** — where you've been featured

### Anti-patterns
- Stock photos
- Ghostwritten corporate-speak
- No personality
- Listing every job on the About page (LinkedIn dump)
- Too many CTAs
- No clear "what you're known for"
- Generic testimonials

### Reference sites
Derek Sivers, Seth Godin, Paul Graham, Julian Shapiro, Anne-Laure Le Cunff, Tim Urban (Wait But Why), Nadia Asparouhova.

---

## 8. Early-Stage Startup (pre-product or MVP)

### Primary audiences
Prospective customers, investors, talent, press, waitlist signups.

### Primary job of the site
Generate signups, investor interest, and initial hires.

### Standard sitemap

```
Home
├── (Product teaser — what you're building)
├── Mission / Manifesto
├── Team (founders)
├── Investors (if raised)
├── Careers
└── Contact / Join waitlist
```

### Home page must have

- Bold positioning (*"We're building [X] for [Y]"*)
- Vision / manifesto
- Founders with credibility
- Investor logos (if raised publicly)
- Waitlist signup / beta access
- Press coverage (if any)

### Trust strategy
Founder credentials + vision clarity + investor caliber (if applicable) + progress signal.

### Voice
Confident, ambitious, specific about the change you want. Avoid:
- Generic startup-speak
- "Disrupting X" without substance
- Mystery without signal
- YC-pattern copying

### Special elements

- **Manifesto page** — the WHY behind the company
- **Job openings** prominent (early-stage startups need to hire)
- **Waitlist with perks** — early access, discount, etc.

### Anti-patterns
- Hiding the product completely (mystery backfires)
- No founder info
- Generic "we're a stealth startup" with no clarity
- No hiring even though you need it
- Mission statement as the whole page

### Reference sites
Stripe (pre-public), Vercel (early), Linear (early), Railway, Resend, Arc Browser (pre-public).

---

## 9. Government / Public Organization

### Primary audiences
Citizens, press, partner agencies, vendors, international bodies.

### Primary job of the site
Deliver services, communicate policy, provide transparency.

### Standard sitemap

```
Home
├── Services (for citizens)
├── About (mission, structure, leadership)
├── Policies / Programs
├── News / Announcements
├── Data / Reports
├── Procurement
├── Careers
└── Contact
```

### Home page must have

- Clear audience routing
- Service finder / search
- News and announcements
- Emergency info (if applicable)
- Multilingual access
- Accessibility prominent

### Trust strategy
Transparency, accessibility, accurate information, clear governance.

### Voice
Plain language. Neutral. Clear. Avoid:
- Politicization
- Legalese
- Jargon
- Tone that feels partisan

### Hard requirements

- **WCAG 2.1 AA** — legally required in most jurisdictions
- **Multilingual** — usually required
- **Plain language** — federal / agency mandates exist
- **Section 508** (US federal)
- **Open data** links
- **FOIA / transparency** links (US)

### Anti-patterns
- Inaccessible PDFs as primary content
- Jargon-heavy copy
- Broken forms
- Missing contact info
- Hidden accessibility statement
- No plain-language alternative
- Out-of-date content

### Reference sites
GOV.UK (gold standard), USA.gov (reformed), Singapore.gov.sg.

---

## 10. Professional Services (Consulting, Accounting, Financial Advisory)

### Primary audiences
Prospective clients, referral partners, candidates, press.

### Primary job of the site
Establish authority and generate qualified leads.

### Standard sitemap

```
Home
├── Services
│   └── [Per-service detail]
├── Industries (if specialized)
├── Team / People
│   └── [Per-person profile]
├── Insights / Thought Leadership
├── Case Studies
├── Careers
├── About
└── Contact
```

### Home page must have

- Clear positioning (who you serve, what problem)
- Services or practice areas
- Featured insights
- Team credentials
- Selected clients
- Contact CTA

### Trust strategy
**Credentials + content.** Years of experience, team qualifications, certifications (CPA, CFA, etc.), thought leadership depth, client roster.

### Voice
Authoritative but accessible. Warm but not casual.

### Key elements

- **Per-person profiles** with credentials and contact
- **Insights page** with regular content
- **Case studies** (often anonymized for privacy)
- **Industry pages** if you specialize

### Compliance callouts
- Financial services: heavy regulation (SEC, FINRA, etc.)
- Required disclaimers
- No performance guarantees
- Audit trail of marketing claims

### Reference sites
McKinsey, BCG, Bain, Deloitte, PwC, EY, KPMG.

---

## 11. E-commerce Brand Site (brand-forward, not just catalog)

### Primary audiences
Prospective customers, existing customers, press, partners, influencers.

### Primary job of the site
Build brand story while driving product discovery.

### Standard sitemap

```
Home
├── Shop (category → product)
├── Collections
├── Our Story (editorial about the brand)
├── Journal (content marketing)
├── Sustainability / Values
├── Stores
├── Help / Support
├── About
└── Contact
```

### Home page must have

- Brand hero
- Featured products / collections
- Editorial story / values
- Press / awards
- Community / UGC
- Newsletter signup

### Trust strategy
Product quality signals, brand story, press, reviews (star ratings), sustainability credentials, return policy, customer service.

### Voice
Depends on the brand — can be editorial (Aesop), playful (Liquid Death), minimal (Apple), warm (Patagonia).

### Anti-patterns
- Generic e-commerce template
- Missing brand story
- No sustainability info (modern consumers expect it)
- Hidden return policy
- Stock photos of "happy customers"

### Reference sites
Aesop, Patagonia, Liquid Death, Everlane, Away, Allbirds, Away, Our Place.

---

## 12. Quick Decision Matrix

| Org type | Primary element | Key trust signal | Voice tone |
|---|---|---|---|
| B2B SaaS | Product + pricing | Case studies + logos | Confident + technical |
| Agency | Case studies | The work itself | Distinctive + editorial |
| Law firm | People | Credentials + cases | Formal + authoritative |
| VC | Thesis + portfolio | Partners + exits | Thoughtful + opinionated |
| Enterprise | Audience routing | Scale + analysts | Measured + international |
| Nonprofit | Mission + impact | Transparency | Warm + specific |
| Personal brand | You | Prior work + press | Distinctly personal |
| Early startup | Vision | Founders + investors | Ambitious + specific |
| Government | Services | Transparency + accuracy | Plain + neutral |
| Professional services | Credentials | Depth + track record | Authoritative + accessible |
| E-commerce brand | Product + story | Reviews + press | Brand-specific |

---

## 13. How to Use This Reference

1. Identify the org type from the user's discovery answers
2. Load the matching section
3. Use the standard sitemap as a starting point (adjust based on what the user said they need)
4. Apply the trust strategy to map proof elements
5. Calibrate voice to the org type
6. Check anti-patterns against the user's stated ideas
7. Reference the listed real-world examples for mood and structure

If the org type isn't listed here, hybridize from the closest two (e.g., "design agency that also has a SaaS product" = agency + B2B SaaS, lean into whichever is more revenue-relevant).
