---
description: Check Ralph loop status
allowed-tools:
  - Bash
---

# Ralph Loop Status

Check the current state of any active Ralph loop.

## Status Check

```bash
RALPH_DIR="$HOME/.cache/claude-ralph"

if [ -f "$RALPH_DIR/active" ]; then
  ITERATION=$(<"$RALPH_DIR/iteration" 2>/dev/null || echo "1")
  MAX=$(<"$RALPH_DIR/max" 2>/dev/null || echo "10")
  echo "RALPH LOOP ACTIVE"
  echo "   Iteration: $ITERATION/$MAX"
  echo ""
  echo "Commands:"
  echo "   /cancel-ralph  - Stop the loop"
  echo "   Continue working - Loop will auto-continue"
else
  echo "No active Ralph loop"
  echo ""
  echo "Start one with: /ralph-loop \"your task\""
fi
```

## State Files

Ralph state is stored in `~/.cache/claude-ralph/`:

| File        | Purpose                                        |
| ----------- | ---------------------------------------------- |
| `active`    | Flag file - presence indicates loop is running |
| `iteration` | Current iteration number                       |
| `max`       | Maximum iterations allowed                     |

## Persistence

Ralph state persists across Claude Code restarts. This allows:

- Resuming loops after connectivity issues
- Checking status from terminal
- Manual intervention if needed
