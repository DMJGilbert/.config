#!/usr/bin/env bash
set -uo pipefail

# $NAME is set by sketchybar; fall back so the script is runnable by hand.
sketchybar -m --set "${NAME:-clock}" label="$(date '+%d/%m %H:%M')"
