#!/usr/bin/env bash
# `ds flujo` — corre un flujo de cerebros (se arman en ds panel → Flujos). Lo llama el comando
# /flujo de Claude Code, que es la forma de activarlos: explícita, con nombre, nunca por adivinar.
#   ds flujo                              lista los flujos
#   ds flujo <nombre> [proyecto…] [+cerebro] [-cerebro] [: indicación libre]
#                                         imprime los pasos para el agente (nombre parcial: "contenido").
#                                         El cerebro del tema (Ganadero para un proyecto del agro) lo suma el
#                                         agente como paso [0] si aplica; +cerebro lo fuerza, -cerebro lo saca.
#                                         Lo que va después de ":" es la indicación del usuario ("5 ideas, con humor").
#                                         /flujo pasa todo como UN solo argumento entre comillas (así paréntesis o "¿?"
#                                         no rompen la shell) y acá se separa.
#   ds flujo records                      una línea por flujo, para env/cerebro/cerebro-nudge.sh
#
# flujos.md: cada "## Nombre" es un grafo. Nodos "- id cerebro | pregunta @ x,y" y cables
# "> desde hasta | condición" (desde "inicio"). Sin condición = en paralelo; con condición = rama.
set -uo pipefail

ROOT="${DUBLIN_CEREBROS:-$(head -1 "$HOME/.config/dublin/cerebros-root" 2>/dev/null)}"
ROOT="${ROOT/#\~/$HOME}"
FILE="$ROOT/flujos.md"

norm() { perl -CSD -MUnicode::Normalize -pe '$_ = lc NFD($_); s/\pM//g; s/[^a-z0-9]+/-/g; s/^-|-$//g'; }

# nombre ␟ tipo ␟ disparo ␟ skills ␟ cerebros ␟ pasos (líneas separadas por ␞), en orden de recorrido.
records() {
  [ -f "$FILE" ] || return 0
  awk -v root="$ROOT" -v sk="$HOME/.claude/skills" '
    function flush(   q,h,t,i,j,id,nx,par,br,out,cers) {
      if (name == "") return
      h = 1; t = 0; q[1] = "inicio"; seen["inicio"] = 1; out = ""; cers = ""
      while (h > t) { id = q[++t]
        for (j = 1; j <= ne; j++) if (ef[j] == id && !(et[j] in seen) && (et[j] in cer)) { seen[et[j]] = 1; q[++h] = et[j]; num[et[j]] = h - 1 } }
      for (i = 1; i <= h; i++) { id = q[i]; par = ""; br = ""
        for (j = 1; j <= ne; j++) if (ef[j] == id && (et[j] in num)) {
          if (ec[j] == "") par = par (par == "" ? "" : " y ") "[" num[et[j]] "]"
          else br = br (br == "" ? "" : " · ") "«" ec[j] "» → [" num[et[j]] "]" }
        nx = par (par != "" && index(par, " y ") ? " (en paralelo)" : "")
        if (br != "") nx = nx (nx == "" ? "" : "; ") "elegí la rama que aplique: " br
        if (id == "inicio") { out = "  Arrancá por " (nx == "" ? "[1]" : nx); continue }
        if (cer[id] ~ /^skill:/) out = out "\x1e  [" num[id] "] Skill " substr(cer[id], 7) ": cargala con el tool Skill y hacé este paso con su método" (pq[id] == "" ? "" : " — " pq[id]) (nx == "" ? "  → fin" : "  → después: " nx)
        else { cers = cers " " cer[id]
          out = out "\x1e  [" num[id] "] ds cerebro ask " cer[id] " \"" (pq[id] == "" ? "<pregunta concreta sobre este caso>" : pq[id]) "\"" (nx == "" ? "  → fin" : "  → después: " nx) } }
      if (h > 1) printf "%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n", name, (tipo == "" ? "consulta" : tipo), trig, sks, cers, out
      name = ""; tipo = ""; trig = ""; sks = ""; ne = 0; split("", cer); split("", pq); split("", seen); split("", num)
    }
    /^## / { flush(); name = substr($0, 4); next }
    /^tipo:/ { tipo = $2; next }
    /^disparo:/ { trig = substr($0, 9); next }
    /^skills:/ { sks = substr($0, 8); next }
    /^- [A-Za-z0-9_]+ [^ ]+/ && name != "" { l = $0; sub(/ @ -?[0-9]+,-?[0-9]+[ \t]*$/, "", l); id = $2; c = $3
      if (c ~ /^skill:/) { if (substr(c, 7) !~ /^(dataviz|artifact-design|artifact-diagramming|code-review|simplify)$/ && system("test -f \"" sk "/" substr(c, 7) "/SKILL.md\"") != 0) next }   # incluidas en Claude Code: sin carpeta
      else if (system("test -f \"" root "/" c "/cerebro.md\"") != 0) next
      cer[id] = c; p = index(l, " | "); pq[id] = p ? substr(l, p + 3) : ""; next }
    /^> [A-Za-z0-9_]+ [A-Za-z0-9_]+/ && name != "" { ne++; ef[ne] = $2; et[ne] = $3; p = index($0, " | "); ec[ne] = p ? substr($0, p + 3) : ""; next }
    END { flush() }' "$FILE"
}

# Cerebro por slug exacto o por palabra entera ("ia" no, "ganadero" sí).
cerebro_of() {
  local want d hits=()
  want="$(printf '%s' "$1" | norm)"
  for d in "$ROOT"/*/cerebro.md; do d="$(basename "$(dirname "$d")")"
    [ "$d" = "$want" ] && { echo "$d"; return 0; }
    case "$d" in "$want"-*|*-"$want"|*-"$want"-*) hits+=("$d") ;; esac
  done
  [ "${#hits[@]}" -eq 1 ] && { echo "${hits[0]}"; return 0; }
  return 1
}
title_of() { head -1 "$ROOT/$1/cerebro.md" | sed 's/^# //'; }
# Ángulos de venta de un flujo de ideas (línea "angulos:" de su bloque). Sin la línea: los de siempre;
# con la línea vacía: ninguno (el usuario los sacó a propósito).
ANGULOS_DEFAULT="dolor, resultado, prueba social, objeción, comparación, oferta"
angulos_of() {
  awk -v n="$1" -v d="$ANGULOS_DEFAULT" '/^## /{on=(substr($0,4)==n); next} on && /^angulos:/{sub(/^angulos: */,""); print; f=1; exit} END{if(!f) print d}' "$FILE"
}

# Reglas para generar ideas: las usa el flujo de ideas y la etapa de ideas del flujo de producción.
ideas_rules() {
  local flow="$1" proys="$2" ang
  ang="$(angulos_of "$flow")"
  if [ -n "$ang" ]; then
    echo "Ángulos de venta: repartí las ideas entre estos ángulos, al menos una por ángulo: ${ang}. Cada ángulo es una puerta distinta a la misma venta (qué le duele, qué quiere lograr, qué prueba le alcanza, qué lo frena, contra qué te compara, qué le hace decir que sí ahora): usá lo que dijeron los cerebros para que cada una sea concreta de este proyecto, no genérica."
  fi
  echo "FUENTE DEL PROYECTO: las FEATURES, investigando el código. Recorré pantallas, rutas, comandos, integraciones y el README para entender qué puede hacer el usuario con el producto y qué problema le resuelve cada cosa; de ahí salen las ideas. Si existe <proyecto>/.agents/product-marketing.md, sumalo (cliente, objeciones, cómo habla). NO uses SESSION.md ni TASKS.md (son la bitácora del agente: bugs, pendientes), ni datos reales: base de datos, seeds, fixtures, logs, exports o planillas de clientes (de ahí salen nombres de campos y números que no son resultados). Cada idea tiene que poder decir qué feature muestra."
  echo "Mirá \`ds contenido list\` para no repetir (tampoco las descartadas) y dejá cada idea en la bandeja con:"
  echo "  ds contenido add <proyecto> \"<título>\" \"<gancho>\" \"${flow}\" \"<ángulo>\" \"<tratamiento>\""
  echo "Si la indicación nombra una campaña, pasala como 7º argumento (\"<campaña>\") con el nombre exacto: el panel agrupa proyecto → campaña → conjunto (el ángulo) → anuncios, como Meta."
  echo "Qué NO es material de contenido (el SESSION.md y el TASKS.md son contexto interno, no fuente de ideas): bugs, errores de datos, incidentes, métricas que salieron mal por un problema del sistema, deuda técnica, cosas a medio hacer, y nombres o datos de clientes o campos reales. Un número entra solo si es un resultado real que el producto le dio a un cliente, no un dato que sale de un error o de cómo se cargó algo. Ante la duda sobre un dato, dejalo afuera o preguntale al usuario. Cada idea le habla a quien compra o usa el producto (no a founders ni a otros devs), salvo que la indicación del usuario diga otra cosa."
  echo "Formato (se decide en una bandeja, tiene que leerse de un vistazo): título = qué es, en 4 a 10 palabras, sin detalles técnicos; gancho = la frase exacta que abre el video, la que se dice o se lee en el primer segundo; tratamiento = todo lo de cómo hacerlo (estructura, planos, edición, efectos, datos a mostrar), en 1 a 3 frases. Nunca metas el tratamiento en el título."
  echo "Sin CTA: no pongas llamados a la acción (\"comentá X\", palabras clave, links) en el tratamiento; el CTA lo decide el usuario al producir."
}

# Los pasos de un flujo, listos para el agente.
#   steps nombre tipo pasos cerebros-del-flujo "proyectos" "forzados" "excluidos"
steps() {
  local flow="$1" tipo="$2" text="$3" encamino="$4" proys="$5" mas="$6" menos="$7" indic="${8:-}" c q cand=""
  if [ "$tipo" = produccion ]; then
    # En producción lo que sigue al nombre es la idea a producir, no proyectos.
    echo "🎬 Flujo «${flow}» — de la idea al video final, en un solo camino. Seguí los pasos en orden; cada uno usa lo que salió del anterior y el usuario decide en cada uno."
    # Qué idea producir la elige SIEMPRE el usuario: una que ya existe o una nueva que sale de la etapa de ideas.
    local lista; lista="$(bash "$(dirname "$0")/../contenido/contenido.sh" list produccion 2>/dev/null; bash "$(dirname "$0")/../contenido/contenido.sh" list cola 2>/dev/null)"
    echo "LA IDEA — la elige el usuario, nunca vos. Si la indicación ya nombra la idea (su gancho o título)$([ -n "$proys" ] && echo " o «${proys}» coincide con una sola"), es esa: salteá la etapa de ideas. Si no, preguntale con AskUserQuestion: «producir una idea que ya está» (opciones: las de abajo, primero En producción, máximo 4, con el gancho como texto) o «generar ideas nuevas» (corrés la etapa de ideas). No arranques hasta que elija. Ideas disponibles:"
    printf '%s\n' "${lista:-  (no hay ideas en Cola ni En producción: arrancá por la etapa de ideas)}"
    echo "Cuando haya idea elegida: buscala con \`ds contenido list\` (título, gancho y tratamiento son el brief) y pasala a producción: ds contenido mover \"<parte del título o gancho>\" produccion"
    echo "  [0] IDENTIDAD DEL PROYECTO — obligatorio, antes de cualquier skill. Estás en la carpeta del proyecto (si no, preguntá cuál es). Leé DESIGN.md (colores, tipografía, espaciado, movimiento), PRESSKIT.md si existe (voz, qué sí / qué no, assets), los logos (buscá public/brand, assets, *logo*), los tokens del código (globals.css, tailwind/theme) y las pantallas reales de la feature que muestra la idea (rutas y componentes de la app). Todo color, fuente, forma y pantalla sale de ahí: nada inventado, nada de paletas genéricas. Si no hay PRESSKIT.md, armalo primero con la skill presskit (le preguntás al usuario lo que falte). Prohibido: SESSION.md, TASKS.md y datos reales de clientes en pantalla (usá datos de ejemplo verosímiles)."
    # La memoria del proyecto guarda lo que el dueño ya corrigió en videos anteriores: leerla evita repetir errores.
    echo "  [0+] MEMORIA DEL PROYECTO — obligatorio: leé las memorias del proyecto en ~/.claude/projects/<carpeta-del-proyecto-con-guiones>/memory/ (sobre todo las de reels, contenido y feedback) y aplicalas como reglas duras. Todo lo que el video diga del producto (funciones, planes, números, nombres de pantallas, textos del bot) se verifica en el código antes de escribirlo; si no está en el código, no va."
    local refs; refs="$(cat "$HOME/.config/dublin/referencias" 2>/dev/null)"
    echo "  [0p] BUYER PERSONA — obligatorio, antes del paso [1]: leé <proyecto>/.agents/buyer-persona.md$([ -n "$refs" ] && [ -d "$refs" ] && echo " (o $refs/buyer-personas/<proyecto>.md)") y <proyecto>/.agents/product-marketing.md si existe. El video le habla a esa persona, en su mundo y con sus palabras. Si no hay ficha o le falta algo (quién compra, qué le duele, qué lo frena, dónde lo ve), preguntale al usuario con AskUserQuestion y guardá la ficha en <proyecto>/.agents/buyer-persona.md; no supongas."
    if [ -n "$refs" ] && [ -d "$refs" ]; then
      echo "  [0r] BIBLIOTECA — leé $refs/README.md y las hojas que indica para cada paso (formatos, guiones, escenas, veo, onetake, checklist). Primero la biblioteca; a los cerebros preguntales solo lo que la biblioteca no cubre."
    fi
    echo "  [0x] REFERENCIAS DEL USUARIO — si te pasa videos, links o imágenes de referencia, analizalos primero (estructura, ritmo, planos, tipografía, qué los hace funcionar) y mandan sobre la biblioteca. Sin referencias ni biblioteca el flujo igual funciona: usá los cerebros y la skill del formato."
    # El video es UNA composición en capas (voz, imagen por escena, texto, FX y sonido) y cada escena elige
    # de qué fuente sale su imagen: no se elige un formato para todo el video.
    local fmt="" k d
    for k in "onetake|cualquier composición gráfica: UI del producto en la forma que pida la idea, tipografía cinética, datos animados, objetos, metáforas visuales. Es además el COMPOSITOR: junta voz, clips y capas en una línea de tiempo (clips como footage)" \
             "papercut-explainer|Papel recortado, collage" \
             "ai-avatar-director|Avatar IA hablando a cámara (HeyGen, Hedra…)" \
             "remotion-video|Animación programada a medida en React"; do
      d="${k%%|*}"; [ -f "$HOME/.claude/skills/$d/SKILL.md" ] && fmt+="      · $d — ${k#*|}"$'\n'
    done
    # Clips de Veo en Google Flow con los créditos de tus cuentas (bot personal, fuera del repo: ~/.config/dublin/flow-bot tiene su ruta)
    if [ -s "$HOME/.config/dublin/flow-bot" ] && [ -d "$HOME/.config/dublin/flow" ]; then
      local fb; fb="$(cat "$HOME/.config/dublin/flow-bot")"
      fmt+="      · flow — Tomas cinematográficas reales con Veo en Google Flow (créditos de tus cuentas). Prompts con ugc-video-prompting; cada clip: $fb/.venv/bin/python $fb/generar.py \"<prompt>\" --out clips/escena-N.mp4 (borrador: Veo Lite, ~10 puntos; --modelo quality solo para el final aprobado)."$'\n'
    fi
    fmt+="      · voz — ElevenLabs o Kokoro local con onetake (scripts/vo_tools.py --engine auto); la voz es el hilo de todo el video."$'\n'
    echo "  [0b] HOJA DE COMPOSICIÓN — se arma después del control del guion y antes del paso de dirección (foco y jerarquía): una tabla escena × capa (tiempo · voz · imagen y su FUENTE · texto en pantalla · FX · sonido), 9:16, un foco único por escena. La fuente de cada escena la elige el usuario: proponé una por escena con su porqué y preguntale con AskUserQuestion (podés agrupar escenas). Un mismo video puede mezclar cine y producto. El tratamiento visual de cada escena sale de la idea, no de una fórmula: puede ser cualquier cosa mientras sea profesional; la lista de fuentes es lo que hay disponible, no un menú obligado, y ningún recurso (celular, mockup, tipografía) es fijo. En la columna FUENTE poné también DÓNDE se genera: «flow-bot» (toma cinematográfica con Veo, en tu Mac con tus créditos) o «servidor» (onetake: UI del producto, tipografía, datos; se renderiza con ds render en el servidor). La voz y el sonido también van al servidor (ds render exec). Fuentes disponibles:"
    printf '%s' "$fmt"
  else
    echo "🧭 Flujo «${flow}»${proys:+ para: ${proys// /, }}. Consultá estos cerebros siguiendo el camino, aplicando cada pregunta a este caso y usando cada respuesta en lo que sigue:"
  fi
  [ -n "$indic" ] && echo "📝 Indicación del usuario — manda sobre todo lo demás: aplicala al formular cada pregunta a los cerebros y en cada idea: «${indic}»"
  # [0] Cerebro del tema: aporta los hechos (datos reales, problemas, cómo habla esa audiencia);
  # el resto del flujo aporta el método.
  q="¿Qué datos reales, problemas concretos y forma de hablar de esta audiencia sirven para ${proys:-este proyecto}?"
  for c in $mas; do echo "  [0] Cerebro del tema (lo pidió el usuario): ds cerebro ask $c \"$q\"  → después: [1]"; done
  if [ -z "$mas" ]; then
    for d in "$ROOT"/*/cerebro.md; do c="$(basename "$(dirname "$d")")"
      case " $encamino $menos " in *" $c "*) continue ;; esac
      cand+="      · $c — $(title_of "$c")$(sed -n 's/^temas: *//p' "$d" | head -1 | cut -d, -f1-5 | sed 's/^./ (&/;s/.$/&…)/')"$'\n'
    done
    if [ -n "$cand" ]; then
      echo "  [0] Cerebro del tema (decidilo vos): mirá el README y el código del proyecto; si es de un rubro que tiene cerebro en esta lista, consultalo primero con: ds cerebro ask <cerebro> \"$q\" y avisale al usuario en una línea cuál sumaste y por qué. Si ninguno es del rubro, no sumes nada."
      printf '%s' "$cand"
    fi
  fi
  # reglas.md = lo destilado de cada cerebro: reglas fijas que no dependen de cómo salga cada consulta.
  echo "REGLAS DE CADA CEREBRO: antes de cada ds cerebro ask, leé $ROOT/<cerebro>/reglas.md si existe y aplicalo como reglas duras; al cerebro preguntale solo lo que esas reglas no cubren, con el caso concreto pegado en la pregunta (guion, escenas, pantalla), nunca en abstracto."
  printf '%s\n' "${text//$'\x1e'/$'\n'}"
  echo "Después decile al usuario en una línea qué tomaste de cada cerebro (y qué rama elegiste, si hubo)."
  if [ "$tipo" = produccion ]; then
    echo "ETAPA DE IDEAS (solo si el usuario eligió generar ideas nuevas; si no, salteá esos pasos):"
    ideas_rules "$flow" "$proys" | sed 's/^/    /'
    echo "    Mostrale las ideas con AskUserQuestion (gancho como texto, ángulo y título como descripción); la que elige pasa a producción y las demás quedan en la bandeja."
    echo "HISTORIA, NO DEMO: el guion es un solo hilo problema → giro → solución en el mundo de la persona de [0p] (personaje, situación concreta con números o lugares reales del rubro, tensión). Si el guion se lee como una lista de funciones del producto, rehacelo antes de mostrarlo. El producto aparece como la herramienta que resuelve la tensión, no como el tema."
    echo "Último paso: generá los assets aprobados (voz, clips de Veo) y componé TODO en onetake (cargá la skill con el tool Skill): una sola línea de tiempo con la voz como hilo, cada escena con su fuente, los clips como footage, texto, FX y sonido de la hoja de composición, y la identidad de [0]. Antes de renderizar, sacá la hoja de contactos (ds render hoja <carpeta> <tiempos> --width 1080 --height 1920) y pasale la checklist de la biblioteca si existe (checklist-antes-del-render.md): si algo falla, se corrige antes de mostrar. Los clips del flow-bot entran como footage en la composición. El render nunca en la Mac: borrador con ds render <carpeta> --width 1080 --height 1920 (rápido) o --lindo, y el final con --final solo cuando lo apruebe; llega a Drive y avisa por ntfy (ds render estado para ver la cola)."
    # Lo que falló en borradores reales (voz cortada, tomas congeladas, final mudo): se controla, no se confía.
    local qa; qa="$(cd "$(dirname "$0")/../video" && pwd)/qa.py"
    echo "CONTROL DE CALIDAD — obligatorio antes de mostrar CUALQUIER borrador: uv run -p 3.12 --with faster-whisper python $qa <video.mp4> --guion <carpeta de tomas de voz o .txt con todo lo que se dice>. Transcribe lo que se escucha y lo compara con el guion, busca imágenes quietas (> 0,5 s), huecos sin sonido y volumen (−14 LUFS). Si falla, se arregla y se vuelve a correr; nunca le mostrás al usuario un video que no pasa, y le decís qué controlaste. Además mirá cuadros del video final (ffmpeg -ss) en cada escena. Reglas que el control no ve: la voz es UNA toma continua por bloque (nunca cortes el audio entre palabras: se come sílabas) y la imagen sigue a la voz palabra por palabra (tiempos de la toma con timestamps); cada toma de video cubre su escena entera (si es más corta, cámara lenta, nunca congelada); si alguien mueve los labios en cámara, su audio suena ahí, y mejor evitarlo: una toma de Veo que habla no coincide con una voz doblada (pedí el plano de espaldas, de perfil lejano o con el celular tapando la boca, o que Veo genere el diálogo con su propio audio); no hay tramos sin voz ni sonido; siempre música (que baje sola bajo la voz) y efectos sacados de los eventos de la composición; el cierre dice la acción (ej. «Registrate gratis…»), no solo la marca."
    echo "EL USUARIO MANEJA EL FLUJO — no supongas nada: toda decisión es una pregunta con AskUserQuestion y no avanzás hasta que conteste. Como mínimo: (1) promesa + gancho: las 3 opciones de [1]; (2) guion: lo mostrás después del control de [3] y aprueba o pide cambios; (3) hoja de composición: fuente de cada escena y el orden; (4) voz (cuál, tono, velocidad) y música; (5) prompts de Veo antes de gastar créditos; (6) borrador antes del final. Si un paso no aplica (no hay escenas de producto o cinematográficas), decí que lo salteás y por qué. Si algo no está en lo que leíste ni lo dijo el usuario, preguntalo."
    echo "CTA — lo decide el usuario, nunca vos: no inventes llamados a la acción (\"comentá X\", palabras clave, links) ni los saques del tratamiento de la idea. Dejá el cierre marcado como [CTA] y preguntale cuál va."
    echo "Al terminar el render: pasale al usuario la ruta del video y marcala publicada recién cuando él lo confirme: ds contenido mover \"<parte del título o gancho>\" publicado"
  fi
  if [ "$tipo" = ideas ]; then
    if [ -n "$proys" ]; then echo "Es un flujo de IDEAS: no implementes nada. Proyectos: ${proys// /, }."
    else echo "Es un flujo de IDEAS: no implementes nada. El usuario no dijo para qué proyectos: si estás dentro de un proyecto (hay SESSION.md o TASKS.md acá), usá ese; si no, preguntáselo antes de empezar."; fi
    ideas_rules "$flow" "$proys"
    echo "Al final decile cuántas dejaste: las elige en ds panel → Contenido."
  fi
}

[ -n "$ROOT" ] && [ -d "$ROOT" ] || { echo "No hay carpeta de cerebros configurada."; exit 1; }

# Un solo argumento con espacios o ":" (así llega desde /flujo): separar acá, sin expandir comodines.
INDIC=""
if [ $# -eq 1 ] && [[ "$1" == *" "* || "$1" == *:* ]]; then
  raw="$1"; [[ "$raw" == *:* ]] && INDIC="${raw#*:}"
  set -f; set -- ${raw%%:*}; set +f
else  # forma terminal: ds flujo contenido rumen : 5 ideas
  args=()
  while [ $# -gt 0 ]; do [ "$1" = ":" ] && { shift; INDIC="$*"; break; }; args+=("$1"); shift; done
  set -- "${args[@]+"${args[@]}"}"
fi
INDIC="$(printf '%s' "$INDIC" | sed 's/^ *//;s/ *$//')"

case "${1:-}" in
  records) records ;;
  "")
    n=0
    while IFS=$'\x1f' read -r flow tipo _ _ _ _; do
      n=$((n+1)); printf '  /flujo %-28s %s\n' "$(printf '%s' "$flow" | norm)" "($tipo) $flow"
    done < <(records)
    [ "$n" -gt 0 ] || echo "Todavía no hay flujos: se arman en ds panel → Flujos." ;;
  *)
    want="$(printf '%s' "$1" | norm)"; shift
    hits=() lines=()
    while IFS= read -r rec; do
      slug="$(printf '%s' "${rec%%$'\x1f'*}" | norm)"
      case "$slug" in "$want"|"$want"-*|*-"$want"|*-"$want"-*) hits+=("$slug"); lines+=("$rec") ;; esac
    done < <(records)
    if [ "${#lines[@]}" -eq 0 ]; then echo "No encontré el flujo «${want}». Los que hay:"; "$0"; exit 1; fi
    if [ "${#lines[@]}" -gt 1 ]; then echo "«${want}» coincide con varios: ${hits[*]}. Decime cuál."; exit 1; fi
    IFS=$'\x1f' read -r flow tipo _ _ cers text <<< "${lines[0]}"
    proys="" mas="" menos=""
    for a in "$@"; do
      case "$a" in
        +*|-*) c="$(cerebro_of "${a:1}")" || { echo "No encontré el cerebro «${a:1}». Los que hay: $(for d in "$ROOT"/*/cerebro.md; do basename "$(dirname "$d")"; done | tr '\n' ' ')"; exit 1; }
               [ "${a:0:1}" = + ] && mas+="$c " || menos+="$c " ;;
        *) proys+="$a " ;;
      esac
    done
    steps "$flow" "$tipo" "$text" "$cers" "${proys% }" "${mas% }" "${menos% }" "$INDIC" ;;
esac
