#!/usr/bin/env bash
# Claude Code Stop Hook: Quality Gates
# Stage 1 of workflow improvements - enforces code standards before session end
#
# Exit codes:
#   0 - All checks passed or no changes to check
#   2 - Quality issues found (feeds back to Claude for fixing)
#
# Supported languages:
#   - Nix (.nix) - alejandra, statix
#   - Markdown (.md) - markdownlint-cli2
#   - YAML (.yaml, .yml) - yamllint
#   - Lua (.lua) - stylua
#   - Rust (.rs) - cargo fmt
#   - JavaScript/TypeScript (.js, .ts, .jsx, .tsx) - prettier
#   - CSS (.css) - prettier
#   - HTML (.html) - prettier
#   - JSON (.json) - prettier
#   - Dart (.dart) - dart format
set -euo pipefail

CHECKS_RAN=false
CHANGED_FILES=""

# === QUALITY GATES ===
# Only run checks if there are uncommitted changes
if ! git diff --quiet HEAD 2>/dev/null; then
  CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)

  # --- Nix files ---
  if echo "$CHANGED_FILES" | grep -q '\.nix$'; then
    CHECKS_RAN=true
    echo ""
    echo "🔍 Checking Nix files..."

    echo "  → alejandra --check ."
    if ! alejandra --check . 2>&1 | head -5; then
      echo ""
      echo "❌ Nix formatting issues found"
      echo "   Run: alejandra ."
      exit 2
    fi

    echo "  → statix check ."
    if ! statix check . 2>&1 | head -5; then
      echo ""
      echo "❌ Nix linting issues found"
      echo "   Run: statix fix ."
      exit 2
    fi
  fi

  # --- Markdown files ---
  if echo "$CHANGED_FILES" | grep -q '\.md$'; then
    CHECKS_RAN=true
    echo ""
    echo "🔍 Checking Markdown files..."

    echo "  → markdownlint-cli2"
    if ! markdownlint-cli2 "**/*.md" 2>&1 | head -10; then
      echo ""
      echo "❌ Markdown linting issues found"
      echo "   Run: markdownlint-cli2 --fix '**/*.md'"
      exit 2
    fi
  fi

  # --- YAML files ---
  if echo "$CHANGED_FILES" | grep -qE '\.(ya?ml)$'; then
    CHECKS_RAN=true
    echo ""
    echo "🔍 Checking YAML files..."

    echo "  → yamllint -d relaxed ."
    if ! yamllint -d relaxed . 2>&1 | head -10; then
      echo ""
      echo "❌ YAML linting issues found"
      exit 2
    fi
  fi

  # --- Lua files ---
  if echo "$CHANGED_FILES" | grep -q '\.lua$'; then
    CHECKS_RAN=true
    echo ""
    echo "🔍 Checking Lua files..."

    echo "  → stylua --check ."
    if ! stylua --check . 2>&1 | head -5; then
      echo ""
      echo "❌ Lua formatting issues found"
      echo "   Run: stylua ."
      exit 2
    fi
  fi

  # --- Rust files ---
  if echo "$CHANGED_FILES" | grep -q '\.rs$'; then
    if [ -f "Cargo.toml" ] && command -v cargo &>/dev/null; then
      CHECKS_RAN=true
      echo ""
      echo "🔍 Checking Rust files..."

      echo "  → cargo fmt -- --check"
      if ! cargo fmt -- --check 2>&1 | head -10; then
        echo ""
        echo "❌ Rust formatting issues found"
        echo "   Run: cargo fmt"
        exit 2
      fi
    fi
  fi

  # --- JavaScript/TypeScript/CSS/HTML/JSON files ---
  if echo "$CHANGED_FILES" | grep -qE '\.(js|ts|jsx|tsx|css|html|json)$'; then
    if command -v prettier &>/dev/null; then
      CHECKS_RAN=true
      echo ""
      echo "🔍 Checking JS/TS/CSS/HTML/JSON files..."

      echo "  → prettier --check"
      # Use xargs -0 to handle filenames with spaces safely
      if ! echo "$CHANGED_FILES" | grep -E '\.(js|ts|jsx|tsx|css|html|json)$' | tr '\n' '\0' | xargs -0 prettier --check 2>&1 | head -10; then
        echo ""
        echo "❌ Formatting issues found"
        echo "   Run: prettier --write ."
        exit 2
      fi
    fi
  fi

  # --- Dart files ---
  if echo "$CHANGED_FILES" | grep -q '\.dart$'; then
    if [ -f "pubspec.yaml" ] && command -v dart &>/dev/null; then
      CHECKS_RAN=true
      echo ""
      echo "🔍 Checking Dart files..."

      echo "  → dart format --set-exit-if-changed --output=none ."
      if ! dart format --set-exit-if-changed --output=none . 2>&1 | head -10; then
        echo ""
        echo "❌ Dart formatting issues found"
        echo "   Run: dart format ."
        exit 2
      fi
    fi
  fi

  if [ "$CHECKS_RAN" = true ]; then
    echo ""
    echo "✅ Quality checks passed"
  fi
fi

# === SESSION RETROSPECTIVE ===
# Log session summary for learning flywheel
RETRO_DIR="$HOME/.local/share/claude-retrospectives"
RETRO_LOG="$RETRO_DIR/sessions.jsonl"

# Only log if we have git changes and aren't in a Ralph loop
if [ -n "$CHANGED_FILES" ] && [ ! -f "$HOME/.cache/claude-ralph/active" ]; then
  mkdir -p "$RETRO_DIR"

  # Gather session metrics
  SESSION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")
  FILES_CHANGED=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
  DOMAINS=$(echo "$CHANGED_FILES" | sed 's/.*\.//' | sort -u | tr '\n' ',' | sed 's/,$//')

  # Log as JSONL for easy parsing
  echo "{\"date\":\"$SESSION_DATE\",\"project\":\"$PROJECT_NAME\",\"files_changed\":$FILES_CHANGED,\"domains\":\"$DOMAINS\"}" >>"$RETRO_LOG"

  echo ""
  echo "📝 Session logged: $PROJECT_NAME ($FILES_CHANGED files, domains: $DOMAINS)"
  echo "   Run /retrospective to analyze patterns"
fi

# === RALPH LOOP ===
# Autonomous iteration - continues session if flag file exists
RALPH_DIR="$HOME/.cache/claude-ralph"

if [ -f "$RALPH_DIR/active" ]; then
  # Read iteration counter (validate numeric, default to 1 if invalid)
  ITERATION=1
  if [ -f "$RALPH_DIR/iteration" ]; then
    ITERATION=$(<"$RALPH_DIR/iteration")
    if ! [[ "$ITERATION" =~ ^[0-9]+$ ]]; then
      ITERATION=1
    fi
  fi

  # Read max iterations (validate numeric, default to 10 if invalid)
  MAX_ITERATIONS=10
  if [ -f "$RALPH_DIR/max" ]; then
    MAX_ITERATIONS=$(<"$RALPH_DIR/max")
    if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
      MAX_ITERATIONS=10
    fi
  fi

  # Check iteration limit
  if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    echo ""
    echo "==================================================="
    echo " RALPH LOOP - Max iterations ($MAX_ITERATIONS) reached"
    echo "==================================================="
    rm -rf "$RALPH_DIR"
    exit 0
  fi

  # Increment counter
  echo $((ITERATION + 1)) >"$RALPH_DIR/iteration"

  # Continue loop - exit 2 feeds back to Claude
  echo ""
  echo "==================================================="
  echo " RALPH LOOP - Iteration $((ITERATION + 1))/$MAX_ITERATIONS"
  echo "==================================================="
  echo ""
  echo "Continuing task. Review progress and take the next step."
  echo "When complete, run: rm ~/.cache/claude-ralph/active"
  echo ""
  exit 2
fi

exit 0
