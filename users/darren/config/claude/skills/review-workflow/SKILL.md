---
name: review-workflow
description: Request and process code reviews with proper context. Use after completing significant implementation work.
---

# Code Review Workflow

Review early, review often - catch issues before they compound.

## When Reviews Are Required

| Scenario                          | Timing             |
| --------------------------------- | ------------------ |
| Each task in subagent-driven work | After each task    |
| Major feature completion          | Before integration |
| Before merging to main            | Pre-merge          |
| When stuck on a problem           | As needed          |
| Before refactoring                | Pre-refactor       |
| After complex bug fix             | Post-fix           |

## How to Request Review

### 1. Gather Context

```bash
# Get commit range for review
git log --oneline -5
git diff main..HEAD --stat
```

### 2. Dispatch Reviewer

```
Task(code-reviewer, prompt="
Review the changes in commits [base]..[head]

**What was implemented:**
[Description of changes]

**Requirements reference:**
[Link or description of requirements]

**Areas of concern:**
[Any specific areas you want extra attention]

**Files changed:**
[List key files]
")
```

### 3. Process Feedback

| Severity  | Action Required                            |
| --------- | ------------------------------------------ |
| Critical  | Fix immediately - blocks all other work    |
| High      | Resolve before proceeding to next task     |
| Medium    | Address in current session if time permits |
| Low/Minor | Document for future improvement            |

## Review Request Template

```markdown
## Code Review Request

**Commits:** [base-sha]..[head-sha]
**Branch:** [branch-name]

### Summary

[1-2 sentences on what changed]

### Changes by File

| File         | Change Type    | Description    |
| ------------ | -------------- | -------------- |
| path/to/file | Added/Modified | [What changed] |

### Requirements

[Link to issue/spec or brief description]

### Testing Done

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

### Areas Needing Attention

- [Specific concern 1]
- [Specific concern 2]

### Questions for Reviewer

- [Any specific questions]
```

## Handling Feedback

### Agree with Feedback

1. Acknowledge the issue
2. Fix immediately (Critical/High) or document (Medium/Low)
3. Respond with what was changed

### Disagree with Feedback

1. **Never** dismiss without explanation
2. Provide technical justification with evidence
3. Reference code patterns or documentation
4. Explain trade-offs considered
5. Be open to being wrong

### Example Response

```markdown
## Review Response

### Critical Issues

- **[File:Line]**: Fixed - [what was changed]

### High Priority

- **[File:Line]**: Fixed - [what was changed]

### Disagreement: [Issue]

I believe [current approach] is correct because:

1. [Technical reason]
2. [Evidence from codebase]
   However, open to discussion if I'm missing something.

### Deferred

- **[Minor issue]**: Added to tech debt tracker for future
```

## Independent Reviewer Pattern

**Critical**: Avoid the self-review trap. An agent reviewing its own work suffers from confirmation bias - it will overlook the same issues it created.

### The Problem

```
Implementation Agent → Reviews Own Code → "Looks good to me!"
                                           ↑
                              Same context, same blind spots
```

### The Solution: Multi-Agent Consensus

Use a **fresh agent** with **no access** to implementation session history:

```
┌─────────────────────────────────────────────────────────────────┐
│                 MULTI-AGENT REVIEW FLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Session 1: IMPLEMENTATION                                      │
│  ├─ Agent implements feature                                    │
│  ├─ Agent summarizes changes (git diff, commit messages)        │
│  └─ Agent creates PR or prepares review request                 │
│                                                                 │
│  Session 2: ISOLATED REVIEW (fresh agent)                       │
│  ├─ Reviewer has NO chat history from Session 1                 │
│  ├─ Reviewer reads only: code, diffs, PR description            │
│  ├─ Reviewer validates against repo checklist                   │
│  └─ Reviewer produces actionable comments                       │
│                                                                 │
│  Session 3: INCORPORATION                                       │
│  ├─ Implementation agent receives feedback                      │
│  ├─ Agent addresses Critical/High issues                        │
│  └─ Agent responds to reviewer (agree/disagree with evidence)   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### How to Dispatch an Independent Reviewer

**Option A: New Claude Session**
```bash
# After implementation, start fresh session for review
claude "/review"  # Fresh context, no implementation history
```

**Option B: Task Tool with Isolated Prompt**
```
Task(code-reviewer, prompt="
Review the changes in the current branch.

**Context (provide ONLY this, not implementation reasoning):**
- Branch: feat/new-feature
- PR description: [paste PR body]
- Files changed: [list from git diff --stat]

**Your task:**
1. Read the actual code changes (git diff main..HEAD)
2. Validate against checklist in .claude/agents/code-reviewer.md
3. Identify issues by severity (Critical/High/Medium/Low)
4. Provide actionable feedback

**DO NOT assume the implementation is correct.**
**DO look for: edge cases, error handling, test coverage, patterns.**
")
```

### Repo-Specific Checklist

The reviewer validates against project-specific concerns:

```markdown
## Review Checklist

### General
- [ ] Follows existing code patterns
- [ ] Error handling is explicit
- [ ] No hardcoded secrets or credentials
- [ ] Tests cover new functionality

### Nix-Specific (this repo)
- [ ] Uses `alejandra` formatting
- [ ] Follows Nix naming conventions
- [ ] `lib.mkIf` for conditional configurations
- [ ] No deprecated options

### Project-Specific
- [ ] Types are strict (no implicit any)
- [ ] Performance considerations addressed
- [ ] [Add your project-specific items here]
```

### Why This Works

| Self-Review (Bad)                     | Independent Review (Good)                |
| ------------------------------------- | ---------------------------------------- |
| Same mental model as implementation   | Fresh perspective                        |
| Remembers "why" and overlooks "what"  | Only sees "what" in the code             |
| Confirmation bias                     | Skeptical by default                     |
| Misses same class of bugs created     | Different blind spots                    |

### Implementation Notes

1. **Summaries over history**: Pass PR descriptions and diffs, not chat logs
2. **No "I did X because Y"**: Reviewer shouldn't know implementation reasoning
3. **Checklist-driven**: Reviewer follows structured checklist, not intuition
4. **Actionable output**: Each issue must have a specific location and fix

## Integration Points

- After **executing-plans** batches
- After **systematic-debugging** fixes
- Before **finishing branches** (merge/PR)
