#!/usr/bin/env bash
# Daily rollup of every project under <projects-root>, as markdown on stdout.
# Zero LLM tokens: pure file parsing. Used by `ds status` and by
# session-context-loader.sh in a cockpit (dir with a .dublin-cockpit file).
#
# Per project: last SESSION.md log entry (+ its Next/Blockers), TASKS.md
# Doing + top of Backlog, open items in TASKS.<user>.local.md.
set -uo pipefail

ROOT="${1:?usage: projects-status.sh <projects-root>}"
STALE_DAYS="${STALE_DAYS:-30}"
TOP_BACKLOG=3
user="$(git config user.name 2>/dev/null | awk '{print tolower($1)}')"
[ -z "$user" ] && user="$(whoami)"
today="$(date +%Y-%m-%d)"
cutoff="$(date -v-"${STALE_DAYS}"d +%Y-%m-%d 2>/dev/null || date -d "-${STALE_DAYS} days" +%Y-%m-%d)"

# Open items of one bucket: section "## <name>" → "- [ ] …" lines (max $3).
bucket() {
  awk -v b="$2" -v max="$3" '
    /^## / { inb = ($0 ~ "^## " b) ; next }
    inb && /^[ ]*- \[ \]/ && n < max { print; n++ }' "$1" 2>/dev/null
}

# Last dated log entry of a SESSION.md ("- YYYY-MM-DD — …") + its sub-bullets.
last_entry() {
  awk '
    /^- [0-9]{4}-[0-9]{2}-[0-9]{2}/ { e = $0; sub_ = ""; on = 1; next }
    on && /^[ ]+- / { sub_ = sub_ "\n" $0; next }
    on && !/^[ ]*$/ { on = 0 }
    END { if (e != "") { if (length(e) > 240) e = substr(e, 1, 240) "…"; print e sub_ } }' "$1"
}

blocks="" stale="" nosession=""
for dir in "$ROOT"/*/; do
  dir="${dir%/}"; name="$(basename "$dir")"
  session=""
  for f in "$dir"/[Ss][Ee][Ss][Ss][Ii][Oo][Nn].md; do [ -f "$f" ] && session="$f"; done
  if [ -z "$session" ]; then nosession+="${name}, "; continue; fi

  entry="$(last_entry "$session")"
  day="$(printf '%s' "$entry" | head -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)"
  [ -z "$day" ] && day="$(date -r "$session" +%Y-%m-%d)"
  if [[ "$day" < "$cutoff" ]]; then stale+="${name} (${day}), "; continue; fi

  b="## ${name} · ${day}"$'\n'
  [ -n "$entry" ] && b+="${entry}"$'\n'
  if [ -f "$dir/TASKS.md" ]; then
    doing="$(bucket "$dir/TASKS.md" Doing 99)"
    next="$(bucket "$dir/TASKS.md" Backlog "$TOP_BACKLOG")"
    [ -n "$doing" ] && b+=$'\n'"**Doing**"$'\n'"${doing}"$'\n'
    [ -n "$next" ] && b+=$'\n'"**Backlog (top ${TOP_BACKLOG})**"$'\n'"${next}"$'\n'
  fi
  mine="$(grep -E '^[ ]*- \[ \]' "$dir/TASKS.${user}.local.md" 2>/dev/null)"
  [ -n "$mine" ] && b+=$'\n'"**Mías**"$'\n'"${mine}"$'\n'
  blocks+="${day}"$'\t'"$(printf '%s' "$b" | base64 | tr -d '\n')"$'\n'
done

echo "# Status — ${today}"
echo
echo "> Generado por \`ds status\` desde \`${ROOT}\`. No editar a mano."
echo "> Activos = log en los últimos ${STALE_DAYS} días, más reciente primero."
echo
printf '%s' "$blocks" | sort -r | while IFS=$'\t' read -r _ enc; do
  [ -n "$enc" ] && { printf '%s' "$enc" | base64 -d; echo; }
done
[ -n "$stale" ] && { echo "## Sin movimiento (>${STALE_DAYS} días)"; echo "${stale%, }"; echo; }
[ -n "$nosession" ] && { echo "## Sin SESSION.md"; echo "${nosession%, }"; }
exit 0
