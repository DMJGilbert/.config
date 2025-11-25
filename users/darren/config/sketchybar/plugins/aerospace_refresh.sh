#!/opt/local/bin/bash

# Colors (Catppuccin Frappe inspired)
export BG_COLOR=0xff414559
export FG_COLOR=0xffffffff
export ACTIVE_COLOR=0xcc00c1ad

# Plugin directory
export PLUGINS_DIR="$HOME/.config/sketchybar/plugins"

# Workspace definitions: key -> icon
# W = Work, C = Communication, P = Personal, F = Fun
declare -A workspace_icons=(
    ["W"]=""
    ["R"]=""
    ["C"]="󰍡"
    ["P"]=""
    ["F"]="󰝚"
)
declare -A workspace_default_montiors=(
    ["W"]="2"
    ["R"]="2"
    ["C"]="1"
    ["P"]="1"
    ["F"]="1"
)

declare -A monitors
while IFS=" " read -r monitor_id display_id; do
    monitors["$monitor_id"]="$display_id"
done < <(/etc/profiles/per-user/darren/bin/aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}')

all_workspaces=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --all)
focused_workspace=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)

for ws in $all_workspaces; do
    /etc/profiles/per-user/darren/bin/sketchybar --remove space.$ws 2>/dev/null
done

workspace_order=("W" "R" "C" "P" "F")

declare -A workspace_to_monitor
for monitor_id in "${!monitors[@]}"; do
    for ws in $(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --monitor $monitor_id); do
        workspace_to_monitor["$ws"]="$monitor_id"
    done
done

for ws in "${workspace_order[@]}"; do
    monitor_id="${workspace_default_montiors[$ws]}"
    if [[ -v workspace_to_monitor[$ws] ]]; then
        monitor_id="${workspace_to_monitor[$ws]}"
    fi
    icon="󰨹"
    if [[ -v workspace_icons[$ws] ]]; then
        icon="${workspace_icons[$ws]}"
    fi
    bg_drawing="off"
    if [[ "$ws" == "$focused_workspace" ]]; then
        bg_drawing="on"
    fi
    /etc/profiles/per-user/darren/bin/sketchybar -m --add space space.$ws left \
        --set space.$ws \
        display="${monitors[$monitor_id]}" \
        background.drawing="$bg_drawing" \
        background.color=$ACTIVE_COLOR \
        icon="$icon" \
        click_script="/etc/profiles/per-user/darren/bin/aerospace workspace $ws"
done

# Brief sleep to ensure aerospace has settled after workspace moves
sleep 0.1

# Re-query focused workspace to get the current state (not the stale one from the beginning)
current_focused=$(/etc/profiles/per-user/darren/bin/aerospace list-workspaces --focused)

# Directly update each workspace's background state instead of relying on events
for ws in "${workspace_order[@]}"; do
    if [[ "$ws" == "$current_focused" ]]; then
        /etc/profiles/per-user/darren/bin/sketchybar --set space.$ws background.drawing=on
    else
        /etc/profiles/per-user/darren/bin/sketchybar --set space.$ws background.drawing=off
    fi
done
