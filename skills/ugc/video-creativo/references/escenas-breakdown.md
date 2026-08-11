# Escenas — Breakdown de Producción Profesional

El breakdown de escenas es el documento que une la visión creativa con la realidad de producción. Si el guion es lo que se dice, el breakdown es lo que se hace, cómo se filma, y cómo se edita.

Un breakdown profesional lo puede leer:
- Un director de fotografía que nunca vio el proyecto
- Un editor que empieza el corte sin haber estado en el rodaje
- Un motion designer que necesita saber dónde van los gráficos
- Un avatar IA / sistema generativo que necesita instrucciones exactas

---

## 1. Sistema de Nomenclatura

Cada escena tiene un código único. Nunca numeración simple (1, 2, 3) — eso no sobrevive revisiones.

### Formato del código de escena

```
[TIPO]-[NÚMERO]-[VARIANTE]
```

| Campo | Valores | Ejemplo |
|---|---|---|
| TIPO | TH (talking head) / BR (b-roll) / SC (screencast) / TX (texto/motion) / TR (transición) | TH |
| NÚMERO | 01-99 (con cero adelante) | 03 |
| VARIANTE | A (principal) / B (alternativa) / R (reshooting) | A |

**Ejemplo**: `TH-03-A` = Talking head, escena 3, versión principal

Cuando hay revisiones: `TH-03-B` reemplaza a `TH-03-A`. La A queda como registro, la B es la vigente.

### Nomenclatura del documento

```
[PROYECTO]-BREAKDOWN-v[VERSION]-[FECHA].md
```

Ejemplo: `MUNDIAL78-BREAKDOWN-v2-20260625.md`

---

## 2. Tipos de Escena — Definición Formal

| Tipo | Código | Descripción |
|---|---|---|
| Talking Head | TH | Persona hablando a cámara. Incluye: sincrónico (labios sincronizan con audio) y no sincrónico (boca visible pero VO grabado por separado) |
| B-Roll | BR | Footage de apoyo visual. El audio principal (VO o sincrónico) continúa. La imagen ilustra o amplía. |
| Screencast | SC | Grabación de pantalla. Incluye: demo en vivo, screen recording editado, captura de interfaz con cursor visible. |
| Motion / Texto | TX | Animación, texto animado, motion graphics, kinetic typography. Sin footage real. |
| Transición | TR | Elemento de conexión entre escenas. Puede ser gráfico (fade, wipe), de cámara (zoom, pan), o de sonido (whoosh, silencio). |
| Mixto | MX | Dos tipos simultáneos. Ej: TH con overlay de texto animado. Especificar la combinación. |

---

## 3. Especificación de Cámara

Usada en escenas TH y BR que se filman (no en SC ni TX).

### Encuadres estándar

| Abreviatura | Nombre | Descripción | Contenido en pantalla |
|---|---|---|---|
| ECU | Extreme Close-Up | Solo ojos / boca / detalle | Máxima intensidad emocional, detalle de producto |
| CU | Close-Up | Cara completa, desde mentón | Hook, confesión, momento de alta intensidad |
| MCU | Medium Close-Up | Desde clavículas | Conversacional íntimo — el más usado en social video |
| MS | Medium Shot | Desde pecho/cintura | Conversacional, gestos visibles |
| MWS | Medium Wide Shot | Desde cadera | Contexto de ambiente visible |
| WS | Wide Shot | Figura entera | Establisher, contexto de lugar |
| OTS | Over The Shoulder | Desde detrás, hacia lo que mira | Demo, pantalla, objeto |
| POV | Point of View | Cámara = ojos del sujeto | Inmersión, perspectiva subjetiva |
| INSERT | Insert Shot | Detalle de objeto / pantalla / mano | Producto, acción específica |

### Movimientos de cámara

| Abreviatura | Movimiento | Efecto emocional |
|---|---|---|
| STATIC | Sin movimiento | Estabilidad, autoridad, peso |
| SLOW ZOOM IN | Zoom lento hacia adentro | Intensidad creciente, revelación |
| SLOW ZOOM OUT | Zoom lento hacia afuera | Perspectiva, contexto |
| PAN L→R / R→L | Movimiento lateral | Recorrido espacial, revelación |
| TILT UP / DOWN | Movimiento vertical | Poder (arriba), vulnerabilidad (abajo) |
| HANDHELD | Cámara en mano | Urgencia, realismo, inmediatez |
| DOLLY IN/OUT | Movimiento físico hacia/desde sujeto | Más íntimo que zoom — sin distorsión de lente |
| RACK FOCUS | Cambio de foco | Dirigir atención, transición narrativa |

---

## 4. Safe Zones por Plataforma

**Crítico para social video.** Si el contenido importante cae fuera de la safe zone, la interfaz de la plataforma lo tapa.

### Instagram Reels / TikTok / YouTube Shorts (9:16)

```
┌─────────────────────┐  ←  Top UI: 0-8% — NO poner contenido aquí
│  ░░░░░░░░░░░░░░░░░  │     (barra de estado del teléfono)
│                     │
│                     │
│   ZONA SEGURA       │  ←  8% a 75% del alto = zona segura para contenido principal
│   CONTENIDO         │
│   PRINCIPAL         │
│                     │
│  ░░░░░░░░░░░░░░░░░  │  ←  75% a 100% — UI inferior: handle, descripción, botones
│  ░ handle ♥ 💬 ↗ ░  │     NO poner información crítica aquí
└─────────────────────┘

Ancho safe: 10% a 90% del ancho (bordes son peligrosos en crop automático)
Texto en pantalla: nunca más abajo del 70% del alto
```

### Instagram Feed / LinkedIn (1:1 o 4:5)

```
┌─────────────────────┐
│                     │
│   TODO EL FRAME     │  ←  Sin overlay de interfaz durante la reproducción
│   ES SEGURO         │     Pero cuidado con el crop automático a 1:1 desde 4:5
│                     │
└─────────────────────┘
```

### YouTube (16:9)

```
┌─────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ←  Top: título y canal
│                                         │
│   ZONA SEGURA                           │  ←  Zona central siempre visible
│   10% de margen en todos los lados      │
│   para end cards y anotaciones          │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  ←  Bottom: progress bar, controles
└─────────────────────────────────────────┘

End cards: últimos 20 segundos, esquinas derecha e izquierda
```

---

## 5. Consideraciones Multi-Formato

Para videos que se publican en más de una plataforma con distintos ratios.

### Estrategia de filmación para multi-formato

Filmar en el ratio más grande disponible (16:9 o vertical 9:16 según el principal), teniendo en cuenta que el contenido crítico debe sobrevivir el recrop.

**"Safe box" universal**: si el contenido importante está en el centro del 9:16 (vertical), sobrevive el recrop a 1:1 y al 16:9. Al revés no funciona.

```
Recomendación: filmar en 9:16 (vertical) si el principal es social.
Para multi-uso (social + web): filmar en 16:9 con el sujeto centrado.
```

### Nota por escena cuando hay multi-formato

```
FORMATOS: 9:16 (principal) | 1:1 (feed) | 16:9 (YouTube)
CROP NOTE: sujeto centrado — safe para los 3 ratios
```

---

## 6. Template Profesional de Escena

Una escena = un bloque completo. Sin excepción.

```markdown
---

### [TIPO]-[NN]-[V] · [NOMBRE DESCRIPTIVO]

**Tipo**: [TH / BR / SC / TX / TR / MX]
**Duración**: [X.X seg]  **Running total**: [X.X seg acumulados]
**Formato**: [9:16 / 1:1 / 16:9 / multi]

#### VISUAL
**Encuadre**: [ECU / CU / MCU / MS / MWS / WS / OTS / POV / INSERT]
**Movimiento**: [STATIC / SLOW ZOOM IN / SLOW ZOOM OUT / HANDHELD / etc.]
**Descripción**: [Qué se ve — sujeto, acción, ambiente. Presente, activo. 1-3 líneas.]
**Safe zone**: [Confirmar que el contenido crítico está dentro de la safe zone de la plataforma]

#### AUDIO
**VO / DIÁLOGO**: "[Texto exacto que se escucha]"
**SFX**: [descripción del efecto de sonido, o "—"]
**MÚSICA**: [track / tipo / volumen relativo a VO en dB, o "—"]
**NIVEL VO**: [-6 dBFS peak / ajustar según plataforma]

#### GRÁFICOS / TEXTO EN PANTALLA
**Texto**: [Contenido exacto — máx 6 palabras, o "—"]
**Posición**: [TOP / CENTER / BOTTOM — con % del frame si es específico]
**Timing**: [aparece en seg X.X / desaparece en seg X.X]
**Estilo**: [font / color / animación de entrada y salida, o "ver DESIGN.md"]
**Safe zone text**: [confirmar que el texto no cae bajo la UI de la plataforma]

#### PRODUCCIÓN
**Locación**: [INT / EXT — descripción, o "STUDIO" / "SCREEN" para SC]
**Iluminación**: [setup básico, o "natural" / "ver referencia: [link]"]
**Talent**: [quién aparece — nombre o descripción]
**Props**: [objetos en escena, o "—"]
**Wardrobe**: [indicación si es relevante, o "—"]
**Nota de dirección**: [cómo debe sonar / moverse / verse el presentador. Solo si no es obvio.]

#### POST-PRODUCCIÓN
**Color grade**: [warm / cool / neutral / match escena anterior / ver mood board]
**VFX**: [descripción de efecto visual si aplica, o "—"]
**Retoque**: [skin smoothing / logo removal / otro, o "—"]

#### TRANSICIÓN
**Entrada**: [desde qué / cómo llega — corte directo / fade / zoom / wipe / desde [escena X]]
**Salida**: [hacia qué / cómo se va — corte / fade a negro / zoom / dissolve]

---
```

---

## 7. Documento Completo — Estructura

El breakdown no es una lista de escenas. Es un documento de producción con secciones.

```markdown
# BREAKDOWN DE PRODUCCIÓN
## [Título del Video]

**Proyecto**: [nombre]
**Versión**: [X.X]
**Fecha**: [YYYY-MM-DD]
**Director**: [nombre / "Content Director AI"]
**Guion aprobado**: [referencia al guion, versión, fecha de aprobación]

---

## RESUMEN DE PRODUCCIÓN

| Campo | Valor |
|---|---|
| Duración total | [X seg / X min X seg] |
| Total de escenas | [N] |
| Escenas TH | [N] |
| Escenas BR | [N] |
| Escenas SC | [N] |
| Escenas TX | [N] |
| Formato principal | [9:16 / 1:1 / 16:9] |
| Formatos adicionales | [lista] |
| Plataforma(s) | [lista] |
| Tipo de producción | [Avatar IA / Generativo / Rodaje propio] |
| Locaciones | [lista de locaciones únicas] |
| Talent | [lista de personas en pantalla] |

---

## TIMELINE DE ESCENAS

Vista rápida para el editor:

| Código | Tipo | Descripción breve | Duración | Total |
|---|---|---|---|---|
| TH-01-A | TH | Hook visual — expresión de sorpresa | 2.0 seg | 0:02 |
| TH-02-A | TH | Primera línea disruptiva | 3.0 seg | 0:05 |
| BR-03-A | BR | B-roll estadio / multitud | 4.0 seg | 0:09 |
| ... | | | | |
| TH-[N]-A | TH | CTA final | 5.0 seg | [total] |

---

## ESCENAS DETALLADAS

[Una entrada por escena siguiendo el template del §6]

---

## APÉNDICES

### A. B-Roll List Completa
Todas las tomas de B-roll necesarias, agrupadas por locación/categoría:

#### [Categoría 1 — ej: "Estadio / Evento"]
- [ ] [BR-03] [descripción exacta de la toma — ángulo, sujeto, acción]
- [ ] [BR-07] [descripción]

#### [Categoría 2 — ej: "Archivo histórico / Stock"]
- [ ] [BR-05] [descripción + fuente: archivo propio / stock / Pexels / Getty]
- [ ] [BR-11] [descripción]

### B. Shot List — Talking Head
Todas las tomas de TH ordenadas por eficiencia de rodaje (no por orden del video):

#### Setup 1 — [Locación / Encuadre principal]
- [ ] [TH-01-A] MCU STATIC — hook visual (2 seg)
- [ ] [TH-02-A] MCU STATIC — primera línea (3 seg)
- [ ] [TH-06-A] MCU SLOW ZOOM IN — punto climático (4 seg)

#### Setup 2 — [Locación alternativa o encuadre diferente]
- [ ] [TH-09-A] CU STATIC — CTA (5 seg)

### C. Texto en Pantalla — Master List
Todos los textos animados, en orden de aparición:

| Código | Aparece en | Texto | Posición | Duración |
|---|---|---|---|---|
| TX-04-A | 0:08 | "[texto]" | CENTER 60% | 2.5 seg |
| TX-08-A | 0:22 | "[texto]" | BOTTOM 20% | 3.0 seg |

### D. Audio Master
Música, SFX, y notas de niveles:

**Música principal**:
- Track: [nombre / link]
- Licencia: [tipo de licencia — libre de royalties / aprobada por marca]
- Timing: [fade in en seg X / full en seg X / fade out en seg X]
- Nivel: [-18 dBFS debajo del VO durante diálogo / -12 dBFS en momentos sin VO]

**SFX list**:
- [seg X.X]: [descripción del efecto]
- [seg X.X]: [descripción]

**Estándares de nivel de audio por plataforma**:
| Plataforma | Target VO | Max Peak |
|---|---|---|
| Instagram / TikTok | -14 LUFS | -1 dBTP |
| YouTube | -14 LUFS | -1 dBTP |
| Facebook / Meta Ads | -24 LUFS | -2 dBTP |

### E. Assets Necesarios

| Asset | Estado | Fuente / Acción |
|---|---|---|
| [logo en intro] | ✅ existe | assets/brand/logos/logo.svg |
| [música track] | ✅ licenciada | assets/brand/music/track.mp3 |
| [B-roll estadio] | ❌ falta | Conseguir en Getty / Archivo Nacional |
| [foto de archivo histórico] | ⚠️ verificar derechos | [fuente] |

### F. Multi-Formato — Notas de Export

Si el video se publica en más de un formato:

| Versión | Ratio | Resolución | Plataforma | Diferencias vs principal |
|---|---|---|---|---|
| Principal | 9:16 | 1080×1920 | Instagram Reels / TikTok | — |
| Feed | 1:1 | 1080×1080 | Instagram Feed | Recrop central, revisar escenas [X, Y] |
| Horizontal | 16:9 | 1920×1080 | YouTube | Refilmar [TH-01] en horizontal |

### G. Checklist de Entrega

**Pre-producción:**
- [ ] Guion aprobado (Gate 3)
- [ ] Shot list revisada — nada ambiguo
- [ ] B-roll list completa — todo conseguible
- [ ] Assets disponibles o plan de obtención
- [ ] Locaciones confirmadas (si aplica)
- [ ] Avatar configurado / prompts listos (si aplica)

**Post-producción:**
- [ ] Todas las escenas tienen transición definida
- [ ] Texto en pantalla: timing marcado, safe zone verificado
- [ ] Audio levels especificados por plataforma
- [ ] Color grade: mood definido o referencia de marca
- [ ] Multi-formato: notas de crop documentadas

**Entrega:**
- [ ] Versión principal exportada
- [ ] Versiones adicionales exportadas
- [ ] Captions/subtítulos en formato .srt / .vtt
- [ ] Thumbnail (si YouTube / LinkedIn)
- [ ] Assets de distribución (stories cut, teaser, snippets)
```

---

## 8. Estándares Técnicos de Export

Para que el editor tenga los specs sin buscarlos:

### Video
| Plataforma | Codec | Bitrate | FPS | Color space |
|---|---|---|---|---|
| Instagram / TikTok | H.264 o H.265 | 8-15 Mbps | 24 / 30 fps | Rec.709 |
| YouTube | H.264 o VP9 | 10-40 Mbps según resolución | 24 / 30 / 60 fps | Rec.709 |
| Meta Ads | H.264 | 4-8 Mbps | 24 / 30 fps | Rec.709 |

### Resoluciones
| Ratio | Resolución estándar | Máxima recomendada |
|---|---|---|
| 9:16 (vertical) | 1080 × 1920 | 1080 × 1920 |
| 1:1 (cuadrado) | 1080 × 1080 | 1080 × 1080 |
| 4:5 (retrato) | 1080 × 1350 | 1080 × 1350 |
| 16:9 (horizontal) | 1920 × 1080 | 3840 × 2160 (4K) |

### Captions / Subtítulos
- Formato: .srt o .vtt (no burned-in como única opción)
- Burned-in también: para plataformas donde el auto-caption falla o el estilo importa
- Posición: máx 20% desde el bottom en 9:16 (por UI de plataforma)
- Máx caracteres por línea: 42 en 9:16, 60 en 16:9
- Duración mínima por card: 1.5 segundos

---

## 9. Anti-Patrones de Breakdown Profesional

- **Escenas sin duración** — el editor no puede trabajar
- **"B-roll genérico"** sin descripción exacta — nadie sabe qué filmar
- **Texto en pantalla sin timing** — el motion designer adivina
- **Sin safe zones documentadas** — el texto queda tapado por la UI
- **Un solo formato** cuando el video va a múltiples plataformas
- **Sin shot list agrupada** — el rodaje repite setups innecesariamente
- **Audio sin specs de nivel** — la mezcla entregada no pasa la validación de la plataforma
- **Assets sin verificar existencia** — el editor bloquea en post porque falta un archivo
- **Sin versioning** — imposible saber si el breakdown es la versión actual
- **Transiciones no definidas** — el editor improvisa y el resultado no coincide con la visión
