---
description: Cancel active Ralph loop
allowed-tools:
  - Bash
---

# Cancel Ralph Loop

Stop any active Ralph loop immediately.

## Cancellation

```bash
RALPH_DIR="$HOME/.cache/claude-ralph"

if [ -d "$RALPH_DIR" ]; then
  ITERATION=$(<"$RALPH_DIR/iteration" 2>/dev/null || echo "?")
  MAX=$(<"$RALPH_DIR/max" 2>/dev/null || echo "?")
  rm -rf "$RALPH_DIR"
  echo "Ralph loop cancelled at iteration $ITERATION/$MAX"
else
  echo "No active Ralph loop to cancel"
fi
```

## When to Cancel

- Task is blocked and needs human input
- Approach isn't working after several iterations
- Need to switch to a different task
- Want to manually take over

## After Cancellation

The session continues normally without autonomous iteration.
You can start a new loop anytime with `/ralph-loop "new task"`.
