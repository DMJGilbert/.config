---
description: Search Obsidian vault for notes and documentation
allowed-tools:
  - mcp__obsidian__search-vault
  - mcp__obsidian__read-note
---

# Search Obsidian Vault

Search your Obsidian vault for notes, specs, and documentation.

**Query**: $ARGUMENTS

## Process

### 1. Execute Search

```
mcp__obsidian__search-vault(query)
```

### 2. Display Results

For each result, show:

- **Title** (from filename or first heading)
- **Path** in vault
- **Preview** (first few lines or matching excerpt)
- **Tags** (from frontmatter)
- **Related** (backlinks if available)

## Output Format

```
Search results for "[query]":

1. **[Title]**
   Path: [path/to/note.md]
   Tags: #tag1 #tag2
   Preview: [First 2-3 lines or matching context]

2. **[Title]**
   Path: [path/to/note.md]
   Tags: #tag1
   Preview: [Content preview]

Found [N] results
```

## Tips

- Search by tag: `tag:spec`
- Search in folder: `path:claude/docs`
- Search by type: `type:adr`
- Combine terms: `authentication api`

## Integration

Use before creating new content to avoid duplicates:

```
/search-vault authentication
/spec User authentication  # Only if not found
```
