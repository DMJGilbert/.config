---
name: complexity-gate
description: Assess task complexity to determine workflow. Use at the start of tasks to route TRIVIAL/SIMPLE to direct action or MEDIUM/COMPLEX to strict RIPER.
allowed-tools: Read, Grep, Glob
argument-hint: "[task description]"
---

# Complexity Gate

Assess task complexity and route to appropriate workflow.

## When to Use

- Start of any development task
- When `/fix` is invoked
- When determining if strict RIPER is needed

## Assessment Criteria

### Scoring Factors

| Factor                    | Points               | Examples                    |
| ------------------------- | -------------------- | --------------------------- |
| **File count**            | +1 per file beyond 2 | 5 files = +3 points         |
| **Keyword: architecture** | +3                   | "redesign architecture"     |
| **Keyword: refactor**     | +2                   | "refactor module"           |
| **Keyword: security**     | +3                   | "fix auth vulnerability"    |
| **Keyword: migrate**      | +3                   | "migrate to new API"        |
| **Keyword: breaking**     | +3                   | "breaking change"           |
| **Keyword: performance**  | +2                   | "optimize queries"          |
| **Scope: module/system**  | +2                   | Affects multiple components |
| **Risk: production**      | +2                   | Production code, data       |
| **Risk: auth/secrets**    | +2                   | Authentication, credentials |

### Negation Factors

| Factor              | Points | Examples       |
| ------------------- | ------ | -------------- |
| **Keyword: simple** | -2     | "simple fix"   |
| **Keyword: quick**  | -2     | "quick change" |
| **Keyword: minor**  | -2     | "minor update" |
| **Keyword: typo**   | -3     | "fix typo"     |

## Thresholds

| Score | Level   | Workflow         |
| ----- | ------- | ---------------- |
| 0-2   | TRIVIAL | Direct action    |
| 3-4   | SIMPLE  | Direct action    |
| 5-7   | MEDIUM  | **Strict RIPER** |
| 8+    | COMPLEX | **Strict RIPER** |

### Minimum Floor Overrides

The score is **floored** before threshold lookup if any of these apply, regardless of negation keywords:

| Trigger                                         | Floor  |
| ----------------------------------------------- | ------ |
| Touches auth, secrets, credentials, or sessions | MEDIUM |
| Touches migration, breaking change, or schema   | MEDIUM |
| Production data path / payment / PII            | MEDIUM |
| Cryptographic operations (signing, encryption)  | MEDIUM |

Rationale: "simple auth typo" should not bypass RIPER — security-relevant changes carry tail risk that the additive keyword score doesn't capture. The floor sets a minimum; positive points still escalate above MEDIUM if warranted.

## Output

After assessment, state:

```
Complexity: [LEVEL] (score: [N])
Factors: [list key factors]
Workflow: [Direct action / Strict RIPER]
```

Then proceed with appropriate workflow.

## Execution Mode Selection

Gate also recommends execution pattern:

| Pattern    | When                                        | Reason                                                |
| ---------- | ------------------------------------------- | ----------------------------------------------------- |
| `direct`   | TRIVIAL/SIMPLE                              | No RIPER needed                                       |
| `subagent` | MEDIUM/COMPLEX, single-layer                | Sequential RIPER with domain agents                   |
| `team`     | COMPLEX + cross-layer                       | Parallel execution with agent team                    |
| `workflow` | COMPLEX (score ≥ 8) + highly parallelisable | Dynamic workflow — orchestration codified as a script |

**Cross-layer indicators** (trigger `team` mode):

- Multiple language types (e.g. Nix + Rust + TypeScript)
- Frontend + backend + infrastructure changes
- 3+ independent file sets with no shared dependencies
- Competing implementation hypotheses to evaluate in parallel

**High-parallelism indicators** (trigger `workflow` mode, requires COMPLEX):

- Codebase-wide audit or scan (e.g. security review of all files)
- Large migration where N independent modules can be updated concurrently
- Multi-source research requiring synthesis from many independent inputs
- Tasks where intermediate results must live in script variables, not context
- REVIEW phase fan-out → use `/riper-review` saved workflow

Include execution mode in output:

```
Complexity: [LEVEL] (score: [N])
Factors: [list key factors]
Workflow: [Direct action / Strict RIPER]
Execution: [direct / subagent / team / workflow]
```

## Examples

**"Fix typo in README"**

- typo: -3
- Single file: 0
- **Score: -3 → TRIVIAL → Direct action**

**"Refactor authentication module"**

- refactor: +2
- auth: +2
- Multiple files likely: +2
- **Score: 6 → MEDIUM → Strict RIPER**

**"Migrate database schema with breaking changes"**

- migrate: +3
- breaking: +3
- production risk: +2
- **Score: 8 → COMPLEX → Strict RIPER**
