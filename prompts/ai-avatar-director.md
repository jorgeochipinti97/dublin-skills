# ai-avatar-director

## Activation Prompts

```
Director brief para avatar a partir de este script: [paste]
```

```
Cast + wardrobe + voz para un ad testimonial de [producto] en TikTok
```

```
Avatar direction for this UGC script using HeyGen
```

```
Armame el brief del crudo: [script] — brand voice [premium/friendly/...]
```

```
Dirección del avatar para [angle] — audiencia [audience], region [ES-AR / EN-US / ...]
```

## Flow

1. Pass in the finished `ugc-scriptwriter` output.
2. The skill blocks if: product category, audience, angle, brand voice, or language/region are missing.
3. Output is a director brief with casting, wardrobe, setting, framing, voice, plus a vendor-agnostic prompt block.
4. Review + approve brief → send to vendor (HeyGen / Hedra / Akool / Arcads / Synthesia) or human operator.
5. Once crudo is rendered and approved → hand off to `ugc-post-production`.

## Example Use Cases

- Director brief for a batch of 5 testimonial ads (same brand, 5 different avatars)
- Vendor-agnostic brief that the ops team executes across HeyGen and Hedra
- Re-cast when the first crudo feels off-brand or uncanny
- Voice direction-only update (same avatar, new script, different tone)
- Campaign consistency review (avoid Same-Face Syndrome across 10+ ads)
- Premium brand launch — casting for luxury tone + measured delivery
- Regional localization (same script, different region-matched avatars for ES-AR / ES-MX / EN-US)
