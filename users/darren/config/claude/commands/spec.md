---
description: Generate technical specification in Obsidian vault
allowed-tools:
  - mcp__obsidian__read-note
  - mcp__obsidian__create-note
  - mcp__obsidian__edit-note
  - mcp__obsidian__search-vault
  - mcp__obsidian__create-directory
  - mcp__memory__*
  - mcp__sequential-thinking__*
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
---

# Generate Technical Specification

Generate a comprehensive technical specification and save to your Obsidian vault.

**Input**: $ARGUMENTS (feature description or GitHub issue number like #123)

## Process

### 1. RESEARCH Phase

**If GitHub issue number provided:**

```bash
gh issue view {issue_number} --json title,body,state,labels,comments
```

**Search existing context:**

```
mcp__memory__aim_search_nodes(query)
mcp__obsidian__search-vault(query)
```

**Gather requirements** from:

- Issue description and comments
- Related code in codebase
- Existing specs in vault

### 2. INNOVATE Phase

For complex systems, use sequential thinking:

```
mcp__sequential-thinking__sequentialthinking(thought, thoughtNumber, totalThoughts)
```

Generate and evaluate:

- Multiple design options
- Trade-offs (performance, complexity, maintainability)
- Risk assessment

### 3. Generate Specification

Use this template:

````markdown
---
type: specification
status: draft
created: YYYY-MM-DD
project: [project-name]
tags: [spec, project-name, feature-area]
issue: [GitHub issue URL if applicable]
---

# [Feature Name] Specification

## Overview

[1-2 paragraphs: what this feature does, why it's needed, who benefits]

## Goals

- [ ] Measurable goal 1
- [ ] Measurable goal 2

## Non-Goals

- Explicit non-goal 1 (what this spec does NOT cover)

## Requirements

### Functional Requirements

1. **FR1**: [Description]
2. **FR2**: [Description]

### Non-Functional Requirements

1. **NFR1 - Performance**: [metric/target]
2. **NFR2 - Security**: [requirement]
3. **NFR3 - Scalability**: [target]

## Technical Design

### Architecture

[System diagram description, component interaction]

### Data Models

```typescript
interface Example {
  // Schema definition
}
```
````

### API Design

| Endpoint     | Method | Description     |
| ------------ | ------ | --------------- |
| /api/example | POST   | Creates example |

## Implementation Plan

### Phase 1: [Name]

- [ ] Task 1
- [ ] Task 2

### Phase 2: [Name]

- [ ] Task 3
- [ ] Task 4

## Testing Strategy

| Type        | Approach    | Coverage Target |
| ----------- | ----------- | --------------- |
| Unit        | [Framework] | Core logic      |
| Integration | [Approach]  | API endpoints   |
| E2E         | [Tool]      | Critical paths  |

## Security Considerations

- Authentication: [Approach]
- Authorization: [Model]
- Data protection: [Strategy]

## Open Questions

- [ ] Question 1
- [ ] Question 2

## References

- [[Related Spec]]
- [External resource](url)

```

### 4. Save to Vault

Determine category:
| Spec Type | Folder |
|-----------|--------|
| API design | `claude/specs/api/` |
| Architecture | `claude/specs/architecture/` |
| Feature | `claude/specs/features/` |

Create spec:
```

mcp**obsidian**create-note("claude/specs/[category]/[feature-slug]-spec.md", content)

```

### 5. Update Knowledge Graph

Store key decisions:
```

mcp**memory**aim_create_entities([{
name: "[feature]-spec",
entityType: "specification",
observations: ["Status: draft", "Key decisions: ..."]
}])

```

## Output

```

Created: claude/specs/[category]/[name]-spec.md

Summary:

- Goals: [count]
- Requirements: [count] functional, [count] non-functional
- Implementation phases: [count]
- Open questions: [count]

Related:

- [[Existing Spec 1]]
- [[Existing Spec 2]]

```

## Auto-Save Behavior

Specs are auto-saved to the vault immediately after generation.
```
