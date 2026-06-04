#!/usr/bin/env bash
set -euo pipefail

# session-start.sh — emit Claude Code systemMessage JSON for SessionStart hook.
# jq escapes branch / commit values so a stray quote or newline can't break the
# hook's JSON payload (which would silently drop the message).
#
# Usage: session-start.sh <default|compact>

mode="${1:-default}"
branch="$(git branch --show-current 2>/dev/null || echo none)"

case "$mode" in
  default)
    commit="$(git log --oneline -1 2>/dev/null || echo none)"
    jq -nc \
      --arg branch "$branch" \
      --arg commit "$commit" \
      '{systemMessage: "Branch: \($branch) | Last commit: \($commit)"}'
    ;;
  compact)
    jq -nc \
      --arg branch "$branch" \
      '{systemMessage: "Post-compaction reminder: Check task list for in-progress work. Re-read any files you were actively editing. Current branch: \($branch)"}'
    ;;
  *)
    echo "session-start.sh: unknown mode '$mode' (expected default|compact)" >&2
    exit 1
    ;;
esac
