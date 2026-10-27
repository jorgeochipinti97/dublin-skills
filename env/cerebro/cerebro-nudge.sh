#!/usr/bin/env bash
# UserPromptSubmit hook (Claude Code, user scope): si el pedido habla de un tema que
# tiene cerebro, le recuerda al agente consultarlo antes de decidir. Cero tokens de LLM:
# solo matchea palabras clave y agrega contexto.
#
# Cada cerebro declara sus temas en su cerebro.md, una línea:
#   temas: interfaz, ui, diseño, pantalla, componente
# Además lee <raíz>/flujos.md (ds panel → Flujos): sugiere /flujo cuando el pedido nombra una
# palabra de "disparo:", y conectado como PostToolUse del tool Skill inyecta los pasos de los
# flujos de consulta que listan esa skill.
# Raíz: $DUBLIN_CEREBROS → ~/.config/dublin/cerebros-root. Sin raíz o sin match: no hace nada.
set -uo pipefail

ROOT="${DUBLIN_CEREBROS:-$(head -1 "$HOME/.config/dublin/cerebros-root" 2>/dev/null)}"
ROOT="${ROOT/#\~/$HOME}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
command -v jq >/dev/null || exit 0

# Minúsculas y sin acentos, para que "diseño" matchee "diseno" y viceversa.
norm() { perl -CSD -MUnicode::Normalize -pe '$_ = lc NFD($_); s/\pM//g'; }
in="$(cat)"
event="$(jq -r '.hook_event_name // "UserPromptSubmit"' <<< "$in")"
skill="$(jq -r '.tool_input.skill // empty' <<< "$in" | sed 's/.*://')"   # "plugin:skill" → "skill"
prompt="$(jq -r '.prompt // empty' <<< "$in" | norm)"
[ -n "$prompt$skill" ] || exit 0

# ¿La palabra/skill $1 aparece? Con skill: comparación exacta; con pedido: palabra entera.
matches() { if [ -n "$skill" ]; then [ "$1" = "$skill" ]; else grep -qiw -- "$1" <<< "$prompt"; fi; }

# Flujos (ds panel → Flujos; la lógica vive en env/flujo/flujo.sh). Tres formas de correrlos:
#  - /flujo <nombre> [proyectos]: explícito, trae los pasos.
#  - El agente interpreta: en cada pedido recibe la lista corta de flujos y decide él si el pedido
#    lo pide de verdad (no por una palabra suelta: "el contenido para el login" no es un flujo).
#    Las palabras de "disparo:" son pistas que se le marcan, no disparadores.
#  - Por skill (PostToolUse): inyecta los pasos, solo en flujos de consulta (agregan contexto, no producen nada).
FLUJO="$(dirname "$0")/../flujo/flujo.sh"
ctx="" enflujo=" " lista=""
case "$prompt" in /flujo*) exit 0 ;; esac   # /flujo ya trae los pasos
if [ -f "$ROOT/flujos.md" ] && [ -f "$FLUJO" ]; then
  while IFS=$'\x1f' read -r flow tipo trig sks cers text; do
    [ -n "$flow" ] && [ -n "$text" ] || continue
    slug="$(printf '%s' "$flow" | norm | sed 's/[^a-z0-9]\{1,\}/-/g;s/^-//;s/-$//')"
    if [ -n "$skill" ]; then
      [ "$tipo" != ideas ] || continue
      IFS=',' read -ra L <<< "$sks"; m=""
      for k in "${L[@]}"; do k="$(printf '%s' "$k" | sed 's/^ *//;s/ *$//')"; [ "$k" = "$skill" ] && m=1; done
      [ -n "$m" ] || continue
      enflujo+="$cers "; ctx+="$(bash "$FLUJO" "$slug")"$'\n'
    else
      pista=""
      IFS=',' read -ra L <<< "$trig"
      for k in "${L[@]}"; do k="$(printf '%s' "$k" | norm | sed 's/^ *//;s/ *$//')"; [ -n "$k" ] && matches "$k" && { pista=" ← el pedido dice «${k}»"; break; }; done
      lista+="  · ${slug} — «${flow}» (${tipo})${pista}"$'\n'
    fi
  done < <(bash "$FLUJO" records)
  [ -n "$lista" ] && ctx+="🧭 Flujos disponibles:"$'\n'"${lista}Si el pedido del usuario realmente pide lo que hace uno de estos flujos (juzgalo por la intención, no por una palabra suelta; una tarea de código casi nunca lo es), corré \`ds flujo <nombre> <proyectos>\` y seguí los pasos que imprime. Si dudás, preguntale en una línea. Si no aplica, ignorá esto sin mencionarlo."$'\n'
fi

for md in "$ROOT"/*/cerebro.md; do
  [ -f "$md" ] || continue
  temas="$(sed -n 's/^temas: *//p' "$md" | head -1)"
  [ -n "$temas" ] && [ -n "$prompt" ] || continue
  case "$enflujo" in *" $(basename "$(dirname "$md")") "*) continue ;; esac   # ya va dentro de un flujo
  hit=""
  IFS=',' read -ra kws <<< "$temas"
  for k in "${kws[@]}"; do
    k="$(printf '%s' "$k" | norm | sed 's/^ *//;s/ *$//')"
    [ -n "$k" ] && grep -qiw -- "$k" <<< "$prompt" && { hit="$k"; break; }
  done
  [ -n "$hit" ] || continue
  slug="$(basename "$(dirname "$md")")"; title="$(head -1 "$md" | sed 's/^# //')"
  n="$(awk '/^## /{on=($0=="## Fuentes"); next} on && /^- /' "$md" | grep -c .)"
  ctx+="🧠 Cerebro relevante: «${title}» (${n} fuentes en NotebookLM). Antes de decidir algo de ${hit}, consultalo con: ds cerebro ask ${slug} \"<pregunta concreta sobre este caso>\". Usá la respuesta y decile al usuario en una línea qué tomaste del cerebro. Si el pedido no es de diseño/decisión, ignorá esto."$'\n'
done

[ -n "$ctx" ] || exit 0
jq -n --arg c "$ctx" --arg e "$event" '{hookSpecificOutput:{hookEventName:$e,additionalContext:$c}}'
