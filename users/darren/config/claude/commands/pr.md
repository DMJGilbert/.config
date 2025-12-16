---
description: Generate PR title and description for current branch
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
  - Bash(git branch:*)
  - Bash(git remote:*)
  - Bash(gh pr view:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Generate PR Description

Generate a comprehensive PR title and description for the current branch. This command is **read-only** - it will NOT create or modify any PR.

Optional argument: $ARGUMENTS (target base branch, defaults to main/master)

## Analysis Steps

1. **Detect Base Branch**

   ```bash
   git remote show origin | grep "HEAD branch"
   ```

   Or fall back to `main` or `master`.

2. **Get Current Branch**

   ```bash
   git branch --show-current
   ```

3. **Get All Commits on Branch**

   ```bash
   git log <base>..HEAD --oneline
   git log <base>..HEAD --pretty=format:"%h %s%n%b"
   ```

4. **Get Full Diff**

   ```bash
   git diff <base>...HEAD --stat
   git diff <base>...HEAD
   ```

5. **Check for Existing PR** (if gh is available)

   ```bash
   gh pr view --json title,body 2>/dev/null || echo "No existing PR"
   ```

## PR Description Format

```markdown
## Summary
[1-3 bullet points describing what this PR does]

## Changes
[Categorized list of changes]

### Added
- New feature X
- New component Y

### Changed
- Modified behavior of Z

### Fixed
- Bug in A

### Removed
- Deprecated B

## Test Plan
- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Edge cases verified

## Breaking Changes
[List any breaking changes, or "None"]

## Related Issues
[Link to related issues if identifiable from commits]

## Screenshots
[If UI changes, note that screenshots should be added]
```

## Output

Provide:

1. **PR Title** (max 72 characters, imperative mood)
2. **PR Description** (in markdown, ready to paste)

Format the output in a code block so it's easy to copy.

**Remember**: Do NOT run `gh pr create` or modify any PR. Only provide the content for the user to use.
