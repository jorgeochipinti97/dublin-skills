# ugc-video-prompting

## Activation Prompts

```
Prompt para Veo 3 para este beat: [beat del script]
```

```
Seedance prompt I2V con estas refs: [talent] + [producto], ángulo [angle]
```

```
Armame el prompt UGC para [Veo 3 / Seedance 2.0] de la hook de este guión
```

```
Traducí el script a prompts de Veo para los 3 beats (hook / body / CTA)
```

```
Prompt UGC handheld, [talent photo attached], product [photo attached]
```

```
Character consistency pack: master ref + seed + fragment para campaña de [n] shots
```

## Flow

1. Pass in the `ugc-scriptwriter` output + target model (Veo 3 / Veo 3.1 / Seedance 2.0).
2. The skill blocks if script/angle, model, mode (T2V/I2V), duration, aspect, or reference assets are missing.
3. Output is a structured prompt + negative prompt (Seedance) + seed/consistency plan + audio lines.
4. Render in the tool of choice (fal.ai / Replicate / Leonardo / Higgsfield / direct API).
5. Validate first render against the checklist. Re-render tighter if UGC tells are weak.
6. Approved renders → hand off to `ugc-post-production` for EDL.

## Example Use Cases

- Veo 3 prompt for a testimonial hook (9:16, 8s, sync audio)
- Seedance I2V with talent photo + product photo for a problem-solution ad
- Before-after matched pair prompts with locked seed for consistency
- B-roll generation for a HeyGen/Hedra lipsync campaign (hybrid pipeline)
- Character consistency pack for a 10-shot campaign (master ref + seed + fragment)
- Negative-prompt boilerplate rescue — existing renders have logos/drift/extra fingers
- Realism tuning — current renders look too cinematic, need phone-shot tells
- Multi-shot sequence for a demo angle (overhead hands shot + reaction shot + product reveal)
