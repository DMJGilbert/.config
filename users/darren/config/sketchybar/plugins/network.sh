#!/usr/bin/env bash
set -uo pipefail

# ifstat may come from Homebrew or from nixpkgs (ifstat-legacy). Prefer PATH so
# the script isn't pinned to one package manager, falling back to the known
# Homebrew locations.
IFSTAT=""
for candidate in ifstat /opt/homebrew/bin/ifstat /usr/local/bin/ifstat; do
    if command -v "$candidate" >/dev/null 2>&1; then
        IFSTAT="$candidate"
        break
    fi
done

DOWN=""
UP=""
if [ -n "$IFSTAT" ]; then
    UPDOWN=$("$IFSTAT" -i en0 -b 0.1 1 2>/dev/null | tail -n1) || UPDOWN=""
    read -r DOWN UP _ <<<"${UPDOWN:-}"
fi

# Drop any fractional part, then fall back to 0. Previously an empty or failed
# ifstat left these unset and `[ "$DOWN" -gt 999 ]` aborted with
# "integer expression expected".
DOWN="${DOWN%%.*}"
UP="${UP%%.*}"
[[ "$DOWN" =~ ^[0-9]+$ ]] || DOWN=0
[[ "$UP" =~ ^[0-9]+$ ]] || UP=0

format_rate() {
    if [ "$1" -gt 999 ]; then
        awk -v v="$1" 'BEGIN { printf "%03.0f Mbps", v / 1000 }'
    else
        awk -v v="$1" 'BEGIN { printf "%03.0f kbps", v }'
    fi
}

highlight() {
    if [ "$1" -gt 0 ]; then echo "on"; else echo "off"; fi
}

sketchybar -m \
    --set network_down label=" $(format_rate "$DOWN")" icon.highlight="$(highlight "$DOWN")" \
    --set network_up label=" $(format_rate "$UP")" icon.highlight="$(highlight "$UP")"
