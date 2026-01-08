---
description: Analyze session patterns and generate workflow insights
allowed-tools:
  - Read
  - Bash
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_add_observations
  - mcp__obsidian__obsidian_append_content
---

# Retrospective

Analyze Claude Code session history and generate workflow insights.

## Session Log Location

Sessions are logged to: `~/.local/share/claude-retrospectives/sessions.jsonl`

Each entry contains:

- `date`: ISO timestamp
- `project`: Project name (from git root)
- `files_changed`: Number of files modified
- `domains`: File extensions touched (e.g., "nix,md,ts")

## Analysis Process

### 1. Load Session Data

```bash
# Read recent sessions (last 30 days by default)
cat ~/.local/share/claude-retrospectives/sessions.jsonl | tail -100
```

### 2. Identify Patterns

Analyze the session data to find:

- **Most active projects**: Which projects have the most sessions?
- **Common domains**: Which file types are modified most often?
- **Session frequency**: Daily/weekly patterns
- **Multi-domain sessions**: How often do sessions span multiple domains?

### 3. Generate Insights

Based on patterns, generate actionable insights:

| Pattern               | Insight                              | Action                          |
| --------------------- | ------------------------------------ | ------------------------------- |
| Frequent Nix work     | Consider ccode-nix preset            | Suggest preset usage            |
| Multi-domain sessions | Orchestrator usage recommended       | Suggest /orchestrate            |
| Repeated file types   | Hook coverage check                  | Verify PreToolUse hints active  |
| Same project daily    | Consider persistent memory           | Suggest /prime for this project |

### 4. Store Learnings

After analysis, persist valuable insights to memory:

```
mcp__memory__aim_add_observations([{
  entityName: "workflow_patterns",
  contents: ["[Date]: [Insight from retrospective]"]
}])
```

### 5. Optional: Create Note

If significant patterns found, create a note in the vault:

```
Path: claude/notes/learnings/retrospective-[date].md
```

## Output Format

```markdown
## Session Retrospective

**Period**: [Date range analyzed]
**Sessions**: [Count]

### Project Activity

| Project | Sessions | Primary Domains |
| ------- | -------- | --------------- |
| ...     | ...      | ...             |

### Domain Patterns

| Domain | Sessions | Often With      |
| ------ | -------- | --------------- |
| ...    | ...      | ...             |

### Insights

1. **[Pattern]**: [Insight and recommended action]
2. ...

### Recommendations

- [ ] [Actionable suggestion based on patterns]
- ...
```

## Arguments

- No arguments: Analyze last 30 days
- `--days N`: Analyze last N days
- `--project NAME`: Filter to specific project
- `--save`: Save insights to Obsidian vault
