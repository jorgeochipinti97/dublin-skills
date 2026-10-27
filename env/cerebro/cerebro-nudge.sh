#!/usr/bin/env bash
# UserPromptSubmit hook (Claude Code, user scope): si el pedido habla de un tema que
# tiene cerebro, le recuerda al agente consultarlo antes de decidir. Cero tokens de LLM:
# solo matchea palabras clave y agrega contexto.
#
# Cada cerebro declara sus temas en su cerebro.md, una línea:
#   temas: interfaz, ui, diseño, pantalla, componente
# Raíz: $DUBLIN_CEREBROS → ~/.config/dublin/cerebros-root. Sin raíz o sin match: no hace nada.
set -uo pipefail

ROOT="${DUBLIN_CEREBROS:-$(head -1 "$HOME/.config/dublin/cerebros-root" 2>/dev/null)}"
ROOT="${ROOT/#\~/$HOME}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
command -v jq >/dev/null || exit 0

# Minúsculas y sin acentos, para que "diseño" matchee "diseno" y viceversa.
norm() { perl -CSD -MUnicode::Normalize -pe '$_ = lc NFD($_); s/\pM//g'; }
prompt="$(jq -r '.prompt // empty' | norm)"
[ -n "$prompt" ] || exit 0

ctx=""
for md in "$ROOT"/*/cerebro.md; do
  [ -f "$md" ] || continue
  temas="$(sed -n 's/^temas: *//p' "$md" | head -1)"
  [ -n "$temas" ] || continue
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
jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
