---
description: Analyze task and delegate to specialist agents
allowed-tools:
  - Task
  - Read
  - Glob
  - Grep
  - mcp__memory__aim_search_nodes
---

Analyze the following task and determine which specialist agent(s) should handle it.
Consider the domain, complexity, and required expertise.

## Task

$ARGUMENTS

## Available Specialist Agents

| Agent                | Domain                              | Best For                         |
| -------------------- | ----------------------------------- | -------------------------------- |
| frontend-developer   | React, TypeScript, Tailwind, shadcn | UI components, client-side logic |
| backend-developer    | APIs, Node.js, Express              | Server endpoints, middleware     |
| database-specialist  | PostgreSQL, SQL, ORMs               | Schema, queries, migrations      |
| ui-ux-designer       | Design systems, accessibility       | UX patterns, design tokens       |
| security-auditor     | OWASP, vulnerabilities              | Security review, hardening       |
| documentation-expert | Technical writing                   | Docs, README, API specs          |
| architect            | System design, patterns             | Architecture decisions           |
| rust-developer       | Rust, systems programming           | Performance-critical code        |
| dart-developer       | Dart, Flutter                       | Cross-platform apps              |
| nix-specialist       | Nix, home-manager, flakes           | System configuration             |
| code-reviewer        | Code review, quality                | PR reviews, audits               |
| test-engineer        | Vitest, Playwright                  | Testing strategies               |

## Analysis Steps

1. **Identify Domains**: What technical areas does this task touch?
2. **Assess Complexity**: Is this a single-agent or multi-agent task?
3. **Check Dependencies**: What order should agents work in?
4. **Plan Execution**: Sequential or parallel execution?

## Response Format

Provide:

1. **Recommended Agent(s)**: Which specialists to use and why
2. **Execution Order**: Sequential steps or parallel tasks
3. **Context to Provide**: What each agent needs to know
4. **Quality Checks**: How to verify the work is complete
5. **Clarifying Questions**: If any requirements are unclear

## Execution Patterns

After analysis, **execute** using these patterns:

### Parallel Execution (Independent Tasks)

Launch multiple agents in a **single message** - they run in parallel automatically:

```
Task(frontend-developer, prompt="Build login form UI")
Task(backend-developer, prompt="Create auth API endpoint")
Task(test-engineer, prompt="Write integration tests")
# Claude waits for all to complete
```

### Sequential Execution (Dependencies)

When outputs feed into subsequent tasks:

```
1. Task(architect) → Design decisions
2. Task(database-specialist) → Schema based on design
3. Task(backend-developer) → API based on schema
```

### Background + Foreground (Long + Short Tasks)

For long audits alongside implementation:

```
audit = Task(security-auditor, prompt="Full audit", run_in_background: true)
Task(frontend-developer, prompt="Build feature")
TaskOutput(audit.id, block: true)  # Collect audit results
```

See `skills/parallel-agents/SKILL.md` for detailed patterns.
