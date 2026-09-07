#!/usr/bin/env bash
set -uo pipefail

# Updates ALL workspace highlighting at once, on aerospace_workspace_change.

AEROSPACE=/etc/profiles/per-user/darren/bin/aerospace
SKETCHYBAR=/etc/profiles/per-user/darren/bin/sketchybar

focused="${FOCUSED_WORKSPACE:-$("$AEROSPACE" list-workspaces --focused)}"

for ws in W R C P F; do
    if [ "$ws" = "$focused" ]; then
        "$SKETCHYBAR" --set "space.$ws" background.drawing=on
    else
        "$SKETCHYBAR" --set "space.$ws" background.drawing=off
    fi
done
