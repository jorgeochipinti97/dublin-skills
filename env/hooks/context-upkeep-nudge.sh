#!/usr/bin/env bash
# Stop hook (Claude Code only). Write-side of context upkeep (TEAM-RULES §7):
# if this session changed source files but left SESSION.md unlogged, force the
# agent to update context before stopping. exit 2 + stderr makes Claude continue;
# guarded by stop_hook_active so it nudges ONCE and never loops.
#
# Installed to <project>/.claude/hooks/ by `install.sh install`.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# Only act inside a Dublin project (has SESSION.md) that is a git repo.
[ -f "$PROJECT_DIR/SESSION.md" ] || exit 0
git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Read the hook payload; bail to "let it stop" if we already nudged this round.
input="$(cat 2>/dev/null || true)"
if command -v jq >/dev/null 2>&1; then
  [ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ] && exit 0
else
  printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
fi

status="$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null)"
[ -z "$status" ] && exit 0   # clean tree → nothing to log

# Source work = any change that is NOT itself a context-tracking file.
src_changed="$(printf '%s\n' "$status" | grep -vE 'SESSION\.md|TASKS[^/]*\.md|\.dublin-env' || true)"
session_touched="$(printf '%s\n' "$status" | grep -E 'SESSION\.md' || true)"

if [ -n "$src_changed" ] && [ -z "$session_touched" ]; then
  n="$(printf '%s\n' "$src_changed" | grep -c .)"
  {
    echo "⚠️ Context upkeep pendiente: cambiaste $n archivo(s) y SESSION.md sigue sin actualizar."
    echo "Antes de cerrar (TEAM-RULES §7): (1) marcá la task hecha en el TASKS.md que corresponda,"
    echo "(2) appendeá una línea fechada a SESSION.md (qué cambió · próximo · blockers, podá lo viejo),"
    echo "(3) guardá cualquier decisión no-obvia en engram (mem_save). Después frená."
  } >&2
  exit 2
fi
exit 0
