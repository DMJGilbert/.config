#!/usr/bin/env bash
set -uo pipefail

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)

if [ -n "$PERCENTAGE" ]; then
    sketchybar --set battery label="$PERCENTAGE%"
else
    sketchybar --set battery label="N/A"
fi
