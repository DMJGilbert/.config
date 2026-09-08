#!/usr/bin/env bash
set -euo pipefail

# Quality Gate — runs on Claude Code session Stop / TeammateIdle events.
# Only runs checks if uncommitted changes exist.
# Exit code 2 feeds errors back to Claude for fixing.
# Set QUALITY_GATE_ENFORCE=1 to make the gate blocking (exit 1).
# Set QUALITY_GATE_VERBOSE=1 to keep successful tool output (default: quiet on success).
# Set QUALITY_GATE_FULL=1 to include expensive checks (nix flake check).

FIX_MODE=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_MODE=1
      shift
      ;;
    *) shift ;;
  esac
done

# Claude Code delivers the hook payload as JSON on stdin. When a Stop hook
# blocks (exit 2), the next Stop carries stop_hook_active=true — if we block
# again on that one we loop until the harness force-quits the turn, which is
# exactly what happened the first time these hooks went live. Always succeed
# while the flag is set: the gate has already had its say this turn.
if [ ! -t 0 ]; then
  hook_input=$(cat 2>/dev/null || true)
  if [ -n "$hook_input" ] && command -v jq >/dev/null 2>&1; then
    if [ "$(printf '%s' "$hook_input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ]; then
      exit 0
    fi
  fi
fi

ENFORCE_MODE="${QUALITY_GATE_ENFORCE:-0}"
VERBOSE="${QUALITY_GATE_VERBOSE:-0}"

if ! git rev-parse --git-dir &>/dev/null; then
  exit 0
fi

# Only run if there are uncommitted changes vs HEAD (covers staged + unstaged).
if git diff --quiet HEAD 2>/dev/null; then
  exit 0
fi

# Failed tools accumulate here; each entry: "<tool> (exit <N>)"
declare -a failed_tools=()
declare -a logs=()

# Run `cmd args…`, label as `$1`. On non-zero exit, record the label + first
# lines of output for the summary; on zero exit, optionally echo when VERBOSE.
run_check() {
  local label="$1"
  shift
  local output rc
  output=$("$@" 2>&1) && rc=0 || rc=$?
  if [[ $rc -eq 0 ]]; then
    if [[ $VERBOSE == "1" && -n $output ]]; then
      printf '%s\n' "$output"
    fi
    return 0
  fi
  failed_tools+=("$label (exit $rc)")
  logs+=("--- $label ---" "$output" "")
  return 0 # don't propagate failure under set -e; summary handles final exit
}

echo "Running quality checks..."
changed_files=$(git diff --name-only HEAD 2>/dev/null || echo "")

# === Nix ===
if echo "$changed_files" | grep -q '\.nix$'; then
  echo "  Checking Nix..."
  if command -v treefmt &>/dev/null; then
    if [[ $FIX_MODE == "1" ]]; then
      treefmt 2>&1 || true
    else
      run_check "treefmt (formatting)" treefmt --fail-on-change
    fi
  fi
  if command -v statix &>/dev/null; then
    if [[ $FIX_MODE == "1" ]]; then
      statix fix . 2>&1 || true
    else
      run_check "statix" statix check .
    fi
  fi
  # nix flake check fully evaluates every configuration — minutes of wall-clock
  # on every Stop event. Opt in with QUALITY_GATE_FULL=1; treefmt + statix cover
  # the fast path and the real check happens at deploy.
  if [[ ${QUALITY_GATE_FULL:-0} == "1" ]] && command -v nix &>/dev/null && [[ -f flake.nix ]]; then
    run_check "nix flake check" nix flake check
  fi
fi

# === Rust ===
if echo "$changed_files" | grep -q '\.rs$'; then
  echo "  Checking Rust..."
  if command -v cargo &>/dev/null; then
    if [[ $FIX_MODE == "1" ]]; then
      cargo fmt 2>&1 || true
    fi
    run_check "cargo clippy" cargo clippy --quiet -- -D warnings
    run_check "cargo check" cargo check
  fi
fi

# === TypeScript ===
if echo "$changed_files" | grep -qE '\.(ts|tsx)$'; then
  echo "  Checking TypeScript..."
  if [[ -f package.json ]] && command -v npx &>/dev/null; then
    if [[ $FIX_MODE == "1" ]]; then
      npx eslint . --fix --quiet 2>&1 || true
    else
      run_check "eslint" npx eslint . --quiet
    fi
    run_check "tsc" npx tsc --noEmit
  fi
fi

# === Dart ===
if echo "$changed_files" | grep -q '\.dart$'; then
  echo "  Checking Dart..."
  if command -v dart &>/dev/null; then
    if [[ $FIX_MODE == "1" ]]; then
      dart fix --apply 2>&1 || true
    fi
    run_check "dart analyze" dart analyze
  fi
fi

echo "  Detecting tests..."

# Rust tests
if echo "$changed_files" | grep -q '\.rs$' && command -v cargo &>/dev/null && [[ -f Cargo.toml ]]; then
  run_check "cargo test" cargo test --quiet
fi

# TypeScript / JavaScript tests — use jq to detect a real `test` script
if echo "$changed_files" | grep -qE '\.(ts|tsx|js|jsx)$' && [[ -f package.json ]] && command -v jq &>/dev/null; then
  if jq -e '.scripts.test' package.json &>/dev/null; then
    run_check "npm test" npm test
  fi
fi

# Dart tests
if echo "$changed_files" | grep -q '\.dart$' && [[ -f pubspec.yaml ]]; then
  if command -v flutter &>/dev/null && grep -q "sdk: flutter" pubspec.yaml 2>/dev/null; then
    run_check "flutter test" flutter test
  elif command -v dart &>/dev/null; then
    run_check "dart test" dart test
  fi
fi

# === Report ===
if ((${#failed_tools[@]} > 0)); then
  {
    echo ""
    echo "============================================================"
    echo "Quality gate: ${#failed_tools[@]} failure(s)"
    echo "============================================================"
    for tool in "${failed_tools[@]}"; do
      echo "  ✗ $tool"
    done
    echo ""
    echo "--- detailed output ---"
    printf '%s\n' "${logs[@]}"
  } >&2

  if [[ $ENFORCE_MODE == "1" ]]; then
    exit 1
  else
    exit 2
  fi
fi

echo "Quality gate passed"
exit 0
