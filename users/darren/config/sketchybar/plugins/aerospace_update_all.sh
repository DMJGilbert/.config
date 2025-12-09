#!/opt/local/bin/bash

# This script updates ALL workspace highlighting at once
# Gets called on aerospace_workspace_change event

# Get focused workspace from environment variable or query aerospace
focused="${FOCUSED_WORKSPACE:-$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)}"

# Log for debugging
echo "[$(date)] aerospace_update_all.sh triggered, focused=$focused, env=$FOCUSED_WORKSPACE" >> /tmp/sketchybar_debug.log

# Update all workspaces
for ws in W R C P F; do
    if [ "$ws" = "$focused" ]; then
        echo "[$(date)] Setting $ws to ON" >> /tmp/sketchybar_debug.log
        /etc/profiles/per-user/darren/bin/sketchybar --set space.$ws background.drawing=on
    else
        /etc/profiles/per-user/darren/bin/sketchybar --set space.$ws background.drawing=off
    fi
done
