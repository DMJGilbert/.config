#!/usr/bin/env bash
# Wrapper script for mcp-figma that reads API key from sops secrets
# Uses @thirdstrandstudio/mcp-figma which supports stdio by default

FIGMA_KEY="${FIGMA_API_KEY:-$(cat /run/secrets/FIGMA_API_KEY 2>/dev/null)}"

if [ -z "$FIGMA_KEY" ]; then
  echo "Error: FIGMA_API_KEY not set and /run/secrets/FIGMA_API_KEY not found" >&2
  exit 1
fi

exec npx -y @thirdstrandstudio/mcp-figma --figma-token "$FIGMA_KEY"
