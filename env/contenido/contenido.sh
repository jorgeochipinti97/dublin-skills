#!/usr/bin/env bash
# `ds contenido` — bandeja de ideas de contenido. La llenan los flujos de tipo "ideas"
# (ds panel → Flujos) y se elige en ds panel → Contenido (sí → Cola, no → Descartadas).
#   ds contenido add <proyecto> "<idea>" ["<gancho>"] ["<flujo>"] ["<ángulo>"] ["<tratamiento>"]
#     idea = título corto · gancho = la frase que abre el video · tratamiento = cómo filmarlo/editarlo
#   ds contenido list [bandeja|cola|produccion|publicado|descartadas]
#   ds contenido mover "<parte del título o gancho>" <bandeja|cola|produccion|publicado|descartadas>
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
  # Filtro duro: lo que suena a error interno no es contenido, lo mande quien lo mande.
  local todo; todo="$(printf '%s %s %s' "$idea" "$gancho" "$det" | perl -CSD -MUnicode::Normalize -pe '$_ = lc NFD($_); s/\pM//g')"
  if grep -qE '\b(bugs?|error(es)?|falla(s|ron)?|fallo|crash|incidentes?|hotfix|deuda tecnica|migracion|mal (cargad|anotad|importad)|(se|fue) (anoto|cargo|importo) (mal|distinto)|duplicad[oa]s?|inconsistenc|datos? (sucio|corrupt|rot))' <<< "$todo"; then
    die "No va a la bandeja: parece salir de un error interno del sistema (bug, dato mal cargado, incidente). El contenido sale de lo que el producto le resuelve al cliente, no de los problemas del sistema."
  fi
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

cmd_mover() {
  local q="${1:-}" to sec n
  [ -n "$q" ] && [ -n "${2:-}" ] || die "Uso: ds contenido mover \"<parte del título o gancho>\" <bandeja|cola|produccion|publicado|descartadas>"
  case "$(printf '%s' "$2" | tr 'A-Z' 'a-z')" in
    bandeja) sec="Bandeja" ;; cola) sec="Cola" ;; produccion|producción) sec="Producción" ;;
    publicado|publicada) sec="Publicado" ;; descartadas|descartada) sec="Descartadas" ;; *) die "Sección desconocida: $2" ;;
  esac
  [ -f "$FILE" ] || die "No hay ideas todavía"
  n="$(grep "^- [0-9]" "$FILE" | grep -ciF -- "$q" || true)"
  [ "$n" -eq 1 ] || die "«${q}» coincide con ${n} ideas: escribí un pedazo más preciso del título o el gancho."
  awk -v q="$q" -v sec="$sec" '
    { a[NR] = $0 }
    END {
      lq = tolower(q)
      for (i = 1; i <= NR; i++) if (a[i] ~ /^- [0-9]/ && index(tolower(a[i]), lq)) { m = a[i]; skip = i; break }
      for (i = 1; i <= NR; i++) { if (i == skip) continue; out[++n] = a[i] }
      # al final de la sección destino (antes de la siguiente "## ")
      for (i = 1; i <= n; i++) if (out[i] == "## " sec) { s = i; break }
      if (!s) { out[++n] = ""; out[++n] = "## " sec; s = n }
      e = n + 1; for (i = s + 1; i <= n; i++) if (out[i] ~ /^## /) { e = i; break }
      k = e - 1; while (k > s && out[k] ~ /^[ \t]*$/) k--
      for (i = 1; i <= k; i++) print out[i]; print m; for (i = k + 1; i <= n; i++) print out[i]
    }' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
  echo "✓ a ${sec}: $q"
}

case "${1:-list}" in
  add) shift; cmd_add "$@" ;;
  list) shift || true; cmd_list "${1:-}" ;;
  mover) shift; cmd_mover "$@" ;;
  *) die "Uso: ds contenido add|list" ;;
esac
