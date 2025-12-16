---
description: Generate documentation in Obsidian vault (API docs, guides, ADRs)
allowed-tools:
  - mcp__obsidian__read-note
  - mcp__obsidian__create-note
  - mcp__obsidian__edit-note
  - mcp__obsidian__search-vault
  - mcp__obsidian__create-directory
  - mcp__obsidian__list-available-vaults
  - mcp__memory__*
  - mcp__sequential-thinking__*
  - Read
  - Grep
  - Glob
---

# Generate Documentation

Generate documentation and save to your Obsidian vault. Supports API docs, guides, and Architecture Decision Records.

**Input**: $ARGUMENTS

## Usage Patterns

```
/doc api src/routes/auth.ts     → API documentation
/doc guide [topic]              → Step-by-step guide
/doc adr [decision]             → Architecture Decision Record
/doc [general topic]            → General documentation
```

## Documentation Types

### 1. API Documentation (`/doc api [file]`)

**Process:**

1. Read the source file(s)
2. Extract endpoints, types, schemas
3. Generate request/response examples
4. Document auth requirements

**Template:**

```markdown
---
type: api-documentation
created: YYYY-MM-DD
source: [file path]
tags: [api, docs, module-name]
---

# [Module] API

## Overview
[Purpose of this API]

## Authentication
[Auth requirements - Bearer token, API key, etc.]

## Endpoints

### `METHOD /path`

**Description**: [What it does]

**Request:**
```typescript
interface RequestBody {
  // fields
}
```

**Response:**

```typescript
interface Response {
  // fields
}
```

**Example:**

```bash
curl -X METHOD https://api.example.com/path \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"field": "value"}'
```

**Status Codes:**

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad request |
| 401 | Unauthorized |

## Error Handling

[Common errors and solutions]

```

**Save to:** `claude/docs/api/[module]-api.md`

---

### 2. User Guide (`/doc guide [topic]`)

**Process:**
1. Understand goal and audience
2. Structure as progressive steps
3. Include code examples
4. Add troubleshooting section

**Template:**
```markdown
---
type: guide
created: YYYY-MM-DD
tags: [guide, topic]
audience: [developers|users|admins]
---

# [Guide Title]

## Overview
[What this guide covers and prerequisites]

## Prerequisites
- [ ] Prerequisite 1
- [ ] Prerequisite 2

## Steps

### Step 1: [Action]
[Detailed instructions]

```bash
# Commands to run
```

### Step 2: [Action]

[Instructions with screenshots/examples]

## Verification

How to verify it worked:

1. Check X
2. Verify Y

## Troubleshooting

### Problem: [Issue]

**Solution**: [Fix]

### Problem: [Issue]

**Solution**: [Fix]

## Next Steps

- [[Related Guide]]
- [[Advanced Topic]]

```

**Save to:** `claude/docs/guides/[topic-slug].md`

---

### 3. Architecture Decision Record (`/doc adr [decision]`)

**Process:**
1. Use sequential thinking to analyze decision
2. Document context, options, trade-offs
3. Record decision and consequences
4. Number sequentially (find highest existing ADR number + 1)

**Template:**
```markdown
---
type: adr
status: accepted
date: YYYY-MM-DD
tags: [adr, architecture]
---

# ADR-[NNNN]: [Decision Title]

## Status
accepted

## Context
[What is the issue motivating this decision?]

## Decision
[What change are we making?]

## Consequences

### Positive
- Benefit 1
- Benefit 2

### Negative
- Trade-off 1
- Trade-off 2

## Options Considered

### Option 1: [Name]
**Pros:** [advantages]
**Cons:** [disadvantages]

### Option 2: [Name]
**Pros:** [advantages]
**Cons:** [disadvantages]

## Implementation Notes
[Technical details, migration path if applicable]

## References
- [[Related ADR]]
- [External resource](url)
```

**Save to:** `claude/docs/decisions/[NNNN]-[slug].md`

---

## Auto-Save Behavior

All documentation is auto-saved to the vault immediately.

## Output Format

```
Created: claude/docs/[category]/[filename].md

Type: [API doc | Guide | ADR]
Sections: [count]

Preview:
[First section]

Related:
- [[Related Doc 1]]
- [[Related Doc 2]]
```
