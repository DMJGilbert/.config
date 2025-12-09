---
description: Generate conventional commit message for staged changes
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
  - Read
  - Grep
  - Glob
---

# Generate Commit Message

Analyze staged changes and generate a conventional commit message. This command is **read-only** - it will NOT execute `git commit`.

Optional argument: $ARGUMENTS (hint for commit type or scope, e.g., "feat" or "auth module")

## Analysis Steps

1. **Check Staged Changes**
   ```bash
   git status
   git diff --cached --stat
   git diff --cached
   ```

2. **Review Recent Commits** (for style consistency)
   ```bash
   git log --oneline -10
   ```

3. **Analyze the Changes**
   - What files are modified?
   - What is the nature of the change? (new feature, bug fix, refactor, etc.)
   - What is the scope? (component, module, feature area)
   - Are there breaking changes?

## Commit Message Format

Follow Conventional Commits specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types
- `feat`: New feature (correlates with MINOR in semver)
- `fix`: Bug fix (correlates with PATCH in semver)
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning (whitespace, formatting)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or correcting tests
- `chore`: Maintenance tasks, dependency updates
- `ci`: CI/CD configuration changes
- `build`: Build system or external dependency changes

### Rules
- Subject line max 50 characters
- Use imperative mood ("add" not "added" or "adds")
- Don't end subject with period
- Body wraps at 72 characters
- Explain what and why, not how

## Output

Provide the commit message in a code block ready to copy:

```
feat(scope): short description

Longer explanation of the change if needed.
Explain the motivation and contrast with previous behavior.

BREAKING CHANGE: description (if applicable)
```

Also provide 2-3 alternative messages if the changes could be categorized differently.

**Remember**: Do NOT run `git commit`. Only provide the message for the user to use.
