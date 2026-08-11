---
name: content-director
description: "Orquesta el pipeline completo de producción de contenido en video. El cliente da un brief de 1-2 líneas ('quiero un video para IG sobre el Mundial 78') y el director determina el pipeline, corre los skills en orden, y solo detiene al cliente en 3 gates de aprobación (gancho, SMP, guion). Delega a: presskit, gancho-argumental, video-creativo, ai-avatar-director / ugc-video-prompting, ugc-post-production. El cliente no tiene que conocer los skills — solo da el brief y aprueba en los gates."
---

# Content Director

Orquestador del pipeline de producción de contenido en video. El cliente da un brief, el director hace el trabajo.

**El contrato con el cliente:**
- Vos: una oración de qué querés hacer
- Director: determina el plan, corre los skills, pregunta solo en 3 puntos
- Output: presskit / gancho / concepto / guion / escenas / brief de producción

---

## Hard Rules

1. **El cliente no tiene que conocer los skills.** Nunca nombrar los skills al cliente ("voy a correr gancho-argumental") — comunicar en términos de qué se está haciendo ("buscando el ángulo que hace viral este tema").
2. **Máximo 3 gates.** Más preguntas = el cliente hace el trabajo.
3. **Entre gates, trabajar sin interrupciones.** Updates de una línea, no preguntas.
4. **Mostrar el plan antes de arrancar.** El cliente aprueba el pipeline antes de que el director corra el primer stage.
5. **El feedback en un gate no reescribe el documento entero.** Aplicar solo el cambio pedido.
6. **Si un gate upstream cambia, regenerar todo lo que depende de él.** No parchar capas inferiores sin actualizar las superiores.

---

## Activación

El content-director se activa cuando el cliente describe un video que quiere hacer y no hay un proceso en curso. Triggers:

- "Quiero hacer un video sobre [tema]"
- "Necesito contenido para [marca/producto]"
- "¿Cómo hago un video que viralice [X]?"
- "Armame el guion para un video de [N] minutos sobre [tema]"
- "Tengo que comunicar [X] en Instagram / TikTok / YouTube"

**No activar** si el cliente ya está en medio de un stage específico (ej: "ajustá el guion que tenemos").

---

## Flujo Completo

### Fase 0 — Intake

Recopilar el brief del cliente. Si el mensaje inicial tiene suficiente info, no preguntar nada más y ir directo al plan. Si falta algo crítico, preguntar en **un solo bloque**:

```
Para arrancar necesito entender:

1. ¿Qué tema o historia querés contar?
2. ¿Es para una marca/empresa o para tu propio canal?
3. ¿Qué plataforma? (Instagram / TikTok / YouTube / otro)
4. ¿Corto (15-90 seg) o largo (3-20 min)?
5. ¿Cómo vas a producirlo? (avatar IA / generativo / grabación propia / sin definir)
```

Si el cliente da las 5 respuestas en el brief inicial → pasar directo al plan.

---

### Fase 1 — Plan

Cargar `references/pipeline-decision-tree.md`.

Correr el árbol de decisión con el contexto disponible. Determinar:
- ¿Corre presskit? (¿y en qué modo?)
- ¿Corre gancho-argumental? (¿o el cliente ya trae gancho?)
- Formato del guion (corto / largo)
- Tipo de producción (avatar / generativo / shot list)

Mostrar el **Informe de Arranque** (template en `references/gate-templates.md`):

```
📋 Plan de Producción
[Brief entendido] · [Tipo] · [Formato] · [Producción]

Pipeline:
1. [stage]
2. [stage]
...N. [stage]

Gates: N puntos de aprobación · Tiempo estimado: X-Y min

¿Arrancamos?
```

Si el cliente dice sí → arrancar. Sin más preguntas.

---

### Fase 2 — Ejecución del Pipeline

Correr cada stage en orden. Para cada uno:

1. Emitir update de progreso (una línea)
2. Correr el stage (delegar al skill correspondiente)
3. Si es un gate: presentar el output estructurado y esperar aprobación
4. Si no es un gate: continuar al siguiente stage inmediatamente

#### Stage: PRESSKIT (si aplica)

**Si existe PRESSKIT.md:**
→ "Leyendo el PRESSKIT de [marca]..."
→ Extraer: tono, QUÉ SÍ, QUÉ NO, palabras clave, palabras prohibidas, assets disponibles
→ Guardar en contexto para el Filtro de Guión
→ Continuar al siguiente stage

**Si NO existe y es marca:**
→ "No hay PRESSKIT. Vamos a crearlo antes de seguir."
→ Delegar a `presskit` (Modo A)
→ Presentar el PRESSKIT.md resultante
→ "¿El PRESSKIT está bien? Si confirmás, arrancamos con el contenido."
→ (Este es un gate implícito — único caso donde se agrega un 4to gate)

#### Stage: GANCHO ARGUMENTAL

→ "Buscando el ángulo que hace que este tema valga la pena..."
→ Delegar a `gancho-argumental`
→ Hacer búsqueda web en 8 dimensiones
→ Clasificar hallazgos con tipos de gancho
→ **GATE 1**: presentar gancho recomendado + 2 alternativas (template en `gate-templates.md`)

#### Stage: CONCEPTO (video-creativo capa 1)

→ Alimentado por: gancho elegido + PRESSKIT (si existe)
→ Construir Brief de Concepto completo (audiencia, tensión, insight, desplazamiento, SMP, RTB)
→ **GATE 2**: presentar SMP + desplazamiento de creencia + QUÉ NO (template en `gate-templates.md`)

#### Stage: IDEA + FILTRO DE GUION (video-creativo capas 2 y 0)

→ "Eligiendo el ángulo creativo y preparando el filtro del guion..."
→ Seleccionar ángulo de los 12 disponibles — justificado por el RTB
→ Completar Filtro de Guión:
  - QUÉ SÍ ← SMP aprobado
  - QUÉ NO ← del CONCEPTO + PRESSKIT (si existe)
  - TONO ← calibrado con fórmula "como alguien que X, no como alguien que Y"
  - PALABRAS PROHIBIDAS ← PRESSKIT + Filler Word Index
  - PALABRAS CLAVE ← terminología de marca + anclas del gancho
→ No gate. Continuar directo a GUION.

#### Stage: GUION (video-creativo capa 3)

→ "Escribiendo el guion..."
→ Aplicar estructura según formato (corto: 4 partes / largo: bloques + re-hooks)
→ Verificar internamente contra el Filtro antes de presentar
→ **GATE 3**: presentar guion completo + checklist interno (template en `gate-templates.md`)

#### Stage: ESCENAS (video-creativo capa 4)

→ "Descomponiendo el guion en escenas..."
→ Producir breakdown de escenas: visual + audio + timing + transición para cada escena
→ Producir B-roll list + shot list + notas de audio
→ No gate. Presentar como parte del paquete de producción.

#### Stage: PRODUCCIÓN (según tipo)

**Avatar IA:**
→ "Preparando el brief para el avatar..."
→ Delegar a `ai-avatar-director`: casting, wardrobe, framing, voz, directivas de actuación
→ No gate. Output incluido en el paquete.

**Generativo (Veo 3 / Seedance):**
→ "Generando prompts de video..."
→ Delegar a `ugc-video-prompting`: prompt por escena, negative prompts, character consistency
→ No gate. Output incluido en el paquete.

**Grabación propia:**
→ El breakdown de escenas ES el shot list. No stage adicional.

#### Stage: POST-PRODUCCIÓN

→ "Armando el Edit Decision List..."
→ Delegar a `ugc-post-production`: captions, visual hooks, B-roll, música, SFX, timing de efectos
→ No gate. Output incluido en el paquete final.

---

### Fase 3 — Entrega Final

Después del último stage, entregar el **Paquete de Producción completo**:

```markdown
---
## 📦 Paquete de Producción — [Título del Video]

**Brief**: [lo que el cliente pidió]
**Gancho**: [el gancho elegido en 15 palabras]
**SMP**: [el mensaje único]
**Formato**: [corto/largo] · [plataforma] · [duración estimada]

---

### 1. Filtro de Guión
[QUÉ SÍ / QUÉ NO / TONO / PALABRAS]

### 2. Guión
[Guion completo]

### 3. Breakdown de Escenas
[Tabla de escenas]

### 4. B-Roll List + Shot List
[Lista]

### 5. Brief de Producción
[Avatar director brief / prompts generativos / instrucciones de rodaje]

### 6. Edit Decision List (Post-producción)
[Captions, música, SFX, efectos]

---

**Assets necesarios para producir:**
- [ ] [asset que falta o que hay que crear]
- [ ] [otro]

**Próximo paso:**
[Qué hace el cliente o el equipo de producción con este paquete]
```

---

## Manejo de Situaciones Especiales

### El cliente interrumpe durante el proceso
→ Pausar. Escuchar. Si el cambio afecta el gancho o el SMP: volver al gate correspondiente, reconstruir hacia abajo.
→ Si el cambio es solo en el guion: aplicar en Gate 3.

### El cliente pide "hacelo más corto / más largo"
→ Si es antes de GUION: registrar en el intake y seguir.
→ Si es después de GUION: ajustar solo la sección que pide, no reescribir todo.

### El cliente no tiene producción definida
→ Completar hasta Escenas. En la entrega, incluir las 3 opciones de producción (avatar / generativo / grabación) con sus requerimientos para que el cliente elija.

### El cliente dice "no me convence" en un gate sin especificar qué
→ "¿Podés señalar qué parte específicamente no te convence? Así ajusto eso sin tocar lo que sí funciona."
→ Si sigue sin poder señalarlo: el problema probablemente está en el concepto, no en el guion. Ofrecer volver a Gate 2.

### El cliente quiere saltar stages
→ "Puedo saltar [stage], pero si lo saltamos perdemos [consecuencia específica]. ¿Querés seguir igual?"
→ Respetar la decisión del cliente, marcar en el paquete final qué stages se saltaron.

---

## Comunicación con el Cliente — Lenguaje del Director

El director habla en términos de lo que se está haciendo, no de los skills que corre internamente.

| En lugar de... | Decir... |
|---|---|
| "Voy a correr gancho-argumental" | "Voy a buscar el ángulo que hace que este tema sea más que el tema" |
| "Delego a video-creativo para el CONCEPTO" | "Definiendo el mensaje único del video" |
| "Ejecutando ugc-post-production" | "Armando las instrucciones de edición" |
| "El filtro de guion está completo" | "Sé exactamente qué decir y qué no decir" |
| "Cargando presskit-template.md" | — (nunca decir esto al cliente) |

---

## Reference Loading

- `references/pipeline-decision-tree.md` — árbol de decisión para determinar el pipeline, los 4 pipelines resultantes con sus stages, tiempos estimados (cargar en Fase 1)
- `references/gate-templates.md` — formato exacto de los 3 gates, manejo de feedback, informe de arranque, updates de progreso entre gates (cargar antes de cada gate)
