# Commit

Generate a conventional commit message for staged changes.

## Process

1. **Check staged changes**:

   ```bash
   git diff --cached --stat
   ```

   If nothing staged, inform user and exit.

2. **Get diff details**:

   ```bash
   git diff --cached
   ```

3. **Check recent commit style**:

   ```bash
   git log --oneline -5
   ```

4. **Analyze changes** and determine:
   - **Type**: feat, fix, refactor, docs, style, test, chore, ci, build, perf
   - **Scope**: Component/module affected (optional)
   - **Description**: Concise summary of what changed

5. **Generate commit message**:

   ```
   <type>(<scope>): <description>

   [optional body explaining why]

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

6. **Present for approval**:
   Show the proposed message and ask user to confirm.

7. **Execute commit**:

   ```bash
   git commit -m "<message>"
   ```

## Conventional Commit Types

| Type       | When to use                             |
| ---------- | --------------------------------------- |
| `feat`     | New feature                             |
| `fix`      | Bug fix                                 |
| `refactor` | Code change that neither fixes nor adds |
| `docs`     | Documentation only                      |
| `style`    | Formatting, no code change              |
| `test`     | Adding/updating tests                   |
| `chore`    | Maintenance tasks                       |
| `ci`       | CI/CD changes                           |
| `build`    | Build system or dependencies            |
| `perf`     | Performance improvement                 |

## Rules

- Keep subject line under 72 characters
- Use imperative mood ("add" not "added")
- Don't end subject with period
- Separate subject from body with blank line
- Body explains "why" not "what"
