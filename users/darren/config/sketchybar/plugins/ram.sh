#!/usr/bin/env bash
set -uo pipefail

# memory_pressure reports free percentage; display the used percentage.
# Strip any trailing "%" before arithmetic rather than relying on awk's
# string-to-number coercion.
LABEL=$(memory_pressure 2>/dev/null | awk '
    /System-wide memory free percentage:/ {
        gsub(/%/, "", $5)
        printf "%02.0f", 100 - $5
        found = 1
    }
    END { if (!found) printf "" }
')

if [ -n "$LABEL" ]; then
    sketchybar -m --set ram_percentage label="${LABEL}%"
else
    sketchybar -m --set ram_percentage label="N/A"
fi
