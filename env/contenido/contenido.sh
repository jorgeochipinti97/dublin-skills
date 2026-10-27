#!/usr/bin/env bash
# `ds contenido` — bandeja de ideas de contenido. La llenan los flujos de tipo "ideas"
# (ds panel → Flujos) y se elige en ds panel → Contenido (sí → Cola, no → Descartadas).
#   ds contenido add <proyecto> "<idea>" ["<gancho>"] ["<flujo>"] ["<ángulo>"] ["<tratamiento>"]
#     idea = título corto · gancho = la frase que abre el video · tratamiento = cómo filmarlo/editarlo
#   ds contenido list [bandeja|cola|produccion|publicado|descartadas]
#
# contenido.md (al lado de finanzas.md; $DUBLIN_CONTENIDO lo cambia), una idea por línea:
#   ## Bandeja      - 2026-10-27 | mi-app | La idea | El gancho | Contenido para proyectos | dolor | Cómo filmarlo
#   ## Cola / ## Producción / ## Publicado / ## Descartadas   (mismas líneas, movidas desde el panel)
set -euo pipefail

PROJECTS="${DUBLIN_PROJECTS:-$(head -1 "$HOME/.config/dublin/projects-root" 2>/dev/null || true)}"
PROJECTS="${PROJECTS/#\~/$HOME}"
FILE="${DUBLIN_CONTENIDO:-$([ -n "$PROJECTS" ] && echo "$(dirname "$PROJECTS")/contenido.md" || echo "$HOME/contenido.md")}"
SECS=("Bandeja" "Cola" "Producción" "Publicado" "Descartadas")

die() { echo "✗ $*" >&2; exit 1; }
clean() { printf '%s' "$1" | tr '\n|' '  ' | sed 's/  */ /g;s/^ //;s/ $//'; }

ensure() {
  [ -f "$FILE" ] || { printf '# Contenido\n' > "$FILE"; for s in "${SECS[@]}"; do printf '\n## %s\n' "$s" >> "$FILE"; done; }
  grep -qx '## Bandeja' "$FILE" || printf '\n## Bandeja\n' >> "$FILE"
}

cmd_add() {
  local proy idea gancho flujo angulo det line
  proy="$(clean "${1:-}")"; idea="$(clean "${2:-}")"; gancho="$(clean "${3:-}")"; flujo="$(clean "${4:-}")"; angulo="$(clean "${5:-}")"; det="$(clean "${6:-}")"
  [ -n "$proy" ] && [ -n "$idea" ] || die "Uso: ds contenido add <proyecto> \"<idea>\" [\"<gancho>\"] [\"<flujo>\"] [\"<ángulo>\"] [\"<tratamiento>\"]"
  ensure
  # Ya propuesta (en cualquier sección, incluidas las descartadas): no se repite.
  grep -qiF "| $proy | $idea |" "$FILE" && { echo "· ya estaba: $idea"; return 0; }
  line="- $(date +%F) | $proy | $idea | $gancho | $flujo"
  [ -n "$angulo$det" ] && line+=" | $angulo"
  [ -n "$det" ] && line+=" | $det"
  # Al final de ## Bandeja (antes de la próxima sección).
  awk -v l="$line" '
    $0 == "## Bandeja" { on = 1; print; next }
    on && /^## / { print l; print ""; on = 0 }
    on && /^[[:space:]]*$/ { blank++; next }
    on { while (blank > 0) { print ""; blank-- } }
    { print }
    END { if (on) print l }' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  echo "✓ a la bandeja: $idea"
}

cmd_list() {
  [ -f "$FILE" ] || { echo "Sin ideas todavía ($FILE)"; return 0; }
  local want="${1:-}"
  awk -v w="$want" '
    /^## / { s = substr($0, 4); k = tolower(s); gsub(/ó/, "o", k); show = (w == "" || k == tolower(w)); if (show) print "\n" s; next }
    show && /^- / { print "  " substr($0, 3) }' "$FILE"
}

case "${1:-list}" in
  add) shift; cmd_add "$@" ;;
  list) shift || true; cmd_list "${1:-}" ;;
  *) die "Uso: ds contenido add|list" ;;
esac
