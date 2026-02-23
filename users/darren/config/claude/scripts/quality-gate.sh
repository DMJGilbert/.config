#!/usr/bin/env bash
set -euo pipefail

# Quality Gate - runs on Claude Code session Stop event
# Only runs checks if uncommitted changes exist
# Exit code 2 feeds errors back to Claude for fixing
# Set QUALITY_GATE_ENFORCE=1 to make gate blocking (exit 1)

# Parse arguments
FIX_MODE=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_MODE=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

ENFORCE_MODE="${QUALITY_GATE_ENFORCE:-0}"

# Check if we're in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
  exit 0
fi

# Only run if uncommitted changes exist
if git diff --quiet HEAD 2>/dev/null; then
  exit 0
fi

echo "Running quality checks..."
errors=0

# Get list of changed files
changed_files=$(git diff --name-only HEAD 2>/dev/null || echo "")

# Check Nix files
if echo "$changed_files" | grep -q '\.nix$'; then
  echo "  Checking Nix..."
  if command -v alejandra &>/dev/null; then
    if [ "$FIX_MODE" = "1" ]; then
      echo "    Fixing Nix formatting..."
      alejandra --quiet . 2>&1 || true
    fi
  fi
  if command -v statix &>/dev/null; then
    statix_output=$(statix check . 2>&1 || true)
    if [ -n "$statix_output" ]; then
      echo "$statix_output"
      if [ "$FIX_MODE" = "1" ]; then
        statix fix . 2>&1 || true
      else
        ((errors++)) || true
      fi
    fi
  fi
  if command -v nix &>/dev/null; then
    if ! nix flake check 2>&1; then
      ((errors++)) || true
    fi
  fi
fi

# Check Rust files
if echo "$changed_files" | grep -q '\.rs$'; then
  echo "  Checking Rust..."
  if command -v cargo &>/dev/null; then
    if [ "$FIX_MODE" = "1" ]; then
      echo "    Fixing Rust formatting..."
      cargo fmt 2>&1 || true
    fi
    if ! cargo clippy --quiet 2>&1; then
      ((errors++)) || true
    fi
    if ! cargo check 2>&1; then
      ((errors++)) || true
    fi
  fi
fi

# Check TypeScript files
if echo "$changed_files" | grep -qE '\.(ts|tsx)$'; then
  echo "  Checking TypeScript..."
  if [ -f "package.json" ]; then
    if command -v npx &>/dev/null; then
      if [ "$FIX_MODE" = "1" ]; then
        echo "    Fixing TypeScript lint issues..."
        npx eslint . --fix --quiet 2>&1 || true
      else
        npx eslint . --quiet 2>&1 || ((errors++)) || true
      fi
      npx tsc --noEmit 2>&1 || ((errors++)) || true
    fi
  fi
fi

# Check Dart files
if echo "$changed_files" | grep -q '\.dart$'; then
  echo "  Checking Dart..."
  if command -v dart &>/dev/null; then
    if [ "$FIX_MODE" = "1" ]; then
      echo "    Fixing Dart issues..."
      dart fix --apply 2>&1 || true
    fi
    dart analyze 2>&1 || ((errors++)) || true
  fi
fi

# Test detection and execution
echo "  Detecting tests..."

# Rust tests
if echo "$changed_files" | grep -q '\.rs$'; then
  if command -v cargo &>/dev/null && [ -f "Cargo.toml" ]; then
    echo "    Running Rust tests..."
    if ! cargo test --quiet 2>&1; then
      ((errors++)) || true
    fi
  fi
fi

# TypeScript/JavaScript tests
if echo "$changed_files" | grep -qE '\.(ts|tsx|js|jsx)$'; then
  if [ -f "package.json" ] && command -v npm &>/dev/null; then
    if npm run --silent 2>&1 | grep -q "test"; then
      echo "    Running npm tests..."
      if ! npm test 2>&1; then
        ((errors++)) || true
      fi
    fi
  fi
fi

# Dart tests
if echo "$changed_files" | grep -q '\.dart$'; then
  if [ -f "pubspec.yaml" ]; then
    if command -v flutter &>/dev/null && grep -q "sdk: flutter" pubspec.yaml 2>/dev/null; then
      echo "    Running Flutter tests..."
      if ! flutter test 2>&1; then
        ((errors++)) || true
      fi
    elif command -v dart &>/dev/null; then
      echo "    Running Dart tests..."
      if ! dart test 2>&1; then
        ((errors++)) || true
      fi
    fi
  fi
fi

# Nix flake check (if flake.nix changed)
if echo "$changed_files" | grep -q 'flake\.nix'; then
  if command -v nix &>/dev/null; then
    echo "    Running nix flake check..."
    if ! nix flake check 2>&1; then
      ((errors++)) || true
    fi
  fi
fi

# Report results
if [ $errors -gt 0 ]; then
  echo "Quality gate found $errors issue(s)"
  if [ "$ENFORCE_MODE" = "1" ]; then
    exit 1  # Blocking failure
  else
    exit 2  # Feed back to Claude
  fi
fi

echo "Quality gate passed"
exit 0
