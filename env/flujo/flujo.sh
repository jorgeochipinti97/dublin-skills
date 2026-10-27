#!/usr/bin/env bash
# `ds flujo` — corre un flujo de cerebros (se arman en ds panel → Flujos). Lo llama el comando
# /flujo de Claude Code, que es la forma de activarlos: explícita, con nombre, nunca por adivinar.
#   ds flujo                              lista los flujos
#   ds flujo <nombre> [proyecto…]         imprime los pasos para el agente (nombre parcial: "contenido")
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
  awk -v root="$ROOT" '
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
        cers = cers " " cer[id]
        out = out "\x1e  [" num[id] "] ds cerebro ask " cer[id] " \"" (pq[id] == "" ? "<pregunta concreta sobre este caso>" : pq[id]) "\"" (nx == "" ? "  → fin" : "  → después: " nx) }
      if (h > 1) printf "%s\x1f%s\x1f%s\x1f%s\x1f%s\x1f%s\n", name, (tipo == "" ? "consulta" : tipo), trig, sks, cers, out
      name = ""; tipo = ""; trig = ""; sks = ""; ne = 0; split("", cer); split("", pq); split("", seen); split("", num)
    }
    /^## / { flush(); name = substr($0, 4); next }
    /^tipo:/ { tipo = $2; next }
    /^disparo:/ { trig = substr($0, 9); next }
    /^skills:/ { sks = substr($0, 8); next }
    /^- [A-Za-z0-9_]+ [^ ]+/ && name != "" { l = $0; sub(/ @ -?[0-9]+,-?[0-9]+[ \t]*$/, "", l); id = $2; c = $3
      if (system("test -f \"" root "/" c "/cerebro.md\"") != 0) next
      cer[id] = c; p = index(l, " | "); pq[id] = p ? substr(l, p + 3) : ""; next }
    /^> [A-Za-z0-9_]+ [A-Za-z0-9_]+/ && name != "" { ne++; ef[ne] = $2; et[ne] = $3; p = index($0, " | "); ec[ne] = p ? substr($0, p + 3) : ""; next }
    END { flush() }' "$FILE"
}

# Los pasos de un flujo, listos para el agente.
steps() {  # nombre tipo pasos [proyecto…]
  local flow="$1" tipo="$2" text="$3"; shift 3
  local proys="${*:-}"
  echo "🧭 Flujo «${flow}»${proys:+ para: ${proys// /, }}. Consultá estos cerebros siguiendo el camino, aplicando cada pregunta a este caso y usando cada respuesta en lo que sigue:"
  printf '%s\n' "${text//$'\x1e'/$'\n'}"
  echo "Después decile al usuario en una línea qué tomaste de cada cerebro (y qué rama elegiste, si hubo)."
  if [ "$tipo" = ideas ]; then
    if [ -n "$proys" ]; then echo "Es un flujo de IDEAS: no implementes nada. Proyectos: ${proys// /, }."
    else echo "Es un flujo de IDEAS: no implementes nada. El usuario no dijo para qué proyectos: preguntáselo antes de empezar."; fi
    echo "Leé el SESSION.md y el TASKS.md de cada proyecto, mirá \`ds contenido list\` para no repetir (tampoco las descartadas) y dejá cada idea en la bandeja con:"
    echo "  ds contenido add <proyecto> \"<idea>\" \"<gancho>\" \"${flow}\""
    echo "Al final decile cuántas dejaste: las elige en ds panel → Contenido."
  fi
}

[ -n "$ROOT" ] && [ -d "$ROOT" ] || { echo "No hay carpeta de cerebros configurada."; exit 1; }

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
    IFS=$'\x1f' read -r flow tipo _ _ _ text <<< "${lines[0]}"
    steps "$flow" "$tipo" "$text" "$@" ;;
esac
