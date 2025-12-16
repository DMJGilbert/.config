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
  - mcp__memory__aim_read_graph
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_create_entities
  - mcp__memory__aim_create_relations
  - mcp__memory__aim_add_observations
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

### 0. Detect Project Name

```bash
# Get project name from git remote or directory
PROJECT=$(basename "$(git remote get-url origin 2>/dev/null)" .git 2>/dev/null) || \
PROJECT=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null) || \
PROJECT=$(basename "$PWD")
```

### 1. Load Knowledge Graph (Two Contexts)

**Load default context** (personal conventions, global patterns):

```
aim_read_graph()  # No context = default
```

**Load project context** (project-specific knowledge):

```
aim_read_graph(context="[PROJECT_NAME]")
```

**Merge behavior:**

- Default context entities are universal (conventions, preferences)
- Project context entities are project-specific (decisions, components)
- If same entity exists in both, project context takes precedence

**If both contexts empty or `/prime refresh`:**

- Continue with full priming steps below
- Store results in project context at the end

**If contexts have data:**

- Load existing context from memory
- Show "Loaded from memory" summary with context sources
- Skip to Step 5 (Git Context) for recent changes only

### 2. Project Structure

```bash
tree -L 3 -I 'node_modules|.git|dist|build|target|__pycache__|.next' --dirsfirst 2>/dev/null || ls -la
```

### 3. Identify Tech Stack

Look for and read relevant config files:

- `package.json` / `package-lock.json` → Node.js/npm
- `Cargo.toml` → Rust
- `flake.nix` / `default.nix` → Nix
- `pyproject.toml` / `requirements.txt` → Python
- `go.mod` → Go
- `Podfile` / `Package.swift` → iOS/Swift
- `docker-compose.yml` / `Dockerfile` → Docker

### 4. Read Key Documentation

- `README.md` - Project overview
- `CLAUDE.md` / `.claude/CLAUDE.md` - AI instructions
- `CONTRIBUTING.md` - Contribution guidelines
- `ARCHITECTURE.md` or `docs/architecture.md` - System design

### 5. Understand Patterns

- Identify directory structure conventions
- Note naming patterns (files, functions, components)
- Find entry points (main.*, index.*, App.*)
- Locate test patterns (*_test.*, *.spec.*, *.test.*)

### 6. Git Context

```bash
git log --oneline -10
git branch -a
git remote -v
```

### 7. Recent Activity

```bash
git diff --stat HEAD~5..HEAD 2>/dev/null || echo "Limited git history"
```

### 8. Store in Knowledge Graph (if new/refresh)

After gathering context, store in **project context** (not default):

```
# Create project entity in PROJECT context
aim_create_entities({
  context: "[PROJECT_NAME]",
  entities: [{
    "name": "[PROJECT_NAME]",
    "entityType": "project",
    "observations": [
      "Name: [project name]",
      "Type: [Library/Application/CLI/Service]",
      "Tech Stack: [languages, frameworks]",
      "Package Manager: [npm/cargo/nix/etc]"
    ]
  }]
})

# Create entities for key directories/modules
aim_create_entities({
  context: "[PROJECT_NAME]",
  entities: [
    {"name": "src", "entityType": "directory", "observations": ["Source code directory", "Contains [description]"]},
    {"name": "tests", "entityType": "directory", "observations": ["Test files", "Uses [test framework]"]}
  ]
})

# Create relations in project context
aim_create_relations({
  context: "[PROJECT_NAME]",
  relations: [
    {"from": "src", "to": "[PROJECT_NAME]", "relationType": "part_of"},
    {"from": "tests", "to": "[PROJECT_NAME]", "relationType": "part_of"}
  ]
})
```

**Note**: Personal conventions go in the **default context** (no context parameter).
Project-specific entities go in the **project context**.

## Output Format

### Project Context Summary

#### Source

- **Default Context**: [count] entities (personal conventions)
- **Project Context** (`[PROJECT_NAME]`): [count] entities / Fresh analysis stored

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

## Memory Location

Memory is stored globally at `~/.local/share/claude-memory/`:

- `memory.jsonl` - Default context (personal conventions)
- `memory-[project].jsonl` - Project-specific context
