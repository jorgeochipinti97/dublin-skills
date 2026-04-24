---
name: ugc-video-prompting
description: "Writes text-to-video / image-to-video prompts for Google Veo 3 (and Veo 3.1) and ByteDance Seedance 2.0 that produce UGC-style content — handheld phone feel, natural lighting, platform-native framing. Translates a UGC script + ad angle into model-specific prompts with the right Subject / Context / Action / Camera / Style / Audio anatomy. Handles image-to-video with reference assets (product shots, talent photos), character/object consistency across shots, and UGC realism 'tells' (handheld sway, imperfect lighting, selfie framing). Includes negative-prompt boilerplate for Seedance. Use AFTER ugc-scriptwriter (to know the angle + beats) and AS ALTERNATIVE to ai-avatar-director when the pipeline uses generative video (Veo/Seedance) instead of lipsync (HeyGen/Hedra)."
---

# UGC Video Prompting (Veo 3 / Seedance 2.0)

Writes prompts for text-to-video and image-to-video models so they produce UGC that reads as real — not cinematic, not AI-obvious.

## Hard Rules

1. **Never write code, never render.** Output is the prompt + negative prompt + model-specific notes.
2. **Never start without context.** If the script/angle, target model, duration, or aspect ratio is missing, STOP and ask.
3. **UGC is not cinema.** If the user asks "make it look cinematic," push back — UGC that looks like a commercial underperforms ads that look like UGC.
4. **Camera as its own sentence.** Veo parses camera instructions more reliably when separated from subject action. Same discipline for Seedance.
5. **Describe motion, not the image, when an image reference is provided.** The model already sees the image — spend tokens on movement and beat.
6. **One beat per prompt.** Most prompts = one shot of 5-10s. Multi-shot sequences are separate prompts unless using Seedance 2.0 multi-shot mode.

## Required Context (block if missing)

1. **Script / beat** — which beat from the `ugc-scriptwriter` output is this shot for? (hook / body / CTA / B-roll insert)
2. **Ad angle** — testimonial / problem-solution / founder / reaction / demo / before-after / comparison / myth-bust / POV / list
3. **Target model** — Veo 3 / Veo 3.1 / Seedance 2.0 / both-variants
4. **Mode** — text-to-video (T2V) / image-to-video (I2V) / image-to-video with audio
5. **Reference assets** — talent photo(s), product photo(s), env photo(s), or "none"
6. **Duration** — 5s / 8s / 10s (check current model limit)
7. **Aspect ratio** — 9:16 (UGC default) / 1:1 / 16:9
8. **Sync audio wanted** — yes / no (native audio: Veo 3 supports; Seedance 2.0 supports multi-asset incl. audio)
9. **Realism target** — UGC-authentic (phone feel) / semi-polished / polished-influencer
10. **Character consistency needed across shots** — yes / no (affects whether we plan a seed + master prompt pattern)

**If the user says "vos decidís":** proceed, flag every creative assumption with `⚠️`.

## Prompt Anatomy — Universal 7 Slots

Every good UGC video prompt covers these. Order matters: put what should dominate the frame first.

1. **Subject** — who (age, gender, ethnicity band, look/archetype). "25-year-old Latina woman, casual, warm-toned skin, minimal makeup."
2. **Context** — where (setting, time of day, background detail). "Her bedroom in soft morning light, unmade bed visible in background."
3. **Action** — what she does, in present tense, concrete verbs. "She picks up a small cream jar, unscrews the lid, dips her finger in, and dabs it under her eye while looking at the phone camera."
4. **Camera** *(separate sentence)* — static / handheld / push-in / pull-back / orbit / tracking, shot size, lens feel. "The camera is a front-facing smartphone held at arm's length, slight handheld sway, no pan."
5. **Lighting** — natural window light / ring light / overhead / golden hour / overcast. "Natural window light from camera-left, soft shadows, no ring-light glare."
6. **Style & Ambiance** — UGC realism descriptors (see UGC Realism Tells below). "Phone-shot authenticity, slight softness, true-to-life color, no film grain."
7. **Audio** *(if model supports sync audio)* — what the voice says, tone, environmental sound. Keep voice line short. "She says calmly: '8 semanas, sin rebote.' Quiet room ambience."

## Two Prompt Structures

### Veo 3 / Veo 3.1 — 5-part formula

`[Cinematography] + [Subject] + [Action] + [Context] + [Style & Ambiance]`

Camera direction is the FIRST line when it must dominate (Veo prioritizes camera + action beat). Keep camera in a separate sentence from subject action.

### Seedance 2.0 — motion-first when I2V

When feeding an image reference, Seedance already "sees" the subject and scene. Skip re-description. Spend the prompt on:
- Motion (subject + camera)
- Beat / reveal / punctuation
- Audio if native

## UGC Realism "Tells" (the whole point)

UGC content wins when the model BELIEVES it's a phone recording, not a shoot. Build this in:

| Tell | Phrase to include |
|---|---|
| Selfie framing | "front-facing smartphone camera", "selfie at arm's length", "phone held in one hand" |
| Handheld motion | "slight handheld sway", "subtle micro-movements", "natural hand unsteadiness" |
| Aspect + safe zone | "vertical 9:16", "framed for mobile viewing" |
| Natural light | "natural window light", "overcast afternoon light", "soft indoor light, no studio setup" |
| Imperfect environment | "unmade bed in background", "kitchen counter with some clutter", "bathroom mirror, normal home" |
| Phone audio feel *(audio-sync models)* | "room tone audible", "casual speaking voice, no studio reverb" |
| Amateur framing | "slightly low angle", "off-center composition", "subject takes up 70% of frame" |
| Realistic skin | "realistic skin texture, pores visible, minimal retouch" |

### UGC Anti-Tells (never include)

- "Cinematic lighting", "dramatic lighting", "film look"
- "4K", "ultra HD", "studio quality", "photorealistic render"
- "Slow-motion", "dolly shot", "crane shot", "aerial view", "drone footage"
- "Dutch angle", "shallow depth of field" (over-bokeh = commercial tell)
- "Perfect skin", "airbrushed", "flawless"
- "Color grading", "cinematic color"
- "Lens flare", "anamorphic", "bokeh"
- "Dramatic background music", "orchestral swell"

If the user requests any of these for a UGC shot, flag and ask if they want UGC or a polished commercial — they're different deliverables.

## Angle → Prompt Patterns

Quick lookup: what camera/framing/action template per ad angle.

| Angle | Camera | Framing | Action pattern |
|---|---|---|---|
| Testimonial | Front-facing selfie, slight handheld | MCU (chest up) | Subject speaks directly to phone, minimal hand gestures, occasional product show |
| Problem-Solution | Front-facing, handheld, occasional B-roll cutaway | MCU → CU on pain moment | Subject shows frustration at pain point, then product as solution |
| Founder | Front-facing, slight handheld, home/desk setting | MCU | Subject speaks directly, occasional glance off-camera (natural) |
| Reaction | Front-facing, handheld, dynamic | CU to MCU | Subject reacts (eyes widen, laugh, surprise), product in frame |
| Demo | Medium overhead or POV hands | MS or top-down | Product-in-use close-up, step-by-step hands, minimal face time |
| Before-After | Matched pair — same angle, same light, same distance | MCU both | Shot 1: before state. Shot 2: after state. Consistency locked. |
| Comparison | Two-shot side-by-side or alternating | MS | Subject holds/shows A vs B, honest reaction per item |
| Myth-Bust | Front-facing MCU, static-adjacent | MCU | Subject states myth (slight tension), then counters with evidence |
| POV | First-person / chest-mounted feel | POV | Hands interact with product in the scene |
| List | Front-facing with text-insert beats | MCU | Subject introduces list, enumerates with short beats |

## Veo 3 / Veo 3.1 — Specifics

> **Verify current docs** for latest syntax, duration limits, and features. Veo iterates fast.

### Structure template (T2V)

```
[Camera as lead sentence, if camera is dominant.]
[Subject line: who, look, archetype.]
[Context line: where, when, background.]
[Action line: present tense, concrete verbs, one beat.]
[Style line: lighting + ambiance + realism tells.]
[Audio line (if sync): dialogue in quotes + tone + env sound.]
```

### Example — Testimonial hook (9:16, 8s, EN-US, sync audio)

```
The camera is a front-facing smartphone held at arm's length, slight handheld sway, no pan.
A 27-year-old woman with warm-toned skin and light freckles, hair in a messy bun, wearing a cream T-shirt.
She is sitting on the edge of her bed in morning light, unmade bed in background, soft natural light from camera-left.
She holds up a small glass jar of cream, gives a quick satisfied half-smile, and says calmly "8 weeks. No dry patches." Her shoulders relax on the last word.
Natural window light, realistic skin texture with visible pores, no studio look, phone-shot authenticity, true-to-life color.
Quiet room tone, casual indoor voice, no reverb.
```

### Veo-specific tips

- **Put camera first** when camera is the control signal; put action first when action matters most.
- **One beat per prompt.** Don't chain two actions.
- **Use film grammar** Veo understands: "wide shot", "medium shot", "close-up", "push-in", "pull-back", "static", "pan left/right".
- **Avoid** "cinematic" tokens unless you WANT commercial feel.
- **Audio quotes** — put dialogue in quotes, specify tone word ("calmly", "excited", "matter-of-fact").

## Seedance 2.0 — Specifics

> **Verify current docs** — Seedance supports text, image, video, and audio inputs (multiple assets per generation), native audio sync, character consistency across shots.

### Structure template (I2V with talent photo + product photo)

```
[Motion / beat — what happens in the 5-10s. Camera + subject movement.]
[Audio if sync — dialogue + tone + env sound.]
[Style — UGC realism tells.]

Negative prompt: [append boilerplate below]
```

**When using reference images, skip re-describing what's in them.** Seedance sees them. Spend tokens on motion.

### Example — Problem-Solution with talent photo + product photo

```
The woman (from reference) picks up the cream jar (from reference) with her right hand, unscrews the lid while looking slightly off-camera in mild frustration, then faces the front-facing phone camera and applies a small dab under her right eye. Slight handheld sway throughout, front-facing smartphone framing.

Audio: She says in a relaxed tone "Terminé con los parches secos." Quiet bedroom ambience.

UGC phone-shot style, natural window light from camera-left, realistic skin with visible pores, vertical 9:16.

Negative prompt: no text overlays, no watermarks, no logos, no extra fingers, no deformed hands, no jump cuts, no whip pans, no Dutch angles, no cinematic bokeh, maintain perfect character consistency across frames, realistic physics, no extra limbs.
```

### Seedance negative-prompt boilerplate (always append)

```
no text overlays, no watermarks, no logos, no extra fingers, no deformed hands, no jump cuts, no whip pans, no Dutch angles, no cinematic bokeh, no neon unless specified, no crowds, maintain perfect character consistency, realistic physics, no extra limbs, no warped faces
```

### Seedance-specific tips

- **Multi-asset**: you can pass talent + product + environment refs. Order in the prompt matches priority.
- **Motion > description** when image-referenced.
- **Character consistency**: always explicit in negative prompt when generating multi-shot sequences.
- **Native audio**: include dialogue in quotes with tone word.

## Character / Object Consistency (multi-shot campaigns)

When the same talent or same product appears across multiple shots:

1. **Lock a master reference image** — generate or source one canonical talent shot + one product shot. Reuse as I2V input every time.
2. **Use a seed** (Veo/Seedance both support) — lock random seed per character to reduce drift.
3. **Master prompt fragment** — write a 1-sentence canonical description of the subject and product. Paste verbatim into every prompt.
4. **In the negative prompt**: always include "maintain perfect character consistency".
5. **Validate every render** — compare frame 1 to the master reference. If facial features drift > 10%, regenerate.

## Output Format

```markdown
# [Product] — [Angle] — [Beat] — [Model] — [Duration]s

**Mode**: [T2V / I2V / I2V+Audio]
**Aspect**: [9:16 / 1:1 / 16:9]
**References**: [talent ref / product ref / env ref / "none"]
**Realism target**: [UGC-authentic / semi-polished / polished-influencer]

---

## Prompt

```
[the full prompt body — structured per target model]
```

## Negative Prompt *(Seedance / Veo 3 if used)*

```
[boilerplate or tuned negative]
```

## Seed / Consistency
- **Seed**: [number or "random, lock on first good render"]
- **Character master ref**: [file path or ⚠️ NEEDED]
- **Product master ref**: [file path or ⚠️ NEEDED]
- **Master description fragment**: [1-sentence canonical subject/product description to reuse]

## Audio *(if sync)*
- **Line**: "[exact dialogue]"
- **Tone**: [calmly / excited / matter-of-fact / etc.]
- **Env sound**: [room tone / kitchen ambience / outdoor / etc.]

## Validation Checklist
- [ ] Camera in its own sentence (Veo) — yes / n/a
- [ ] Motion-first when I2V (Seedance) — yes / n/a
- [ ] UGC realism tells present (handheld, natural light, selfie framing)
- [ ] No cinematic anti-tells (drone, cinematic, 4K, dolly, dramatic)
- [ ] Negative prompt attached (Seedance)
- [ ] Consistency plan if multi-shot — seed + master ref + fragment
- [ ] Aspect ratio matches platform (9:16 for TikTok/Reels/Shorts)

## Handoff
→ Pass renders + script to `ugc-post-production` for EDL.
→ Flag any re-renders needed after first-pass review.
```

## Anti-Patterns

- **Cinematic tokens for UGC** — "cinematic, 4K, film look, dolly shot" kills UGC authenticity.
- **Describing a referenced image** in I2V — wastes prompt budget, dilutes motion control.
- **Multi-beat prompts** — two actions in 5s = muddy result. One beat per prompt.
- **Camera embedded in subject sentence** — reduces Veo's ability to parse camera intent.
- **Skipping negative prompt on Seedance** — gets logos, extra fingers, jump cuts, character drift.
- **No consistency plan** — 10-shot campaign with drifting faces = unusable.
- **"Polished influencer" when the ad angle is testimonial** — mismatch kills credibility.
- **Over-specifying** — 40-line prompts with 30 adjectives underperform 8-line focused prompts.
- **Generic action verbs** — "interacts with", "uses the product" = the model has no concrete motion to render.
- **Dialogue too long for duration** — 20 words of dialogue in 5s = rushed audio or clipped. ~2.5 words/sec.
- **Asking for sound effects the model can't control** — if audio sync is limited, keep SFX for post (`ugc-post-production`).

## Reference Loading

- Model docs are the ground truth. Flag model-specific syntax with `⚠️ VERIFY CURRENT DOCS` when in doubt.
- Sources used while writing this skill: Veo 3 prompting guides from Google Cloud, Leonardo.ai, Replicate, DreamHost, Visla, and LTX Studio; Seedance 2.0 guides from Higgsfield, Atlabs, YouMind-OpenLab.

## Handoff

1. User renders via Veo / Seedance (or their wrapper — fal.ai, Replicate, Leonardo, Higgsfield, etc.).
2. First render → validate against the checklist.
3. Re-render with tighter prompt or different seed if UGC tells are weak.
4. Approved render → pass to `ugc-post-production` for EDL (captions + hooks + music).
5. If the UGC pipeline uses **both** lipsync (HeyGen/Hedra for talking head) and generative video (Veo/Seedance for B-roll / scene), `ai-avatar-director` handles the lipsync shots and this skill handles the generative shots.
