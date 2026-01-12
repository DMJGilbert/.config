---
description: Quality-gated development workflow with complexity assessment
skills:
  - quality-gate
  - requirements-dialogue
  - writing-plans
  - poc
  - review-workflow
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - mcp__memory__aim_memory_search
  - mcp__sequential-thinking__sequentialthinking
---

# Quality-Gated Development

Unified entry point for development tasks with built-in quality gates.

**Task:** $ARGUMENTS

## Step 1: Complexity Assessment

Run the 4-question complexity gate:

```
Q1: Do I know exactly which files to change?           Y / N
Q2: Have I done this exact pattern before?             Y / N
Q3: Could this break something else?                   Y / N
Q4: Is there a new library/API/integration?            Y / N
```

**Routing:**

| Answers | Tier | Workflow |
|---------|------|----------|
| All Y on Q1/Q2, N on Q3/Q4 | TRIVIAL | → Step 2a |
| 1 N on Q1 or Q2 | SIMPLE | → Step 2b |
| Y on Q3 (could break) | MEDIUM | → Step 2c |
| Y on Q4 (new/unknown) | COMPLEX | → Step 2d |

## Step 2a: TRIVIAL Workflow

```
Edit → Quick Review → Commit
```

1. Make the change directly
2. Quick self-review: `git diff`
3. Commit if correct

## Step 2b: SIMPLE Workflow

```
Plan → Implement → Review → Commit
```

1. **Plan**: Brief plan (which files, what changes)
2. **Implement**: Make changes
3. **Review**: Self-review with `git diff`
4. **Commit**: If all checks pass

## Step 2c: MEDIUM Workflow

```
Brainstorm → Plan → Implement → Review → Commit
```

1. **Brainstorm** (requirements-dialogue skill):
   - Explore 2-3 approaches
   - Apply constraint questions
   - Self-check before proceeding

2. **Plan** (writing-plans skill):
   - Create task breakdown
   - Pre-mortem analysis
   - Identify riskiest assumption

3. **Implement**: Execute plan with TodoWrite tracking

4. **Review**: Comprehensive self-review

5. **Commit**: With conventional commit format

## Step 2d: COMPLEX Workflow

```
Brainstorm → Plan → POC → Validate → Implement → Review → Commit
```

1. **Brainstorm**: Full requirements dialogue

2. **Plan**: Detailed plan with pre-mortem

3. **POC** (poc skill):
   - Identify riskiest assumption from plan
   - Create minimal proof-of-concept
   - Time-box the POC
   - Evaluate outcome

4. **Validate POC**:
   - SUCCESS → Proceed to implementation
   - FAILURE → Return to brainstorm with learnings
   - PARTIAL → Adjust plan, maybe second POC
   - TIMEOUT → Simplify or choose different approach

5. **Implement**: Execute validated plan

6. **Review**: Full review before commit

7. **Commit**: Document POC learnings if valuable

## Phase Transitions

Each phase includes a self-check before proceeding:

### After Brainstorm
```
□ Explored at least 2 approaches
□ Identified failure modes
□ Scope is bounded
```

### After Plan
```
□ Each step has success criteria
□ Riskiest assumption identified
□ Dependencies explicit
```

### After POC (if applicable)
```
□ Risk was validated
□ Learnings documented
□ Go/no-go decision made
```

### After Implement
```
□ All planned tasks complete
□ Tests pass (if applicable)
□ No untracked changes
```

## Output Format

```markdown
## Development Summary

**Task:** [Original request]
**Tier:** [TRIVIAL | SIMPLE | MEDIUM | COMPLEX]

### Workflow Executed
[List of phases completed]

### Changes Made
| File | Change |
|------|--------|
| ... | ... |

### Quality Gates Passed
- [ ] Complexity assessment
- [ ] Constraint questions (if MEDIUM+)
- [ ] Pre-mortem (if MEDIUM+)
- [ ] POC validation (if COMPLEX)
- [ ] Self-review
- [ ] Tests pass

### Learnings (if any)
[Notable insights for future reference]
```

## Integration

This command orchestrates:
- `quality-gate` skill for complexity assessment
- `requirements-dialogue` skill for brainstorming
- `writing-plans` skill for planning
- `poc` skill for validation
- `review-workflow` skill for review process

For multi-agent tasks, use `/orchestrate` instead.
