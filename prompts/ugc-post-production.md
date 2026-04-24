# ugc-post-production

## Activation Prompts

```
EDL para este crudo + script: [refs]
```

```
Plan de edición: captions + B-roll + música para [producto], [platform]
```

```
Post-production EDL for this approved avatar render
```

```
Qué FX y cuándo para este video UGC de [duration]s en TikTok
```

```
Style guide de captions + música para brand voice [premium/friendly/...]
```

## Flow

1. Pass in the script + avatar crudo (link / file ref).
2. The skill blocks if platform, brand voice, B-roll availability, or music license is missing.
3. Output is an Edit Decision List (EDL) with time / beat / cut / FX / caption / B-roll / SFX / music / WHY per row.
4. Editor executes the EDL in CapCut / Premiere / DaVinci / Remotion.
5. QA the first cut against the EDL's `Why` column — anything without a reason gets cut.

## Example Use Cases

- First-pass EDL for a new UGC ad after crudo approval
- Multi-platform adaptation (same crudo, different EDL per platform)
- Caption style guide for a brand's ongoing UGC output
- FX rescue — crudo is flat, needs energy without re-rendering
- Music selection + sync plan for a 30-video batch
- Brand-voice alignment review (existing edits are off-brand)
- Export-spec standardization across agency deliverables
