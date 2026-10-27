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
      if (c ~ /^skill:/) { if (system("test -f \"" sk "/" substr(c, 7) "/SKILL.md\"") != 0) next }
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

# Los pasos de un flujo, listos para el agente.
#   steps nombre tipo pasos cerebros-del-flujo "proyectos" "forzados" "excluidos"
steps() {
  local flow="$1" tipo="$2" text="$3" encamino="$4" proys="$5" mas="$6" menos="$7" indic="${8:-}" c q cand=""
  if [ "$tipo" = produccion ]; then
    # En producción lo que sigue al nombre es la idea a producir, no proyectos.
    echo "🎬 Flujo «${flow}» — producir la pieza de ${proys:+la idea «${proys}»}${proys:-la idea que elija el usuario}. Seguí el camino paso a paso; cada paso usa lo que salió del anterior."
    # Qué idea producir la elige SIEMPRE el usuario: sin idea, o si la palabra coincide con varias, se le pregunta.
    local lista; lista="$(bash "$(dirname "$0")/../contenido/contenido.sh" list produccion 2>/dev/null; bash "$(dirname "$0")/../contenido/contenido.sh" list cola 2>/dev/null)"
    echo "ELEGIR LA IDEA — la elige el usuario, nunca vos. ${proys:+Si «${proys}» coincide con más de una idea, o con ninguna, p}${proys:-P}reguntale con la herramienta de preguntas (AskUserQuestion): una opción por idea con el gancho como texto y el ángulo y el título como descripción, primero las de En producción y después las de la Cola (máximo 4; si hay más, las 4 primeras y que escriba otra en «Other»). No arranques hasta que elija. Ideas disponibles:"
    printf '%s\n' "${lista:-  (no hay ideas en Cola ni En producción: decile que apruebe alguna en ds panel → Contenido)}"
    echo "Antes de empezar: buscala con \`ds contenido list\` (título, gancho y tratamiento son el brief) y pasala a producción: ds contenido mover \"<parte del título o gancho>\" produccion"
    echo "  [0] IDENTIDAD DEL PROYECTO — obligatorio, antes de cualquier skill. Estás en la carpeta del proyecto (si no, preguntá cuál es). Leé DESIGN.md (colores, tipografía, espaciado, movimiento), PRESSKIT.md si existe (voz, qué sí / qué no, assets), los logos (buscá public/brand, assets, *logo*), los tokens del código (globals.css, tailwind/theme) y las pantallas reales de la feature que muestra la idea (rutas y componentes de la app). Todo color, fuente, forma y pantalla sale de ahí: nada inventado, nada de paletas genéricas. Si no hay PRESSKIT.md, armalo primero con la skill presskit (le preguntás al usuario lo que falte). Prohibido: SESSION.md, TASKS.md y datos reales de clientes en pantalla (usá datos de ejemplo verosímiles)."
  else
    echo "🧭 Flujo «${flow}»${proys:+ para: ${proys// /, }}. Consultá estos cerebros siguiendo el camino, aplicando cada pregunta a este caso y usando cada respuesta en lo que sigue:"
  fi
  [ -n "$indic" ] && echo "📝 Indicación del usuario — manda sobre todo lo demás: aplicala al formular cada pregunta a los cerebros y en cada idea: «${indic}»"
  # [0] Cerebro del tema: aporta los hechos (datos reales, problemas, cómo habla esa audiencia);
  # el resto del flujo aporta el método.
  q="¿Qué datos reales, problemas concretos y forma de hablar de esta audiencia sirven para ${proys:-este proyecto}?"
  for c in $mas; do echo "  [0] Cerebro del tema (lo pidió el usuario): ds cerebro ask $c \"$q\"  → después: [1]"; done
  if [ -z "$mas" ] && [ "$tipo" != produccion ]; then
    for d in "$ROOT"/*/cerebro.md; do c="$(basename "$(dirname "$d")")"
      case " $encamino $menos " in *" $c "*) continue ;; esac
      cand+="      · $c — $(title_of "$c")$(sed -n 's/^temas: *//p' "$d" | head -1 | cut -d, -f1-5 | sed 's/^./ (&/;s/.$/&…)/')"$'\n'
    done
    if [ -n "$cand" ]; then
      echo "  [0] Cerebro del tema (decidilo vos): mirá el README y el código del proyecto; si es de un rubro que tiene cerebro en esta lista, consultalo primero con: ds cerebro ask <cerebro> \"$q\" y avisale al usuario en una línea cuál sumaste y por qué. Si ninguno es del rubro, no sumes nada."
      printf '%s' "$cand"
    fi
  fi
  printf '%s\n' "${text//$'\x1e'/$'\n'}"
  echo "Después decile al usuario en una línea qué tomaste de cada cerebro (y qué rama elegiste, si hubo)."
  if [ "$tipo" = produccion ]; then
    echo "EL USUARIO ELIGE EN CADA PASO CREATIVO, con la herramienta de preguntas (AskUserQuestion), y no avanzás hasta que conteste: (1) concepto: 2 o 3 opciones distintas, cada una en una línea; (2) guion y escenas: los mostrás y aprueba o pide cambios; (3) borrador del video: lo mira y aprueba antes del render final. Si en otro paso hay una decisión de gusto (estilo, música, voz), también le das opciones."
    echo "Al terminar el render: pasale al usuario la ruta del video y marcala publicada recién cuando él lo confirme: ds contenido mover \"<parte del título o gancho>\" publicado"
  fi
  if [ "$tipo" = ideas ]; then
    if [ -n "$proys" ]; then echo "Es un flujo de IDEAS: no implementes nada. Proyectos: ${proys// /, }."
    else echo "Es un flujo de IDEAS: no implementes nada. El usuario no dijo para qué proyectos: si estás dentro de un proyecto (hay SESSION.md o TASKS.md acá), usá ese; si no, preguntáselo antes de empezar."; fi
    local ang; ang="$(angulos_of "$flow")"
    if [ -n "$ang" ]; then
      echo "Ángulos de venta: repartí las ideas entre estos ángulos, al menos una por ángulo: ${ang}. Cada ángulo es una puerta distinta a la misma venta (qué le duele, qué quiere lograr, qué prueba le alcanza, qué lo frena, contra qué te compara, qué le hace decir que sí ahora): usá lo que dijeron los cerebros para que cada una sea concreta de este proyecto, no genérica."
    fi
    echo "FUENTE DEL PROYECTO: las FEATURES, investigando el código. Recorré pantallas, rutas, comandos, integraciones y el README para entender qué puede hacer el usuario con el producto y qué problema le resuelve cada cosa; de ahí salen las ideas. Si existe <proyecto>/.agents/product-marketing.md, sumalo (cliente, objeciones, cómo habla). NO uses SESSION.md ni TASKS.md (son la bitácora del agente: bugs, pendientes), ni datos reales: base de datos, seeds, fixtures, logs, exports o planillas de clientes (de ahí salen nombres de campos y números que no son resultados). Cada idea tiene que poder decir qué feature muestra."
    echo "Mirá \`ds contenido list\` para no repetir (tampoco las descartadas) y dejá cada idea en la bandeja con:"
    echo "  ds contenido add <proyecto> \"<título>\" \"<gancho>\" \"${flow}\" \"<ángulo>\" \"<tratamiento>\""
    echo "Qué NO es material de contenido (el SESSION.md y el TASKS.md son contexto interno, no fuente de ideas): bugs, errores de datos, incidentes, métricas que salieron mal por un problema del sistema, deuda técnica, cosas a medio hacer, y nombres o datos de clientes o campos reales. Un número entra solo si es un resultado real que el producto le dio a un cliente, no un dato que sale de un error o de cómo se cargó algo. Ante la duda sobre un dato, dejalo afuera o preguntale al usuario. Cada idea le habla a quien compra o usa el producto (no a founders ni a otros devs), salvo que la indicación del usuario diga otra cosa."
    echo "Formato (se decide en una bandeja, tiene que leerse de un vistazo): título = qué es, en 4 a 10 palabras, sin detalles técnicos; gancho = la frase exacta que abre el video, la que se dice o se lee en el primer segundo; tratamiento = todo lo de cómo hacerlo (estructura, planos, edición, efectos, datos a mostrar), en 1 a 3 frases. Nunca metas el tratamiento en el título."
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
