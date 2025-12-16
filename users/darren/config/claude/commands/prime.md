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
  - mcp__memory__read_graph
  - mcp__memory__search_nodes
  - mcp__memory__create_entities
  - mcp__memory__create_relations
  - mcp__memory__add_observations
---

# Context Prime

Load comprehensive project context for this session, with persistent memory.

Target: $ARGUMENTS

If no argument provided, prime with full project context. You can specify:
- `/prime src/` - Focus on a specific directory
- `/prime api` - Focus on a specific area (api, auth, database, etc.)
- `/prime quick` - Minimal context (just structure and key files)
- `/prime refresh` - Force refresh knowledge graph even if exists

## Priming Steps

### 0. Check Knowledge Graph (First!)

```
mcp__memory__read_graph()
```

**If knowledge graph has project entities:**
- Load existing context from memory
- Show "Loaded from memory" summary
- Skip to Step 5 (Git Context) for recent changes only
- Proceed to output

**If knowledge graph is empty or `/prime refresh`:**
- Continue with full priming steps below
- Store results in knowledge graph at the end

### 1. Project Structure
```bash
tree -L 3 -I 'node_modules|.git|dist|build|target|__pycache__|.next' --dirsfirst 2>/dev/null || ls -la
```

### 2. Identify Tech Stack
Look for and read relevant config files:
- `package.json` / `package-lock.json` → Node.js/npm
- `Cargo.toml` → Rust
- `flake.nix` / `default.nix` → Nix
- `pyproject.toml` / `requirements.txt` → Python
- `go.mod` → Go
- `Podfile` / `Package.swift` → iOS/Swift
- `docker-compose.yml` / `Dockerfile` → Docker

### 3. Read Key Documentation
- `README.md` - Project overview
- `CLAUDE.md` / `.claude/CLAUDE.md` - AI instructions
- `CONTRIBUTING.md` - Contribution guidelines
- `ARCHITECTURE.md` or `docs/architecture.md` - System design

### 4. Understand Patterns
- Identify directory structure conventions
- Note naming patterns (files, functions, components)
- Find entry points (main.*, index.*, App.*)
- Locate test patterns (*_test.*, *.spec.*, *.test.*)

### 5. Git Context
```bash
git log --oneline -10
git branch -a
git remote -v
```

### 6. Recent Activity
```bash
git diff --stat HEAD~5..HEAD 2>/dev/null || echo "Limited git history"
```

### 7. Store in Knowledge Graph (if new/refresh)

After gathering context, store in knowledge graph:

```
# Create project entity
create_entities([{
  "name": "project",
  "entityType": "project",
  "observations": [
    "Name: [project name]",
    "Type: [Library/Application/CLI/Service]",
    "Tech Stack: [languages, frameworks]",
    "Package Manager: [npm/cargo/nix/etc]"
  ]
}])

# Create entities for key directories/modules
create_entities([
  {"name": "src", "entityType": "directory", "observations": ["Source code directory", "Contains [description]"]},
  {"name": "tests", "entityType": "directory", "observations": ["Test files", "Uses [test framework]"]},
  # ... other key directories
])

# Create entities for key patterns/conventions
create_entities([{
  "name": "conventions",
  "entityType": "patterns",
  "observations": [
    "Naming: [camelCase/snake_case]",
    "Testing: [framework] in [location]",
    "Config: [how managed]",
    "Imports: [style]"
  ]
}])

# Create relations
create_relations([
  {"from": "src", "to": "project", "relationType": "part_of"},
  {"from": "tests", "to": "project", "relationType": "part_of"},
  {"from": "conventions", "to": "project", "relationType": "describes"}
])
```

## Output Format

### Project Context Summary

#### Source
- **Memory**: Loaded from knowledge graph / Fresh analysis stored

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
