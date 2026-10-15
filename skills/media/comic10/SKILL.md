---
name: comic10
description: Reel papercut estilo Tribuna (fútbol) a partir de una nota del CMS — jugadores de papel con la CARA REAL recortada de la foto de la nota, look Tribuna blanco y negro con Bebas Neue, voz ElevenLabs rioplatense, 25-33 s vertical, cierre con pregunta para comentar. Usar para «hacé un reel de la última nota», «otro reel como el de Paredes», «comic10 con esta nota», o cualquier reel de una nota deportiva de Tribuna (o de otra cuenta, adaptando la identidad).
---

# comic10 — reel papercut de una nota

Arma un reel vertical de 25-33 s sobre UNA nota, con el pipeline de **papercut-explainer** y el look aprobado por el owner en octubre 2026 (reels de Paredes, Battaglia y la Selección sin Messi para @tribuna.ar).

## Requisitos

- **papercut-explainer** instalado (modo Standard): `git clone https://github.com/0xS4N4TG/papercut-explainer && cd papercut-explainer && ./install.sh --mode standard`. Deja las skills `papercut-*`, la librería (`PAPERCUT_LIB`, ver `~/.config/papercut-explainer/config.env`) y el venv `~/.local/share/papercut-explainer/tools-venv`.
- **ElevenLabs:** `ELEVENLABS_API_KEY` en el entorno (o en un `.env` que se cargue con `set -a; . archivo; set +a`). Nunca pegar la clave en el chat ni commitearla.
- Una **carpeta de serie** por cuenta (p. ej. `~/PROGRAMACION/tribuna-reels`) con `SERIES.md`, `tools/el_voice.py` y `episodes/`. Si ya hay episodios terminados ahí, copiar patrones de sus `src/scenes/*.tsx` (nunca importar entre proyectos).

## Reglas del usuario (no negociables)

- **Nada de los muñecos genéricos del kit (Critter) ni de los backdrops del kit** (laboratorio, museo, depósito…): «no tiene nada que ver con lo deportivo». Personas = figuras de papel humanas (`Person` del theme); sets de fútbol (Vestuario, Cancha con tribunas, Pizarra táctica, marcador).
- **La cara real** del protagonista va recortada de la foto de la nota (`og.jpg`), con borde blanco tipo revista. Personas que la nota no muestra o no nombra: cara dibujada o tarjeta con nombre, **nunca inventar una cara real** (Messi = camiseta 10 vacía; Belmonte = tarjeta sólo con nombre).
- **Identidad Tribuna:** blanco y negro, Bebas Neue, pestaña negra con el logo TRIBUNA arriba en todos los frames, captions negras con letra blanca y la palabra clave invertida. Sin celeste ni dorado de marca (sí los colores de las camisetas de los clubes).
- **Nada fuera de la nota**: cada número, fecha, rival y frase sale de la nota (`research/facts.md`). Lo que la nota da como posible se muestra como posible («RIVAL POSIBLE, NO CONFIRMADO»).
- **Voz:** guion escrito como suena (números en palabras, oraciones completas, sin «…»), una sola toma; cierre con una pregunta, nunca «link en la bio». Mandarle el audio al usuario apenas sale.
- **Mac de 8 GB:** máximo 2 agentes de escena a la vez, `CONC=1` en qa.sh, render final con `--workers 2 --conc 2`, matar `chrome-headless-shell` al terminar.
- El usuario evalúa mirando: mostrar la escena 1 renderizada antes de mandar a construir el resto, y al final abrir el mp4 (`open`) y mandarlo.

## Pasos

1. **Nota.** Última nota: `curl -s https://<sitio>/feed.xml` (Tribuna: `https://tribuna.ar/feed.xml`) (primer `<item>`); «la siguiente» = la de después en el feed; «que no sea de X» = saltear. Bajar el HTML y sacar párrafos + `og:image` (la foto).
2. **Episodio.** `cd <serie> && DONOR=<episodio anterior>/papercut/node_modules $PAPERCUT_LIB/new_episode.sh . NN-slug CompId out-name` (sin DONOR hace `npm i`). Copiar de un episodio anterior o de `templates/` de esta skill: `theme-club.tsx` (club, con `Jugador`/`Companero`) o `theme-seleccion.tsx` (selecciones, `KITS`, `Camiseta10`) → `src/theme.tsx`; `PapercutVideo.tsx` (pestaña del logo) → `src/`. Fuente Bebas Neue en `public/fonts/bebas-neue-400-latin{,-ext}.woff2` (Google Fonts, OFL) y el logo de la cuenta en `public/cast/` (Tribuna: el `logo` del JSON-LD de la home).
3. **Cara.** Mirar la foto (Read) y trazar el polígono de la cabeza: `~/.local/share/papercut-explainer/tools-venv/bin/python -I <skill>/scripts/cut_face.py src.jpg public/cast/<nombre>-head.png preview.jpg 'x,y x,y …'`; leer el preview y corregir. Agregar el personaje al theme (patrón `Jugador`/`Battaglia`/`Scaloni`: `<Img … maxWidth: 'none'>` FUERA del `<Paper>`).
4. **Facts + BRIEF** en `research/facts.md` (formato de `papercut-strategy`). Elegir un **formato familiar distinto** al de los reels anteriores (ya usados: cinchada médico vs DT, tráiler de película de regreso, aviso clasificado «SE BUSCA»).
5. **Guion** `narration/script.json`: 70-85 palabras (ElevenLabs en castellano va a ~2,8 palabras/s → 25-31 s). Hook con número + nombre conocido en la primera frase; una tira de tres; última línea = pregunta que retoma el hook. Campo `tts` opcional con la pronunciación (misma cantidad de palabras que `text`).
6. **Voz:** desde `narration/`, con `ELEVENLABS_API_KEY` exportada: `python3 <skill>/scripts/el_voice.py 5da4nOCHLuswM3TyAUSo` (voz «Diego», argentina; listá otras con `GET /v2/voices`; `FORCE=1` para regenerar). Genera UNA toma con `/with-timestamps` y la corta por oración en `voice/final_narrator/*.wav` + `timing_narrator.js`. Exportar m4a y mandarlo.
7. **Plan** `papercut/episode.json`: escenas de 1,5-5 s cortadas en palabras; `banners` con datos que la voz NO dice (fecha, competencia, caveat); `hook` (2-5 palabras en torn tags, `hold` = duración de S01 para que no tape S02); `cuts` (un solo tear/pageTurn, tapePull al CTA); bed `marimba-heist-Dm-112`. Luego `stubs.py`, `build_vo.py`, `timing_md.py`.
8. **Prueba:** capturar el párrafo clave de la nota con `capture.mjs … --full --clip 0,Y,600,H --scale 2` (si se cuelga después de guardar, esperar el archivo y matar el proceso). Una sola por reel, con `RealShot` + `MarkerCircle`.
9. **S01Hook** lo hace el lead (frame 0 en plena acción, push acelerado los últimos 10 f) y se manda una captura al usuario. Después el **STORYBOARD.md** (reglas globales de theme/identidad + un bloque por escena con eventos por palabra) y 2 agentes `papercut-scene` en paralelo, con los gotchas de abajo en el prompt.
10. **Revisar** cada contact sheet de los agentes (mirar que los eventos se vean en su palabra, que la cámara no se vaya antes de que aparezca el dato, que nada tape caras, banner o captions). Corregir.
11. **Render:** `cues.py` → `audio/render.mjs` → `render.sh --workers 2 --conc 2` → `ffmpeg -crf 23` a `~/Desktop/<cuenta>-<slug>-reel.mp4` (queda < 30 MB para mandarlo) → contact sheet con ffmpeg `tile` y mirarla → `open` + SendUserFile + texto de posteo (hook, pregunta, 3-4 hashtags).

## Gotchas aprendidos

- `<Img>` dentro de un contenedor de ancho 0 necesita `maxWidth: 'none'` (Tailwind lo deja en 0).
- Lo que sobresale mucho de un `<Paper>` lo recorta la región del filtro SVG: caras con foto y cosas altas van fuera del `<Paper>`.
- `cueOf` saca todo lo que no es a-z0-9: `cue('desgarró')` y `cue('desgarr')` andan; para la segunda aparición `cue('treinta', 1)`.
- `CrabTrack` tiene un `hold` igual para todas las paradas: calcular `at`/`hold` contra las palabras para que cada dato quede ≥ 0,5 s en cuadro.
- El kit (`src/lib`) no se toca; la identidad se aplica en `theme.tsx` con `Object.assign(C, …)` / `Object.assign(FONT, …)`.
- Para otra cuenta (p. ej. Rumen 360, ganadería): misma receta cambiando identidad (colores, logo, fuente de captions) y elenco en `theme.tsx`; la protagonista puede ser la mascota/logo de la marca recortada como cabeza.
