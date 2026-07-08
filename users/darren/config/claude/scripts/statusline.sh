#!/usr/bin/env bash
# Claude Code status line: model | directory | git branch | context usage.
# Receives session JSON on stdin (see https://code.claude.com/docs/en/statusline).
set -euo pipefail

input=$(cat)

model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // "?"' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // 0 | floor' <<<"$input")

branch=$(git -C "$dir" branch --show-current 2>/dev/null || true)

dim=$'\033[2m'
bold=$'\033[1m'
reset=$'\033[0m'

ctx_colour=$'\033[32m' # green
if [ "$ctx" -ge 80 ]; then
  ctx_colour=$'\033[31m' # red
elif [ "$ctx" -ge 60 ]; then
  ctx_colour=$'\033[33m' # yellow
fi

line="${bold}${model}${reset} ${dim}|${reset} ${dir/#$HOME/\~}"
if [ -n "$branch" ]; then
  line+=" ${dim}|${reset}  ${branch}"
fi
line+=" ${dim}|${reset} ${ctx_colour}${ctx}%${reset} ctx"

printf '%s\n' "$line"
