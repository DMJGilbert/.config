---
name: poc
description: Validate risky assumptions with minimal effort before full implementation. Use when plan identifies uncertain feasibility.
---

# Proof of Concept Framework

Validate the riskiest assumption with minimal effort before committing to full implementation.

## When to Use

- Plan identifies a "riskiest assumption"
- Using unfamiliar library/API
- Architectural change with uncertain fit
- Complex integration between components
- Quality gate routes to COMPLEX tier

## When NOT to Use

- Clear, well-understood task
- Known pattern you've done before
- Simple changes with no uncertainty

## POC Structure

### Step 1: Define the Risk

State the single thing you're most uncertain about:

```markdown
**Risk Statement:** "I'm not sure if [specific uncertainty]"

Examples:
- "I'm not sure if library X can do Y"
- "I'm not sure if this pattern will scale"
- "I'm not sure if A can integrate with B"
- "I'm not sure if this approach handles edge case Z"
```

### Step 2: Design Minimal Test

Write the smallest possible code that proves/disproves the risk:

```markdown
**POC Scope:**
- Goal: Prove [specific thing]
- Inputs: [Hardcoded test data - OK]
- Output: [What success looks like]

**Explicitly OUT of scope:**
- Error handling (not needed for POC)
- Edge cases (testing happy path only)
- Production code quality
- Tests (POC IS the test)
```

### Step 3: Define Success Criteria

Must be binary - works or doesn't:

```markdown
**Success:** [Specific observable outcome]
**Failure:** [What failure looks like]

Examples:
- Success: "API returns expected JSON structure"
- Failure: "API returns error or wrong format"
```

### Step 4: Set Time Box

If POC takes too long, the approach is wrong:

| POC Type | Time Box |
|----------|----------|
| API call test | 15-30 min |
| Library integration | 30-60 min |
| Architecture pattern | 1-2 hours |
| Complex integration | 2-4 hours |

**If you hit the time box without success → approach is too complex**

## POC Outcomes

```
┌─────────────────────────────────────────────────────────────────┐
│                     POC OUTCOMES                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SUCCESS                                                        │
│  ├─ Proceed to full implementation                              │
│  ├─ POC code is DISCARDED (or refactored)                      │
│  └─ Document: "POC proved [X] works because [Y]"               │
│                                                                 │
│  FAILURE                                                        │
│  ├─ Return to PLAN phase with learnings                        │
│  ├─ Document: "POC failed because [X]. Alternative: [Y]"       │
│  └─ Consider different approach or technology                  │
│                                                                 │
│  PARTIAL                                                        │
│  ├─ Identify what worked vs what didn't                        │
│  ├─ Adjust plan to work around limitations                     │
│  └─ May need second POC for remaining uncertainty              │
│                                                                 │
│  TIMEOUT                                                        │
│  ├─ Approach is too complex for current constraints            │
│  ├─ Return to BRAINSTORM for simpler alternatives              │
│  └─ Consider: Is the requirement actually necessary?           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## POC Location

Store POC code separately from production code:

```
project/
├── src/              # Real code - DON'T put POC here
└── .poc/             # Disposable POC experiments (git-ignored)
    └── YYYY-MM-DD-description/
        ├── poc.ts    # Minimal test code
        └── notes.md  # What was learned
```

Add to `.gitignore`:

```
.poc/
```

## POC Template

```markdown
# POC: [Description]

**Date:** YYYY-MM-DD
**Risk:** [What we're validating]
**Time Box:** [Duration]

## Hypothesis

If [action], then [expected result], because [reasoning].

## Minimal Test

[Code or steps]

## Result

- [ ] SUCCESS - Proceed with implementation
- [ ] FAILURE - Need alternative approach
- [ ] PARTIAL - [What worked, what didn't]
- [ ] TIMEOUT - Approach too complex

## Learnings

[What we discovered, whether success or failure]

## Next Steps

[Based on outcome]
```

## Integration

This skill is used by:

- `/dev` command (COMPLEX tier)
- `writing-plans` skill (when riskiest assumption identified)
- `orchestrator` agent (before delegating uncertain tasks)
