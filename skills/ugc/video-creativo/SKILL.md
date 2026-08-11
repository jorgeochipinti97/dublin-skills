---
name: video-creativo
description: "Flujo completo de producción de contenido en video: CONCEPTO → IDEA → GUION → ESCENAS. Soporta video corto (15-90 seg: ads, UGC, reels, shorts) y video largo (3-20 min: YouTube, curso, documental). Empieza siempre en el CONCEPTO estratégico (Single Minded Proposition, insight, desplazamiento de creencia) antes de cualquier escritura. Produce: brief de concepto, selección de ángulo creativo, guión formateado para el oído, y breakdown de escenas listo para producción. Handoff a ai-avatar-director (lipsync), ugc-video-prompting (generativo), o equipo de producción real."
---

# Video Creativo

Flujo de comunicación estratégica para video. Cubre las 4 capas en orden obligatorio:

```
CONCEPTO → IDEA → GUION → ESCENAS
```

Cada capa se construye sobre la anterior. Saltear el CONCEPTO produce un guión que parece funcionar pero no comunica nada específico. Saltear la IDEA produce un guión que dice lo correcto de la manera más obvia. Saltear el GUION produce escenas sin alma.

---

## Hard Rules

1. **Empezar siempre en CONCEPTO.** Sin brief de concepto aprobado, no se escribe una línea de guión.
2. **Un video = un mensaje.** Si hay dos mensajes, hay dos videos.
3. **El guión se escribe para el oído, no para el ojo.** Frases cortas. Contracciones. Sin construcciones de texto.
4. **El hook visual y el hook verbal son dos cosas distintas** — deben complementarse, no repetirse.
5. **El CTA es específico o no existe.** "Seguime para más contenido" = CTA nulo.
6. **Nunca inventar datos, testimonios o resultados sin marcar ⚠️.**

---

## Contexto Requerido

Antes de producir cualquier output, necesitamos:

### Si es contenido de marca — leer PRESSKIT.md primero

Si existe un `PRESSKIT.md` en la raíz del proyecto, leerlo antes de cualquier otra cosa. Alimenta directamente:
- El Filtro de Guión (QUÉ SÍ / QUÉ NO / TONO / PALABRAS)
- El Brief de Concepto (restricciones de claims, compliance)
- El Breakdown de Escenas (assets disponibles: intro, b-roll, música)

Si no existe PRESSKIT.md y es contenido de marca → crear uno primero con el skill `presskit`.

### Mínimo

1. **Producto / servicio / idea que comunicamos** — qué es, en una oración
2. **Audiencia target** — específica. No "emprendedores". Sí "founders de SaaS B2B con < 20 clientes que llevan 6+ meses sin tracción."
3. **Objetivo de comunicación** — qué queremos que piense / sienta / haga la audiencia después
4. **Prueba disponible (RTB)** — datos, historia real, demostración, credencial, caso de cliente
5. **Formato** — `corto` (15/30/60/90 seg) o `largo` (3/5/10/20 min)
6. **Plataforma** — TikTok / Instagram Reels / YouTube Shorts / YouTube / LinkedIn / Ads (Meta/Google) / otro
7. **Producción disponible** — avatar IA / grabación propia / generativo (Veo 3 / Seedance) / equipo real

### Opcional pero mejora el output

- Restricciones de marca / lo que no se puede decir
- Ejemplos de videos que les gustan como referencia
- Tensión o pain específico que escucharon de la audiencia
- Videos anteriores que ya hicieron (para no repetir)

**Si el usuario dice "inventá lo que falte":** proceder con ⚠️ en cada supuesto, confirmar al final.

---

## Flujo de Trabajo

### Capa 1 — CONCEPTO

**Cargar**: `references/concepto-framework.md`

Producir el **Brief de Concepto**:

```markdown
## Brief de Concepto

**Audiencia**: [específica]
**Tensión activa**: [el dolor / deseo sin resolver HOY]
**Insight**: [la verdad incómoda que todos sienten pero nadie dice]
**Desplazamiento de creencia**:
  - ANTES: [creencia actual]
  - DESPUÉS: [creencia que queremos instalar]
**SMP**: [Una sola oración — audiencia puede resultado si mecanismo]
**Razón para creer (RTB)**: [demostración / prueba social / autoridad / lógica / datos]
**Acción esperada**: [específica]
**Restricciones**: [lo que NO se puede decir o hacer]
```

**Gate**: el Brief de Concepto debe estar confirmado antes de pasar a IDEA. Si hay ambigüedad en el SMP, resolverla aquí.

---

### Capa 2 — IDEA

**Cargar**: `references/idea-angles.md`

1. **Definir el formato** de video (talking head / B-roll + VO / pantalla / híbrido)
2. **Seleccionar el ángulo** de los 12 disponibles — justificar por qué este ángulo match con el RTB
3. **Definir la imagen mental de los primeros 3 seg** — lo que la audiencia VE antes de que nadie hable
4. **Validar con la prueba de anclaje**: ¿esta IDEA sería imposible sin este SMP específico?

Output:

```markdown
## Idea Creativa

**Ángulo**: [nombre del ángulo — ej: "La Brecha de Curiosidad"]
**Justificación**: [por qué este ángulo para este concepto — 1 línea]
**Formato de video**: [talking head / b-roll + VO / pantalla / híbrido]
**Imagen mental (primeros 3 seg)**: [qué se VE, concreto y específico]
**Hook visual**: [lo que la cámara muestra — 1 línea]
**Hook verbal (primera línea de audio)**: [exactamente lo que se dice]
**Prueba de anclaje**: ✅ / ❌ [esta idea solo funciona con este SMP]
```

---

### Capa 3 — GUION

**Cargar**: `references/guion-estructura.md`

**Gate previo — Filtro de Guión (§0 del reference):**
Antes de escribir una línea, completar y confirmar:
- **QUÉ SÍ** — el SMP en una oración (viene del concepto)
- **QUÉ NO** — lista explícita de temas, frames, o emociones que no deben aparecer
- **TONO** — calibrado con la fórmula "como alguien que X, no como alguien que Y"
- **PALABRAS PROHIBIDAS** — las que rompen el tono o el concepto
- **PALABRAS CLAVE** — las que anclan el gancho

Sin filtro aprobado, no se escribe.

Producir el guión completo. Formato diferente según duración.

#### Para video CORTO (15-90 seg)

Estructura 4 partes:

```markdown
## Guión

**Formato**: [corto — Xseg]
**Palabras totales**: [N] (~X palabras/seg)
**Plataforma**: [plataforma]

---

[HOOK] (0-3 seg)
"[Primera línea — disruptiva, específica, para el scroll]"

[TENSIÓN] (3-15 seg)
"[El problema nombrado — en segunda persona cuando sea posible]"

[DESARROLLO] (15-X seg)
"[La idea en acción — proof, mecanismo, historia, según el ángulo]"

[CIERRE + CTA] (últimos 5-10 seg)
"[Remate que cierra el loop + CTA específico]"
```

#### Para video LARGO (3-20 min)

Estructura en bloques:

```markdown
## Guión

**Formato**: [largo — X min]
**Palabras totales**: [N]
**Plataforma**: [plataforma]

---

[HOOK INICIAL] (0-30 seg)
"[Hook que para el abandono temprano]"

[PROMESA] (30-90 seg)
"[Qué van a saber / poder / entender al terminar. Explícito.]"

---

[BLOQUE 1 — Nombre de la sección] (X min)
RE-HOOK: "[Por qué esta sección importa]"
CONTENIDO: "[...]"
EJEMPLO: "[...]"
TRANSICIÓN: "[Puente a bloque 2]"

[BLOQUE 2 — Nombre] (X min)
...

[SÍNTESIS] (últimos 2-3 min)
"[El patrón que une todo]"

[CTA FINAL] (último 1 min)
"[Una sola acción específica]"
```

---

### Capa 4 — ESCENAS

**Cargar**: `references/escenas-breakdown.md`

Traducir el guión a instrucciones de producción. Una escena por unidad visual.

```markdown
## Breakdown de Escenas

**Video**: [nombre]
**Duración total**: [X seg / X min]
**Escenas totales**: [N]

---

### ESCENA 1 — [Nombre descriptivo]
**Tipo**: [Talking Head / B-roll / Pantalla / Texto]
**Duración**: [X seg]
**Timing**: [0-X seg]

VISUAL: [qué se ve — encuadre, sujeto, acción]
AUDIO: "[línea exacta del guión]"
ON-SCREEN: [texto en pantalla si aplica — máx 5-6 palabras]
ENTRADA: [corte directo / fade / desde anterior]
SALIDA: [corte / fade / zoom]
NOTA: [dirección si aplica]

---
[repetir por cada escena]

---

## B-Roll List
- [ ] [descripción de toma necesaria]
- [ ] [...]

## Shot List (Talking Head)
- [ ] [encuadre — CU / MS / MW]
- [ ] [...]

## Audio
MÚSICA: [tipo / momento / volumen]
SFX: [lista por momento]
VO / PRESENTADOR: [tono / notas específicas]
```

---

## Handoff

Después de ESCENAS, según la producción disponible:

| Producción | Siguiente skill |
|---|---|
| Avatar IA (HeyGen / Hedra / Arcads) | → `ai-avatar-director` (director brief completo) |
| Video generativo (Veo 3 / Seedance) | → `ugc-video-prompting` (prompts por escena) |
| Equipo real / auto-filmación | → El breakdown de escenas es el shot list de rodaje |
| Post-producción (cualquiera) | → `ugc-post-production` (EDL: captions, B-roll, música, SFX) |

---

## Anti-Patrones

### En CONCEPTO
- Concepto = feature o tagline (no hay insight ni desplazamiento)
- Dos mensajes en un video
- Insight fabricado que no es real para la audiencia

### En IDEA
- Idea que podría servir para cualquier otro concepto (no está anclada)
- Hook que necesita contexto para entenderse
- Imagen mental vaga ("una persona hablando sobre su experiencia")

### En GUION
- Apertura con "Hola, soy X y en este video..."
- CTA genérico: "Seguime para más contenido"
- Frases escritas para el ojo, no para el oído
- Dos mensajes compitiendo en el mismo guión

### En ESCENAS
- Escenas sin duración definida
- B-roll vago ("footage de la empresa")
- Texto en pantalla que transcribe el audio palabra por palabra
- Falta de instrucciones de tono / actuación cuando son no-obvias

---

## Reference Loading

- `references/concepto-framework.md` — brief de concepto, SMP, insight, desplazamiento de creencia, RTB, errores comunes (cargar en Capa 1 — siempre)
- `references/idea-angles.md` — 12 ángulos creativos con mecánica y ejemplo, selección por RTB, prueba de anclaje, hook visual vs verbal (cargar en Capa 2)
- `references/guion-estructura.md` — estructura para corto (4 partes) y largo (bloques + re-hooks), velocidad de habla por formato, formato físico del guión, reglas de escritura para el oído (cargar en Capa 3)
- `references/escenas-breakdown.md` — template de escena, tipos de escena, shot list, B-roll list, texto en pantalla, audio/música/SFX, end card (cargar en Capa 4)
