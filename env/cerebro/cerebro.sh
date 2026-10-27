#!/usr/bin/env bash
# `ds cerebro` — cerebros de estudio: carpeta local en markdown ⇄ notebook de NotebookLM.
#
#   ds cerebro new "<Tema>" [fuente…]   crea carpeta + notebook (+ fuentes)
#   ds cerebro add <tema> <fuente…>     agrega fuentes (URL, YouTube, archivo) y sube
#   ds cerebro sync [<tema>]            sube lo que falta, trae fuentes nuevas y
#                                       baja tarjetas, exámenes y reportes
#   ds cerebro ask <tema> "<pregunta>"  pregunta al notebook; guarda la Q&A en preguntas.md
#   ds cerebro list
#
# La carpeta es la fuente de verdad (cerebro.md). Sync nunca borra: une ambos lados.
set -uo pipefail

CONF="$HOME/.config/dublin/cerebros-root"
B=$'\e[1m'; G=$'\e[32m'; Y=$'\e[33m'; R=$'\e[31m'; D=$'\e[2m'; N=$'\e[0m'
die() { echo "${R}$*${N}" >&2; exit 1; }
nlm() { notebooklm --quiet "$@"; }

command -v notebooklm >/dev/null || die "Falta notebooklm-py: uv tool install \"notebooklm-py[browser]\" && notebooklm login --browser chrome"
command -v jq >/dev/null || die "Falta jq: brew install jq"

# ---- Carpeta raíz: $DUBLIN_CEREBROS → config → preguntar una vez -------------
if [ -n "${DUBLIN_CEREBROS:-}" ]; then ROOT="$DUBLIN_CEREBROS"
elif [ -f "$CONF" ]; then ROOT="$(head -1 "$CONF")"
else
  printf "${Y}¿Carpeta donde guardar los cerebros?${N} "; read -r ROOT
  ROOT="${ROOT/#\~/$HOME}"; mkdir -p "$ROOT" "$(dirname "$CONF")"; printf '%s\n' "$ROOT" > "$CONF"
fi
mkdir -p "$ROOT"

# iconv de macOS translitera "é" como "'e": se borran esas marcas antes de armar el slug.
slug() { printf '%s' "$1" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null | tr -d "'\`^~\"" | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '-' | sed 's/^-//;s/-$//'; }

# Carpeta de un tema: exacto, si no la única que lo contenga.
dir_of() {
  local s; s="$(slug "$1")"
  [ -f "$ROOT/$s/cerebro.md" ] && { echo "$ROOT/$s"; return; }
  local m; m="$(cd "$ROOT" && ls -d *"$s"*/ 2>/dev/null)"
  [ "$(printf '%s\n' "$m" | grep -c .)" -eq 1 ] && { echo "$ROOT/${m%/}"; return; }
  die "No encuentro el cerebro \"$1\". Cerebros: $(cd "$ROOT" && ls -d */ 2>/dev/null | tr -d / | tr '\n' ' ')"
}
nb_of() { sed -n 's/^notebook: *//p' "$1/cerebro.md" | head -1; }

# Fuentes listadas en cerebro.md (sección ## Fuentes), sin el "- " ni comentarios.
local_sources() {
  awk '/^## /{on=($0=="## Fuentes"); next} on && /^- /{sub(/^- /,""); sub(/  +\(.*\)$/,""); print}' "$1/cerebro.md"
}
add_line() {  # agrega "- <x>" al final de ## Fuentes
  awk -v l="- $2" '{a[NR]=$0} END{for(i=1;i<=NR;i++) if(a[i]=="## Fuentes"){s=i;break}
    e=NR+1; for(i=s+1;i<=NR;i++) if(a[i]~/^## /){e=i;break}
    k=e-1; while(k>s && a[k]~/^[ \t]*$/) k--
    for(i=1;i<=k;i++) print a[i]; print l; for(i=k+1;i<=NR;i++) print a[i]}' "$1/cerebro.md" > "$1/cerebro.md.tmp" \
    && mv "$1/cerebro.md.tmp" "$1/cerebro.md"
}

# Sube una fuente (URL / YouTube / archivo relativo a la carpeta).
upload() {
  local dir="$1" nb="$2" src="$3" out
  if [ -f "$dir/$src" ]; then out="$(nlm source add -n "$nb" "$dir/$src" --follow-symlinks --json 2>/dev/null)"  # symlink = libro que vive en otra carpeta
  else out="$(nlm source add -n "$nb" "$src" --json 2>/dev/null)"; fi
  if jq -e '.source.id' <<< "$out" >/dev/null 2>&1; then echo "  ${G}↑${N} $src"
  else echo "  ${Y}⚠ no se pudo subir (o quedó en duda): $src${N}"; fi
}

# Flashcards JSON → formato del plugin Spaced Repetition de Obsidian.
cards_md() {
  jq -r '"# " + .title + "\n\n#flashcards\n\n" +
    ([.cards[] | ([.front.flashcardContentBlock[].content] | join("\n")) + "\n?\n" +
                 ([.back.flashcardContentBlock[].content] | join("\n"))] | join("\n\n"))' "$1"
}

cmd_new() {
  local tema="$1"; shift
  [ -n "$tema" ] || die "Uso: ds cerebro new \"<Tema>\" [fuente…]"
  local dir="$ROOT/$(slug "$tema")"
  [ -f "$dir/cerebro.md" ] && die "Ya existe: $dir"
  local nb; nb="$(nlm create "$tema" --json | jq -r '.id // .notebook.id // .notebook_id')"
  [ -n "$nb" ] && [ "$nb" != null ] || die "No pude crear el notebook en NotebookLM."
  mkdir -p "$dir"
  printf '# %s\n\nnotebook: %s\n\n## Fuentes\n\n## Notas\n' "$tema" "$nb" > "$dir/cerebro.md"
  echo "${G}✓ Cerebro \"$tema\"${N} → $dir"
  local s; for s in "$@"; do add_line "$dir" "$s"; upload "$dir" "$nb" "$s"; done
}

cmd_add() {
  local dir nb s; dir="$(dir_of "${1:?Uso: ds cerebro add <tema> <fuente…>}")"; shift
  nb="$(nb_of "$dir")"
  for s in "$@"; do add_line "$dir" "$s"; upload "$dir" "$nb" "$s"; done
}

cmd_sync_one() {
  local dir="$1" nb remote s
  nb="$(nb_of "$dir")"; echo "${B}$(basename "$dir")${N}"
  remote="$(nlm source list -n "$nb" --json)" || { echo "  ${Y}⚠ no pude leer el notebook${N}"; return; }

  # 1. local → NotebookLM: fuentes que no están (por URL o título).
  while IFS= read -r s; do
    [ -z "$s" ] && continue
    jq -e --arg s "$s" --arg b "$(basename "$s")" \
      '.sources[] | select(.url == $s or .title == $s or .title == $b)' <<< "$remote" >/dev/null \
      || upload "$dir" "$nb" "$s"
  done <<< "$(local_sources "$dir")"

  # 2. NotebookLM → local: fuentes agregadas allá (web, research) que no figuran acá.
  local have; have="$(local_sources "$dir")"; have="$have"$'\n'"$(sed 's|.*/||' <<< "$have")"  # archivos: también por nombre, sin carpeta
  jq -r '.sources[] | select(.status == "ready") | (.url // .title)' <<< "$remote" | while IFS= read -r s; do
    grep -qxF "$s" <<< "$have" || { add_line "$dir" "$s  (desde NotebookLM)"; echo "  ${G}↓${N} fuente: $s"; }
  done

  # 3. Artefactos de Studio → archivos (tarjetas para repasar, exámenes, reportes para leer).
  # studio/.bajados = ids ya bajados (dos artefactos con el mismo título no se pisan: el segundo lleva el id).
  mkdir -p "$dir/studio"
  local arts id title type tmp out seen="$dir/studio/.bajados"; arts="$(nlm artifact list -n "$nb" --json 2>/dev/null)"
  [ -f "$seen" ] || : > "$seen"
  jq -r '.artifacts[]? | select(.status == "completed") | [.id, .title, .type_id] | @tsv' <<< "$arts" |
  while IFS=$'\t' read -r id title type; do
    grep -qxF "$id" "$seen" && continue
    case "$type" in
      flashcards) out="$dir/studio/tarjetas-$(slug "$title").md"; [ -f "$out" ] && out="${out%.md}-${id:0:8}.md"
        tmp="$(mktemp)"
        nlm download flashcards -n "$nb" -a "$id" --format json --force "$tmp" >/dev/null 2>&1 \
          && cards_md "$tmp" > "$out" && echo "$id" >> "$seen" && echo "  ${G}↓${N} tarjetas: $title"; rm -f "$tmp" ;;
      quiz) out="$dir/studio/examen-$(slug "$title").json"; [ -f "$out" ] && out="${out%.json}-${id:0:8}.json"   # preguntas tipo examen, las toma ds panel
        nlm download quiz -n "$nb" -a "$id" --format json --force "$out" >/dev/null 2>&1 && echo "$id" >> "$seen" && echo "  ${G}↓${N} examen: $title" ;;
      report) out="$dir/studio/reporte-$(slug "$title").md"; [ -f "$out" ] && out="${out%.md}-${id:0:8}.md"
        nlm download report -n "$nb" -a "$id" --force "$out" >/dev/null 2>&1 && echo "$id" >> "$seen" && echo "  ${G}↓${N} reporte: $title" ;;
    esac
  done
}

cmd_sync() {
  if [ -n "${1:-}" ]; then cmd_sync_one "$(dir_of "$1")"; return; fi
  local d; for d in "$ROOT"/*/; do [ -f "$d/cerebro.md" ] && cmd_sync_one "${d%/}"; done
}

cmd_ask() {
  local dir nb q ans; dir="$(dir_of "${1:?Uso: ds cerebro ask <tema> \"<pregunta>\"}")"; q="${2:?Falta la pregunta}"
  nb="$(nb_of "$dir")"
  ans="$(nlm ask -n "$nb" "$q" --json | jq -r '.answer')" || die "NotebookLM no respondió."
  printf '%s\n' "$ans"
  printf '\n## %s — %s\n\n%s\n' "$(date +%Y-%m-%d)" "$q" "$ans" >> "$dir/preguntas.md"
}

cmd_list() {
  local d; for d in "$ROOT"/*/; do
    [ -f "$d/cerebro.md" ] || continue
    printf '%s  %s(%s fuentes)%s\n' "$(head -1 "$d/cerebro.md" | sed 's/^# //')" "$D" "$(local_sources "${d%/}" | grep -c .)" "$N"
  done
}

case "${1:-}" in
  new)  shift; cmd_new "$@" ;;
  add)  shift; cmd_add "$@" ;;
  sync) shift; cmd_sync "${1:-}" ;;
  ask)  shift; cmd_ask "$@" ;;
  list|"") cmd_list ;;
  *) die "Comandos: new, add, sync, ask, list" ;;
esac
