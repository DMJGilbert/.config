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

### 0. GATE (self-assessment — always runs first)

On invocation, run the complexity assessment yourself (see `references/complexity.md`) before entering RESEARCH — do not assume the user pre-routed correctly:

- **TRIVIAL/SIMPLE** → state the score and downgrade to direct action; do not run the phase ladder on a one-liner.
- **Live-system debugging** (feedback comes from a system the user operates — remote host, Home Assistant, hardware) → use the DIAGNOSE loop (see `references/complexity.md` § DIAGNOSE Loop) instead of the full ladder.
- **MEDIUM/COMPLEX** → proceed to RESEARCH.

### Agent Hygiene (applies to every phase)

- **Inline-first**: the lead does RESEARCH inline by default; spawn a researcher only when the task spans 3+ independent file sets (per the Orchestration Primitives table).
- **Preview before spawn**: before spawning any agent, state its intended prompt in one line so the user can veto cheaply.
- **Stand down means stop**: TaskStop teammates/background agents the moment their phase output is accepted — never leave them emitting idle heartbeats.
- **No open-ended fixers**: never spawn an `acceptEdits` agent with an open-ended "debug and fix it" prompt; diagnose first, then delegate a scoped change.

### Phase State (survives compaction)

At every phase transition, persist the current phase + pointer to the approved plan/spec (vault spec, or `.claude/riper-state.md` if the vault is unavailable). After any context compaction, re-read it and restate the current phase header before continuing — compaction summaries do not preserve phase discipline.

### 1. RESEARCH

**Agent**: researcher (opus)
**Purpose**: Deep understanding before solutions
**Reasoning effort**: High (`ultrathink`) for COMPLEX tasks

**Actions**:

- Read relevant code files
- Use LSP for navigation (go-to-definition, find-references)
- Search for related patterns
- Query memory for prior context
- Query context7 for library docs

**Output**: Problem summary, relevant files, constraints, open questions

**Rule**: Do NOT propose solutions yet

**Exit criteria** (advance only when all true):

- Relevant files identified and their relationships are clear
- Constraints documented (technical, scope, time)
- Open questions explicitly listed (or marked "none")
- Still in problem-space — no solution language has been written

---

### 2. INNOVATE

**Agent**: researcher (opus)
**Purpose**: Generate multiple approaches
**Reasoning effort**: High (`ultrathink`) for COMPLEX tasks

**Actions**:

- Brainstorm 2-4 distinct solutions
- For each, identify pros/cons/risks
- Consider trade-offs

**Output**: Options with trade-offs for planner

**Rule**: Do NOT pick a winner yet

**Exit criteria** (advance only when all true):

- At least 2 distinct approaches generated
- Pros / cons / risks listed per approach
- Trade-offs between approaches stated, not implicit
- No single winner chosen yet — still in option-space

---

### 3. PLAN

**Runs inline** (the `planner` agent was removed — it was never spawned)
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

**Exit criteria** (advance only when all true):

- Approach selected with stated reason
- Task list broken down to individually-executable units
- Affected files enumerated
- Verification criteria defined per task
- Spec saved to vault, decisions stored to memory
- No code has been written yet

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

**Exit criteria** (advance only when all true):

- User has explicitly approved (not inferred from absence of pushback)
- Any feedback incorporated back into PLAN
- Plan still reflects current codebase state (not stale)

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
3. Run `/code-review` on changed code to catch correctness bugs, quality, and efficiency issues
4. Present: what was done, verification output, code-review findings, any issues
5. Say "Ready for feedback" and wait for user response
6. Adjust based on feedback, then continue to next batch

**Stop immediately when**:

- A task fails verification and the fix isn't obvious
- A dependency is missing or unclear
- The plan doesn't match the actual codebase state
- 3+ fix attempts fail on the same issue (circuit breaker)

**Agent selection**:

| Extension   | Agent    |
| ----------- | -------- |
| .nix        | nix      |
| .rs         | rust     |
| .ts, .tsx   | frontend |
| .js (node)  | backend  |
| .html, .css | ui       |
| .dart       | dart     |
| .yaml (HA)  | hass     |

**Execution mode** (determined in PLAN phase): see canonical table in `references/complexity.md` (§ Execution Mode Selection). RIPER uses `subagent` / `team` / `workflow`; the `direct` mode bypasses RIPER and is selected by the gate before this skill runs.

**Rule**: Follow the plan, don't improvise

**Deviation checkpoint**: If execution requires reversing a decision the user previously approved or stated (library choice, design direction), or adding a dependency, submodule, or config default not named in the approved plan, STOP and confirm first — one sentence stating the change and why, before the tool call that makes it. Silent pivots are the failure mode; friction with the approved approach is a checkpoint, not an implementation detail.

**Committing**: Never include commit steps in plans or task batches unless the user explicitly requested committing — the user always commits manually via `/commit`.

**Exit criteria** (advance only when all true):

- All tasks from the plan complete
- Each task has verification output cited (per Verification Gate in CLAUDE.md)
- No outstanding fix attempts (circuit breaker not tripped)
- Diff is ready for REVIEW phase

---

### 6. REVIEW

**Agents**: security-reviewer, bug-hunter, quality-reviewer, intent/style reviewer (parallel)
**Purpose**: Validate implementation

**Preferred**: Use `/riper-review` saved workflow — resolves scope (committed diff **plus** uncommitted work), infers branch intent, runs the 4 reviewers and the project's lint/typecheck concurrently, then adversarially verifies and baseline-attributes every Critical/High finding.

**Manual fallback** (if workflow unavailable):

- Spawn all 4 reviewers in parallel as subagents
- Each focuses on their specialty
- Run the project lint and type checker; triage their diagnostics as findings
- Aggregate findings by severity
- Present unified report

**Output**:

- `review.md` at the repo root: branch intent, iteration number, issues numbered and grouped into Logical Errors / Style Compliance / Other, each with a grep-verified line number and a provenance label (new / pre-existing / latent bug exposed by this branch)
- Chat summary: Critical/High/Medium/Low issues, refuted findings, coverage gaps
- Overall assessment
- Ready to merge or needs fixes

**Iterative reviews**: `review.md` is read back on the next run — each prior issue is re-checked and reported as fixed / unchanged / partially improved, and the iteration count increments.

### Processing Review Findings

When review findings require fixes:

1. Read all findings before acting
2. Verify each suggestion against actual code (reviewers can be wrong)
3. Fix one issue at a time, test between each
4. Push back technically if a suggestion doesn't apply
5. Re-run reviewers after fixes to confirm resolution

**Exit criteria** (workflow complete when all true):

- All 4 reviewers ran (or manual fallback completed), and lint/typecheck either ran or the reason it could not is recorded
- Changed files outside lint/typecheck config paths reviewed manually and the gap noted
- Findings aggregated by the canonical Severity Rubric (`workflows/riper-review.js`)
- Each Critical/High finding triaged (applied as fix, rejected with rationale, or accepted as known risk)
- Each Critical/High finding attributed: introduced by this branch, pre-existing on the base ref, or a latent bug exposed by this branch (latent-exposed still blocks merge)
- Merge recommendation stated: ready / needs fixes / block

---

## Enforce-able Checks

These positive checks make phase-skipping detectable rather than relying on "don't skip" intent:

1. **Before INNOVATE** — state the 3-bullet RESEARCH summary back (problem, relevant files, open questions). If you can't, you skipped RESEARCH.
2. **Before EXECUTE** — restate the PLAN's task list verbatim (1 line per task). If you're improvising, this check fails.
3. **Before declaring task done** — cite the verification command output (per Verification Gate in CLAUDE.md). If you can't cite, you skipped verification.
4. **Before REVIEW** — confirm all PLAN tasks have verification output cited. If not, EXECUTE hasn't actually exited.
5. **Before merge/handoff** — state the merge recommendation from REVIEW (ready / needs fixes / block). Implicit "looks fine" is not a recommendation.

Each check has a corresponding **Exit criteria** block in the phase definitions above — these checks just make the check moment explicit at the gate.

## When Plan is Rejected

1. Ask for specific feedback
2. If approach is wrong → return to INNOVATE
3. If understanding is wrong → return to RESEARCH
4. If details are wrong → revise PLAN

---

## Team Execution (Swarm Mode)

When plan specifies team execution:

### Setup

1. Lead spawns teammates via the Agent tool (`subagent_type`) or natural-language team instructions
2. Worktree isolation is the default; set `worktree.bgIsolation: "none"` in settings.json to allow working-copy edits
3. Assign file ownership per teammate (no overlaps)
4. Define dependency waves in plan

### Execution

1. **Wave-by-wave**: All teammates in wave 1 execute in parallel → wait → wave 2
2. **No overlapping writes**: Shared read access, exclusive write ownership
3. **Report to lead**: Teammates flag completion and blockers
4. **Lead coordinates**: Resolves conflicts, manages dependencies, makes trade-offs

### Completion

- All teammates report findings
- Lead aggregates changes
- REVIEW phase examines full changeset
