# Pipeline Decision Tree

Determina qué stages correr y en qué orden a partir del brief del cliente. El director corre este árbol antes de hacer cualquier otra cosa.

---

## Árbol de Decisión

### Nodo 1 — ¿Es contenido de marca o contenido de tema libre?

**Marca** = hay un brand/empresa/producto detrás del video. Tiene identidad, reglas, assets.
**Tema libre** = persona/creador hablando de un tema. No hay brand guidelines.

```
¿Es contenido de marca?
├── SÍ → Nodo 2A (branch con PRESSKIT)
└── NO → Nodo 2B (branch sin PRESSKIT)
```

### Nodo 2A — Branch con PRESSKIT

```
¿Existe PRESSKIT.md en el proyecto?
├── SÍ → leer PRESSKIT.md → Nodo 3
└── NO → correr `presskit` (Modo A — crear) → confirmar → Nodo 3
```

### Nodo 2B — Branch sin PRESSKIT

```
→ Saltar directo a Nodo 3 (sin presskit)
```

### Nodo 3 — ¿El cliente tiene un gancho ya o solo tiene un tema?

**Gancho** = ya saben la tensión/paradoja/ironía que quieren explotar
**Tema** = saben de qué quieren hablar pero no el ángulo que lo hace viral

```
¿El cliente trae un gancho argumental?
├── SÍ → registrar el gancho → Nodo 4
└── NO → correr `gancho-argumental` → presentar hallazgos → elegir gancho → Nodo 4
```

Señales de que NO tiene gancho:
- "quiero hacer un video sobre [tema]" sin más
- El ángulo que propone es el obvio/superficial (el Mundial 78 = "Argentina ganó el mundial")
- No hay tensión, paradoja, ni dato oculto en lo que describe

Señales de que SÍ tiene gancho:
- Describe una ironía o contradicción específica
- Menciona un dato concreto que cambia la lectura del tema
- Ya sabe la historia que quiere contar y por qué importa más de lo que parece

### Nodo 4 — ¿Qué formato tiene el video?

```
¿Formato?
├── CORTO (15-90 seg): Reels / TikTok / Shorts / Ad → Pipeline Corto
└── LARGO (3-20 min): YouTube / Webinar / Curso → Pipeline Largo
```

Si no lo especificó: preguntar ahora (única pregunta pendiente antes de correr).

### Nodo 5 — ¿Qué producción va a usar?

```
¿Tipo de producción?
├── Avatar IA (HeyGen/Hedra/Arcads) → producción: `ai-avatar-director`
├── Video generativo (Veo 3 / Seedance) → producción: `ugc-video-prompting`
├── Grabación propia / equipo real → producción: breakdown de escenas como shot list
└── Sin decisión aún → registrar como "TBD" y el director pregunta al final de GUION
```

---

## Los Pipelines Resultantes

### Pipeline A — Marca + Sin gancho + Corto + Avatar

```
presskit (si no existe)
    ↓
gancho-argumental
    ↓ [GATE: elegir gancho]
video-creativo / CONCEPTO
    ↓ [GATE: aprobar SMP]
video-creativo / IDEA
    ↓
video-creativo / FILTRO DE GUION (alimentado por presskit)
    ↓
video-creativo / GUION
    ↓ [GATE: aprobar guion]
video-creativo / ESCENAS
    ↓
ai-avatar-director
    ↓
ugc-post-production
```

### Pipeline B — Sin marca + Con gancho + Corto + Generativo

```
gancho-argumental (validar y expandir el gancho del cliente)
    ↓
video-creativo / CONCEPTO
    ↓ [GATE: aprobar SMP]
video-creativo / IDEA + FILTRO DE GUION
    ↓
video-creativo / GUION
    ↓ [GATE: aprobar guion]
video-creativo / ESCENAS
    ↓
ugc-video-prompting
    ↓
ugc-post-production
```

### Pipeline C — Sin marca + Sin gancho + Largo + Grabación propia

```
gancho-argumental
    ↓ [GATE: elegir gancho]
video-creativo / CONCEPTO
    ↓ [GATE: aprobar SMP]
video-creativo / IDEA + FILTRO DE GUION
    ↓
video-creativo / GUION (estructura larga con bloques + re-hooks)
    ↓ [GATE: aprobar guion]
video-creativo / ESCENAS (breakdown completo como shot list)
    ↓
[entrega: guion + shot list para equipo de producción]
ugc-post-production (post-producción)
```

### Pipeline D — Marca + Con gancho + Cualquier formato

```
presskit (leer si existe, crear si no)
    ↓
[gancho ya definido — registrar, no correr gancho-argumental]
video-creativo / CONCEPTO (alimentado por gancho + presskit)
    ↓ [GATE: aprobar SMP]
video-creativo / IDEA + FILTRO DE GUION (presskit → QUÉ SÍ/NO/TONO)
    ↓
video-creativo / GUION
    ↓ [GATE: aprobar guion]
video-creativo / ESCENAS
    ↓
[producción según tipo]
    ↓
ugc-post-production
```

---

## Tiempos Estimados por Stage

Para comunicarle al cliente cuánto va a tardar el proceso:

| Stage | Tiempo estimado |
|---|---|
| Intake + árbol de decisión | 2-5 min |
| presskit (crear) | 10-20 min |
| gancho-argumental | 10-20 min |
| video-creativo CONCEPTO | 5-10 min |
| video-creativo IDEA + FILTRO | 5 min |
| video-creativo GUION (corto) | 5-10 min |
| video-creativo GUION (largo) | 15-30 min |
| video-creativo ESCENAS | 5-15 min |
| ai-avatar-director | 5-10 min |
| ugc-video-prompting | 5-10 min |
| ugc-post-production | 5-10 min |

**Pipeline completo corto (A o B)**: 45-90 min de trabajo concentrado con gates.
**Pipeline completo largo (C)**: 60-120 min.
