---
name: retrospective
description: Review session for learnings and update agent memories
---

# Retrospective Command

Review the current session and update relevant agent memories.

## Process

1. **Analyze session**:
   - What agents were used?
   - What patterns emerged?
   - What issues were encountered?
   - What solutions worked?

2. **Identify learnings**:
   - New patterns discovered
   - Anti-patterns to avoid
   - Project-specific conventions
   - Reusable solutions

3. **Update memories**:
   - Read relevant agent MEMORY.md files from `~/.claude/agent-memory/{agent}/MEMORY.md`
   - Add new learnings to appropriate sections
   - Remove outdated information
   - Keep memories concise (under 200 lines)

4. **Store decisions**:
   - Use AIM memory for key decisions
   - Link related entities
   - Tag with project context

## Output

Present summary:

```
## Session Retrospective

### Learnings
- [Learning 1]
- [Learning 2]

### Memory Updates
- {agent}/MEMORY.md: [what was added]

### Decisions Stored
- [Decision entities created]
```

## When to Run

- After complex task completion
- When a pattern is discovered across multiple files
- When a solution to a recurring problem is found
- User requests: `/retrospective`
