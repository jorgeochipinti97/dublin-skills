---
name: marketing-brain
description: "Cerebro de marketing: contexto de producto (posicionamiento, ICP, dolores, objeciones, competencia, lenguaje del cliente), psicología de persuasión (modelos mentales, sesgos, Jobs to be Done) y creativos de anuncios (ángulos, hooks, variantes, formatos por plataforma, iteración con datos de performance). Usar cuando el usuario pide 'posicionamiento', 'público objetivo', 'ICP', 'por qué compra la gente', 'psicología', 'persuasión', 'ángulos de anuncio', 'hooks', 'variantes de ads', 'ad creative', o antes de escribir un guion/campaña sin contexto de producto. Alimenta video-creativo, ugc-scriptwriter, landing-page-architect y onetake."
---

# Marketing Brain

Una entrada, tres modos. Cargar **solo** la referencia del modo que se necesita.

Basado en [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) (`product-marketing`, `marketing-psychology`, `ad-creative`). Licencia MIT en `LICENSE`.

## Paso 0 — Contexto de producto

Antes de cualquier modo, buscar el documento de contexto: `.agents/product-marketing.md` (o `.claude/product-marketing.md`). Si existe, leerlo y no repreguntar lo que ya dice. Si no existe y el trabajo es para una marca/producto concreto → correr el Modo 1 primero (versión corta si el usuario está apurado: producto, público, dolor principal, diferencial, objeción principal, palabras del cliente).

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
