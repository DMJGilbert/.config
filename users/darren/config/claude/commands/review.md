# Review

Code review for staged changes or full branch.

## Usage

- `/review` - Review staged changes (default)
- `/review --branch` - Review full branch diff from main

## Process

### 1. Get Changes

**Staged (default)**:

```bash
git diff --cached
```

**Branch** (with `--branch` flag):

```bash
# Find merge base
BASE=$(git merge-base main HEAD)
git diff $BASE..HEAD
```

If no changes found, inform user and exit.

### 2. Invoke Review Agents (Parallel)

Launch three reviewers simultaneously:

```
Task(security-reviewer, prompt="Review these changes for security issues: [diff]")
Task(bug-hunter, prompt="Review these changes for bugs and edge cases: [diff]")
Task(quality-reviewer, prompt="Review these changes for quality issues: [diff]")
```

### 3. Aggregate Findings

Collect results from all three reviewers and merge:

1. Combine all findings
2. Sort by severity: Critical → High → Medium → Low
3. Deduplicate overlapping issues
4. Present unified report

## Output Format

```markdown
## Code Review

### Critical
- [Issue from any reviewer]

### High
- [Issue]

### Medium
- [Issue]

### Low
- [Issue]

### Summary

**Security**: [assessment]
**Correctness**: [assessment]
**Quality**: [assessment]

**Overall**: [Ready to merge / Needs fixes / Major concerns]
```

## Notes

- Review does not modify files
- Issues include file:line references
- Suggestions are actionable
