---
description: Reflect on previous response and iteratively improve it
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__sequential-thinking__sequentialthinking
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_add_observations
---

# Reflect

Reflect on and improve: $ARGUMENTS

If no argument, reflect on the most recent response or action in this conversation.

## Self-Refinement Framework

Based on [Self-Refine](https://arxiv.org/abs/2303.17651) and [Reflexion](https://arxiv.org/abs/2303.11366) papers, which demonstrate **8-21% quality improvement** through feedback loops.

### Phase 1: CRITIQUE

Analyze the previous output through multiple lenses:

#### Correctness Lens

- Is the logic sound?
- Are there edge cases missed?
- Does it actually solve the problem?

#### Completeness Lens

- Are all requirements addressed?
- Is anything missing?
- Are there unstated assumptions?

#### Quality Lens

- Is the code/solution maintainable?
- Does it follow best practices?
- Is it the simplest solution?

#### Risk Lens

- What could go wrong?
- Are there security implications?
- What are the failure modes?

### Phase 2: IDENTIFY IMPROVEMENTS

Use `mcp__sequential-thinking__sequentialthinking` for complex analysis:

```
For each issue identified:
1. What is the specific problem?
2. Why is it a problem?
3. What is the ideal state?
4. What is the minimal change to achieve it?
```

Categorize improvements:

| Priority | Type | Description |
|----------|------|-------------|
| Critical | Must fix | Breaks functionality or security |
| High | Should fix | Significant quality impact |
| Medium | Could improve | Better but not essential |
| Low | Nice to have | Minor enhancement |

### Phase 3: REFINE

For each Critical/High improvement:

1. State the current approach
2. Explain why it's suboptimal
3. Provide the improved version
4. Explain why it's better

### Phase 4: VERIFY

Chain-of-Verification (CoVe):

1. Generate verification questions for the refinement
2. Answer each question independently
3. If answers reveal issues, return to Phase 2

### Phase 5: MEMORIZE (Optional)

If significant insights were gained:

```
mcp__memory__aim_add_observations([{
  entityName: "conventions",
  contents: ["Learned: [insight from this reflection]"]
}])
```

## Output Format

```markdown
## Reflection on: [Topic]

### Critique
| Lens | Finding | Severity |
|------|---------|----------|
| Correctness | [Issue] | [Critical/High/Medium/Low] |
| ... | ... | ... |

### Improvements

#### [Improvement 1]
**Current**: [What it is now]
**Issue**: [Why it's problematic]
**Refined**: [Better approach]
**Rationale**: [Why this is better]

### Verification
- [ ] [Verification question 1] → [Answer]
- [ ] [Verification question 2] → [Answer]

### Insights to Remember
- [Key learning for future]
```

## When to Use

- After completing a significant implementation
- When output quality seems suboptimal
- Before finalizing architectural decisions
- After debugging sessions to capture learnings
