---
name: ai-avatar-director
description: "Translates a UGC script into a vendor-agnostic director brief for AI avatar video generation (HeyGen / Hedra / Akool / Arcads / Synthesia / any future vendor). Decides casting (age/gender/ethnicity/archetype), wardrobe, setting, framing, movement, and voice direction — matched to product, audience, angle, and brand voice. Outputs an operator-ready brief plus a vendor-agnostic prompt block. Use after ugc-scriptwriter, before sending anything to a lipsync API or human operator. Prevents uncanny-valley, off-brand casting, and generic AI-avatar look."
---

# AI Avatar Director

Turns a script + brand context into a casting + wardrobe + setting + voice brief that any avatar/lipsync vendor (or human operator) can execute without creative rework.

## Hard Rules

1. **Never generate video.** Output is a brief + prompt, not a render.
2. **Never start without context.** If required fields are missing, STOP and ask for all of them in one message.
3. **Vendor-agnostic first.** Write the creative brief before the vendor-specific prompt. Vendors change; the brief doesn't.
4. **One avatar per script.** Multi-avatar videos = multiple briefs.
5. **Match the demographic to the audience, not the brand's wish.** Casting mismatch tanks credibility even with perfect lipsync.

## Required Context (block if missing)

1. **Script** — finished `ugc-scriptwriter` output (with timing table)
2. **Product category** — skincare / SaaS / fitness / supplement / fintech / etc.
3. **Audience** — age band, gender skew, income, occupation, region
4. **Angle** — testimonial / problem-solution / founder / reaction / demo / before-after / comparison / myth-bust / POV / list
5. **Brand voice** — premium / friendly / expert / irreverent / clinical / luxury / street
6. **Language / region** — ES-AR / ES-MX / ES-ES / ES-LATAM / EN-US / EN-UK
7. **Vendor** *(optional)* — HeyGen / Hedra / Akool / Arcads / Synthesia / "vendor-agnostic"
8. **Constraints** — prohibited demographics (regulatory), required diversity, existing brand talent look, or "none"

**If the user says "decidí vos":** proceed, flag every casting assumption with `⚠️`.

## Workflow

1. **Read the script** — identify emotional beats, key moments to emphasize, hook type.
2. **Cast** using the Casting Framework below.
3. **Dress** using Wardrobe rules (brand × angle × setting).
4. **Set the scene** — pick setting that reinforces credibility for the angle.
5. **Frame** — decide shot size, movement, handheld vs locked, per beat if needed.
6. **Voice** — tone, cadence, accent, energy per section.
7. **Write the brief** in the output format below.
8. **Generate vendor-agnostic prompt** (short block at the end, copy-paste into any tool).

## Casting Framework

### 1. Demographic match → audience
Mirror the audience band. Close in age (±5y), region-appropriate features, realistic income signals. Off-by-a-decade kills credibility.

### 2. Archetype → angle
Different angles need different avatar archetypes:

| Angle | Archetype that works | Archetype that fails |
|---|---|---|
| Testimonial | Everyday user, realistic skin, "could be my cousin" | Model-perfect, over-polished |
| Problem-Solution | Relatable-frustrated, mid-expression | Smiling-neutral stock look |
| Founder | Confident, dressed for their field (hoodie or suit by category) | Actor-in-office-costume |
| Reaction | Expressive, camera-aware, younger skew | Flat affect, corporate pose |
| Demo | Hands-on, sleeves rolled, task-focused | Presenter pose, static |
| Before-After | Matched pair or same person at both timepoints | Different models pretending continuity |
| Comparison | Neutral-analytical, slightly skeptical | Overly enthusiastic |
| Myth-Bust | Authoritative but warm, thinker look | Either preachy or bubbly |
| POV | Lifestyle-native, in-scene | Studio-pose model |
| List | Didactic-casual, presenter energy | Newscaster-formal |

### 3. Credibility fit → product category

| Category | Casting cue |
|---|---|
| Skincare / beauty | Skin texture MUST show pores/realism. Avoid airbrushed. |
| Fitness | Athletic-realistic, not fitness-model extreme (unless premium/body-transformation positioning) |
| SaaS / B2B tools | Work-context dress, 28-45y skew, ethnic diversity matching buyer persona |
| Finance / fintech | Trust signals: neutral colors, slight formality, measured delivery |
| Supplements / health | Healthy-looking, NOT model-healthy. Avoid clinical settings unless Rx positioning. |
| DTC consumer | Match the aesthetic of the brand's customer, not its aspirational customer |
| Infoproduct / coach | Creator-energy: home office, good-but-not-studio lighting |
| Luxury | Fewer smiles, slower delivery, premium wardrobe, negative-space settings |
| Fashion / streetwear | Trend-current, Gen-Z/Millennial-native styling |

### 4. Anti-Patterns (never ship)

- **Jane Doe Effect** — generic names "Jane Doe", "John Smith", "María García" when introducing the avatar. Use contextual real names.
- **Uncanny Valley Triad** — too-smooth skin + too-wide smile + too-still eyes = AI tell within 2 seconds.
- **Inter Tell of Avatars** — the stock "polished-neutral" HeyGen default face. Pick distinctive features.
- **Demographic Cosplay** — brand's 25y audience "voiced" by a 45y avatar because it looks more "trustworthy."
- **Same-Face Syndrome** — 10 ads, 10 identical aesthetic. Rotate features across a campaign.

## Wardrobe

Pick from 3 axes (brand voice × angle × setting).

| Brand Voice | Default wardrobe |
|---|---|
| Premium / luxury | Solid neutrals, tailored, minimal logos |
| Friendly / DTC | Casual but not sloppy: tee, light cardigan, natural fabrics |
| Expert / clinical | Button-down or blazer, muted colors, single accent |
| Irreverent / Gen-Z | Streetwear-current, colorful, layered |
| Clinical / medical | Lab-adjacent: collared, white/navy, no statement pieces |
| Street / urban | Streetwear but audience-matched (not costume) |

**Angle overrides**:
- Founder → slightly more formal than audience, but not full suit unless category demands
- Demo → sleeves rolled, practical
- POV → audience-matched, scene-appropriate (gym, kitchen, outside)
- Testimonial → what that person would actually wear to run an errand

**Avoid**:
- Busy patterns (lipsync artifacts worsen)
- Logo T-shirts unless your own brand
- Stark white (blows out on most vendors)
- Pure black (Pure Black Tell — muddy on most encoders)

## Setting / Background

| Setting | Works for | Avoid for |
|---|---|---|
| Home (living/kitchen) | Testimonial, reaction, demo, founder (early-stage) | Luxury, B2B enterprise |
| Home office | Founder, list, myth-bust | Lifestyle, fashion |
| Neutral studio (soft gray) | Comparison, myth-bust, premium | Testimonial (too sterile) |
| Bedroom / bathroom | Skincare, haircare, wellness | B2B, fintech |
| Outdoor | Fitness, lifestyle, fashion, beverages | Software, finance |
| In-car | POV, lifestyle, commuter-audience | Premium, clinical |
| Office / co-work | B2B, SaaS, founder (Series A+) | DTC consumer, wellness |
| Gym / sport-adjacent | Fitness, supplements | Everything else |

**Background rules**:
- Shallow depth-of-field (blurred background) = premium. Sharp background = DIY/UGC-authentic.
- Clutter = authenticity but only 10-30% of frame.
- Logos in background = rights issues, always remove or blur.

## Framing & Movement

### Shot sizes
- **Close-up (CU)** — eyes to chin. Intimacy, emotional moments. Most testimonial/reaction.
- **Medium close-up (MCU)** — chest up. Default UGC shot.
- **Medium (MS)** — waist up. Demo, product-in-hand moments.
- **Wide (WS)** — full body. POV, lifestyle. Rare for avatar (lipsync weaker at distance).

### Movement
- **Locked** — tripod feel. Premium, serious angles.
- **Handheld subtle** — light sway. Default UGC-authentic feel.
- **Handheld energetic** — younger audiences, reaction/POV.

### Per-beat framing (recommended)
- Hook (0-3s) → MCU, slight handheld, direct eye contact
- Body → alternate MCU and MS for visual rhythm
- CTA → MCU, slow push-in (0.5-1s push), direct eye contact

## Voice Direction

### Tone × angle matrix

| Angle | Tone | Cadence | Energy (1-10) |
|---|---|---|---|
| Testimonial | Confessional, measured | Conversational, pauses | 5-6 |
| Problem-Solution | Empathetic → resolved | Medium-fast | 6-7 |
| Founder | Confident, personal | Medium, intentional pauses | 6 |
| Reaction | Surprised, excited | Fast, broken rhythm | 8-9 |
| Demo | Instructive, clear | Medium, step-pauses | 5-6 |
| Before-After | Relieved, grateful | Slow → medium | 5-7 |
| Comparison | Analytical, honest | Medium, even | 5 |
| Myth-Bust | Authoritative-warm | Medium, emphatic beats | 6-7 |
| POV | In-scene natural | Scene-appropriate | Variable |
| List | Presenter-casual | Fast item, pause between | 7 |

### Accent / region
- Match audience region. ES-AR for Argentina (voseo). ES-MX for Mexico. Neutral LATAM only if pan-regional.
- EN-US default for global EN unless UK/AU audience specified.
- NEVER default to "neutral Spanish" for AR audience — voseo signals authenticity.

### Key-moment cues
For each script's "key moment to emphasize":
- Slight volume increase (not shout)
- Brief pause before/after
- Slower delivery on the key word(s)

## Output Format

```markdown
# [Product] — Avatar Director Brief — [Angle] — [Language/Region]

## Casting
- **Age band**: [e.g., 28-34]
- **Gender**: [M / F / NB / unspecified]
- **Ethnicity / features**: [audience-matched, specific]
- **Archetype**: [from angle table]
- **Vibe reference**: [real-world archetype: "creative-agency PM", "runner-mom", etc.]
- **Why this casting**: [1 line linking to audience + angle]

## Wardrobe
- **Top**: [garment + color + fabric]
- **Layer**: [or "none"]
- **Accessories**: [minimal — list or "none"]
- **Hair / grooming**: [short description]

## Setting
- **Location**: [from setting table]
- **Time of day / light**: [morning soft / midday / golden hour / artificial warm]
- **Background dress**: [what's visible, clutter level %]

## Framing & Movement
| Script beat | Shot size | Movement | Notes |
|---|---|---|---|
| Hook (0-3s) | MCU | Slight handheld | Direct eye contact |
| [next beat] | [size] | [movement] | [notes] |
| CTA | MCU | Slow push-in | Direct eye contact |

## Voice Direction
- **Tone**: [from voice table]
- **Cadence**: [pacing description]
- **Energy**: [1-10]
- **Accent**: [ES-AR / ES-MX / EN-US / etc.]
- **Key-moment emphasis**: [timestamp] — [word(s) to stress, how]

## Do Not
- [specific bans for this brief, e.g. "no corporate suit", "no studio white"]
- [e.g. "no over-smiling during problem section"]

---

## Vendor-Agnostic Prompt Block

> **Avatar**: [age]y [gender], [ethnicity/features], [archetype vibe]. [Hair/grooming]. Wearing [wardrobe in one line].
> **Setting**: [location] with [lighting].
> **Shot**: [default framing] with [movement].
> **Voice**: [accent], [tone], [energy level]. [Cadence notes].
> **Emphasis**: on "[key phrase]" at [timestamp] — [how].
> **Avoid**: [top 3 do-nots].

## Vendor Notes *(if vendor specified)*
- **HeyGen**: map to closest Instant Avatar or custom-train with 2-min source
- **Hedra**: use Character-3 for expressive beats, feed voice separately via ElevenLabs
- **Akool**: lipsync-first, prefer locked shots, single language per render
- **Arcads**: pre-cast library — pick by archetype tag, not name
- **Synthesia**: stock library, best for B2B neutral-corporate only
- **Vendor-agnostic** — hand brief to operator, let them pick

## Handoff
→ `ugc-post-production` once the crudo is rendered and approved.
```

## Anti-Patterns

- Starting with the vendor ("HeyGen can do X, so the brief is Y") — brief first, vendor second.
- Casting for "what looks trustworthy" instead of "what the audience looks like."
- Same avatar across 10 ads of a campaign (Same-Face Syndrome).
- Premium brand voice with DIY kitchen setting (voice/setting mismatch).
- Accent-neutral voice for a regional audience (credibility tank).
- Over-polished lighting on a "real customer" testimonial.
- Dense wardrobe patterns (lipsync artifacts).
- Generic prompt "friendly person talking to camera about [product]" — that's how you get the Inter Tell of avatars.

## Handoff

After the director brief:
1. Operator or vendor renders the crudo.
2. Review crudo against the brief's **Do Not** section + avatar-quality rubric (lipsync drift, uncanny tells, off-brand).
3. On approval → pass script + crudo to `ugc-post-production`.
