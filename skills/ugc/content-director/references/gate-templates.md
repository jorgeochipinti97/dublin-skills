# Gate Templates — Puntos de Aprobación

Los gates son los únicos momentos donde el director para y espera al cliente. Entre gates, el director trabaja sin interrupciones.

Regla: **máximo 3 gates por pipeline**. Más gates = el cliente hace el trabajo en vez del director.

---

## Cuándo Gatear (y cuándo NO)

### Gates obligatorios

| Gate | Cuándo | Por qué es obligatorio |
|---|---|---|
| **Gate 1 — Gancho** | Después de gancho-argumental | El gancho es la dirección de todo. Si el cliente elige el equivocado, todo lo que sigue está mal. |
| **Gate 2 — SMP** | Después de CONCEPTO | El SMP es el único mensaje del video. Si no está bien, el guion está mal sin importar cuán bien esté escrito. |
| **Gate 3 — Guion** | Después de GUION | El guion es lo que el cliente va a grabar / el avatar va a decir. Es el punto de no-retorno práctico. |

### NO gatear en

- Selección del ángulo creativo (IDEA) — el director elige, el cliente lo ve en el guion
- Filtro de guion — es interno, el cliente no tiene que aprobarlo
- Breakdown de escenas — si el guion está aprobado, las escenas son derivativas
- Configuración del avatar director — técnico, no estratégico
- Post-producción — el cliente ve el output final, no el EDL intermedio

---

## Formato de Cada Gate

### GATE 1 — Elección de Gancho

```markdown
---
## 🎯 Gate 1 — Elegir el Gancho

Encontré [N] ganchos potenciales para "[tema]". 
El video va a construirse alrededor de **uno solo**.

### Gancho recomendado
**[Tipo]: [El gancho en 15 palabras]**

> "[Formulación exacta como quedaría en el hook del video]"

Por qué este: [una línea — qué emoción activa, por qué es el más fuerte]
Fuentes: [referencias verificadas]

### Alternativas
**Opción B — [Tipo]**: "[formulación]"
**Opción C — [Tipo]**: "[formulación]"

---
¿Seguimos con el recomendado, preferís otra opción, o ajustamos la formulación?
```

**Lo que el director necesita del cliente**: "el recomendado" / "la B" / "la C" / "ajustar X". Nada más.

---

### GATE 2 — Aprobación del SMP

```markdown
---
## 🎯 Gate 2 — El mensaje único

Antes de escribir una sola línea del guion, necesito que confirmes el mensaje central.

**Este video va a instalar una sola idea en la mente del espectador:**

> "[SMP completo]"

**Lo que el espectador va a pensar antes del video:**
"[creencia actual]"

**Lo que va a pensar después:**
"[creencia nueva]"

**Lo que NO vamos a decir en este video:**
- [QUÉ NO 1]
- [QUÉ NO 2]
- [QUÉ NO 3]

**Tono:** "[fórmula calibrada]"

---
¿Aprobás este mensaje o hay algo que ajustar antes de escribir?
```

**Lo que el director necesita**: "aprobado" / "cambiar X" / "el tono debería ser más Y". Nada más.

---

### GATE 3 — Aprobación del Guion

```markdown
---
## 🎯 Gate 3 — El Guion

**Formato**: [corto/largo] · **Duración estimada**: [X seg / X min] · **~[N] palabras**

---

[GUION COMPLETO]

---

**Checklist interno:**
- ✅ Hook en 3 seg
- ✅ SMP respetado
- ✅ QUÉ NO: ninguno de los temas prohibidos aparece
- ✅ Tono: "[calibración]"
- ✅ CTA específico: "[el CTA exacto]"
- ✅ Palabras prohibidas: ninguna detectada

---
¿Aprobás el guion, querés ajustar algo, o preferís revisar una sección específica?

Cuando confirmes, produzco el breakdown de escenas y sigo con la producción.
```

**Lo que el director necesita**: "aprobado" / "cambiar [sección específica]" / "el hook está bien pero el cierre no". Nada más.

---

## Manejo de Feedback en Gates

### Si el cliente aprueba sin cambios
→ Continuar al siguiente stage inmediatamente, sin pausa ni confirmación adicional.

### Si el cliente pide un ajuste específico
→ Aplicar el ajuste, mostrar el delta (no el documento completo de nuevo), confirmar.
→ Formato: "Ajusté [qué]. ¿Seguimos?"

### Si el cliente rechaza y pide algo diferente
→ En Gate 1: generar 2 nuevas opciones de gancho + justificación.
→ En Gate 2: revisar el SMP con el input del cliente, una sola propuesta nueva.
→ En Gate 3: identificar la sección exacta, reescribir solo esa sección.

**Nunca reescribir el documento entero por feedback general** ("no me convence del todo"). Preguntar: "¿Qué parte específicamente?" Si no pueden señalarlo, el problema suele estar en el CONCEPTO, no en el guion.

### Si el cliente quiere cambiar algo de un gate anterior desde un gate posterior
→ "Para cambiar [el gancho / el SMP], tengo que volver a ese punto y reconstruir lo que viene después. ¿Confirmás que querés hacer ese cambio?"
→ Aplicar el cambio y regenerar las capas que dependen de él.

---

## El Informe de Arranque (antes del Gate 1)

El primer output del director — antes de correr cualquier skill — es el plan:

```markdown
---
## 📋 Plan de Producción

**Brief**: "[lo que entendí del pedido del cliente]"
**Tipo**: [con marca / sin marca] · **Formato**: [corto/largo] · **Plataforma**: [plataforma]
**Producción**: [avatar / generativo / equipo / TBD]

**Pipeline que voy a correr:**

1. [✅ PRESSKIT — leer] / [🔄 PRESSKIT — crear] / [— no aplica]
2. [🔄 GANCHO ARGUMENTAL — buscar] / [✅ GANCHO — ya definido por el cliente]
3. 🔄 VIDEO CREATIVO — CONCEPTO → IDEA → FILTRO → GUION → ESCENAS
4. 🔄 [ai-avatar-director / ugc-video-prompting / shot list]
5. 🔄 UGC POST-PRODUCTION

**Gates de aprobación**: [N] puntos donde voy a pausar para tu input
**Tiempo estimado**: [X-Y minutos en total]

---
¿Arrancamos o querés ajustar algo del plan primero?
```

Si el cliente aprueba el plan → arrancar sin más.
Si el cliente quiere ajustar → aplicar el ajuste al plan antes de arrancar.

---

## Comunicación Durante el Proceso (sin gates)

Entre gates, el director trabaja sin interrumpir. Puede emitir **updates de progreso** — una línea, no una pregunta:

```
→ Buscando ganchos en 8 dimensiones...
→ Encontré 4 ganchos relevantes. Clasificando...
→ Escribiendo el CONCEPTO a partir del gancho elegido...
→ Filtro de guión completado. Escribiendo el guion...
→ Guion listo. Preparando para Gate 3...
```

Estos updates son informativos, no solicitudes de aprobación. El cliente no tiene que responder.
