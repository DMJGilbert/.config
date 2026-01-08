---
description: Fix a problem (text description or GitHub issue number)
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

- **GitHub Issue**: If argument is a number (e.g., `123` or `#123`), fetch issue details as context
- **Text Description**: If argument is text, treat it as the problem description
- **No argument**: Prompt user to describe the problem

## RIPER Workflow

This command follows the RIPER workflow phases:

### Phase 1: RESEARCH (Root Cause Investigation)

**Core Principle: ALWAYS find root cause before attempting fixes. Symptom fixes are failure.**

1. **Understand the Problem**

   **If GitHub issue number provided:**

   ```bash
   gh issue view $1 --json title,body,state,labels,comments
   ```

   Extract: title, description, labels, comments, expected vs actual behavior.

   **If text description provided:**
   Parse the description to understand:
   - What is broken or needs to change?
   - What is the expected behavior?
   - Any error messages or symptoms?

2. **Root Cause Investigation (MANDATORY)**
   - **Read error messages thoroughly** - Don't skip warnings or stack traces
   - **Reproduce consistently** - Verify you can trigger the issue reliably
   - **Check recent changes** - Examine git diffs, dependencies, config changes
   - **Trace data flow** - Backward trace from error to find where bad values originate
   - **Add instrumentation** - In multi-component systems, add logging at boundaries

3. **Pattern Analysis**
   - Locate similar working code in the codebase
   - Read reference implementations completely (not skimmed)
   - List every difference between working and broken code
   - Understand all dependencies and assumptions

4. **Gather Context**
   - Search codebase for related files (`Grep`, `Glob`)
   - Check knowledge graph: `mcp__memory__aim_memory_search`
   - Read relevant files to understand current implementation
   - Identify affected components and dependencies

5. **Document Understanding**
   - Summarize the problem clearly
   - State the **root cause**, not just symptoms
   - Note any ambiguities to clarify with user

### Phase 2: INNOVATE (Hypothesis & Testing)

6. **Form Hypothesis**
   - State your hypothesis clearly with specific reasoning
   - "I believe X is failing because Y, evidenced by Z"
   - Use `mcp__sequential-thinking__sequentialthinking` for complex problems

7. **Analyze Solutions**
   - Consider multiple approaches
   - Evaluate trade-offs (complexity, performance, maintainability)
   - Test hypothesis with smallest possible change
   - **Change only ONE variable at a time**

8. **Select Approach**
   - Choose the most appropriate solution
   - Document the reasoning
   - Identify risks and edge cases

**Red Flags - STOP and Return to RESEARCH:**

- Proposing fixes without understanding the issue
- Attempting multiple simultaneous changes
- Making assumptions without verification
- "Quick fixes" before investigation

### Phase 3: PLAN

6. **Create Implementation Plan**
   - List files to be modified
   - Define the order of changes
   - Identify tests or validation needed
   - Estimate scope

7. **Create Branch** (if significant change)

   ```bash
   git checkout -b fix/short-description
   ```

### Phase 4: EXECUTE

8. **Implement Fix**
   - Make the necessary code changes
   - Follow existing code patterns and style
   - Use appropriate specialist agents if needed:
     - `nix-specialist` for Nix files
     - `home-assistant-dev` for HA configs
     - `test-engineer` for adding tests

9. **Validate Changes**
   - Run `nix flake check` for Nix changes
   - Run `alejandra --check .` for formatting
   - Run `statix check .` for linting
   - Test the fix manually if applicable

### Phase 5: REVIEW

10. **Self-Review**
    - Check all changes with `git diff`
    - Verify no unintended changes
    - Ensure code quality standards are met

11. **Report Results**
    - Summarize what was changed
    - Explain how the fix works
    - Note any follow-up actions needed

## Output Format

```markdown
## Problem Summary

[Clear description of what needed fixing]

## Root Cause

[What caused the issue - if applicable]

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

## Error Handling

- If problem is unclear: Ask clarifying questions before proceeding
- If fix requires breaking changes: Warn user and get confirmation
- If multiple solutions exist: Present options and let user choose

## When 2+ Fix Attempts Fail

**Trigger ultrathink mode** for deeper analysis:

```
ultrathink: What are all the possible root causes?
What assumptions am I making? What haven't I checked yet?
```

See `skills/ultrathink-trigger/SKILL.md` for complexity indicators.

## When 3+ Fix Attempts Fail

**STOP.** This signals an architectural problem, not a fixable bug:

1. Do not attempt another fix
2. Return to Phase 1 (RESEARCH)
3. Question whether the underlying pattern/design is sound
4. Discuss with user: "Should we refactor architecture vs. continue fixing symptoms?"
5. Consider dispatching architect agent for design review

**Random fixes waste time and create new bugs. Quick patches mask underlying issues.**
