---
description: Comprehensive code review of staged changes
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git log:*)
  - Bash(git show:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Code Review

Perform a comprehensive code review of: $ARGUMENTS

If no argument provided, review staged changes (`git diff --cached`).

## Analysis Steps

1. **Get Context**
   - Run `git status` to see what's staged
   - Run `git diff --cached` to see the actual changes
   - Run `git diff --cached --stat` for a summary

2. **Code Quality Review**
   - Check for clean code principles (SOLID, DRY, KISS)
   - Verify meaningful naming conventions
   - Look for code smells (long functions, deep nesting, magic numbers)
   - Check error handling completeness

3. **Security Review**
   - Look for hardcoded secrets or credentials
   - Check input validation
   - Review authentication/authorization logic
   - Identify injection risks (SQL, XSS, command)

4. **Architecture Review**
   - Verify changes follow existing patterns
   - Check for proper separation of concerns
   - Look for circular dependencies
   - Assess coupling and cohesion

5. **Performance Review**
   - Identify potential bottlenecks
   - Check for N+1 query patterns
   - Look for unnecessary computations
   - Review memory usage patterns

6. **Test Coverage**
   - Check if new code has corresponding tests
   - Identify untested edge cases
   - Verify test quality and assertions

## Output Format

Group findings by severity:

### Critical

Issues that must be fixed before merging (security vulnerabilities, data loss risks)

### High

Significant issues that should be addressed (performance problems, missing error handling)

### Medium

Code quality concerns (code smells, maintainability issues)

### Low

Minor suggestions and style improvements

For each finding, provide:

- **File:Line** - Location of the issue
- **Issue** - Clear description of the problem
- **Suggestion** - How to fix it

End with a summary: total issues by severity and overall assessment.
