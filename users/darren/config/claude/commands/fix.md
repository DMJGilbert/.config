# Fix

Problem-solving with RIPER workflow.

## Usage

- `/fix [problem description]` - Fix a described problem
- `/fix #123` - Fix GitHub issue by number

## Process

### 1. Parse Input

If input starts with `#`, fetch GitHub issue:

```bash
gh issue view [number] --json title,body,labels
```

### 2. Assess Complexity

Invoke `complexity-gate` skill to assess:

| Level   | Criteria                         | Action       |
| ------- | -------------------------------- | ------------ |
| TRIVIAL | Single file, obvious fix         | Direct fix   |
| SIMPLE  | 1-2 files, clear solution        | Direct fix   |
| MEDIUM  | 3+ files, some complexity        | Strict RIPER |
| COMPLEX | Architecture, security, breaking | Strict RIPER |

### 3a. Direct Fix (TRIVIAL/SIMPLE)

1. Identify the issue
2. Make the fix
3. Run relevant tests
4. Present changes for review

### 3b. Strict RIPER (MEDIUM/COMPLEX)

**RESEARCH** (researcher agent):

- Investigate the problem systematically
- Reproduce the issue with documented steps
- Trace data flow backward from symptom to root cause
- Check recent changes (`git log`, `git diff`) for regression sources
- Find relevant code and understand root cause

**Circuit breaker**: If 3+ fix attempts fail, STOP. The problem is likely architectural, not a simple bug. Return to RESEARCH and question assumptions.

**INNOVATE** (researcher agent):

- Brainstorm 2-4 approaches
- Evaluate trade-offs

**PLAN** (planner agent):

- Select approach
- Create implementation spec
- Define tasks and tests
- Save to vault

**⏸️ APPROVAL**:
Present plan and wait for user confirmation.

**EXECUTE** (domain agents):

- Implement according to plan
- Run sequentially if multiple languages
- Run tests after each task
- Run `/simplify` on changed code at each batch checkpoint

**REVIEW** (3 reviewers in parallel):

- Security review
- Bug hunt
- Quality review
- Aggregate findings

### 4. Complete

**Verify before claiming done** (see Verification Gate):

1. Run the test/command that proves the fix works
2. Show the output as evidence
3. Only then present summary

Present summary:

- What was fixed (with root cause)
- Files changed
- Test output proving the fix
- Any remaining concerns
