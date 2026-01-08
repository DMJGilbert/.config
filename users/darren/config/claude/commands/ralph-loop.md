---
description: Start autonomous iteration loop for batch tasks
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
---

# Ralph Loop: Autonomous Iteration

Start an autonomous iteration loop for: $ARGUMENTS

## Setup

1. Parse options from arguments:
   - `--max-iterations N` or `--max N` (default: 10)

2. Create state directory and files:

```bash
mkdir -p ~/.cache/claude-ralph
echo "1" > ~/.cache/claude-ralph/iteration
echo "10" > ~/.cache/claude-ralph/max  # or parsed value
touch ~/.cache/claude-ralph/active
```

3. Display header:

```
===================================================
 RALPH LOOP - Iteration 1/10
===================================================
Task: [description from arguments]
```

## Iteration Protocol

Each iteration:

1. **Assess**: What is the current state vs goal?
2. **Plan**: What's the single most important next step?
3. **Execute**: Do that one step
4. **Verify**: Did it work? Check tests/builds
5. **Decide**: Complete or continue?

## Completion

When task is FULLY complete:

1. Remove flag: `rm ~/.cache/claude-ralph/active`
2. Output summary of what was accomplished

The Stop hook will end the loop when the flag is removed.

## Constraints

- One significant change per iteration
- Always verify changes work before moving on
- If blocked, explain and await input (remove flag first)

## Cost Warning

**Token Usage**: Ralph loops consume significant tokens. A 10-iteration loop
on a large codebase can cost $20-50+ in API credits. Use conservatively:

- Start with `--max-iterations 5` for new tasks
- Monitor progress each iteration
- Use `/cancel-ralph` if stuck

## Command Composition

Ralph can wrap other commands for autonomous execution:

```bash
# Autonomous bug fixing
/ralph-loop "/fix issue #42" --max-iterations 5

# Autonomous refactoring with orchestration
/ralph-loop "/orchestrate refactor auth module"

# Iterative documentation generation
/ralph-loop "Document all public APIs in src/lib/"
```

## Status and Control

- `/ralph-status` - Check current iteration and state
- `/cancel-ralph` - Stop the loop immediately
