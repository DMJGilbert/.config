#!/opt/local/bin/bash

# Get focused workspace from environment variable or query aerospace as fallback
focused="${FOCUSED_WORKSPACE}"
if [ -z "$focused" ]; then
    focused=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)
fi

if [ "$1" = "$focused" ]; then
    sketchybar --set space.$1 background.drawing=on
else
    sketchybar --set space.$1 background.drawing=off
fi
