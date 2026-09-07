#!/usr/bin/env bash
# PostToolUse hook: format the file Claude Code just wrote.
#
# Reads the hook payload on stdin and dispatches on file extension. Dispatch
# happens here rather than via per-handler `if` predicates so the matching
# rules live in one testable place.
#
# Always exits 0 — a formatter that is missing, or that fails on a file the
# model is midway through editing, must never block the tool call.
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

# Run only if the formatter is actually on PATH.
run() {
  command -v "$1" >/dev/null 2>&1 || return 0
  "$@" || true
}

case "$file" in
*.nix) run alejandra --quiet "$file" ;;
*.rs) run rustfmt "$file" ;;
*.ts | *.tsx | *.js | *.jsx | *.css | *.html | *.json | *.md | *.yaml | *.yml)
  run prettier --write "$file"
  ;;
*.dart) run dart format "$file" ;;
*.lua) run stylua "$file" ;;
*.py) run ruff format "$file" ;;
esac

exit 0
