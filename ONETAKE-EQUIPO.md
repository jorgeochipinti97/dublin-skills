# onetake — videos de producto con Claude

**Repo:** https://github.com/jorgeochipinti97/dublin-skills
**Skill:** [`skills/media/onetake/`](https://github.com/jorgeochipinti97/dublin-skills/tree/main/skills/media/onetake)
**Origen:** [feitangyuan/onetake](https://github.com/feitangyuan/onetake) (ahí están los videos de ejemplo terminados)

---

## Qué hace

Hace **videos cortos de producto** (10–30 s, hasta ~60 s si tienen voz en off) con calidad de video de lanzamiento:

- Lanzamientos, teasers, promos
- Demos de una feature **sin grabar pantalla**: Claude rehace la UI en HTML a partir de capturas
- Tipografía animada, motion graphics, la UI real como material
- Efectos de sonido sintetizados, voz en off y subtítulos
- Versiones en otros idiomas del mismo video
- Auditar un video que "parece un PowerPoint" y arreglarlo

No usa personas a cámara ni video generado por IA (para eso están las otras ramas, ver abajo).

**Cómo funciona por dentro:** cada video es un archivo HTML animado que se renderiza cuadro por cuadro → borrador en 1080p30, final en 4K60 con motion blur real. Un control automático rechaza el video si se ve como slideshow antes de que alguien lo tenga que mirar.

---

## Dónde entra en el flujo de video

`content-director` arma solo el circuito según el pedido. Ahora tiene **3 ramas de producción**:

| Rama | Cuándo | Skills |
|---|---|---|
| Avatar IA | Persona hablando a cámara (HeyGen, Hedra…) | `ai-avatar-director` → `ugc-post-production` |
| Generativo | Escenas filmadas con IA (Veo 3, Seedance) | `ugc-video-prompting` → `ugc-post-production` |
| **Motion de producto** | **Lanzamiento / demo / teaser con UI y tipografía** | **`onetake`** (post-producción opcional) |

Flujo completo de la rama motion:

```
presskit (si es una marca)
   ↓
gancho-argumental (opcional, si no hay gancho)      ← aprobás el gancho
   ↓
video-creativo: CONCEPTO                            ← aprobás el mensaje principal
   ↓
video-creativo: IDEA + GUION                        ← aprobás el guion
   ↓
video-creativo: ESCENAS  (= guía de ritmo para onetake)
   ↓
onetake: arma el video, sonido, subtítulos y render
   ↓
ugc-post-production (solo si hace falta música o captions extra)
```

Solo te frena en **3 puntos de aprobación**: gancho, mensaje principal y guion. El resto corre solo.

---

## Instalación

```bash
git clone https://github.com/jorgeochipinti97/dublin-skills.git
cd dublin-skills
./install.sh install
```

¿Ya lo tenías instalado? Actualizá:

```bash
cd dublin-skills && git pull && ./install.sh install
# o, dentro de un proyecto Dublin:
ds update
```

Abrí una sesión nueva de Claude Code después de instalar.

### Dependencias (una vez por máquina)

Sin esto Claude arma el video pero **no lo puede renderizar**:

- `python3` con: `playwright` (+ Chromium), `numpy`, `scipy`, `Pillow`, `matplotlib`, `fonttools`, `brotli`
- `opencv-python` (para analizar videos de referencia)
- `ffmpeg` / `ffprobe`
- `node`
- Solo para voz en off: `faster-whisper` y Kokoro TTS

En Mac:

```bash
brew install ffmpeg node
pip3 install playwright numpy scipy Pillow matplotlib fonttools brotli opencv-python
python3 -m playwright install chromium
```

---

## Cómo pedirlo

**Flujo completo (recomendado si arrancás de cero)** — pedíselo a content-director:

```
Quiero un video de 20 segundos para Instagram lanzando la nueva función de exportar de mi app
```

**Directo a onetake** (ya tenés guion o solo querés el video):

```
/onetake haceme un video de lanzamiento de 15 segundos para mi app
/onetake armá un demo de la feature de exportar rehaciendo la UI desde estas capturas
/onetake este video parece un PowerPoint, decime por qué y arreglalo
/onetake hacé la versión en inglés con voz en off y subtítulos
```

Tip: usá `/onetake` explícito — la descripción de la skill está en inglés/chino y un pedido en español a veces no la dispara solo.

**Combinando a mano:**

```
Con video-creativo armá el guion de un teaser de 20 s y después hacelo con /onetake
```

---

## Qué tener en cuenta

- **Pasale material real:** capturas de la UI, logo, colores. Mejor input = mejor video.
- **Primero borrador, después final:** el render 4K60 es lento; se hace solo cuando el corte está aprobado.
- **No editar la skill a mano:** es código de terceros; se actualiza re-copiando desde el repo de origen.
- **Ejemplos:** `skills/media/onetake/cases/` tiene la explicación de cada video de muestra (ritmo, decisiones). Los videos terminados están en el [repo original](https://github.com/feitangyuan/onetake).
