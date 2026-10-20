#!/usr/bin/env bash
# `ds voz` — anotar tareas hablando, 100% local.
#   micrófono → whisper.cpp (transcribe) → Ollama (interpreta) → TASKS.md
#
#   ds voz                 graba hasta Enter
#   ds voz "en X agregá…"  salta la grabación (texto directo)
#
# Acciones: agregar (→ ## Backlog, o TASKS.<user>.local.md si es "para mí")
# y hecho (→ mueve la task a ## Done como [x]). Siempre muestra el plan y
# pide Enter antes de escribir. Si el proyecto es ambiguo, pregunta.
set -uo pipefail

MODEL="${DUBLIN_VOZ_MODEL:-qwen2.5:1.5b}"
WHISPER_MODEL="${DUBLIN_WHISPER_MODEL:-$HOME/.local/share/dublin/whisper/ggml-small.bin}"
MIC="${DUBLIN_MIC:-:0}"                       # avfoundation audio device
OLLAMA="${OLLAMA_HOST:-http://127.0.0.1:11434}"
CONF="$HOME/.config/dublin/projects-root"

B=$'\e[1m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; D=$'\e[2m'; N=$'\e[0m'
die() { echo "${R}$*${N}" >&2; exit 1; }

user="${DUBLIN_USER:-$(whoami)}"   # TASKS.<user>.local.md (si el proyecto ya tiene uno, se usa ese)

# ---- Carpeta de proyectos: $DUBLIN_PROJECTS → cockpit → config → preguntar ----
if [ -n "${DUBLIN_PROJECTS:-}" ]; then
  ROOT="$DUBLIN_PROJECTS"
elif [ -f "$PWD/.dublin-cockpit" ]; then
  ROOT="$(head -1 "$PWD/.dublin-cockpit")"
elif [ -f "$CONF" ]; then
  ROOT="$(head -1 "$CONF")"
else
  printf "${Y}¿Carpeta de tus proyectos?${N} "; read -r ROOT
  ROOT="${ROOT/#\~/$HOME}"
fi
[ -d "$ROOT" ] || die "No existe la carpeta de proyectos: $ROOT"
[ -f "$CONF" ] || [ -n "${DUBLIN_PROJECTS:-}" ] || { mkdir -p "$(dirname "$CONF")"; printf '%s\n' "$ROOT" > "$CONF"; }

projects="$(cd "$ROOT" && for d in */; do printf '%s\n' "${d%/}"; done)"

# ---- 1. Texto: argumento o micrófono ----------------------------------------
if [ $# -gt 0 ]; then
  text="$*"
else
  command -v ffmpeg >/dev/null || die "Falta ffmpeg: brew install ffmpeg"
  command -v whisper-cli >/dev/null || die "Falta whisper: brew install whisper-cpp"
  [ -f "$WHISPER_MODEL" ] || die "Falta el modelo de whisper. Bajalo una vez (~490 MB):
  mkdir -p \"$(dirname "$WHISPER_MODEL")\" && curl -L -o \"$WHISPER_MODEL\" https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  ffmpeg -loglevel error -f avfoundation -i "$MIC" -ar 16000 -ac 1 -y "$tmp/in.wav" </dev/null &
  rec=$!
  printf "${B}🎙  Hablá… (Enter para terminar)${N}"; read -r _
  kill -INT "$rec" 2>/dev/null; wait "$rec" 2>/dev/null
  [ -s "$tmp/in.wav" ] || die "No se grabó audio (¿permiso de micrófono para la terminal?)"
  # --prompt sesga el vocabulario hacia los nombres reales de los proyectos.
  text="$(whisper-cli -m "$WHISPER_MODEL" -l es -nt -np --prompt "Proyectos: $(printf '%s, ' $projects)" -f "$tmp/in.wav" 2>/dev/null | tr -s ' \n' ' ' | sed 's/^ *//;s/ *$//')"
fi
[ -n "$text" ] || die "No entendí nada."
echo "${D}» ${text}${N}"

# ---- 2. Interpretar con el modelo local --------------------------------------
curl -sf "$OLLAMA/api/tags" >/dev/null || die "Ollama no está corriendo: brew services start ollama"

system="Convertís lo que dice el usuario (español rioplatense) en acciones sobre listas de tareas.
Proyectos válidos (usá el nombre EXACTO o \"\" si no se nombra ninguno o no estás seguro):
$(printf '%s\n' "$projects" | sed 's/^/- /')

Reglas:
- accion: \"agregar\" para tareas nuevas; \"hecho\" si dice que algo está hecho/terminado/listo o pide marcarlo.
- tarea: la tarea en infinitivo, corta, sin el nombre del proyecto ni palabras como agregá/anotá/en.
- privada: true solo si dice \"para mí\", \"mía\" o \"personal\".
- Si menciona varias tareas, un item por cada una.

Ejemplos:
\"en racingsur agregá probar el login con google\" → {\"items\":[{\"accion\":\"agregar\",\"proyecto\":\"racingsur\",\"privada\":false,\"tarea\":\"probar el login con google\"}]}
\"para mí, llamar a Andi por el presupuesto\" → {\"items\":[{\"accion\":\"agregar\",\"proyecto\":\"\",\"privada\":true,\"tarea\":\"llamar a Andi por el presupuesto\"}]}
\"marcá como hecho el backup de postgres en racingsur\" → {\"items\":[{\"accion\":\"hecho\",\"proyecto\":\"racingsur\",\"privada\":false,\"tarea\":\"backup de postgres\"}]}"

schema='{"type":"object","properties":{"items":{"type":"array","items":{"type":"object","properties":{"accion":{"type":"string","enum":["agregar","hecho"]},"proyecto":{"type":"string"},"privada":{"type":"boolean"},"tarea":{"type":"string"}},"required":["accion","proyecto","privada","tarea"]}}},"required":["items"]}'

req="$(jq -n --arg m "$MODEL" --arg s "$system" --arg u "$text" --argjson f "$schema" \
  '{model:$m, stream:false, format:$f, options:{temperature:0}, keep_alive:"10m",
    messages:[{role:"system",content:$s},{role:"user",content:$u}]}')"
plan="$(curl -sf "$OLLAMA/api/chat" -d "$req" | jq -c '.message.content | fromjson | .items[]' 2>/dev/null)" \
  || die "El modelo no devolvió algo válido. ¿Está bajado? ollama pull $MODEL"
[ -n "$plan" ] || die "No encontré ninguna tarea en lo que dijiste."

# ---- Helpers -----------------------------------------------------------------
norm() { printf '%s' "$1" | tr 'A-Z_-' 'a-z  '; }

# Proyecto → nombre de carpeta real. Exacto, si no por coincidencia parcial;
# si hay 0 o varias, pregunta. Vacío = cancelar el item.
resolve_project() {
  local want="$1" n cands=() p ans i
  [ -z "$want" ] && { echo ""; return; }
  while IFS= read -r p; do
    [ "$(norm "$p")" = "$(norm "$want")" ] && { echo "$p"; return; }
    n="$(norm "$p")"
    case "$n" in *"$(norm "$want")"*) cands+=("$p") ;; esac
  done <<< "$projects"
  [ ${#cands[@]} -eq 1 ] && { echo "${cands[0]}"; return; }
  if [ ${#cands[@]} -gt 1 ]; then
    echo "${Y}¿Cuál \"$want\"?${N}" >&2
    for i in "${!cands[@]}"; do echo "  $((i+1))) ${cands[$i]}" >&2; done
    printf "  número (Enter = saltear): " >&2; read -r ans </dev/tty
    [[ "$ans" =~ ^[0-9]+$ ]] && [ "$ans" -ge 1 ] && [ "$ans" -le ${#cands[@]} ] && echo "${cands[$((ans-1))]}"
    return
  fi
  printf "${Y}No encuentro el proyecto \"%s\". Escribí el nombre (Enter = saltear):${N} " "$want" >&2
  read -r ans </dev/tty; [ -n "$ans" ] && resolve_project "$ans"
}

# Archivo de tareas destino (lo crea con los buckets si no existe).
tasks_file() {
  local proj="$1" priv="$2" f
  if [ "$priv" = true ]; then
    f="$(ls "$ROOT/$proj"/TASKS.*.local.md 2>/dev/null | head -1)"
    [ -n "$f" ] || f="$ROOT/$proj/TASKS.$user.local.md"
  else f="$ROOT/$proj/TASKS.md"; fi
  if [ ! -f "$f" ]; then
    printf '# Tasks — %s\n\n## Backlog\n\n## Done\n' "$proj" > "$f"
    if [ "$priv" = true ] && ! grep -qx '\*\.local\.md' "$ROOT/$proj/.gitignore" 2>/dev/null; then
      printf '\n# Private personal tasks\n*.local.md\n' >> "$ROOT/$proj/.gitignore"
    fi
  fi
  echo "$f"
}

# Inserta una línea al final de la sección "## <bucket>" (la crea si falta).
append_to() {
  local f="$1" bucket="$2" line="$3"
  awk -v b="## $bucket" -v l="$line" '
    { a[NR] = $0 }
    END {
      for (i = 1; i <= NR; i++) if (a[i] ~ "^" b) { s = i; break }
      if (!s) { for (i = 1; i <= NR; i++) print a[i]; print ""; print b; print l; exit }
      e = NR + 1
      for (i = s + 1; i <= NR; i++) if (a[i] ~ /^## /) { e = i; break }
      k = e - 1; while (k > s && a[k] ~ /^[ \t]*$/) k--
      for (i = 1; i <= k; i++) print a[i]
      print l
      for (i = k + 1; i <= NR; i++) print a[i]
    }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

# Mejor task abierta para un texto: "archivo<TAB>nro<TAB>línea" (por palabras en común).
find_task() {
  local want="$1"; shift
  awk -v w="$(norm "$want")" '
    BEGIN { n = split(w, ws, /[^a-z0-9áéíóúñü]+/) }
    /^[ ]*- \[ \]/ {
      l = tolower($0); s = 0
      for (i = 1; i <= n; i++) if (length(ws[i]) > 3 && index(l, ws[i])) s++
      if (s > best) { best = s; out = FILENAME "\t" FNR "\t" $0 }
    }
    END { if (best > 0) print out }' "$@" 2>/dev/null
}

# Mueve la línea N (+ sus líneas de continuación indentadas) a ## Done como [x].
mark_done() {
  local f="$1" nr="$2" moved
  moved="$(awk -v n="$nr" 'NR == n { sub(/- \[ \]/, "- [x]"); print; on = 1; next }
                          on && /^[ ]+[^ -]/ { print; next } { on = 0 }' "$f")"
  awk -v n="$nr" 'NR == n { on = 1; next } on && /^[ ]+[^ -]/ { next } { on = 0; print }' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  append_to "$f" Done "$moved"
}

# ---- 3. Plan + confirmación ---------------------------------------------------
actions=()
while IFS= read -r it; do
  acc="$(jq -r .accion <<< "$it")"; tarea="$(jq -r .tarea <<< "$it")"
  priv="$(jq -r .privada <<< "$it")"; proj="$(resolve_project "$(jq -r .proyecto <<< "$it")")"

  if [ "$acc" = agregar ]; then
    if [ -z "$proj" ]; then
      if [ "$priv" = true ] && [ -f "$PWD/.dublin-cockpit" ]; then proj="."  # personal sin proyecto → cockpit
      else echo "${Y}  ⤳ salteada (sin proyecto): $tarea${N}"; continue; fi
    fi
    actions+=("agregar"$'\t'"$proj"$'\t'"$priv"$'\t'"$tarea")
    dest="$proj"; [ "$proj" = "." ] && dest="cockpit"
    echo "  ${G}+${N} ${B}${dest}${N}$([ "$priv" = true ] && echo " (privada)") → $tarea"
  else
    if [ -n "$proj" ]; then files=("$ROOT/$proj"/TASKS*.md)
    else files=("$ROOT"/*/TASKS*.md); fi
    hit="$(find_task "$tarea" "${files[@]}")"
    if [ -z "$hit" ]; then echo "${Y}  ⤳ no encontré una task abierta para: $tarea${N}"; continue; fi
    actions+=("hecho"$'\t'"$hit")
    hf="${hit%%$'\t'*}"; hl="${hit##*$'\t'}"
    echo "  ${G}✓${N} ${B}$(basename "$(dirname "$hf")")${N} → hecho: ${hl#*- \[ \] }"
  fi
done <<< "$plan"

[ ${#actions[@]} -gt 0 ] || exit 0
printf "Enter = aplicar · n = cancelar: "; read -r ok </dev/tty
[ "$ok" = n ] && { echo "Cancelado."; exit 0; }

# ---- 4. Aplicar ---------------------------------------------------------------
for a in "${actions[@]}"; do
  IFS=$'\t' read -r kind x y z <<< "$a"
  if [ "$kind" = agregar ]; then
    if [ "$x" = "." ]; then f="$PWD/TASKS.$user.local.md"; [ -f "$f" ] || printf '# Tasks — personal\n\n## Backlog\n\n## Done\n' > "$f"
    else f="$(tasks_file "$x" "$y")"; fi
    append_to "$f" Backlog "- [ ] $z"
  else
    mark_done "$x" "$y"
  fi
done
echo "${G}✓ Listo.${N}"
