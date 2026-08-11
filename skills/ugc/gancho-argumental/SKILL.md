---
name: gancho-argumental
description: "Investigación web sistemática para encontrar ganchos argumentales — la capa de tensión, ironía, paradoja o dato oculto que convierte un tema en una historia. Input: tema + audiencia + plataforma. Output: brief de investigación con hallazgos etiquetados por tipo de gancho (ironía contextual, dato que reencuadra, personaje olvidado, protesta silenciada, paradoja moral, etc.) y rankeados por potencial viral. Alimenta directamente el CONCEPTO de video-creativo. Usa búsqueda web real — no genera datos de memoria."
---

# Gancho Argumental

Investigación web para encontrar la capa de significado que transforma un tema en una historia.

El tema es lo que la audiencia espera. El gancho es por qué van a compartir el video.

**El ejemplo fundacional**: no es "el Mundial 78 Argentina". Es "el Mundial 78 se celebraba mientras la dictadura desaparecía personas a 2 km del estadio". La diferencia entre esas dos formulaciones es exactamente lo que esta skill busca.

---

## Hard Rules

1. **Nunca generar datos de memoria.** Buscar en la web. Si un dato no tiene fuente verificable, marcarlo `⚠️ VERIFICAR`.
2. **Dos fuentes por dato** antes de clasificarlo como verificado.
3. **Un gancho principal** por brief. Puede haber secundarios como contexto, pero el video se construye alrededor de uno.
4. **El gancho tiene que ser verificable** — un gancho que no se puede defender en comentarios destruye la credibilidad del canal.
5. **Buscar en al menos 2 idiomas** para temas históricos o internacionales.

---

## Contexto Requerido

Antes de buscar:

1. **Tema central** — el evento, persona, o fenómeno que el video va a tratar
2. **Ángulo inicial** — lo que ya saben / lo que ya iban a decir sin esta investigación
3. **Audiencia** — quién va a ver el video (específico)
4. **Plataforma** — Instagram / TikTok / YouTube / LinkedIn / otro
5. **Formato** — corto (15-90 seg) o largo (3-20 min)
6. **Tono buscado** — denuncia / asombro / reflexión / ironía / educativo

Opcional: país/región de la audiencia, idioma del video, restricciones de contenido sensible.

---

## Flujo de Trabajo

### Fase 1 — Mapeo de dimensiones

Cargar `references/search-playbook.md`.

Identificar las 8 dimensiones aplicables al tema:
1. Contexto político / histórico simultáneo
2. Personajes que la historia ignoró
3. Números reales (no redondos, no los populares)
4. Protestas, resistencias, voces en contra del momento
5. Documentos ahora disponibles (desclasificados, archivos, investigaciones)
6. Contexto cultural de la época
7. Consecuencias no obvias (long tail)
8. Comparaciones que incomodan

Para cada dimensión: definir las queries concretas antes de buscar.

### Fase 2 — Búsqueda sistemática

Ejecutar búsquedas web reales. Para cada dimensión: mínimo 2-3 queries.

Por cada resultado relevante:
- Guardar la URL exacta
- Extraer el dato específico (no el artículo entero — la pieza de información)
- Verificar con segunda fuente

### Fase 3 — Clasificación y ranking

Cargar `references/hook-taxonomy.md`.

Para cada hallazgo:
1. Clasificar el tipo de gancho (de los 11)
2. Aplicar los 4 tests de calidad (ascensor / tensión / verificabilidad / audiencia)
3. Puntuar potencial viral (★1-5)
4. Definir rol en el video (gancho principal / contexto / apoyo / CTA)

### Fase 4 — Brief de investigación

Producir el output estructurado.

---

## Output — Brief de Investigación

```markdown
# Brief de Investigación: [Tema]

**Tema**: [el evento / persona / fenómeno]
**Ángulo original** (lo que se iba a decir sin esta investigación): [...]
**Plataforma**: [...]  **Formato**: [corto/largo]  **Audiencia**: [...]

---

## Gancho Principal Recomendado

**Tipo**: [nombre del gancho]
**El gancho en 15 palabras**: "[formulación exacta — como quedaría en el hook del video]"
**Por qué este**: [una línea — qué emoción activa, por qué es el más fuerte]
**Potencial viral**: ★★★★★

**Hallazgo**:
[El dato / hecho / tensión — expandido, con contexto mínimo]

**Fuentes**:
- [URL fuente 1]
- [URL fuente 2]

**Verificado**: ✅ / ⚠️ [nota si requiere verificación adicional]

---

## Ganchos Secundarios (capas de profundidad)

### Gancho 2 — [Tipo]
**El dato**: [una oración]
**Fuente**: [URL]
**Verificado**: ✅ / ⚠️
**Potencial viral**: ★★★★☆
**Rol sugerido**: [contexto / apoyo / CTA / siguiente video]

### Gancho 3 — [Tipo]
[mismo formato]

[repetir hasta cubrir los hallazgos relevantes]

---

## Datos de Apoyo Verificados

Lista de datos concretos (no ganchos en sí, pero útiles para el guión):

- [dato específico] — Fuente: [URL]
- [dato específico] — Fuente: [URL]
- [dato específico] — Fuente: [⚠️ verificar — una sola fuente]

---

## Dimensiones Sin Hallazgos Relevantes

[Lista de dimensiones que se exploraron y no produjeron ganchos útiles — para transparencia]

---

## Handoff a video-creativo

El gancho principal alimenta directamente:
- **Insight** del Brief de Concepto: [formulación del insight]
- **Desplazamiento de creencia**: ANTES "[creencia común]" → DESPUÉS "[creencia nueva]"
- **SMP sugerido**: "[audiencia] puede [resultado] si [entiende este gancho]"
- **RTB disponible**: [qué prueba tenemos — documentos, datos verificados, testimonios]
```

---

## Ejemplo de Aplicación — Mundial 78

**Input del usuario**: "quiero hacer un video para IG sobre el mundial 78, se cumplen 40 años" (nota: son 47 años en 2025 desde 1978)

**Ángulo original sin investigación**: "Argentina ganó el Mundial 78 en casa" → contenido de fútbol estándar

**Después de búsqueda sistemática** — Gancho principal identificado:

> "El mundial se celebraba mientras la ESMA, el mayor centro de detención y tortura de la dictadura, operaba a menos de 2 km del estadio Monumental donde se jugó la final."

**Tipo**: Ironía contextual ★★★★★

**Ganchos secundarios encontrados**:
- Personaje olvidado: César Menotti, un marxista declarado, dirigía la selección de la dictadura
- Protesta silenciada: Johan Cruyff rechazó ir al mundial en protesta — Holanda llegó a la final sin él
- Dato que reencuadra: Argentina le ganó 6-0 a Perú en el partido que necesitaba para pasar. Perú necesitaba perder por 4+. El arquero peruano había nacido en Argentina. El régimen peruano recibió un crédito argentino semanas antes.
- Paradoja moral: La FIFA tenía informes de Amnesty International sobre las violaciones de derechos humanos antes del torneo y eligió no intervenir.

---

## Relación con el Pipeline de Video

Este skill es la **capa de investigación previa** al CONCEPTO de `video-creativo`.

```
gancho-argumental (investigación)
        ↓
   Brief de investigación
        ↓
video-creativo → CONCEPTO (alimentado por el gancho)
                → IDEA (el ángulo creativo para comunicar ese gancho)
                → GUION
                → ESCENAS
        ↓
ai-avatar-director / ugc-video-prompting
        ↓
ugc-post-production
```

El gancho principal se convierte en el **insight** y en la base del **SMP** del Brief de Concepto.

---

## Anti-Patrones

- **Usar datos de memoria sin verificar** — el dato que "todo el mundo sabe" puede ser incorrecto o inexacto
- **El gancho sensacionalista sin sustancia** — el hook promete más de lo que el video puede justificar con fuentes
- **Múltiples ganchos principales** — elegir uno; los demás son capas
- **Mezclar gancho con opinión** — el gancho debe ser un hecho verificable, no una interpretación. La interpretación va en el guión.
- **Inventar la conexión** — si hay que forzar la relación entre dos hechos, no es un gancho real
- **No guardar las fuentes** — cuando la audiencia cuestione el dato en comentarios, la fuente es la credibilidad

---

## Reference Loading

- `references/hook-taxonomy.md` — 11 tipos de gancho argumental con definición, por qué viraliza, ejemplos reales, potencial viral, y señales de detección (cargar siempre — es el marco conceptual)
- `references/search-playbook.md` — 8 dimensiones de búsqueda con queries modelo, protocolo de verificación, tests de calidad del gancho, formato de hallazgo (cargar siempre — es el método de trabajo)
