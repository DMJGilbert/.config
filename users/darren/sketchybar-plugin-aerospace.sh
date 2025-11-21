#!/bin/bash

# Get workspace ID from argument
WORKSPACE=$1

# Colors
ACTIVE_COLOR=0xff81c8be
INACTIVE_COLOR=0x00626880

# Check if this is the focused workspace
if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on background.color=$ACTIVE_COLOR
else
  sketchybar --set $NAME background.drawing=off
fi
