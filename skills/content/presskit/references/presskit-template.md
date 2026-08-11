# PRESSKIT.md — Template de Proyecto

Este archivo vive en la raíz del proyecto. Es el contrato de marca que todos los skills de contenido leen antes de producir cualquier output.

Copiar, completar, y guardar como `PRESSKIT.md` en la raíz del repositorio de la marca.

---

```markdown
# PRESSKIT — [Nombre de la Marca]

> Versión: [X.X] — Actualizado: [YYYY-MM-DD]
> Owner: [persona responsable de actualizar este archivo]

---

## 1. Identidad de Marca

### Nombre oficial
[Nombre exacto como debe aparecer en todo el contenido]

Variantes permitidas:
- [Nombre corto si existe]
- [Abreviatura si existe]

Variantes PROHIBIDAS:
- [Errores comunes / apodos no autorizados]

### Tagline / Claim oficial
[El tagline actual. Si hay versiones por idioma, listarlas todas.]
- ES: "[tagline en español]"
- EN: "[tagline en inglés]"

### Posicionamiento en una oración
[Quiénes son, para quién, qué los diferencia — la misma fórmula que el SMP de concepto]

---

## 2. Assets — Rutas de Archivos

> Rutas relativas a la raíz del proyecto. Actualizar si los archivos se mueven.

### Logos
```
assets/brand/logos/
├── logo-principal.svg          # Logo completo, uso preferido
├── logo-principal-dark.svg     # Versión para fondos oscuros
├── logo-principal-light.svg    # Versión para fondos claros
├── logo-horizontal.svg         # Variante horizontal
├── isotipo.svg                 # Solo el símbolo, sin texto
├── isotipo-dark.svg
└── favicon.png                 # 32x32px, para web
```

Formatos disponibles: [SVG / PNG / PDF / EPS — indicar cuáles]
Resolución mínima para video: [resolución mínima recomendada, ej: 1000px de ancho]

### Colores
```
assets/brand/colors/
├── palette.json                # Todos los colores en HEX/RGB/HSL
└── palette.figma               # Referencia Figma (si existe)
```

**Paleta principal:**
| Nombre | HEX | RGB | Uso |
|---|---|---|---|
| [Color primario] | #[HEX] | rgb([R],[G],[B]) | [uso principal] |
| [Color secundario] | #[HEX] | rgb([R],[G],[B]) | [uso] |
| [Color de acento] | #[HEX] | rgb([R],[G],[B]) | [uso] |
| [Neutro claro] | #[HEX] | rgb([R],[G],[B]) | [uso] |
| [Neutro oscuro] | #[HEX] | rgb([R],[G],[B]) | [uso] |

**Para video:**
- Color de fondo preferido en videos: [HEX]
- Color de texto en pantalla sobre fondo de marca: [HEX]
- Color del lower third / subtítulos: [HEX]

### Tipografías
```
assets/brand/fonts/
├── [FontName]-Regular.woff2
├── [FontName]-Bold.woff2
└── [FontName]-Italic.woff2     (si existe)
```

| Tipografía | Peso | Uso |
|---|---|---|
| [Font principal] | Regular / Bold | Títulos, cuerpo |
| [Font secundaria] | [pesos] | [uso] |

Sustitutos seguros (si las fuentes de marca no están disponibles):
- Principal → [Google Font o sistema equivalente]
- Secundaria → [equivalente]

### Fotografía y Video de Marca
```
assets/brand/photography/
├── product/                    # Fotos del producto
├── lifestyle/                  # Fotos de estilo de vida / contexto
├── team/                       # Fotos del equipo / fundadores
└── backgrounds/                # Fondos aprobados

assets/brand/video/
├── intro/                      # Secuencia de intro (con variantes de duración)
│   ├── intro-3s.mp4
│   ├── intro-5s.mp4
│   └── intro-10s.mp4
├── outro/                      # Secuencia de outro / end card
│   ├── outro-5s.mp4
│   └── outro-10s.mp4
├── b-roll/                     # B-roll de marca aprobado
│   ├── [descripción-escena]/
│   └── [...]
└── music/                      # Música / jingles aprobados
    ├── [jingle-nombre].mp3
    └── [track-ambient].mp3
```

### Presentador / Avatar de Marca
```
assets/brand/presenter/
├── photo-frontal.jpg           # Foto para AI avatar
├── photo-lateral.jpg           # Ángulo alternativo
├── voice-sample.mp3            # Muestra de voz (para voice cloning)
└── avatar-config.json          # Config del avatar si ya está configurado
```

Plataforma de avatar en uso: [HeyGen / Hedra / Arcads / Synthesia / ninguna]
ID del avatar (si está creado): [ID o "crear nuevo"]

---

## 3. Voz y Tono de Marca

### Personalidad de marca
[3-5 adjetivos que describen la voz. No ambiguos — específicos.]

Somos: [adjetivo 1] / [adjetivo 2] / [adjetivo 3]
NO somos: [opuesto 1] / [opuesto 2] / [opuesto 3]

### Tono calibrado para video
"Como [descripción específica], no como [lo opuesto]."

Ejemplo de calibración:
- En videos educativos: "Como alguien que encontró algo y lo comparte entre colegas, no como un professor dando clase."
- En videos de producto: "Como alguien que muestra algo que le cambió el trabajo, no como alguien que vende."
- En videos de marca: "Como alguien seguro de lo que es, no como alguien que busca aprobación."

### Registro de voz
| Dimensión | Calibración |
|---|---|
| Formal ↔ Casual | [posición en escala — ej: "casual pero profesional"] |
| Emocional ↔ Racional | [posición — ej: "predominantemente racional con toques emocionales"] |
| Directo ↔ Narrativo | [posición] |
| Autoridad ↔ Colaboración | [posición] |

### Persona gramatical en video
- [ ] Primera persona singular (yo / me / mi)
- [ ] Primera persona plural (nosotros / nuestro)
- [ ] Segunda persona directa (vos / tú / usted)
- [x] [la que corresponde a esta marca]

---

## 4. Reglas de Contenido

### QUÉ SÍ — Contenido aprobado

Temas y formatos que la marca puede abordar:
- [tema / tipo de contenido aprobado]
- [otro]
- [otro]

Claims que pueden hacerse (verificados, aprobados por legal):
- "[claim específico con fuente]"
- "[otro]"

### QUÉ NO — Contenido prohibido

Temas que la marca no puede tocar en ningún formato:
- [tema prohibido — y por qué en una línea]
- [otro]
- [otro]

Comparaciones prohibidas:
- NO mencionar a [competidor A] en ningún video
- NO comparar con [producto / categoría]
- NO usar datos de [fuente] (no verificados / disputados)

Claims que NO pueden hacerse (riesgo legal / reputacional):
- NO afirmar "[claim prohibido]" — [razón]
- NO usar porcentajes sin fuente verificada
- [otro]

### Palabras y frases PROHIBIDAS (específicas de esta marca)
- "[palabra]" — [razón: rompe tono / tiene connotación negativa / error pasado]
- "[frase]" — [razón]
- [Filler Word Index universal — siempre aplica]

### Palabras y frases CLAVE (que deben / pueden aparecer)
- "[palabra de marca]" — la terminología propia que diferencia
- "[claim corto]" — puede repetirse en videos
- "[nombre del producto / servicio como debe decirse]"

---

## 5. Reglas por Plataforma

### Instagram
- Handle: @[handle]
- Hashtags de marca (siempre incluir): #[hashtag1] #[hashtag2]
- Hashtags permitidos (categoría): [lista]
- Hashtags PROHIBIDOS: [lista]
- Formato preferido de caption: [largo / corto / con emoji / sin emoji]
- Política de @ a otras cuentas: [libre / solo socios aprobados / nunca]
- Stories: [política de uso]
- Reels: [duración preferida / música: solo librería Meta / puede ser trending]

### TikTok
- Handle: @[handle]
- Sonidos: [solo originales / trending permitido / solo librería comercial]
- Duración preferida: [15s / 30s / 60s]
- Política de duetos / stitch: [permitido / prohibido]

### YouTube
- Canal: [URL]
- Intro obligatorio: [sí — archivo: assets/brand/video/intro/intro-[X]s.mp4 / no]
- Outro obligatorio: [sí / no]
- Cards y end screens: [política]
- Descripción: [template o "libre"]

### LinkedIn
- Página: [URL]
- Tono en LinkedIn específicamente: [puede ser más formal que otras plataformas]
- Política de artículos vs posts: [cuándo usar cada uno]

---

## 6. Compliance y Legal

### Menciones legales obligatorias
[Si el sector lo requiere — farmacéutico, financiero, alimentos, etc.]
- "[texto de disclaimer que debe aparecer en ciertos contenidos]"
- Cuándo aplica: [condición]

### Derechos de imagen
- Personas en contenido: [solo equipo interno / talent con contrato / stock aprobado]
- Menores en contenido: [prohibido / con consentimiento escrito]
- Testimonios de clientes: [requieren autorización firmada en assets/brand/releases/]

### Música y audio
- Música de terceros: [prohibida / solo librería sin royalties / con licencia verificada]
- Librería aprobada: [Epidemic Sound / Artlist / Musicbed / otra / sin librería]
- Efectos de sonido: [mismas reglas que música]

### Proceso de aprobación de contenido
1. [primer paso — ej: "guión a [nombre/rol] para aprobación"]
2. [segundo paso]
3. [paso final antes de publicar]

Tiempo estimado de aprobación: [X días hábiles]
Contacto de aprobación: [nombre / canal]

---

## 7. Integración con Skills de Contenido

Este archivo es leído por los siguientes skills antes de producir output:

| Skill | Qué lee | Para qué |
|---|---|---|
| `video-creativo` | §3 (Voz), §4 (Reglas), §5 (Plataforma) | Filtro de guión — QUÉ SÍ / QUÉ NO / TONO |
| `gancho-argumental` | §4 (Claims), §6 (Compliance) | Verificar que el gancho no viola reglas de marca |
| `ugc-scriptwriter` | §3, §4, §5 | Ángulo y tono del script |
| `ai-avatar-director` | §2 (Presenter), §3 | Config del avatar + voz |
| `ugc-post-production` | §2 (Video assets), §5 | Intro/outro, música, hashtags |
| `blog-writer` | §3, §4 | Tono y restricciones de contenido escrito |
| `landing-page-architect` | §3, §4, §6 | Copy de marca, claims aprobados |

---

## 8. Historial de Cambios

| Fecha | Versión | Cambio | Responsable |
|---|---|---|---|
| [YYYY-MM-DD] | 1.0 | Creación inicial | [nombre] |
| [YYYY-MM-DD] | [X.X] | [qué cambió] | [nombre] |
```
