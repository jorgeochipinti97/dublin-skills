#!/usr/bin/env zsh
# CI board builder — runs in the TEAM HUB repo (e.g. GitHub Actions), NOT locally.
# Clones every repo listed in REGISTRY.md (shallow), maps them, and reuses
# `ds team-board` to regenerate BOARD.md + members/. The workflow commits the result.
#
# Auth for private repos is handled by the workflow (git insteadOf + token), so this
# script just `git clone`s the URLs as written in REGISTRY.md.
#
# Usage:  DS=/path/to/dublin-skills/install.sh  zsh build-board-ci.sh [<hub-dir>]
emulate -L zsh
set -uo pipefail

HUB="${1:-$PWD}"
: "${DS:?set DS=/path/to/dublin-skills/install.sh}"
[[ -f "$HUB/REGISTRY.md" ]] || { print -r -- "no REGISTRY.md in $HUB"; exit 1 }

WORK="$HUB/.board-ci-repos"
rm -rf "$WORK"; mkdir -p "$WORK"
: > "$HUB/team.local.md"

local line proj rest url
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" == '|'* ]] || continue
    rest="${line#|}"
    proj="${rest%%|*}"; proj="${proj// /}"
    [[ -z "$proj" || "$proj" == "proyecto" || "$proj" == -* ]] && continue
    rest="${rest#*|}"; url="${rest%%|*}"; url="${url// /}"
    [[ -z "$url" ]] && continue
    print -r -- "cloning ${proj} ← ${url}"
    if git clone --depth 1 "$url" "$WORK/$proj" >/dev/null 2>&1; then
        print -r -- "${proj}=${WORK}/${proj}" >> "$HUB/team.local.md"
    else
        print -r -- "  ! clone falló: ${proj} (¿acceso/URL?)"
    fi
done < "$HUB/REGISTRY.md"

( cd "$HUB" && zsh "$DS" team-board )
rm -rf "$WORK"
