#!/usr/bin/env bash
# Dublin change-safety guard — PreToolUse hook for Bash.
# Reads the tool-call JSON from stdin, blocks (exit 2) destructive ops so the
# agent is forced to run the change-safety protocol first. Zero LLM tokens.
#
# Wired by ./install.sh team into .claude/settings.json (Claude Code).
# Exit codes: 0 = allow, 2 = block (stderr is fed back to the agent).

set -euo pipefail

input="$(cat)"

# Extract the command. Prefer jq; fall back to a grep if jq is absent.
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // ""')"
else
  cmd="$(printf '%s' "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//; s/"$//')"
fi

[ -z "$cmd" ] && exit 0

block() {
  echo "🛑 change-safety guard: $1" >&2
  echo "" >&2
  echo "This looks like a destructive / production-affecting operation." >&2
  echo "Before running it, complete the change-safety protocol:" >&2
  echo "  1. Tested snapshot/backup   4. In-flight transaction check" >&2
  echo "  2. Written rollback plan    5. Declared off-peak change window" >&2
  echo "  3. Stakeholder + on-call    6. Second-human approval (medium+)" >&2
  echo "" >&2
  echo "If this is safe (local/dev/throwaway), re-run noting that explicitly." >&2
  exit 2
}

# Normalize to lowercase for matching.
lc="$(printf '%s' "$cmd" | tr '[:upper:]' '[:lower:]')"

# --- Destructive SQL ---------------------------------------------------------
case "$lc" in
  *"drop table"*|*"drop database"*|*"drop schema"*|*truncate*)
    block "destructive SQL (DROP/TRUNCATE) detected" ;;
esac
# UPDATE / DELETE without a WHERE clause.
if printf '%s' "$lc" | grep -Eq '\b(update|delete)\b' && ! printf '%s' "$lc" | grep -Eq '\bwhere\b'; then
  block "UPDATE/DELETE without a WHERE clause"
fi

# --- Destructive Git ---------------------------------------------------------
case "$lc" in
  *"push --force"*|*"push -f"*|*"push --force-with-lease"*)
    block "force push to a remote branch" ;;
  *"reset --hard"*)
    block "git reset --hard (discards work)" ;;
  *"--no-verify"*)
    block "--no-verify bypasses commit/push hooks (banned)" ;;
esac

exit 0
