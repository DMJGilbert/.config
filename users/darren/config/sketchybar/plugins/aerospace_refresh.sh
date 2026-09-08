#!/usr/bin/env bash
set -uo pipefail

# Requires bash 4+ for associative arrays. Under the launchd agent this
# resolves to the Nix bash, but aerospace.toml invokes this script via
# exec-and-forget, where `env bash` can resolve to macOS's /bin/bash 3.2 —
# which rejects `declare -A`. Re-exec under a bash 4+ if we landed on an old one.
if [ -z "${BASH_VERSINFO:-}" ] || [ "${BASH_VERSINFO[0]}" -lt 4 ]; then
    for candidate in \
        /run/current-system/sw/bin/bash \
        /etc/profiles/per-user/darren/bin/bash \
        /opt/homebrew/bin/bash; do
        if [ -x "$candidate" ]; then
            exec "$candidate" "$0" "$@"
        fi
    done
    echo "aerospace_refresh.sh requires bash 4+ (found ${BASH_VERSION:-unknown})" >&2
    exit 1
fi

AEROSPACE=/etc/profiles/per-user/darren/bin/aerospace
SKETCHYBAR=/etc/profiles/per-user/darren/bin/sketchybar

# Colors (Catppuccin Frappe inspired)
export BG_COLOR=0xff414559
export FG_COLOR=0xffffffff
export ACTIVE_COLOR=0xcc00c1ad

export PLUGINS_DIR="$HOME/.config/sketchybar/plugins"

# Workspace definitions: key -> icon
# W = Work, R = Reference, C = Communication, P = Personal, F = Fun
declare -A workspace_icons=(
    ["W"]=""
    ["R"]=""
    ["C"]="󰍡"
    ["P"]=""
    ["F"]="󰝚"
)
# Fallback monitor per workspace, used only when aerospace doesn't report one.
declare -A workspace_default_monitors=(
    ["W"]="2"
    ["R"]="2"
    ["C"]="1"
    ["P"]="1"
    ["F"]="1"
)

declare -A monitors
while IFS=" " read -r monitor_id display_id; do
    monitors["$monitor_id"]="$display_id"
done < <("$AEROSPACE" list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}')

all_workspaces=$("$AEROSPACE" list-workspaces --all)
focused_workspace=$("$AEROSPACE" list-workspaces --focused)

for ws in $all_workspaces; do
    "$SKETCHYBAR" --remove "space.$ws" 2>/dev/null
done

workspace_order=("W" "R" "C" "P" "F")

declare -A workspace_to_monitor
for monitor_id in "${!monitors[@]}"; do
    for ws in $("$AEROSPACE" list-workspaces --monitor "$monitor_id"); do
        workspace_to_monitor["$ws"]="$monitor_id"
    done
done

for ws in "${workspace_order[@]}"; do
    monitor_id="${workspace_default_monitors[$ws]}"
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
    "$SKETCHYBAR" -m --add space "space.$ws" left \
        --set "space.$ws" \
        display="${monitors[$monitor_id]:-1}" \
        background.drawing="$bg_drawing" \
        background.color="$ACTIVE_COLOR" \
        icon="$icon" \
        click_script="$AEROSPACE workspace $ws"
done

# Brief sleep to ensure aerospace has settled after workspace moves
sleep 0.1

# Re-query focused workspace to get current state, not the stale value above
current_focused=$("$AEROSPACE" list-workspaces --focused)

for ws in "${workspace_order[@]}"; do
    if [[ "$ws" == "$current_focused" ]]; then
        "$SKETCHYBAR" --set "space.$ws" background.drawing=on
    else
        "$SKETCHYBAR" --set "space.$ws" background.drawing=off
    fi
done
