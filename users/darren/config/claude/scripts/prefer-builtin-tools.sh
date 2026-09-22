#!/usr/bin/env bash
# PreToolUse hook: route Bash file reads, searches and whole-file rewrites to
# the built-in Read/Grep/Glob/Edit/Write tools.
#
# Auto mode's system prompt instructs the model to reach for cat/head/grep/sed
# instead of the dedicated tools. Those Bash calls then match an `ask` rule or
# go to the auto mode classifier, while the built-in tools are auto-approved
# with no review at all — so the shell route buys a permission prompt and no
# extra capability. A system-level instruction only loses to a hook, which is
# why the redirect lives here and not in CLAUDE.md.
#
# Only unambiguous single-command cases are denied; anything carrying a pipe,
# redirect, substitution or chained command passes through untouched.
# Set CLAUDE_ALLOW_BASH_FILE_TOOLS=1 to disable.
#
# Always exits 0 — exit 2 would block on a payload this script failed to parse.
set -uo pipefail

[ "${CLAUDE_ALLOW_BASH_FILE_TOOLS:-0}" = "1" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Paths the model is expected to script against freely.
is_scratch() {
  case "$1" in
    /dev/* | /tmp/* | /private/tmp/* | "$TMPDIR"* | \$TMPDIR* | *scratchpad/*) return 0 ;;
    *) return 1 ;;
  esac
}

# An in-place sed rewrite is unreviewable and silently drops anything the
# pattern mangles, so it is denied wherever it appears, pipeline or not.
if [[ $cmd =~ (^|[^[:alnum:]_/-])sed[[:space:]] ]] && [[ $cmd =~ [[:space:]]-i([[:space:]]|$|\'|\.) ]]; then
  deny "Use the Edit tool instead of 'sed -i'. Edit fails loudly on a stale or ambiguous match where sed corrupts the file silently, and Edit needs no permission prompt."
fi

# A heredoc redirected at a tracked file retypes the whole file; anything not
# retyped (Nerd Font glyphs, PUA codepoints) is lost without an error.
if [[ $cmd == *"<<"* ]]; then
  target=""
  if [[ $cmd =~ \>+[[:space:]]*\"?\'?([^[:space:]\"\'\|\;\&\<\>]+) ]]; then
    target="${BASH_REMATCH[1]}"
  elif [[ $cmd =~ (^|[^[:alnum:]_/-])tee[[:space:]]+(-a[[:space:]]+)?\"?\'?([^[:space:]\"\'\|\;\&\<\>-][^[:space:]\"\'\|\;\&\<\>]*) ]]; then
    target="${BASH_REMATCH[3]}"
  fi
  if [ -n "$target" ] && ! is_scratch "$target"; then
    deny "Use the Write tool (new file) or Edit (existing file) instead of a heredoc redirect to '$target'. A heredoc rewrite destroys every byte not retyped. Heredocs into \$TMPDIR or the scratchpad are fine."
  fi
fi

# `cd <dir> && …` is how the model usually prefixes exploration; judge the
# command that actually runs.
rest="$cmd"
while [[ $rest =~ ^cd[[:space:]]+\"?[^[:space:]\"\&\;\|]+\"?[[:space:]]*\&\&[[:space:]]* ]]; do
  rest="${rest#"${BASH_REMATCH[0]}"}"
done

# Beyond a single plain invocation the shell is doing real work; leave it be.
case "$rest" in
  *[\|\<\>\;\&\`]* | *"\$("* | *$'\n'*) exit 0 ;;
esac

read -r -a argv <<<"$rest" || exit 0
[ "${#argv[@]}" -gt 0 ] || exit 0
tool="${argv[0]##*/}"

case " ${argv[*]} " in
  *" --help "* | *" --version "*) exit 0 ;;
esac

has_operand() {
  local arg
  for arg in "${argv[@]:1}"; do
    [[ $arg == -* ]] || return 0
  done
  return 1
}

case "$tool" in
  cat | head | tail)
    has_operand || exit 0
    # Read has no equivalent of following a growing file.
    case " ${argv[*]} " in
      *" -f "* | *" -F "* | *" --follow"*) exit 0 ;;
    esac
    deny "Use the Read tool instead of '$tool'. Read is auto-approved with no permission prompt, and it injects the path-scoped rules from ~/.claude/rules that cat/head/tail bypass."
    ;;
  sed)
    [[ " ${argv[*]} " == *" -n "* ]] || exit 0
    has_operand || exit 0
    deny "Use the Read tool (with offset/limit for a line range) instead of 'sed -n'. Read needs no permission prompt and injects the path-scoped rules that sed bypasses."
    ;;
  grep | egrep | fgrep | rg | ag)
    has_operand || exit 0
    deny "Use the Grep tool instead of '$tool'. It runs ripgrep, is auto-approved with no permission prompt, and takes pattern/glob/output_mode directly."
    ;;
  find)
    case " ${argv[*]} " in
      *" -exec "* | *" -execdir "* | *" -ok "* | *" -delete "*) exit 0 ;;
    esac
    deny "Use the Glob tool instead of 'find'. Glob is auto-approved with no permission prompt; 'find' matches an ask rule and prompts every time."
    ;;
esac

exit 0
