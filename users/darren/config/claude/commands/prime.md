---
description: Prime Claude with comprehensive project context
allowed-tools:
  - Bash(git:*)
  - Bash(tree:*)
  - Bash(ls:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Context Prime

Load comprehensive project context for this session.

Target: $ARGUMENTS

If no argument provided, prime with full project context. You can specify:
- `/prime src/` - Focus on a specific directory
- `/prime api` - Focus on a specific area (api, auth, database, etc.)
- `/prime quick` - Minimal context (just structure and key files)

## Priming Steps

1. **Project Structure**
   ```bash
   tree -L 3 -I 'node_modules|.git|dist|build|target|__pycache__|.next' --dirsfirst 2>/dev/null || ls -la
   ```

2. **Identify Tech Stack**
   Look for and read relevant config files:
   - `package.json` / `package-lock.json` → Node.js/npm
   - `Cargo.toml` → Rust
   - `flake.nix` / `default.nix` → Nix
   - `pyproject.toml` / `requirements.txt` → Python
   - `go.mod` → Go
   - `Podfile` / `Package.swift` → iOS/Swift
   - `docker-compose.yml` / `Dockerfile` → Docker

3. **Read Key Documentation**
   - `README.md` - Project overview
   - `CLAUDE.md` / `.claude/CLAUDE.md` - AI instructions
   - `CONTRIBUTING.md` - Contribution guidelines
   - `ARCHITECTURE.md` or `docs/architecture.md` - System design

4. **Understand Patterns**
   - Identify directory structure conventions
   - Note naming patterns (files, functions, components)
   - Find entry points (main.*, index.*, App.*)
   - Locate test patterns (*_test.*, *.spec.*, *.test.*)

5. **Git Context**
   ```bash
   git log --oneline -10
   git branch -a
   git remote -v
   ```

6. **Recent Activity**
   ```bash
   git diff --stat HEAD~5..HEAD 2>/dev/null || echo "Limited git history"
   ```

## Output Format

### Project Context Summary

#### Overview
- **Project**: [Name from package.json/Cargo.toml/etc]
- **Type**: [Library/Application/CLI/Service]
- **Tech Stack**: [Languages, frameworks, tools]
- **Package Manager**: [npm/cargo/nix/pip/etc]

#### Structure
```
[Condensed tree output with annotations]
```

#### Key Files
| File | Purpose |
|------|---------|
| `src/main.ts` | Application entry point |
| `src/lib/` | Core library code |
| ... | ... |

#### Patterns & Conventions
- **Naming**: [camelCase/snake_case/kebab-case]
- **Testing**: [Jest/pytest/cargo test] in [location]
- **Config**: [How configuration is managed]
- **Imports**: [Absolute/relative, aliases]

#### Active Development
- **Recent focus**: [Based on recent commits]
- **Current branch**: [branch name]
- **Open work**: [Any uncommitted changes]

#### Quick Reference
```bash
# Build
[build command]

# Test
[test command]

# Run
[run command]
```

### Ready to Assist
[Brief statement of understanding and readiness to help with the project]
