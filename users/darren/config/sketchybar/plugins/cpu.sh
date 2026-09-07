#!/usr/bin/env bash
set -uo pipefail

# Total CPU across all processes, normalised by thread count. Summing every
# pcpu column in one awk pass replaces the previous two grep/sed/awk pipelines
# plus two `whoami` forks — this runs on a timer, so fork count matters.
CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
LABEL=$(ps -eo pcpu | awk -v cores="$CORE_COUNT" '
    NR > 1 { sum += $1 }
    END    { printf "%02.0f", (cores > 0 ? sum / cores : 0) }
')

sketchybar -m --set cpu_percent label="${LABEL:-00}%"
