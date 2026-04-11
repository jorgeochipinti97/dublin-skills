# Landing Page Fundamentals

Structural, UX, and measurement principles. Copy theory lives in `copywriting-theory.md`.

---

## 1. One Goal Principle

One page, one goal, one primary CTA (repeated). Two CTAs to different outcomes = two half-pages on one URL, cannibalizing each other.

---

## 2. Anatomy (pick sections intentionally)

**Core** (order matters):
1. Hero (headline + subhead + CTA + visual + trust line)
2. Social proof bar
3. Problem / agitation
4. Solution + unique mechanism
5. Features → benefits (3-6)
6. How it works (3-5 steps)
7. Deep social proof
8. Objections / FAQ
9. Pricing (if relevant)
10. Risk reversal
11. Final CTA
12. Footer

**Optional by product**: comparison table · video demo · integrations · team/founders · awards · stats bar · security/compliance.

---

## 3. Above the Fold (5-second test)

First viewport must answer: **What / Who / Why / Next** in under 5 seconds.

**Minimum elements**: logo · headline · subhead · primary CTA · trust signal · supporting visual.

**Never above the fold**: long nav (5+ links) · multiple competing CTAs · stock photos · auto-rotating carousels · jargon · "watch this 5-minute video" as the only CTA.

---

## 4. Visual Hierarchy

- **F-pattern** for text-heavy, **Z-pattern** for visual-heavy
- Biggest element = most important thing (usually headline)
- CTA = highest-contrast element in viewport
- Whitespace = breathing room for what matters
- Directional cues (arrows, gaze, motion) pull eyes to CTA

**Flag as broken**: headline smaller than logo · multiple equal-weight buttons · body text larger than subhead · monochrome "hierarchy".

---

## 5. Message Match

Ad/email/post headline promise → landing page headline mirrors it. Mismatch kills 30-50% of conversion. Non-negotiable.

---

## 6. Friction Reduction

### Form friction
- Ask minimum (email only for lead gen)
- Progressive disclosure — ask more later
- Smart defaults, pre-fill what you can
- Inline validation
- Labels above fields (not placeholders — accessibility + disappearing text)
- Autofocus first field
- `autocomplete` attributes

### Decision friction
- No nav (or minimal) — every link is an exit door
- ONE primary CTA
- Pre-select recommended plan
- Max 3 pricing tiers

### Cognitive friction
- 8th-grade language unless audience is technical
- Short sentences + paragraphs
- Scannable (bullets, bolding, headers)
- Progressive disclosure for complex info (FAQ, accordions)

---

## 7. Trust Signals

**Essential**: recognizable logos · specific numbers · real testimonials (name/photo/role/company) · review scores with count · money-back guarantee · security badges (SOC2/GDPR/HIPAA if relevant) · real contact info · company longevity · transparent pricing.

**Anti-trust (remove)**: stock photo testimonials · fake "as featured in" · vague claims ("many customers love it") · fake scarcity · missing contact info · typos · blurry product shots.

---

## 8. Mobile-First

60%+ of traffic is mobile. Blueprint assumes mobile is primary.

- Headline readable without zoom (20-24px min)
- CTA thumb-reachable, ≥44×44px tap target
- Short paragraphs
- Compressed images (WebP/AVIF)
- Single-column forms
- No hover-only interactions
- Consider sticky bottom CTA on long pages
- Flag per-section: layout stacking, CTA visibility, image necessity

---

## 9. Performance

1s → 3s load time = 32% more bounces (Google).

**Targets**: LCP <2.5s · INP <200ms · CLS <0.1

**Flag in handoff**: hero image <100KB WebP/AVIF · fonts subset/preloaded/max 2 weights · defer third-party scripts · reserve image/font space (avoid CLS) · SVG for icons/logos · CDN for assets.

---

## 10. Accessibility (WCAG 2.1 AA minimum)

- Contrast: 4.5:1 body, 3:1 large text
- Keyboard navigation + visible focus rings
- Alt text on meaningful images (empty alt for decorative)
- Semantic HTML (`h1`, `button`, `a` — not `div` soup)
- Visible form labels tied via `for`/`id`
- Error messages announced to screen readers
- Respect `prefers-reduced-motion`
- Skip-to-content link

Flag ARIA needs for custom accordions, tabs, modals.

---

## 11. Scroll Depth Reality

Assume: 100% see hero · 50% scroll past · 30% reach features · 20% reach pricing · 10% reach FAQ · 5% reach footer.

Implications:
- Hero must be self-sufficient (converts the 50% who never scroll)
- Each major section gets a micro-CTA
- Final CTA restates the promise (late skimmers)
- Don't bury price, guarantee, or main differentiator at the bottom

---

## 12. Page Type by Commitment Level

- **Low** (newsletter, waitlist, free tool): short · light proof · email-only form · no pricing/FAQ/objections
- **Medium** (trial, demo, low-ticket): 5-8 sections · logos + 2-3 testimonials · top 2-3 objections · visible "no credit card" or guarantee
- **High** (high-ticket, B2B, course, coaching): 10-20 sections · video testimonials + case studies + metrics · deep objection handling · strong guarantee · multiple CTA repeats · FAQ · founder video · real urgency if applicable

---

## 13. Killers (never include)

Unclear headline · multiple competing CTAs · generic stock photos · long nav · autoplay video with sound · load-time modals · hero image that isn't the product · features without benefits · testimonials without names · no social proof above fold · 5+ pricing plans · third-person copy · no guarantee · buried price (unless enterprise) · 3MB+ weight · layout shifts · no mobile optimization.

---

## 14. Measurement

**Primary metric** (one number):
- Lead gen → submission rate
- Sales → purchase rate + revenue per visitor
- Waitlist → signup rate + referral activation
- Webinar → registration + show rate
- Demo → booked + held rate
- App → install + D1 open

**Secondary**: scroll depth (25/50/75/100) · time on page · per-CTA CTR · form abandonment · source attribution · device conversion gap.

**In blueprint**: flag primary metric by name, which events to fire, UTM preservation, implied A/B tests.

---

## 15. Section Ordering Heuristics

**Emotional buyer (B2C)**: Hero → Problem → Solution → Benefits → Testimonials → Offer → Guarantee → CTA

**Logical buyer (B2B/technical)**: Hero → Logos → Solution → Features/Benefits → How it works → Case studies → Pricing → FAQ → CTA

**Impulse (low-ticket)**: Hero → Social proof → Benefits → Offer → Guarantee → CTA

**High-consideration (enterprise)**: Hero → Problem → Solution → Mechanism → Benefits → Case studies → Proof → Pricing → FAQ → Risk reversal → Founder story → Final CTA
