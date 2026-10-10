---
name: marketing-brain
description: "Cerebro de marketing: contexto de producto (posicionamiento, ICP, dolores, objeciones, competencia, lenguaje del cliente), psicología de persuasión (modelos mentales, sesgos, Jobs to be Done) y creativos de anuncios (ángulos, hooks, variantes, formatos por plataforma, iteración con datos de performance). Usar cuando el usuario pide 'posicionamiento', 'público objetivo', 'ICP', 'por qué compra la gente', 'psicología', 'persuasión', 'ángulos de anuncio', 'hooks', 'variantes de ads', 'ad creative', o antes de escribir un guion/campaña sin contexto de producto. Alimenta video-creativo, ugc-scriptwriter, landing-page-architect y onetake."
---

# Marketing Brain

Una entrada, tres modos. Cargar **solo** la referencia del modo que se necesita.

Basado en [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (`product-marketing`, `marketing-psychology`, `ad-creative`). Licencia MIT en `LICENSE`.

## Paso 0 — Contexto de producto

Antes de cualquier modo, buscar el documento de contexto: `.agents/product-marketing.md` (o `.claude/product-marketing.md`). Si existe, leerlo y no repreguntar lo que ya dice. Si no existe y el trabajo es para una marca/producto concreto → correr el Modo 1 primero (versión corta si el usuario está apurado: producto, público, dolor principal, diferencial, objeción principal, palabras del cliente).

## Modo rápido — Ficha de Marketing (default dentro del flujo de video)

El usuario no tiene por qué saber de marketing. **Proponer, no interrogar**: armar la ficha a partir del brief, el PRESSKIT, la web del producto y búsqueda web; preguntar solo lo que no se puede deducir, en lenguaje llano y máximo 3 preguntas ("¿qué vendés?", "¿a quién se lo querés vender?", "¿dónde y a qué precio?"). Cero jerga sin traducir: si aparece un término (ICP, objeción, JTBD), explicarlo en media línea.

```markdown
## Ficha de Marketing — [producto]

**A quién le hablamos (buyer persona)**
- [Etiqueta descriptiva, ej: "El que vio el Mundial con el viejo" — 40-55, AR] — no inventar nombre ni foto
- Qué quiere: [deseo en sus palabras]
- Qué le duele / qué le frena: [dolor u objeción principal]
- Dónde está: [plataforma donde lo encontramos]

**Por qué compraría (principio psicológico)**: [uno solo + media línea de por qué]

**3 ángulos de venta** (cómo le entramos)
1. [Ángulo] — [en criollo: qué le decimos y por qué funciona] ← recomendado
2. [Ángulo] — [...]
3. [Ángulo] — [...]

**Lo que no sabemos**: [datos marcados `[FALTA]`, nunca inventados]
```

El usuario aprueba o corrige en una línea ("el 2", "es para regalar, no para uno"). La ficha aprobada se guarda en `.agents/product-marketing.md` (sección "Ficha rápida") para no repreguntar en el próximo video del mismo producto. B2C: una persona principal; B2B: personas por rol (ver `references/product-marketing.md` §3).

## Modos

| Modo | Cuándo | Cargar |
|---|---|---|
| **1 · Contexto de producto** | Producto/cliente nuevo, cambió el posicionamiento, no hay `.agents/product-marketing.md` | `references/product-marketing.md` |
| **2 · Psicología** | Elegir el insight, la promesa o el gancho; entender por qué alguien compraría o no | `references/psychology.md` |
| **3 · Creativos de anuncios** | Ángulos, hooks, variantes, formatos por plataforma, iterar con datos | `references/ad-creative.md` (+ sus subreferencias en `references/ad-creative/` solo si el pedido las requiere) |

Subreferencias útiles para video: `ad-creative/hook-system.md`, `ad-creative/short-form-video-specs.md`, `ad-creative/motion-video-ads.md`, `ad-creative/awareness-headlines.md`.

## Uso dentro del flujo de video

- **video-creativo / CONCEPTO** → leer el contexto (Modo 1) y elegir el insight con Modo 2: qué creencia desplaza el video y qué principio psicológico la mueve (ej. aversión a la pérdida, prueba social, costo de oportunidad). Nombrar el principio en el brief.
- **gancho-argumental / GANCHO** → cruzar los hallazgos con `ad-creative/hook-system.md` y el nivel de conciencia del público (`awareness-headlines.md`).
- **Variantes** → Modo 3 para generar 3-5 ganchos/ángulos alternativos del mismo guion cuando el cliente quiere testear.
- **onetake / ugc-scriptwriter** → reciben el guion ya anclado en el contexto; no inventan público ni promesa.

## Reglas Dublin (encima del material original)

- **Lenguaje del cliente > lenguaje de marketing.** Si el contexto tiene frases textuales de clientes, el guion las usa.
- **Filler Word Index** y **Data Realism** aplican: nada de "revolucionario", "potenciá", números redondos inventados (99.99% Problem), testimonios de Jane Doe.
- **Cero datos inventados.** Si falta un dato del producto (precio, métrica, competidor), preguntar o marcarlo `[FALTA]`; nunca rellenar.
- **Español rioplatense** por default para piezas en español (voseo), salvo que el contexto diga otro mercado.

## Anti-patrones

- Escribir un guion para una marca sin contexto de producto ("Generating without grounding": se lee como cualquier otro anuncio del feed).
- Aplicar 10 principios psicológicos a la vez. Un video = un principio dominante.
- Cargar las 12 subreferencias de ad-creative "por las dudas".
