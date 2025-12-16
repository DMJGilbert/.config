---
description: Create a note in Obsidian vault
allowed-tools:
  - mcp__obsidian__read-note
  - mcp__obsidian__create-note
  - mcp__obsidian__edit-note
  - mcp__obsidian__search-vault
  - mcp__memory__*
  - Read
  - Grep
  - Glob
---

# Create Obsidian Note

Create a note in your Obsidian vault. Notes are organized by type and automatically linked with wikilinks.

**Topic**: $ARGUMENTS

## Process

### 1. Determine Note Type

Based on the topic, categorize the note:

| Type | Folder | Use For |
|------|--------|---------|
| `daily` | `claude/notes/daily/YYYY-MM-DD/` | Session notes, meeting notes |
| `concept` | `claude/notes/concepts/` | Explaining concepts, patterns, mental models |
| `learning` | `claude/notes/learnings/` | Insights, gotchas, best practices |
| `reference` | `claude/notes/reference/` | Quick reference, cheatsheets |

### 2. Search for Related Notes

Before creating, search for existing related content:
```
mcp__obsidian__search-vault(query)
```

### 3. Generate Note Content

Structure:
```markdown
---
type: [daily|concept|learning|reference]
created: YYYY-MM-DD
tags: [relevant, tags]
related: []
---

# Title

## Summary
[Brief overview - 1-2 sentences]

## Details
[Main content]

## Code Examples
[If applicable]

## Related
- [[Related Note 1]]
- [[Related Note 2]]

## References
- [External link](url)
```

### 4. Create Note

Use obsidian MCP to create the note:
```
mcp__obsidian__create-note(path, content)
```

Path format: `claude/notes/[type]/[slug].md`
- Use kebab-case for filenames
- Include date prefix for daily notes: `YYYY-MM-DD-topic.md`

### 5. Add Wikilinks

Link to any related notes found in step 2 using `[[note-name]]` syntax.

## Output

After creating, display:
```
Created: claude/notes/[type]/[filename].md

Preview:
[First 5-10 lines]

Related notes:
- [[Note 1]]
- [[Note 2]]
```

## Auto-Save Behavior

This command auto-saves to the vault. The note is created immediately without prompting.
