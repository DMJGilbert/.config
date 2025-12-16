# Project Guidelines

## Git Workflow

### Conventional Commits

All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `build`: Build system or dependencies

**Examples:**

```
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
refactor(utils): extract date formatting to helper
```

### Branch Naming

- `feat/short-description` - New features
- `fix/issue-number-description` - Bug fixes
- `refactor/description` - Refactoring
- `docs/description` - Documentation

## Code Review Standards

### Must Check

1. **Security**: No hardcoded secrets, proper input validation, safe SQL queries
2. **Performance**: No N+1 queries, efficient algorithms, proper caching
3. **Tests**: Adequate coverage, edge cases handled
4. **Architecture**: Follows existing patterns, no circular dependencies

### Severity Levels

- **Critical**: Security vulnerabilities, data loss risks, breaking changes
- **High**: Performance issues, missing error handling, test gaps
- **Medium**: Code smells, maintainability concerns, documentation gaps
- **Low**: Style issues, minor improvements, suggestions

## Code Style

### General

- Prefer clarity over cleverness
- Keep functions small and focused (single responsibility)
- Use meaningful names (no abbreviations)
- Handle errors explicitly

### Language-Specific

**Nix:**

- Use `alejandra` for formatting
- Prefer attribute sets over let bindings where possible
- Use `lib.mkIf` for conditional configurations

**TypeScript/JavaScript:**

- Use `biome` or `prettier` for formatting
- Prefer `const` over `let`
- Use TypeScript strict mode

**Swift:**

- Use `swiftformat` for formatting
- Follow Swift API Design Guidelines
- Prefer value types over reference types

**Rust:**

- Use `rustfmt` for formatting
- Handle all `Result` and `Option` types explicitly
- Prefer iterators over manual loops

## Security Baselines

- No secrets in code (use environment variables or secret managers)
- Validate all external input
- Use parameterized queries for database access
- Keep dependencies updated
- Follow principle of least privilege

## Performance Baselines

- Database queries should be indexed
- API responses should be paginated
- Large lists should be virtualized
- Images should be optimized and lazy-loaded
- Bundle size should be monitored

## RIPER Workflow Methodology

All complex tasks follow the RIPER phases for thorough, structured execution:

```
┌─────────────────────────────────────────────────────────────────┐
│                      RIPER WORKFLOW                             │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────┤
│  RESEARCH   │  INNOVATE   │    PLAN     │   EXECUTE   │ REVIEW  │
│             │             │             │             │         │
│ Understand  │  Generate   │   Design    │ Implement   │ Verify  │
│ the problem │  solutions  │   approach  │ the fix     │ quality │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────┘
```

### Phase Details

| Phase | Purpose | Key Actions |
|-------|---------|-------------|
| **RESEARCH** | Deep understanding | Read code, search memory, gather context |
| **INNOVATE** | Solution exploration | Generate options, evaluate trade-offs |
| **PLAN** | Design approach | Define tasks, identify dependencies, order execution |
| **EXECUTE** | Implementation | Delegate to agents, make changes, validate |
| **REVIEW** | Quality assurance | Verify outputs, update knowledge graph, report |

### Anti-Patterns

- **Never** skip RESEARCH phase
- **Never** execute without a PLAN
- **Always** REVIEW before completing

## Context Engineering Techniques

Research-backed techniques integrated into agents and commands for improved output quality.

### Self-Refinement (Reflexion)

Based on [Self-Refine](https://arxiv.org/abs/2303.17651) and [Reflexion](https://arxiv.org/abs/2303.11366) - achieves **8-21% quality improvement**.

**Command**: `/reflect [topic]`

**Process**:

1. **CRITIQUE** - Analyze through correctness, completeness, quality, risk lenses
2. **IDENTIFY** - Prioritize improvements (Critical → High → Medium → Low)
3. **REFINE** - Apply improvements with clear before/after
4. **VERIFY** - Chain-of-Verification questions
5. **MEMORIZE** - Store insights in knowledge graph

**Used by**: orchestrator (REVIEW phase), code-reviewer

### Chain-of-Verification (CoVe)

Generate verification questions for outputs, answer independently, catch errors.

```
For each significant output:
1. Generate 3-5 verification questions
2. Answer each question independently
3. If answers reveal issues, refine output
4. Repeat until verified
```

### Multi-Perspective Review (LLM-as-Judge)

Based on [LLM-as-a-Judge](https://arxiv.org/abs/2306.05685) and [Multi-Agent Debate](https://arxiv.org/abs/2305.14325).

**Specialized Perspectives**:

| Perspective | Focus |
|-------------|-------|
| Bug Hunter | Logic errors, edge cases, race conditions |
| Security Auditor | Injection, auth gaps, data exposure |
| Performance Analyst | Big O, N+1 queries, memory leaks |
| Maintainability Expert | Readability, function size, test coverage |
| Historical Context | Codebase patterns, regression risk |
| Contracts Reviewer | API contracts, type definitions |

**Used by**: code-reviewer agent

### Five Whys (Kaizen)

Toyota's root cause analysis technique for drilling from symptoms to fundamental causes.

**Command**: `/why [problem]`

**Process**:

```
WHY 1: Why is [symptom] happening?
├── Because: [First-level cause]
├── Evidence: [How verified]
└── Continue...

WHY 5: ROOT CAUSE identified
```

**Countermeasures**:

- **Immediate**: Quick fix for symptom (temporary)
- **Corrective**: Fix the root cause (permanent)
- **Preventive**: Prevent similar issues (systemic)

### Verbalized Sampling

Based on [Verbalized Sampling](https://arxiv.org/abs/2510.01171) - achieves **2-3x diversity improvement**.

**Command**: `/brainstorm [topic]`

**Perspectives Explored**:

| Perspective | Question |
|-------------|----------|
| Pragmatist | What's the simplest solution that works? |
| Perfectionist | What's the ideal, no-constraints solution? |
| Skeptic | What could go wrong? Hidden assumptions? |
| Innovator | How would this be solved in 5 years? |
| User | What does the end user actually need? |

**Phases**: DIVERGE → EXPLORE → EVALUATE → REFINE → SYNTHESIZE

### Agentic Context Engineering

Based on [Agentic Context Engineering](https://arxiv.org/abs/2510.04618) - **10.6% improvement** through memory updates.

**Principle**: After reflection, persist insights to knowledge graph for future sessions.

```
# Store learnings after significant work
mcp__memory__aim_add_observations([{
  entityName: "conventions",
  contents: ["Learned: [insight from this session]"]
}])

# Create new entities for decisions
mcp__memory__aim_create_entities([{
  name: "decision_name",
  entityType: "decision",
  observations: ["Context", "Choice made", "Rationale"]
}])
```

**Used by**: orchestrator, architect, /reflect command

### Quick Reference

| Technique | Command/Agent | When to Use |
|-----------|---------------|-------------|
| Self-Refinement | `/reflect`, orchestrator | After completing significant work |
| CoVe | Built into agents | Verifying complex outputs |
| Multi-Perspective | code-reviewer | Code reviews, PR analysis |
| Five Whys | `/why` | Debugging, incident analysis |
| Verbalized Sampling | `/brainstorm` | Generating diverse solutions |
| Memory Updates | All agents | After decisions, learnings |

## Development Best Practices

Extracted from battle-tested skills and integrated into agents.

### Systematic Debugging (in /fix command)

**Core Principle: ALWAYS find root cause before attempting fixes.**

```
┌─────────────────────────────────────────────────────────────────┐
│  SYSTEMATIC DEBUGGING - 4 PHASES                                │
├─────────────────┬─────────────────┬─────────────────┬───────────┤
│  1. INVESTIGATE │  2. ANALYZE     │  3. HYPOTHESIZE │ 4. FIX    │
│  Root cause     │  Pattern        │  State clearly  │ Single    │
│  before fixes   │  analysis       │  Test smallest  │ change    │
│  Read errors    │  Compare working│  One variable   │ Verify    │
│  Reproduce      │  vs broken      │  at a time      │           │
└─────────────────┴─────────────────┴─────────────────┴───────────┘
```

**When 3+ Fixes Fail → STOP**

- This signals an **architectural problem**, not a fixable bug
- Return to investigation, question the design
- Discuss: "Refactor architecture vs. continue fixing symptoms?"

### Test-Driven Development (in test-engineer agent)

**Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST**

```
RED → GREEN → REFACTOR

1. Write ONE failing test (verify it fails)
2. Minimal code to pass (nothing more)
3. Clean up while green
```

| Anti-Pattern | Why Bad | Solution |
|--------------|---------|----------|
| Tests after code | Pass immediately, prove nothing | Delete and restart |
| Arbitrary timeouts | Flaky, slow | Condition-based waiting |
| Testing implementation | Brittle on refactor | Test behavior |

### Code Review Frequency (in code-reviewer agent)

**Review early, review often** - catch issues before they compound.

| Scenario | Review Type |
|----------|-------------|
| Per task (subagent work) | After each task |
| Major feature | Before integration |
| Pre-merge | Full review |
| Stuck/blocked | Ad-hoc |

### Git Workflow Best Practices

**Worktrees for Parallel Development:**

- Use `.worktrees/` or `worktrees/` directory
- Verify in `.gitignore` before creating
- Run tests to establish baseline

**Finishing a Branch:**

1. Verify all tests pass
2. Choose: Merge locally / Create PR / Keep / Discard
3. Clean up worktree if applicable
4. Never merge with failing tests

### Nix Best Practices (in nix-specialist agent)

| Do | Don't |
|----|-------|
| `writeShellApplication` | `writeShellScriptBin` |
| `nix build --print-out-paths` | Impose build timeouts |
| Fix ShellCheck warnings | Suppress them |
| `alejandra` after changes | Skip formatting |
| flake-parts for complex flakes | Manual flake structure |

## Agent Orchestration

For complex tasks, use specialist agents to handle domain-specific work efficiently.

### Invocation Methods

- **Orchestrator**: `use orchestrator` or `/orchestrate [task]` for multi-domain tasks
- **Direct**: `use [agent-name]` for specific domain work
- **Fix Command**: `/fix [problem or issue#]` for problem-solving with RIPER

### Available Specialists

| Domain | Agent | Trigger Keywords |
|--------|-------|------------------|
| Frontend | frontend-developer | react, component, tailwind, shadcn, tsx |
| Backend | backend-developer | api, endpoint, server, express, route |
| Database | database-specialist | sql, schema, query, migration, prisma |
| UI/UX | ui-ux-designer | design, accessibility, ux, layout |
| Security | security-auditor | security, vulnerability, owasp, audit |
| Docs | documentation-expert | document, readme, api-docs, jsdoc |
| Architecture | architect | architecture, pattern, scale, design |
| Rust | rust-developer | rust, cargo, tokio, systems |
| Dart | dart-developer | dart, flutter, widget, riverpod |
| Nix | nix-specialist | nix, flake, home-manager, darwin |
| Review | code-reviewer | review, pr, quality, lint |
| Testing | test-engineer | test, vitest, playwright, coverage |
| Home Assistant | home-assistant-dev | home-assistant, automation, dashboard, lovelace |

### MCP Integration

Use MCP servers to extend Claude's capabilities with external tools and data sources.

> **Note**: MCP server paths in `.mcp.json` are user-specific (hardcoded to `/Users/darren/...`).
> When forking this config, update paths in `.mcp.json` for memory storage and filesystem access.

#### Available MCP Servers

| MCP Server | Purpose | Key Tools |
|------------|---------|-----------|
| **memory** | Persistent knowledge graph | `aim_create_entities`, `aim_search_nodes`, `aim_read_graph` |
| **context7** | Library documentation | `resolve-library-id`, `get-library-docs` |
| **github** | Repository operations | `get_pull_request`, `search_issues`, `create_pull_request_review` |
| **sequential-thinking** | Complex reasoning | `sequentialthinking` for multi-step analysis |
| **magic-ui** | UI components | Component implementations, animations, effects |
| **puppeteer** | Browser automation | Screenshots, navigation, form filling |
| **hass-mcp** | Home Assistant | Entity control, automation, dashboard |
| **filesystem** | Safe file operations | Sandboxed access to Developer/, .config/, tmp/ |
| **obsidian** | Obsidian vault | Search notes, create docs, specs, ADRs |

#### Agent ↔ MCP Mapping

| Agent | MCPs Used | Use Case |
|-------|-----------|----------|
| orchestrator | memory, github, sequential-thinking, obsidian | Project knowledge, PR context, task breakdown, vault docs |
| architect | memory, sequential-thinking, context7 | Store decisions, design patterns, research |
| frontend-developer | context7, magic-ui | React docs, UI components |
| backend-developer | context7 | API framework documentation |
| code-reviewer | github, memory | PR files, comments, reviews, pattern checks |
| test-engineer | puppeteer | Visual testing, E2E automation |
| nix-specialist | context7 | Nix/home-manager documentation |
| database-specialist | context7 | ORM/database documentation |
| ui-ux-designer | magic-ui | UI components |
| home-assistant-dev | hass-mcp, context7 | Entity queries, service calls, HA docs |
| documentation-expert | obsidian, context7 | Generate and save docs to vault |

#### MCP Usage Examples

```
# Knowledge Graph Memory
mcp__memory__aim_read_graph()                       # Load all stored knowledge
mcp__memory__aim_search_nodes("authentication")     # Search for relevant context
mcp__memory__aim_create_entities([{name, entityType, observations}])
mcp__memory__aim_add_observations([{entityName, contents}])

# Fetch library documentation
mcp__context7__resolve-library-id("react")
mcp__context7__get-library-docs("/vercel/next.js", topic="routing")

# Get PR context before review
mcp__github__get_pull_request(owner, repo, pr_number)
mcp__github__get_pull_request_files(owner, repo, pr_number)

# Complex multi-step planning
mcp__sequential-thinking__sequentialthinking(thought="...", thoughtNumber=1, totalThoughts=5)

# Home Assistant entity lookup
mcp__hass-mcp__list_entities(domain="light")
mcp__hass-mcp__entity_action(entity_id="light.living_room", action="on")

# Obsidian vault operations
mcp__obsidian__search("authentication")              # Search vault notes
mcp__obsidian__read_file("claude/specs/auth-spec.md") # Read a note
mcp__obsidian__create_note("claude/notes/...", content) # Create note
```

### Persistent Memory

Claude maintains a knowledge graph across sessions using the `memory` MCP server.

#### Commands

- `/prime` - Loads existing knowledge or creates new project context
- `/prime refresh` - Force refresh knowledge graph
- `/remember` - View/search/manage memory manually

#### Automatic Memory

- `/prime` checks knowledge graph first, skips analysis if context exists
- Architect agent stores architectural decisions automatically
- Orchestrator searches memory before delegating tasks

#### What Gets Stored

| Entity Type | Examples |
|-------------|----------|
| `project` | Project name, tech stack, package manager |
| `service` | Backend services, integrations |
| `component` | UI components, modules |
| `decision` | Architecture decisions (ADRs) |
| `pattern` | Code conventions, naming patterns |

#### Memory Location

Stored in `.aim/` directory (git-ignored). Persists across sessions.

### Obsidian Vault Integration

Claude auto-saves generated documentation to the Obsidian vault.

> **Note**: Vault path (`/Users/darren/Developer/dmjgilbert/vault`) is user-specific.
> Update in `.mcp.json` filesystem server and relevant commands when forking.

#### Vault Structure

```
vault/
└── claude/                    # Claude's workspace
    ├── specs/                 # Technical specifications
    │   ├── api/
    │   ├── architecture/
    │   └── features/
    ├── docs/                  # Documentation
    │   ├── api/              # API documentation
    │   ├── guides/           # How-to guides
    │   └── decisions/        # ADRs (Architecture Decision Records)
    ├── notes/                 # Working notes
    │   ├── daily/            # Daily session notes
    │   ├── concepts/         # Concept explanations
    │   ├── learnings/        # Insights and gotchas
    │   └── reference/        # Quick references
    └── projects/              # Project-specific folders
```

#### Auto-Save Behavior

- Specs, docs, and notes are automatically saved to the vault
- Uses `[[wikilinks]]` for cross-referencing related content
- Frontmatter includes type, date, tags for organization

#### Commands

| Command | Purpose |
|---------|---------|
| `/note [topic]` | Create note (daily, concept, learning) |
| `/spec [feature]` | Generate technical specification |
| `/doc api [file]` | Generate API documentation |
| `/doc guide [topic]` | Generate step-by-step guide |
| `/doc adr [decision]` | Generate Architecture Decision Record |
| `/search-vault [query]` | Search vault content |

#### Security

- Vault content is git-ignored in this repo (see `.gitignore`)
- Use `git diff` to verify no vault content before committing
- Vault is closed-source - never reference vault paths in issues/PRs

### Background Task Execution

Run independent agent tasks in parallel by calling multiple Task tools in a single message. Use `run_in_background: true` sparingly.

#### When to Use Background Tasks

**Default**: Use foreground tasks (no `run_in_background`). Multiple Task calls in one message run in parallel automatically.

| Scenario | Mode | Reason |
|----------|------|--------|
| Frontend + Backend work | Parallel (foreground) | Multiple Task calls in single message |
| Security audit | Background only if doing other work | Otherwise use foreground |
| Schema → API → UI | Sequential | Each depends on previous |
| Quick file lookup | Foreground | Fast, immediate result |

**Avoid**: `run_in_background: true` unless you have specific work to do while waiting. Task IDs must be captured and used within the same response to avoid "No task found" errors.

#### Parallel Execution Pattern

**IMPORTANT**: Launch multiple agents in a **single message** for automatic parallel execution. Avoid `run_in_background: true` unless you need to do other work while waiting.

```
# RECOMMENDED: Multiple Task calls in one message run in parallel automatically
Task(frontend-developer, prompt="Build login form")
Task(backend-developer, prompt="Create auth API")
# Claude waits for both to complete, then continues

# Then run dependent task
Task(test-engineer, prompt="Write integration tests for login flow")
```

#### Sequential Execution Pattern

```
# When outputs feed into next task
1. Task(architect) → Returns design doc
2. Task(database-specialist) → Uses design to create schema
3. Task(backend-developer) → Implements API using schema
4. Task(code-reviewer) → Reviews all changes
```

### Workflow Example

```
User: "Add a new user profile page with authentication"

1. use orchestrator → Analyzes task, identifies agents needed
2. Delegates to frontend-developer → Creates React components
3. Delegates to backend-developer → Creates API endpoints
4. Delegates to test-engineer → Writes tests
5. Delegates to code-reviewer → Reviews final implementation
```

## Slash Commands Reference

All commands available as `/command` in Claude Code or `cc-command` from terminal.

### Code Quality & Review

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/review` | `cc-review` | Comprehensive code review of staged changes |
| `/audit [target]` | `cc-audit` | Deep code audit (entire codebase, file, or function) |
| `/perf` | `cc-perf` | Performance audit of codebase |
| `/security` | `cc-security` | Security-focused audit (OWASP, secrets, auth) |
| `/health` | `cc-health` | Project health assessment and scorecard |
| `/deps` | `cc-deps` | Dependency audit (outdated, vulnerabilities, licenses) |

### Git Workflows

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/commit` | `cc-commit` | Generate conventional commit message for staged changes |
| `/pr` | `cc-pr` | Generate PR title and description for current branch |

### Context & Memory

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/prime [refresh]` | `cc-prime` | Prime Claude with comprehensive project context |
| `/remember [query]` | `cc-remember` | Manage persistent memory (knowledge graph) |

### Problem Solving (CEK Techniques)

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/fix [problem or issue#]` | `cc-fix` | Fix a problem using RIPER workflow |
| `/why [problem]` | `cc-why` | Five Whys root cause analysis |
| `/reflect [topic]` | `cc-reflect` | Self-refinement of previous response |
| `/brainstorm [topic]` | `cc-brainstorm` | Generate diverse ideas using multiple perspectives |

### Documentation & Explanation

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/explain [code]` | `cc-explain` | Explain code sections and document complex logic |
| `/note [topic]` | `cc-note` | Create note in Obsidian vault |
| `/spec [feature]` | `cc-spec` | Generate technical specification in vault |
| `/doc [type] [topic]` | `cc-doc` | Generate documentation (API, guide, ADR) |
| `/search-vault [query]` | `cc-search-vault` | Search Obsidian vault |

### Orchestration

| Command | Shell Alias | Description |
|---------|-------------|-------------|
| `/orchestrate [task]` | `cc-orchestrate` | Analyze task and delegate to specialist agents |

## Shell Integration

### Claude Code Aliases

The `ccode` alias runs Claude Code with MCP server secrets automatically loaded:

```bash
ccode           # Start interactive Claude Code session
ccode "prompt"  # Run with initial prompt
cc-fix "bug"    # Run /fix command directly
```

Note: `ccode` is used instead of `cc` to avoid conflict with the C compiler.

### Command Functions

All slash commands have corresponding shell functions:

```bash
# Code quality
cc-review           # Review staged changes
cc-audit file.ts    # Audit specific file
cc-security         # Security audit

# Git workflows
cc-commit           # Generate commit message
cc-pr               # Generate PR description

# Problem solving
cc-fix "error X"    # Fix from description
cc-fix 123          # Fix GitHub issue #123
cc-why "failure"    # Root cause analysis
cc-reflect          # Improve last response
cc-brainstorm "X"   # Generate ideas

# Context
cc-prime            # Load project context
cc-prime refresh    # Force refresh context
```

### MCP Secrets

Secrets are loaded from sops-nix decrypted files for the duration of Claude commands:

- `GITHUB_PERSONAL_ACCESS_TOKEN`
- `HASS_HOST` / `HASS_TOKEN`
