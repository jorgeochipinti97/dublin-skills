#!/usr/bin/env bash
# SessionStart hook (Claude Code only).
# Injects the project's persistent context into the model at session start so it
# never has to "remember" to read it: team-memory facts + SESSION.md state, plus
# a LOUD warning when the engram binary is missing (persistent memory silently
# dead otherwise). Output is added to context via SessionStart `additionalContext`.
#
# Installed to <project>/.claude/hooks/ by `install.sh install`.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
MEM_DIR="$PROJECT_DIR/.claude/team-memory"
SESSION="$PROJECT_DIR/SESSION.md"
nl=$'\n'

body=""

# 0. HARD RULES banner — first thing in context every session, so the rules stay
#    salient instead of decaying inside a long CLAUDE.md. Anti-hallucination lever.
body+="⚠️ HARD RULES (no negociables, valen sobre todo lo demás):${nl}"
body+="1. CERO INVENTOS — verificá (READ/CHECK/ASK) antes de afirmar nada del código."
body+=" Nunca inventes archivos, funciones, flags, endpoints o APIs. \"No sé / dejame"
body+=" verificar\" es la respuesta correcta, no una debilidad. Si no se puede verificar"
body+=" en el repo, decilo explícito.${nl}"
body+="2. NO SUPONGAS — ante ambigüedad, PREGUNTÁ antes de actuar. No asumas requisitos,"
body+=" rutas ni intención.${nl}"
body+="3. FINISH NOW — no difieras lo que se puede terminar ahora; si está bloqueado,"
body+=" decí exactamente qué falta.${nl}"
body+="4. CHANGE-SAFETY — antes de tocar prod (DB/tienda/deploy/infra/DNS/secrets):"
body+=" snapshot probado + rollback + comms + ventana + aprobación.${nl}${nl}"

# 1. engram health — the single most common silent failure (per-machine binary).
if ! command -v engram >/dev/null 2>&1; then
  body+="🔴 ENGRAM NO ESTÁ INSTALADO en esta máquina — la memoria persistente"
  body+=" (mem_save / mem_search / mem_session_start) NO funciona. Las decisiones"
  body+=" NO se guardan entre sesiones. Instalá una vez:"
  body+="${nl}    brew install gentleman-programming/tap/engram"
  body+="${nl}Hasta entonces: avisá al dev al inicio y registrá decisiones en SESSION.md como fallback.${nl}${nl}"
fi

# 2. Team memory — the seeded hard rules + facts. Re-injected every session so
#    they stay salient instead of decaying inside a long CLAUDE.md.
if [ -d "$MEM_DIR" ]; then
  mem=""
  for f in "$MEM_DIR"/*.md; do
    [ -e "$f" ] || continue
    [ "$(basename "$f")" = "MEMORY.md" ] && continue   # index, not a fact
    mem+="$(cat "$f")${nl}${nl}"
  done
  if [ -n "$mem" ]; then
    body+="## Team memory — reglas y hechos del equipo (vigentes)${nl}${nl}${mem}"
  fi
fi

# 3. SESSION.md — current project state (what's in progress / next / blockers).
if [ -f "$SESSION" ]; then
  body+="## SESSION.md — estado actual del proyecto${nl}${nl}$(cat "$SESSION")${nl}"
fi

# 4. "Tus tasks en este repo" — incomplete tasks tagged with your @handle.
if [ -f "$PROJECT_DIR/TASKS.md" ]; then
  handle="$(git -C "$PROJECT_DIR" config user.name 2>/dev/null | awk '{print tolower($1)}')"
  [ -z "$handle" ] && handle="$(whoami)"
  mine="$(grep -E '^[ ]*- \[ \]' "$PROJECT_DIR/TASKS.md" 2>/dev/null | grep -F "@${handle}" || true)"
  if [ -n "$mine" ]; then
    body+="${nl}## Tus tasks pendientes en este repo (@${handle})${nl}${nl}${mine}${nl}"
  fi
fi

[ -z "$body" ] && exit 0

# Emit as SessionStart additionalContext. jq does safe JSON escaping; if jq is
# absent, plain stdout is still added to context by SessionStart.
if command -v jq >/dev/null 2>&1; then
  jq -n --arg ctx "$body" \
    '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
else
  printf '%s' "$body"
fi
exit 0
