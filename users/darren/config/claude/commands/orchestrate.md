---
description: Analyze task and delegate to specialist agents
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
