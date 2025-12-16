---
description: Generate diverse ideas using verbalized sampling and multi-perspective exploration
allowed-tools:
  - Read
  - Glob
  - Grep
  - WebSearch
  - mcp__sequential-thinking__sequentialthinking
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__memory__aim_search_nodes
---

# Brainstorm

Generate diverse ideas for: $ARGUMENTS

## Verbalized Sampling Technique

Based on [Verbalized Sampling](https://arxiv.org/abs/2510.01171) research which achieves **2-3x diversity improvement** while maintaining quality.

## Process

### Phase 1: DIVERGE - Generate Diverse Perspectives

Explore the problem from multiple viewpoints:

#### Perspective 1: The Pragmatist

- What's the simplest solution that works?
- What do most projects do in this situation?
- What's the 80/20 approach?

#### Perspective 2: The Perfectionist

- What's the ideal, no-constraints solution?
- What would a 10x engineer do?
- What would make this truly elegant?

#### Perspective 3: The Skeptic

- What could go wrong with obvious approaches?
- What are the hidden assumptions?
- What edge cases matter?

#### Perspective 4: The Innovator

- How would this be solved in 5 years?
- What if we used a completely different paradigm?
- What unconventional approaches exist?

#### Perspective 5: The User

- What does the end user actually need?
- What's the real problem behind the stated problem?
- What would delight vs. just satisfy?

### Phase 2: EXPLORE - Research and Expand

For each promising direction:

```
# Search for existing solutions
WebSearch(query="[approach] best practices")

# Check library documentation
mcp__context7__get-library-docs(...)

# Look for patterns in codebase
mcp__memory__aim_search_nodes(query="[related topic]")
```

### Phase 3: EVALUATE - Compare Options

Use structured comparison:

| Idea | Complexity   | Risk         | Value        | Novelty      | Score |
| ---- | ------------ | ------------ | ------------ | ------------ | ----- |
| A    | Low/Med/High | Low/Med/High | Low/Med/High | Low/Med/High | /20   |
| B    | ...          | ...          | ...          | ...          | /20   |

Scoring:

- **Complexity**: Low=5, Med=3, High=1 (simpler is better)
- **Risk**: Low=5, Med=3, High=1 (safer is better)
- **Value**: High=5, Med=3, Low=1 (more value is better)
- **Novelty**: Varies based on need (innovation vs. proven)

### Phase 4: REFINE - Develop Top Ideas

For top 2-3 ideas, develop:

```markdown
### Idea: [Name]

**Concept**: [One-sentence description]

**How it works**:

1. [Step 1]
2. [Step 2]
3. [Step 3]

**Pros**:

- [Advantage 1]
- [Advantage 2]

**Cons**:

- [Disadvantage 1]
- [Disadvantage 2]

**Implementation sketch**:
[High-level approach or pseudocode]

**Open questions**:

- [Question 1]
- [Question 2]
```

### Phase 5: SYNTHESIZE - Combine and Recommend

Often the best solution combines elements from multiple ideas:

```markdown
## Recommended Approach

**Core**: [Primary approach from Idea X]
**Enhanced by**: [Element from Idea Y]
**With safeguards from**: [Element from Idea Z]

**Rationale**: [Why this combination]
```

## Output Format

```markdown
## Brainstorm: [Topic]

### Problem Understanding

[Restate the problem to ensure alignment]

### Perspectives Explored

| Perspective   | Key Insight | Idea Generated |
| ------------- | ----------- | -------------- |
| Pragmatist    | [Insight]   | [Idea]         |
| Perfectionist | [Insight]   | [Idea]         |
| Skeptic       | [Insight]   | [Idea]         |
| Innovator     | [Insight]   | [Idea]         |
| User          | [Insight]   | [Idea]         |

### Top Ideas Detailed

#### Idea 1: [Name]

[Full development...]

#### Idea 2: [Name]

[Full development...]

#### Idea 3: [Name]

[Full development...]

### Comparison Matrix

| Criteria          | Idea 1 | Idea 2 | Idea 3 |
| ----------------- | ------ | ------ | ------ |
| Complexity        |        |        |        |
| Risk              |        |        |        |
| Value             |        |        |        |
| Time to implement |        |        |        |
| Maintainability   |        |        |        |

### Recommendation

**Go with**: [Recommended approach]
**Because**: [Rationale]
**Next steps**: [Actions to proceed]
```

## Tips for Better Brainstorming

1. **Resist premature convergence** - Generate at least 5 distinct ideas before evaluating
2. **Embrace bad ideas** - They often lead to good ones
3. **Combine freely** - Best solutions often hybrid multiple approaches
4. **Question constraints** - Some "requirements" are actually preferences
5. **Sleep on it** - For big decisions, revisit after a break
