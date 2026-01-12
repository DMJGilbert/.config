---
description: Fix a problem (text description or GitHub issue number)
skills:
  - systematic-debugging
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Bash(nix:*)
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
  - mcp__sequential-thinking__sequentialthinking
  - mcp__memory__aim_memory_search
---

# Fix Problem

Fix the specified problem: $ARGUMENTS

**Input modes:**

- **GitHub Issue**: If argument is a number (e.g., `123` or `#123`), fetch issue details
- **Text Description**: If argument is text, treat as problem description
- **No argument**: Prompt user to describe the problem

## RIPER Workflow

This command follows the RIPER workflow phases, using the `systematic-debugging` skill for root cause investigation.

### Phase 1: RESEARCH

**Gather context and understand the problem.**

1. **If GitHub issue provided:**

   ```bash
   gh issue view $1 --json title,body,state,labels,comments
   ```

2. **Apply systematic-debugging skill (4 phases):**
   - Root Cause Investigation
   - Pattern Analysis
   - Hypothesis Testing
   - Implementation approach

3. **Gather additional context:**
   - Search codebase: `Grep`, `Glob`
   - Check knowledge graph: `mcp__memory__aim_memory_search`
   - Read relevant files

### Phase 2: INNOVATE

**Form and test hypotheses.**

1. State hypothesis: "I believe X is failing because Y, evidenced by Z"
2. Use `mcp__sequential-thinking__sequentialthinking` for complex problems
3. Evaluate trade-offs (complexity, performance, maintainability)
4. **Change only ONE variable at a time**

### Phase 3: PLAN

1. List files to be modified
2. Define order of changes
3. Identify tests/validation needed
4. Create branch if significant: `git checkout -b fix/short-description`

### Phase 4: EXECUTE

1. Make code changes following existing patterns
2. Use specialist agents if needed:
   - `nix-specialist` for Nix files
   - `home-assistant-dev` for HA configs
   - `test-engineer` for adding tests
3. Validate: `nix flake check`, `alejandra --check .`, `statix check .`

### Phase 5: REVIEW

1. Self-review with `git diff`
2. Verify no unintended changes
3. Report results

## Output Format

```markdown
## Problem Summary

[Clear description of what needed fixing]

## Root Cause

[What caused the issue]

## Solution

[How it was fixed]

## Changes Made

| File         | Change                |
| ------------ | --------------------- |
| path/to/file | Description of change |

## Validation

- [ ] Code compiles/builds
- [ ] Formatting passes
- [ ] Linting passes
- [ ] Manual testing (if applicable)

## Next Steps

[Any follow-up actions, commits, PRs, etc.]
```

## Escalation Rules

### When 2+ Fix Attempts Fail

**Trigger ultrathink mode:**

```
ultrathink: What are all the possible root causes?
What assumptions am I making? What haven't I checked yet?
```

### When 3+ Fix Attempts Fail

**STOP.** This signals an architectural problem, not a fixable bug.

See `systematic-debugging` skill for detailed escalation process.
