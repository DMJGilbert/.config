---
name: quality-gate
description: Assess task complexity and route to appropriate workflow tier. Use at the start of any development task.
---

# Quality Gate Assessment

Assess task complexity using a 4-question checklist and route to the appropriate workflow tier.

## When to Use

- Starting any development task
- Before choosing a workflow approach
- When unsure of task complexity

## The 4-Question Checklist (30 seconds)

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLEXITY GATE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Q1: Do I know exactly which files to change?           Y / N  │
│                                                                 │
│  Q2: Have I done this exact pattern before?             Y / N  │
│                                                                 │
│  Q3: Could this break something else?                   Y / N  │
│                                                                 │
│  Q4: Is there a new library/API/integration?            Y / N  │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│  SCORING:                                                       │
│                                                                 │
│  All Y on Q1/Q2, N on Q3/Q4  →  TRIVIAL                        │
│  1 N on Q1 or Q2             →  SIMPLE                         │
│  Y on Q3 (could break)       →  MEDIUM                         │
│  Y on Q4 (new/unknown)       →  COMPLEX (add POC)              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Tier Definitions

| Tier | Description | Workflow |
|------|-------------|----------|
| **TRIVIAL** | Known files, known pattern, no risk | Edit → Quick Review → Commit |
| **SIMPLE** | Minor uncertainty, low risk | Plan → Implement → Review → Commit |
| **MEDIUM** | Some ambiguity, moderate risk | Brainstorm → Plan → Implement → Review → Commit |
| **COMPLEX** | New technology, high risk, architecture | Brainstorm → Plan → POC → Validate → Implement → Review → Commit |

## Self-Check Templates

Use these after each phase to catch issues early.

### After Brainstorm (30 sec)

```
□ Explored at least 2 different approaches
□ Identified failure modes for chosen approach
□ Can explain why rejected approaches were rejected
□ Scope is clearly bounded (know what's OUT)

Any unchecked? → Spend 2 more minutes on that area
```

### After Plan (30 sec)

```
□ Each step has clear success criteria
□ Riskiest assumption is identified
□ Dependencies between steps are explicit
□ Know how to verify the final result

Riskiest assumption unclear? → Need POC
Steps have circular deps? → Reorder plan
```

### After Each Agent Handoff (15 sec)

```
□ Previous agent's output meets its contract
□ Tests/checks for previous work pass
□ No unresolved questions or assumptions

Contract not met? → Fix before proceeding
```

## Integration

This skill is used by:

- `/dev` command (unified entry point)
- `orchestrator` agent (task analysis)
- `writing-plans` skill (complexity assessment)
