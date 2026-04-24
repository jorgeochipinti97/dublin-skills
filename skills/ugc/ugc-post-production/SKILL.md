---
name: ugc-post-production
description: "Turns an approved avatar crudo + script into the finished UGC video: captions (style, timing, placement), visual hooks (zoom punch, shake, jump cut, pattern interrupt), B-roll intercut, music selection + sync to beats, sound design (SFX, whoosh, needle drops). Outputs a cut-ready edit decision list (EDL) explaining WHICH effect at WHICH timestamp and WHY it earns its place. Vendor-agnostic: editor can execute in CapCut / Premiere / DaVinci / Remotion. Use after ai-avatar-director render is approved. Enforces Filler Word Index on on-screen text."
---

# UGC Post-Production

Cuts and polishes the avatar crudo into the shipped ad. Every effect earns its place or it's cut.

## Hard Rules

1. **Never render.** Output is an edit decision list (EDL) + asset list + style guide.
2. **Never start without inputs.** If the script, crudo, or brand voice is missing, STOP and ask.
3. **Every FX has a reason.** The EDL must state WHY each effect lands where it lands. "Looks cool" is not a reason.
4. **Under-edit beats over-edit.** If a beat doesn't need a cut, don't cut. Energy comes from intention, not volume.
5. **Captions are mandatory.** No UGC ships without hard-burned captions (Meta defaults to muted; 85%+ watch on mute).

## Required Context (block if missing)

1. **Script** — finished `ugc-scriptwriter` output (with timing table)
2. **Avatar crudo** — link / file ref / duration
3. **Platform(s)** — TikTok / Reels / Shorts / Meta Feed / YouTube
4. **Brand voice** — premium / friendly / expert / irreverent / clinical / luxury / street
5. **Brand assets** — fonts, colors, logo (or "use UGC defaults")
6. **B-roll available** — product shots, lifestyle clips, screen recordings, or "none yet"
7. **Music license** — brand library / Artlist / Epidemic / licensed original / "any royalty-free"
8. **Language** — ES (AR/MX/ES/LATAM) / EN (US/UK)
9. **Pace target** — chill / medium / fast (influences cut density)

**If the user says "hacelo vos":** proceed, flag every invented asset with `⚠️` and list missing assets at the end.

## Workflow

1. **Mark the beats** — annotate the script with retention-risk moments (transitions, long sentences, low-energy middles).
2. **Plan captions** — style + timing scheme per platform.
3. **Plan visual hooks** — one per retention-risk moment. Pick from the FX library by reason.
4. **Plan B-roll intercuts** — where A-roll alone loses energy.
5. **Plan music** — genre, BPM match, drop alignment to key beats.
6. **Plan sound design** — SFX for emphasis, transitions, CTAs.
7. **Write the EDL** using the output format below.
8. **Flag missing assets** and handoff.

## Captions

### Style per brand voice

| Brand voice | Caption style | Font family | Weight | Color | Highlight |
|---|---|---|---|---|---|
| Premium / luxury | Minimal, single line bottom | Serif or refined sans (e.g. Söhne-style) | 500 | White + 80% opacity | None |
| Friendly / DTC | Karaoke word-by-word | Rounded sans (e.g. Inter Display alt, Nunito) | 700 | White + shadow | Yellow or brand accent |
| Expert / clinical | Sentence-by-sentence bottom | Neutral sans | 500 | White on 40% black pill | None |
| Irreverent / Gen-Z | Pop-in per word + emoji | Display / wavy | 800 | White + colored strokes | Rotating brand color per word |
| Street / urban | Word-by-word, larger, center-mid | Bold display | 900 | White, thick black stroke | Red / neon per keyword |
| Clinical / medical | Sentence bottom, muted | Neutral sans | 400 | White 90% + light background | None |

**Inter Tell avoidance**: never default to Inter Regular 16px. Pick a font with character.
**Pure Black Tell**: never `#000` — use `#0A0A0A` or `#111` with a subtle shadow.

### Timing schemes

| Scheme | When | How |
|---|---|---|
| Word-by-word (karaoke) | TikTok, Reels, Gen-Z | Each word pops in on its syllable, highlight active word |
| Phrase-by-phrase | Meta Feed, YouTube | 2-4 word chunks, 400-600ms each |
| Sentence bottom | Premium, B2B, clinical | Full sentence, stable 2-3s |

### Placement rules

- Bottom-center for 9:16 (TikTok/Reels/Shorts): raise above the platform UI band (safe zone bottom ~270px for iPhone).
- Center-middle only for short emphasis words (1-2 per video max).
- Never bottom-left or bottom-right — covered by platform UI.
- Never on the avatar's mouth area.

### On-Screen Text Rules

- ≤ 7 words per overlay, ever
- No period at end of caption lines (social convention)
- Emojis allowed if brand voice permits, max 1 per line
- Swap every banned Filler Word (see Filler Word Index below) with concrete replacement

## Visual Hooks (FX Library)

Each entry: what it does + when to use + when NOT to use.

### Zoom punch (fast push-in, 200-400ms)
- **Use**: on hook reveal, on key stat, on CTA, on emotional beat
- **Don't use**: every sentence (loses impact after 2 per video)
- **Why**: draws attention, resets viewer focus

### Jump cut (remove micro-pauses)
- **Use**: between beats, when avatar breathes or pauses unintentionally
- **Don't use**: in measured/premium tones (breaks the tone)
- **Why**: compresses time, keeps energy high, UGC-authentic feel

### Shake (2-3 frames subtle jitter)
- **Use**: on "surprise" moments, reaction angle hooks
- **Don't use**: premium/clinical brands
- **Why**: conveys energy, startle reflex

### Whip pan transition
- **Use**: between scene/B-roll cuts
- **Don't use**: as a default transition (becomes cliché)
- **Why**: connects two shots with kinetic energy

### Zoom + shake combo (1-frame zoom + micro-shake)
- **Use**: on a single "punchline" word in a reaction or list
- **Don't use**: more than once per video
- **Why**: punctuation mark for emphasis

### Flash frame (1 white/brand frame)
- **Use**: at scene change, before CTA reveal
- **Don't use**: on seizure-risk platforms (YouTube ads strict, Meta flags)
- **Why**: hard reset for viewer attention

### Speed ramp (0.5x → 1x on reveal)
- **Use**: before-after moment, unboxing beat
- **Don't use**: in dialogue-heavy sections (lipsync breaks)
- **Why**: makes the reveal feel earned

### Freeze frame + text
- **Use**: list angle (item callouts), comparison (winner per axis)
- **Don't use**: emotional/testimonial moments (kills momentum)
- **Why**: gives viewer time to read + process

### B-roll intercut
- **Use**: whenever A-roll alone drops energy (middle section, long explanation)
- **Don't use**: if it doesn't visually support the line (random cutaways = noise)
- **Why**: adds visual variety, shows product in context

### Picture-in-picture (PiP)
- **Use**: demo angle (screen recording in corner while avatar talks)
- **Don't use**: testimonial, reaction (distracts from face)
- **Why**: shows product while keeping human connection

## B-Roll Strategy

### Ratio by angle

| Angle | A-roll % | B-roll % |
|---|---|---|
| Testimonial | 70-80 | 20-30 |
| Problem-Solution | 50-60 | 40-50 |
| Founder | 60-70 | 30-40 |
| Reaction | 80-90 | 10-20 |
| Demo | 30-40 | 60-70 |
| Before-After | 40 | 60 (the transformation IS the content) |
| Comparison | 50 | 50 (split-screen heavy) |
| Myth-Bust | 60 | 40 (text overlays + proof clips) |
| POV | 30 | 70 (scene is the content) |
| List | 40 | 60 (item visuals per point) |

### B-roll timing

- Never cut away during a critical spoken word (punchline, stat, CTA).
- Minimum duration: 0.8s (anything shorter reads as glitch).
- Maximum cutaway from avatar: 4s (or viewer forgets who's talking).
- Intercut on emphasis words in measured delivery; intercut between sentences in fast delivery.

## Music & Sound Design

### Genre × brand voice

| Brand voice | Genre suggestions | BPM range |
|---|---|---|
| Premium / luxury | Ambient, cinematic minimal, neo-classical | 70-90 |
| Friendly / DTC | Acoustic-pop, indie, lo-fi | 90-110 |
| Expert / clinical | Corporate minimal, light electronic | 80-100 |
| Irreverent / Gen-Z | Hyperpop, phonk, meme-core | 120-150 |
| Street / urban | Hip-hop instrumental, drill-adjacent | 130-160 |
| Clinical / medical | Ambient neutral, barely-there | 70-85 |

### Sync rules

- Drop/swell on: hook end (3s mark), CTA start, before-after reveal.
- Fade music 30% under speech — never full-volume under dialogue.
- Hard cut on music at CTA for emphasis (music stops, voice lands alone, then music returns for end card).

### Sound design SFX

- **Whoosh** — scene transitions (once per 15s max)
- **Pop / click** — caption emphasis on single words
- **Cash register / ding** — price/offer reveal (comedic brands only)
- **Needle drop** — tonal shift (myth-bust "but actually...")
- **Sub boom** — hook punch, reveal
- **Silence (1 beat)** — before CTA (high-conversion, under-used)

### SFX Anti-Patterns

- Every cut with a whoosh = amateur tell
- Laser zaps / dated 2015 YouTuber SFX = cringe tell
- Library default SFX at full volume = amateur mix (drop to -12dB to -18dB)

## Filler Word Index — BANNED in On-Screen Text

Same bans as `ugc-scriptwriter`. Captions are read twice as fast as speech — filler words double-count.

| Category | ES | EN |
|---|---|---|
| Hype verbs | Potenciar, Revolucionar, Transformar | Elevate, Unleash, Revolutionize |
| Hype adjectives | Innovador, De vanguardia, Next-gen | Cutting-edge, Game-changing |
| Empty phrases | "Descubrí el poder de", "Lleva tu X al siguiente nivel" | "Unlock the power of", "Take it to the next level" |

## Output Format

```markdown
# [Product] — Post-Production EDL — [Angle] — [Duration]s — [Platform]

**Crudo**: [file ref / link]
**Script**: [file ref / link]
**Pace target**: [chill / medium / fast]
**Brand voice**: [voice] → Caption style: [style from table]

---

## Caption Plan
- **Scheme**: [word-by-word / phrase / sentence]
- **Font**: [family, weight]
- **Color**: [primary + highlight]
- **Placement**: [bottom-center / center-mid]
- **Max line length**: 7 words
- **Safe zone**: [e.g. 270px from bottom on 9:16]

## Edit Decision List

| Time | Beat | Cut | FX | Caption | B-roll / A-roll | SFX | Music | Why |
|---|---|---|---|---|---|---|---|---|
| 0:00-0:03 | Hook | — | Zoom punch @0:02 | "[text]" | A-roll MCU | Sub boom @0:00 | Drop @0:03 | Lock attention in first 2s |
| 0:03-0:08 | Context | Jump cut @0:05 | — | "[text]" | A-roll | — | Under -12dB | Compress mid-energy beat |
| 0:08-0:14 | Discovery | — | B-roll intercut @0:10-0:12 | "[text]" | B-roll (product) | Whoosh @0:10 | Steady | Show product while narrating |
| ... | ... | ... | ... | ... | ... | ... | ... | ... |
| X:XX-end | CTA | Hard cut | Slow push-in + flash frame | "[CTA]" | A-roll MCU | Silence 0.5s before, click on CTA | Music cuts, returns on end card | High-conversion pattern |

## Music
- **Track**: [name / library / ⚠️ NEEDED]
- **BPM**: [number]
- **In-point**: [timestamp in track]
- **Sync beats**: [list of timestamps + what they sync to]
- **Ducking**: -12dB under dialogue

## B-roll List
- **Clip 1**: [description] — duration: [X.Xs] — source: [own / stock / ⚠️ NEEDED]
- **Clip 2**: [description] — duration: [X.Xs] — source: [own / stock / ⚠️ NEEDED]
- [...]

## Sound Design
- [timestamp] — [SFX] — [volume] — [purpose]
- [...]

## Export Specs
- **Aspect ratio**: [9:16 / 1:1 / 16:9]
- **Resolution**: [1080x1920 / 1080x1080 / 1920x1080]
- **Codec**: H.264, 10-12 Mbps
- **Audio**: AAC 128kbps, -16 LUFS (Meta/TikTok standard)
- **File naming**: `[brand]_[product]_[angle]_[duration]_[platform]_[version].mp4`

## Missing Assets
- [list each ⚠️ item from above, or "none"]

## Handoff
- Editor executes this EDL in [CapCut / Premiere / DaVinci / Remotion].
- After first cut → review for: caption readability on mobile, music ducking levels, B-roll holds on critical words, export LUFS check.
- On approval → export multi-format (9:16 primary, derivatives if needed).
```

## Anti-Patterns

- **Edit-dumping** — every transition whooshed, every word zoomed. Viewer numbs out. FX lose meaning.
- **Caption wall** — more than 7 words on screen at once. Unreadable on mobile.
- **Music drowning dialogue** — music at -6dB or higher under speech. Unwatchable on mute → still bad on sound.
- **B-roll during critical words** — cutting away from the avatar exactly when they deliver the stat/CTA kills comprehension.
- **Transition cliché** — every cut a whoosh / every scene a whip pan. Use sparingly.
- **Platform-ignorant export** — YouTube 16:9 upload that's actually 9:16 cropped = dead on arrival.
- **Inter Tell captions** — Inter Regular 16px white on nothing. Pick a font with character.
- **Pure Black Tell** — `#000` anywhere. Use `#0A0A0A` minimum.
- **Default library SFX** at full volume. Always duck.

## Handoff

- Editor renders per EDL.
- QA against the EDL's `Why` column — if an effect doesn't match its reason, cut it.
- Export checks:
  - Captions readable at phone-held distance
  - -16 LUFS audio for Meta/TikTok, -14 LUFS for YouTube
  - No Pure Black, no Inter default, no Filler Words on screen
  - File naming convention followed
- Ship.
