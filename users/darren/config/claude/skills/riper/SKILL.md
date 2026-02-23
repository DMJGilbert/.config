---
name: riper
description: RIPER workflow methodology for structured development. Loaded when strict mode is triggered for MEDIUM/COMPLEX tasks.
allowed-tools: Read, Grep, Glob, LSP
---

# RIPER Workflow

Structured development workflow ensuring thorough analysis before implementation.

## Phases

```
RESEARCH → INNOVATE → PLAN → [APPROVAL] → EXECUTE → REVIEW
```

### 1. RESEARCH

**Agent**: researcher (sonnet)
**Purpose**: Deep understanding before solutions

**Actions**:
- Read relevant code files
- Use LSP for navigation (go-to-definition, find-references)
- Search for related patterns
- Query memory for prior context
- Query context7 for library docs

**Output**: Problem summary, relevant files, constraints, open questions

**Rule**: Do NOT propose solutions yet

---

### 2. INNOVATE

**Agent**: researcher (sonnet)
**Purpose**: Generate multiple approaches

**Actions**:
- Brainstorm 2-4 distinct solutions
- For each, identify pros/cons/risks
- Consider trade-offs

**Output**: Options with trade-offs for planner

**Rule**: Do NOT pick a winner yet

---

### 3. PLAN

**Agent**: planner (sonnet)
**Purpose**: Create implementation specification

**Actions**:
- Review research and options
- Select best approach (or combine)
- Break down into tasks
- Identify files to change
- Define test criteria
- Save spec to vault
- Store decisions to memory

**Output**: Implementation plan with tasks

**Rule**: Do NOT write code yet

---

### 4. APPROVAL GATE

**Purpose**: User confirms plan before execution

**Present**:
- Summary of approach
- Task list
- Files affected
- Risks identified

**Wait for**: User approval or feedback

**On rejection**: Return to PLAN (or RESEARCH if fundamental issue)

---

### 5. EXECUTE

**Agent**: Domain agents (sonnet)
**Purpose**: Implement the plan

**Actions**:
- Execute in batches of 3 tasks
- After each batch: verify results, present status, pause for feedback
- Use appropriate domain agent per file type
- Run tests after each task
- Sequential execution for multi-language

**Batch checkpoint protocol**:
1. Complete up to 3 tasks from the plan
2. Run verification (tests, build, checks) for the batch
3. Present: what was done, verification output, any issues
4. Say "Ready for feedback" and wait for user response
5. Adjust based on feedback, then continue to next batch

**Stop immediately when**:
- A task fails verification and the fix isn't obvious
- A dependency is missing or unclear
- The plan doesn't match the actual codebase state
- 3+ fix attempts fail on the same issue (circuit breaker)

**Agent selection**:
| Extension | Agent |
|-----------|-------|
| .nix | nix |
| .rs | rust |
| .ts, .tsx | frontend |
| .js (node) | backend |
| .html, .css | ui |
| .dart | dart |
| .yaml (HA) | hass |

**Execution mode** (determined in PLAN phase):

| Mode | Use When | Pattern |
|------|----------|---------|
| Subagent (default) | Single-layer, same file type, sequential, <3 files | Domain agents called sequentially by lead |
| Team | Cross-layer (3+ languages), 3+ independent file sets, competing approaches | Parallel teammates with file ownership |

**Rule**: Follow the plan, don't improvise

---

### 6. REVIEW

**Agents**: security-reviewer, bug-hunter, quality-reviewer (parallel)
**Purpose**: Validate implementation

**Actions**:
- Run all 3 reviewers in parallel
- Each focuses on their specialty
- Aggregate findings by severity
- Present unified report

**Output**:
- Critical/High/Medium/Low issues
- Overall assessment
- Ready to merge or needs fixes

### Processing Review Findings

When review findings require fixes:
1. Read all findings before acting
2. Verify each suggestion against actual code (reviewers can be wrong)
3. Fix one issue at a time, test between each
4. Push back technically if a suggestion doesn't apply
5. Re-run reviewers after fixes to confirm resolution

---

## Anti-Patterns

1. **Never** skip RESEARCH - understand before acting
2. **Never** execute without a PLAN - know what you're building
3. **Never** skip REVIEW - validate your work
4. **Never** ignore approval gate - user must confirm plan

## When Plan is Rejected

1. Ask for specific feedback
2. If approach is wrong → return to INNOVATE
3. If understanding is wrong → return to RESEARCH
4. If details are wrong → revise PLAN

---

## Team Execution (Swarm Mode)

When plan specifies team execution:

### Setup
1. Lead spawns teammates via delegate mode
2. Assign file ownership per teammate (no overlaps)
3. Define dependency waves in plan

### Execution
1. **Wave-by-wave**: All teammates in wave 1 execute in parallel → wait → wave 2
2. **No overlapping writes**: Shared read access, exclusive write ownership
3. **Report to lead**: Teammates flag completion and blockers
4. **Lead coordinates**: Resolves conflicts, manages dependencies, makes trade-offs

### Completion
- All teammates report findings
- Lead aggregates changes
- REVIEW phase examines full changeset
