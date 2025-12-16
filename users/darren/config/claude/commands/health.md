---
description: Project health assessment and scorecard
allowed-tools:
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git shortlog:*)
  - Bash(find:*)
  - Bash(wc:*)
  - Bash(npm outdated:*)
  - Bash(cargo outdated:*)
  - Bash(nix flake info:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Project Health Check

Perform a comprehensive health assessment of the project. This command is **read-only** - it will NOT modify any files.

Focus area: $ARGUMENTS

If no argument provided, run full health check. You can focus on specific areas:

- `/health dependencies` - Only check dependencies
- `/health tests` - Only check test coverage and quality
- `/health docs` - Only check documentation
- `/health git` - Only check git health
- `/health debt` - Only check technical debt

## Analysis Areas

### 1. Dependencies

- Check for outdated packages
- Identify deprecated dependencies
- Look for security vulnerabilities (via lock files)
- Count direct vs transitive dependencies

### 2. Code Quality

- Estimate test coverage (by file count/patterns)
- Check for linting configuration
- Look for TODO/FIXME/HACK comments
- Identify dead code patterns

### 3. Documentation

- README presence and completeness
- API documentation coverage
- Code comments ratio
- CHANGELOG maintenance

### 4. Technical Debt

- Count TODO/FIXME comments
- Identify long functions (>50 lines)
- Find complex files (high cyclomatic complexity indicators)
- Look for duplicated code patterns

### 5. Git Health

- Commit frequency and patterns
- Branch hygiene
- Large files in history
- Contributor distribution

### 6. Security

- Secrets detection (patterns only)
- Dependency vulnerabilities
- Security configuration files
- Authentication patterns

## Output Format

### Project Health Scorecard

| Category | Score | Status |
|----------|-------|--------|
| Dependencies | X/10 | emoji |
| Code Quality | X/10 | emoji |
| Documentation | X/10 | emoji |
| Technical Debt | X/10 | emoji |
| Git Health | X/10 | emoji |
| Security | X/10 | emoji |
| **Overall** | **X/10** | **emoji** |

### Detailed Findings

#### Dependencies

- Total: X direct, Y transitive
- Outdated: X packages
- Vulnerabilities: X known
- Action items: [list]

#### Code Quality

- Test files: X
- Linting: Configured/Not configured
- TODOs: X found
- Action items: [list]

#### Documentation

- README: Present/Missing (X% complete)
- API docs: X% coverage
- Action items: [list]

#### Technical Debt

- TODOs/FIXMEs: X
- Long functions: X
- Complex files: X
- Action items: [list]

#### Git Health

- Last commit: X days ago
- Active contributors: X
- Branch count: X
- Action items: [list]

#### Security

- Potential secrets: X patterns found
- Security config: Present/Missing
- Action items: [list]

### Priority Action Items

1. [Critical] Item description
2. [High] Item description
3. [Medium] Item description
