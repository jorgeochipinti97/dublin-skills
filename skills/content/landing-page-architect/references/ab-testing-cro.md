# A/B Testing & CRO for Landing Pages

When to run tests, what to test first, how to write hypotheses, and how to interpret results. Applies after the page is live and receiving traffic.

---

## 1. CRO Mindset — What This Is Not

CRO (Conversion Rate Optimization) is not:
- "Let's test button colors" → button color rarely matters; copy, offer, and trust do
- Guessing → every test is a hypothesis derived from evidence
- Endless iteration → test the highest-leverage element first and stop when you have a winner

CRO is: identifying why visitors aren't converting, forming a hypothesis, testing it, and deploying the winner.

---

## 2. Research Before Testing

The most common CRO mistake: testing before you know what's broken.

### Data sources (priority order)

1. **Heatmaps** (Hotjar, Microsoft Clarity, Mouseflow) — where they click, where they rage-click, where they stop scrolling
2. **Session recordings** — watch 20-30 real sessions before running any test
3. **Exit surveys** — "What stopped you from [action] today?" (Hotjar poll, or Typeform embed)
4. **Analytics funnel** — where does the drop happen? (Hero → Section 3 = early; Pricing → CTA = objection stage)
5. **Form abandonment** — which field causes people to stop?
6. **Customer interviews** — 5 customers who bought, 5 who didn't. Ask why.

No data → no test. Guessing is just a test with no hypothesis.

---

## 3. Prioritization — ICE Framework

Score every test candidate on 3 axes. Run highest-ICE tests first.

| Axis | Score 1-10 | Question |
|---|---|---|
| **Impact** | How much could this move the primary metric if we're right? |
| **Confidence** | How sure are we (based on data) that this is the actual problem? |
| **Ease** | How fast/cheap to run the test? |

ICE = (Impact + Confidence + Ease) / 3

**Prioritize ICE > 6. Never guess ICE — derive it from data.**

### Example prioritization

| Test | I | C | E | ICE |
|---|---|---|---|---|
| Rewrite hero headline | 9 | 8 | 8 | 8.3 |
| Change CTA button color | 2 | 2 | 9 | 4.3 |
| Add risk reversal section | 7 | 7 | 7 | 7.0 |
| Shorten the form (email only) | 8 | 9 | 8 | 8.3 |
| Add video testimonial | 6 | 5 | 5 | 5.3 |

---

## 4. Test Hierarchy — What Matters Most

Not all elements have equal leverage. Test in this order:

### Tier 1 — Highest leverage (test first)
- **The offer** — is what you're offering what they actually want?
- **The headline** — are you speaking to the right pain/desire?
- **The primary CTA and trust line** — action verb, value promise, friction reducer
- **Form length** — fewer fields almost always converts better
- **Above-the-fold layout** — mobile vs desktop first-viewport composition

### Tier 2 — Medium leverage
- **Social proof placement** — logos above vs below hero; testimonials before vs after pricing
- **Price presentation** — monthly vs annual toggle; anchoring; free tier presence
- **Risk reversal** — guarantee language, placement, duration
- **Hero image / video** — product screenshot vs people vs abstract

### Tier 3 — Low leverage (test last)
- CTA button color (if contrast is already sufficient)
- Font choice within the same weight/family
- Section order (usually)
- Footer content

---

## 5. Hypothesis Writing

A test without a hypothesis is an experiment. A test with a hypothesis is CRO.

### Formula

> **Because** [we observed / we know] [evidence], **we believe** changing [element] **will** [direction] [primary metric] **for** [audience segment].

### Examples

> Because heatmaps show 70% of mobile visitors don't scroll past the hero (evidence), we believe rewriting the hero headline to name the specific audience ("For solo founders who sell services") will increase scroll depth to pricing on mobile by 20%.

> Because exit surveys show "too expensive" is the top objection (evidence), we believe adding a "Pay monthly, cancel anytime" line directly under the CTA will increase trial signups for visitors who reached the pricing section.

> Because session recordings show most form abandonment happens at the "phone number" field (evidence), we believe removing the phone field and asking for it post-signup will increase form completions by 15%.

---

## 6. Statistical Significance — The Basics

Don't call a winner early.

### Minimum sample size
Use a sample size calculator before starting. Rule of thumb:
- 10% baseline conversion rate → need ~400 conversions per variant for 80% power, p < 0.05
- 5% baseline → ~800 per variant
- 2% → ~2,000 per variant

Tools: [statsig.com calculator](https://statsig.com/ab-testing-calculator), Optimizely's calculator, or any standard A/B calculator.

### Significance threshold
- Standard: **p < 0.05** (95% confidence that the result is not random)
- For high-stakes decisions (pricing changes): p < 0.01

### Minimum runtime
- **At minimum 2 weeks**, regardless of significance — to account for day-of-week effects
- Never call a winner the first day even if p = 0.001

### Common mistakes
- Stopping a test the moment one variant "looks better" (peeking problem)
- Running multiple simultaneous tests on the same element (interaction effects)
- Testing on insufficient traffic (underpowered tests produce unreliable results)
- Forgetting to segment results (a winner on desktop can be a loser on mobile)

---

## 7. Common CRO Wins by Section

Based on real-world CRO data. Start here when you don't have specific data.

### Hero
- Rewrite headline to name the specific ICP ("For VPs of Engineering at Series A companies" beats "For software teams")
- Add specific number to subhead ("Reduce deploy time from 45 min to 8 min" beats "Ship faster")
- Product screenshot vs lifestyle photo: product screenshot almost always wins for SaaS
- Add "No credit card required" directly under CTA

### Social Proof
- Logos in grayscale vs color: test — color wins for brand recognition, grayscale for "serious" brands
- Moving logos bar faster vs slower
- Testimonials with face photo vs without: photo wins consistently
- Testimonial placement: after hero vs after problem section (depends on product type)

### CTA
- "Start free trial" vs "Get started" vs "Try for free": "Start free trial" often wins on clarity
- Button copy that names the outcome: "Start hiring faster" > "Sign up"
- Trust line directly below CTA: "No credit card · Cancel anytime" reduces the perceived risk of clicking

### Forms
- Removing one field: almost always increases completions
- "Work email" label vs "Email" label: "Work email" sets expectations, often converts better for B2B
- Single field (email) vs progressive: for lead gen, single field wins
- Inline vs separate form page: inline almost always wins for low-commitment actions

### Pricing
- Showing "most popular" on a tier
- Annual vs monthly default
- Removing "forever free" tier to reduce anchor confusion
- Price with vs without cents ($99 vs $99.00 — drop the .00)

### Risk reversal
- 30-day vs 14-day money back: 30-day usually converts better (higher perceived confidence)
- "No questions asked" language
- Guarantee badge (visual) vs text only: badge wins for trust signaling

---

## 8. Running the Test

### Technical setup
- **Google Optimize** (sunset) → now: **VWO**, **Optimizely**, **Convert**, **Statsig**, or **A/B Tasty**
- For simpler tests: **split URLs** (two separate pages, traffic split at routing level) — less complex than on-page variations
- **Feature flags** (LaunchDarkly, Statsig, GrowthBook) for full-stack tests

### Traffic split
- 50/50 for A/B (two variants)
- 33/33/33 for A/B/C (three variants — requires 3× the traffic; usually not recommended)
- Never go below 10% on a variant (statistical noise)

### What to instrument
- Primary metric: the conversion event you're testing for
- Secondary metrics: scroll depth, time on page, rage clicks, form field abandonment
- Segment: mobile vs desktop, new vs returning, traffic source

---

## 9. Declaring a Winner

- Both statistical significance (p < 0.05) AND practical significance (the lift matters to the business)
- 2+ weeks of runtime
- No major external event during the test (sale, PR spike, algorithm change)
- Check segments before declaring: is the winner consistent across mobile/desktop?

### If there's no winner
- Not every test produces a clear winner — that's information too
- A flat test tells you the element didn't matter — move to the next ICE candidate
- A test where your variant *lost* is also valuable — you now know what not to do

---

## 10. CRO Program Cadence

For a page with enough traffic (500+ conversions/month):

1. **Research sprint** (1 week) — heatmaps + recordings + exit surveys + funnel analysis
2. **Hypothesis backlog** — score all ideas with ICE, rank
3. **Test sprint** — run 1-2 tests at a time (never more on the same section)
4. **Winner deployment** — deploy winner, document learning
5. **Iteration** — return to backlog, start next test
6. **Quarterly page audit** — review all active sections against benchmarks

---

## 11. CRO Checklist

Before launching a test:
- [ ] Evidence for the hypothesis (not a guess)?
- [ ] ICE score calculated?
- [ ] Sample size estimated with a calculator?
- [ ] Minimum 2-week runtime planned?
- [ ] Primary metric instrumented?
- [ ] Segment analysis planned (mobile vs desktop)?
- [ ] No other active tests on the same section?

After the test:
- [ ] 2+ weeks elapsed?
- [ ] Statistical significance reached (p < 0.05)?
- [ ] Practical significance — is the lift meaningful?
- [ ] Winner consistent across mobile / desktop / traffic sources?
- [ ] Learning documented in backlog?
