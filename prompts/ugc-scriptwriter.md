# ugc-scriptwriter

## Activation Prompts

```
Necesito un guión UGC para [producto] en [TikTok/Reels/Shorts]
```

```
Armame 3 hooks para un ad de [producto] estilo testimonial
```

```
Write a 30s UGC script for [product] targeting [audience]
```

```
Guión UGC estilo problema-solución para [producto], CTA [acción]
```

```
Genera 5 variantes de guión para split-test de [producto]
```

```
Script demo de 30s para [SaaS/tool], audiencia [role]
```

## Flow

1. The skill blocks and asks for: product, audience, platform, duration, language/region, angle (or "pick for me"), proof, CTA, forbidden claims, # of variants.
2. You answer in one block.
3. The skill outputs shoot-ready scripts — table with timing, spoken line, on-screen text, B-roll.
4. Hand off to `ai-avatar-director` for casting + voice.
5. Hand off to `ugc-post-production` for captions + visual hooks + music.

## Example Use Cases

- First batch of UGC ads for a DTC product launch
- Hook split-test (3-5 variants, same body + CTA) for Meta Ads
- Testimonial scripts from real customer reviews
- Founder-story script for a new brand with no proof yet
- Comparison script against a named competitor
- Multi-platform campaign (same angle, different pacing per platform)
- Batch generation for a creative agency producing 20+ videos/week
