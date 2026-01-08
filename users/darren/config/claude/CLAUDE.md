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

| Phase        | Purpose              | Key Actions                                          |
| ------------ | -------------------- | ---------------------------------------------------- |
| **RESEARCH** | Deep understanding   | Read code, search memory, gather context             |
| **INNOVATE** | Solution exploration | Generate options, evaluate trade-offs                |
| **PLAN**     | Design approach      | Define tasks, identify dependencies, order execution |
| **EXECUTE**  | Implementation       | Delegate to agents, make changes, validate           |
| **REVIEW**   | Quality assurance    | Verify outputs, update knowledge graph, report       |

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

| Perspective            | Focus                                     |
| ---------------------- | ----------------------------------------- |
| Bug Hunter             | Logic errors, edge cases, race conditions |
| Security Auditor       | Injection, auth gaps, data exposure       |
| Performance Analyst    | Big O, N+1 queries, memory leaks          |
| Maintainability Expert | Readability, function size, test coverage |
| Historical Context     | Codebase patterns, regression risk        |
| Contracts Reviewer     | API contracts, type definitions           |

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

**Flags**:

- `--deep` - Force ultrathinking for thorough analysis
- `--quick` - Suppress auto-detect, fast brainstorm only

**Auto-Ultrathink**: Complex topics (architecture, trade-offs, security, multi-domain) auto-trigger ultrathinking for EVALUATE and SYNTHESIZE phases.

**Perspectives Explored**:

| Perspective   | Question                                   |
| ------------- | ------------------------------------------ |
| Pragmatist    | What's the simplest solution that works?   |
| Perfectionist | What's the ideal, no-constraints solution? |
| Skeptic       | What could go wrong? Hidden assumptions?   |
| Innovator     | How would this be solved in 5 years?       |
| User          | What does the end user actually need?      |

**Phases**: DIVERGE → EXPLORE → EVALUATE → REFINE → SYNTHESIZE

### Agentic Context Engineering

Based on [Agentic Context Engineering](https://arxiv.org/abs/2510.04618) - **10.6% improvement** through memory updates.

**Principle**: After reflection, persist insights to knowledge graph for future sessions.

```
# Store learnings after significant work
mcp__memory__aim_memory_add_facts([{
  entityName: "conventions",
  contents: ["Learned: [insight from this session]"]
}])

# Create new entities for decisions
mcp__memory__aim_memory_store([{
  name: "decision_name",
  entityType: "decision",
  observations: ["Context", "Choice made", "Rationale"]
}])
```

**Used by**: orchestrator, architect, /reflect command

### Quick Reference

| Technique           | Command/Agent            | When to Use                       |
| ------------------- | ------------------------ | --------------------------------- |
| Self-Refinement     | `/reflect`, orchestrator | After completing significant work |
| CoVe                | Built into agents        | Verifying complex outputs         |
| Multi-Perspective   | code-reviewer            | Code reviews, PR analysis         |
| Five Whys           | `/why`                   | Debugging, incident analysis      |
| Verbalized Sampling | `/brainstorm`            | Generating diverse solutions      |
| Memory Updates      | All agents               | After decisions, learnings        |

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

| Anti-Pattern           | Why Bad                         | Solution                |
| ---------------------- | ------------------------------- | ----------------------- |
| Tests after code       | Pass immediately, prove nothing | Delete and restart      |
| Arbitrary timeouts     | Flaky, slow                     | Condition-based waiting |
| Testing implementation | Brittle on refactor             | Test behavior           |

### Code Review Frequency (in code-reviewer agent)

**Review early, review often** - catch issues before they compound.

| Scenario                 | Review Type        |
| ------------------------ | ------------------ |
| Per task (subagent work) | After each task    |
| Major feature            | Before integration |
| Pre-merge                | Full review        |
| Stuck/blocked            | Ad-hoc             |

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

| Do                             | Don't                  |
| ------------------------------ | ---------------------- |
| `writeShellApplication`        | `writeShellScriptBin`  |
| `nix build --print-out-paths`  | Impose build timeouts  |
| Fix ShellCheck warnings        | Suppress them          |
| `alejandra` after changes      | Skip formatting        |
| flake-parts for complex flakes | Manual flake structure |

## Agent Orchestration

For complex tasks, use specialist agents to handle domain-specific work efficiently.

### Invocation Methods

- **Orchestrator**: `use orchestrator` or `/orchestrate [task]` for multi-domain tasks
- **Direct**: `use [agent-name]` for specific domain work
- **Fix Command**: `/fix [problem or issue#]` for problem-solving with RIPER

### Available Specialists

| Domain         | Agent                | Trigger Keywords                                |
| -------------- | -------------------- | ----------------------------------------------- |
| Frontend       | frontend-developer   | react, component, tailwind, shadcn, tsx         |
| Backend        | backend-developer    | api, endpoint, server, express, route           |
| Database       | database-specialist  | sql, schema, query, migration, prisma           |
| UI/UX          | ui-ux-designer       | design, accessibility, ux, layout               |
| Security       | security-auditor     | security, vulnerability, owasp, audit           |
| Docs           | documentation-expert | document, readme, api-docs, jsdoc               |
| Architecture   | architect            | architecture, pattern, scale, design            |
| Rust           | rust-developer       | rust, cargo, tokio, systems                     |
| Dart           | dart-developer       | dart, flutter, widget, riverpod                 |
| Nix            | nix-specialist       | nix, flake, home-manager, darwin                |
| Review         | code-reviewer        | review, pr, quality, lint                       |
| Testing        | test-engineer        | test, vitest, playwright, coverage              |
| Home Assistant | home-assistant-dev   | home-assistant, automation, dashboard, lovelace |

### Agent Configuration

Agents are defined in `.claude/agents/*.md` files with YAML frontmatter:

```yaml
---
name: agent-name
description: What this agent does
permissionMode: acceptEdits # Optional: controls file edit permissions
skills:
  - test-driven-development
---
# Agent instructions in markdown...
```

#### Frontmatter Fields

| Field            | Required | Description                                                            |
| ---------------- | -------- | ---------------------------------------------------------------------- |
| `name`           | Yes      | Unique identifier (lowercase, hyphens)                                 |
| `description`    | Yes      | Natural language description of agent's purpose                        |
| `permissionMode` | No       | Permission handling for subagent context                               |
| `skills`         | No       | List of skills to auto-load                                            |
| `model`          | No       | Model to use (`sonnet`, `opus`, `haiku`, or `inherit`)                 |

> **Note**: Do NOT include a `tools:` field in agent frontmatter. Explicit tool lists cause sandboxed execution where file operations don't persist. Omit the field to inherit all tools from the main thread.

#### Permission Modes

| Mode                | Description                              | Use Case                 |
| ------------------- | ---------------------------------------- | ------------------------ |
| `default`           | Prompts for permission on first tool use | Read-only agents         |
| `acceptEdits`       | Auto-accepts file edit permissions       | Agents that modify files |
| `plan`              | Read-only, cannot modify files           | Analysis/review agents   |
| `bypassPermissions` | Skips all prompts                        | Trusted automation only  |

**Note**: Agents that modify files should use `permissionMode: acceptEdits` to allow file modifications in subagent context.

#### Model Strategy

Use different models based on task complexity to optimize cost and quality:

| Model   | Use Case                                | Agents                                     |
| ------- | --------------------------------------- | ------------------------------------------ |
| `haiku` | Fast exploration, simple lookups        | documentation-expert, Explore agent        |
| `sonnet`| Implementation, moderate complexity     | Most agents (default)                      |
| `opus`  | Architecture, security, deep analysis   | code-reviewer, security-auditor, architect |

**Guidelines**:

- **haiku**: File enumeration, simple searches, doc generation, quick lookups
- **sonnet**: Code implementation, bug fixes, moderate analysis (default for most tasks)
- **opus**: Security audits, architecture decisions, complex debugging, code reviews

**Orchestrator Tiering**:

The orchestrator automatically selects model tier based on task classification:

```
RESEARCH phase  → haiku (exploration) or sonnet (analysis)
INNOVATE phase  → sonnet or opus (for architecture)
PLAN phase      → sonnet
EXECUTE phase   → agent-specific (see agent model field)
REVIEW phase    → opus (for quality-critical review)
```

### MCP Integration

Use MCP servers to extend Claude's capabilities with external tools and data sources.

> **Note**: MCP server paths in `.mcp.json` are user-specific (hardcoded to `/Users/darren/...`).
> When forking this config, update paths in `.mcp.json` for memory storage and filesystem access.

#### Available MCP Servers

| MCP Server              | Purpose                    | Key Tools                                                         |
| ----------------------- | -------------------------- | ----------------------------------------------------------------- |
| **memory**              | Persistent knowledge graph | `aim_memory_store`, `aim_memory_search`, `aim_memory_read_all`    |
| **context7**            | Library documentation      | `resolve-library-id`, `query-docs`                                |
| **sequential-thinking** | Complex reasoning          | `sequentialthinking` for multi-step analysis                      |
| **magic-ui**            | UI components              | Component implementations, animations, effects                    |
| **puppeteer**           | Browser automation         | Screenshots, navigation, form filling                             |
| **hass-mcp**            | Home Assistant             | Entity control, automation, dashboard                             |
| **filesystem**          | Safe file operations       | Sandboxed access to Developer/, .config/, tmp/                    |
| **obsidian**            | Obsidian vault             | Search notes, create docs, specs, ADRs                            |

#### Agent ↔ MCP Mapping

| Agent                | MCPs Used                                     | Use Case                                                  |
| -------------------- | --------------------------------------------- | --------------------------------------------------------- |
| orchestrator         | memory, sequential-thinking, obsidian         | Project knowledge, task breakdown, vault docs             |
| architect            | memory, sequential-thinking, context7         | Store decisions, design patterns, research                |
| frontend-developer   | context7, magic-ui                            | React docs, UI components                                 |
| backend-developer    | context7                                      | API framework documentation                               |
| code-reviewer        | memory                                        | Pattern checks, codebase knowledge                        |
| test-engineer        | puppeteer                                     | Visual testing, E2E automation                            |
| nix-specialist       | context7                                      | Nix/home-manager documentation                            |
| database-specialist  | context7                                      | ORM/database documentation                                |
| ui-ux-designer       | magic-ui                                      | UI components                                             |
| home-assistant-dev   | hass-mcp, context7                            | Entity queries, service calls, HA docs                    |
| documentation-expert | obsidian, context7                            | Generate and save docs to vault                           |

#### MCP Usage Examples

```
# Knowledge Graph Memory
mcp__memory__aim_memory_read_all()                  # Load all stored knowledge
mcp__memory__aim_memory_search("authentication")   # Search for relevant context
mcp__memory__aim_memory_store([{name, entityType, observations}])
mcp__memory__aim_memory_add_facts([{entityName, contents}])

# Fetch library documentation
mcp__context7__resolve-library-id("react")
mcp__context7__query-docs("/vercel/next.js", query="routing")

# Get PR context before review (via gh CLI)
gh pr view 123 --json title,body,state,files,comments
gh issue view 456 --json title,body,state,labels

# Complex multi-step planning
mcp__sequential-thinking__sequentialthinking(thought="...", thoughtNumber=1, totalThoughts=5)

# Home Assistant entity lookup
mcp__hass-mcp__list_entities(domain="light")
mcp__hass-mcp__entity_action(entity_id="light.living_room", action="on")

# Obsidian vault operations
mcp__obsidian__obsidian_simple_search("authentication")    # Search vault notes
mcp__obsidian__obsidian_get_file_contents("claude/specs/auth-spec.md") # Read a note
mcp__obsidian__obsidian_append_content("claude/notes/...", content)    # Append to note
```

### Persistent Memory

Claude maintains a knowledge graph across sessions using the `memory` MCP server.

#### Memory Contexts

Memory is organized into contexts for isolation and sharing:

| Context         | Purpose                           | Storage File                 |
| --------------- | --------------------------------- | ---------------------------- |
| (default)       | Personal conventions, preferences | `memory.jsonl`               |
| `[project]`     | Project-specific knowledge        | `memory-[project].jsonl`     |
| `work`          | Cross-project work patterns       | `memory-work.jsonl`          |
| `client-[name]` | Isolated client data              | `memory-client-[name].jsonl` |

#### Commands

- `/prime` - Loads default + project contexts, merges for session
- `/prime refresh` - Force refresh knowledge graph
- `/remember` - View/search/manage memory (both contexts)
- `/remember --context=work` - View specific context
- `/remember contexts` - List all available contexts

#### Automatic Memory

- `/prime` loads both default (conventions) and project-specific contexts
- Project name auto-detected from git remote or directory name
- Architect agent stores decisions in project context
- Orchestrator searches both contexts before delegating

#### What Gets Stored

| Entity Type  | Context | Examples                                  |
| ------------ | ------- | ----------------------------------------- |
| `project`    | project | Project name, tech stack, package manager |
| `service`    | project | Backend services, integrations            |
| `component`  | project | UI components, modules                    |
| `decision`   | project | Architecture decisions (ADRs)             |
| `pattern`    | default | Code conventions, naming patterns         |
| `preference` | default | Personal tool preferences                 |

#### Memory Location

Stored globally at `~/.local/share/claude-memory/`:

```
~/.local/share/claude-memory/
├── memory.jsonl           # Default context (personal)
├── memory-config.jsonl    # Project: config
├── memory-myapp.jsonl     # Project: myapp
└── memory-work.jsonl      # Work context
```

Available across all projects via `~/.mcp.json`.

#### Context Phase Management

Manage context efficiently across RIPER phases to prevent token bloat:

| Phase     | Context Strategy                                           |
| --------- | ---------------------------------------------------------- |
| RESEARCH  | Load minimal context, expand as needed                     |
| INNOVATE  | Summarize research findings, focus on options              |
| PLAN      | Condense to actionable items, drop exploration artifacts   |
| EXECUTE   | Pass only relevant context to agents                       |
| REVIEW    | Summarize outcomes, store learnings, drop implementation   |

**Best Practices:**

1. **Start lean**: Use `/prime fast` for quick context load
2. **Expand selectively**: Read files only when directly relevant
3. **Summarize early**: After RESEARCH, summarize findings before INNOVATE
4. **Delegate context**: Pass only essential context to subagents
5. **Prune artifacts**: Don't carry exploration code into EXECUTE
6. **Store learnings**: After REVIEW, persist insights to memory graph

**Context Signals:**

```
"Context is growing large" → Summarize before continuing
"Multiple agents involved"  → Create focused prompts per agent
"Repeated file reads"       → Summarize once, reference summary
"Session > 30 min"          → Consider /prime refresh
```

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

| Command                 | Purpose                                |
| ----------------------- | -------------------------------------- |
| `/note [topic]`         | Create note (daily, concept, learning) |
| `/spec [feature]`       | Generate technical specification       |
| `/doc api [file]`       | Generate API documentation             |
| `/doc guide [topic]`    | Generate step-by-step guide            |
| `/doc adr [decision]`   | Generate Architecture Decision Record  |
| `/search-vault [query]` | Search vault content                   |

#### Security

- Vault content is git-ignored in this repo (see `.gitignore`)
- Use `git diff` to verify no vault content before committing
- Vault is closed-source - never reference vault paths in issues/PRs

### Background Task Execution

Run independent agent tasks in parallel by calling multiple Task tools in a single message. Use `run_in_background: true` sparingly.

#### Background Bash Commands

Press **Ctrl+B** to move a running Bash command to the background. This is useful for:

- Long-running builds (webpack, make, cargo build)
- Package installations (npm install, yarn)
- Development servers (npm run dev)
- Test suites (pytest, jest)

The command runs asynchronously and output can be retrieved later. Use `/tasks` to list background tasks.

**Note**: In tmux, press Ctrl+B twice (tmux uses it as prefix key).

#### When to Use Background Tasks

**Default**: Use foreground tasks (no `run_in_background`). Multiple Task calls in one message run in parallel automatically.

| Scenario                | Mode                                | Reason                                |
| ----------------------- | ----------------------------------- | ------------------------------------- |
| Frontend + Backend work | Parallel (foreground)               | Multiple Task calls in single message |
| Security audit          | Background only if doing other work | Otherwise use foreground              |
| Schema → API → UI       | Sequential                          | Each depends on previous              |
| Quick file lookup       | Foreground                          | Fast, immediate result                |

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

### Agent Pipeline Patterns

Common multi-agent patterns for complex tasks:

#### Full-Stack Feature Pipeline

```
architect → database-specialist → backend-developer → frontend-developer → test-engineer → code-reviewer
```

Use when: Building new features that span the entire stack.

#### Security Review Pipeline

```
security-auditor → code-reviewer → documentation-expert
```

Use when: Pre-release security validation with documentation.

#### Refactoring Pipeline

```
code-reviewer (analysis) → architect (design) → [domain-agent] (implement) → test-engineer → code-reviewer (verify)
```

Use when: Large-scale refactoring requiring design review.

#### Documentation Pipeline

```
[domain-agent] (implement) → documentation-expert → code-reviewer
```

Use when: New features that need documentation.

#### Parallel Independence Pattern

```
┌─ frontend-developer ─┐
│                      │
Task → database-specialist → code-reviewer
│                      │
└─ backend-developer ──┘
```

Use when: Frontend and backend can be developed independently after schema.

#### Review Gate Pattern

```
agent1 → code-reviewer → agent2 → code-reviewer → agent3 → code-reviewer
```

Use when: High-stakes changes requiring verification between steps.

## Slash Commands Reference

All commands available as `/command` in Claude Code or `cc-command` from terminal.

### Code Quality & Review

| Command           | Shell Alias   | Description                                            |
| ----------------- | ------------- | ------------------------------------------------------ |
| `/review`         | `cc-review`   | Comprehensive code review of staged changes            |
| `/audit [target]` | `cc-audit`    | Deep code audit (entire codebase, file, or function)   |
| `/perf`           | `cc-perf`     | Performance audit of codebase                          |
| `/security`       | `cc-security` | Security-focused audit (OWASP, secrets, auth)          |
| `/health`         | `cc-health`   | Project health assessment and scorecard                |
| `/deps`           | `cc-deps`     | Dependency audit (outdated, vulnerabilities, licenses) |

### Git Workflows

| Command   | Shell Alias | Description                                             |
| --------- | ----------- | ------------------------------------------------------- |
| `/commit` | `cc-commit` | Generate conventional commit message for staged changes |
| `/pr`     | `cc-pr`     | Generate PR title and description for current branch    |

### Context & Memory

| Command             | Shell Alias   | Description                                     |
| ------------------- | ------------- | ----------------------------------------------- |
| `/prime [refresh]`  | `cc-prime`    | Prime Claude with comprehensive project context |
| `/remember [query]` | `cc-remember` | Manage persistent memory (knowledge graph)      |

### Problem Solving (CEK Techniques)

| Command                    | Shell Alias     | Description                                        |
| -------------------------- | --------------- | -------------------------------------------------- |
| `/fix [problem or issue#]` | `cc-fix`        | Fix a problem using RIPER workflow                 |
| `/why [problem]`           | `cc-why`        | Five Whys root cause analysis                      |
| `/reflect [topic]`         | `cc-reflect`    | Self-refinement of previous response               |
| `/brainstorm [topic] [--deep\|--quick]` | `cc-brainstorm` | Generate diverse ideas (auto-ultrathink on complex topics) |

### Documentation & Explanation

| Command                 | Shell Alias       | Description                                      |
| ----------------------- | ----------------- | ------------------------------------------------ |
| `/explain [code]`       | `cc-explain`      | Explain code sections and document complex logic |
| `/note [topic]`         | `cc-note`         | Create note in Obsidian vault                    |
| `/spec [feature]`       | `cc-spec`         | Generate technical specification in vault        |
| `/doc [type] [topic]`   | `cc-doc`          | Generate documentation (API, guide, ADR)         |
| `/search-vault [query]` | `cc-search-vault` | Search Obsidian vault                            |

### Orchestration

| Command               | Shell Alias      | Description                                    |
| --------------------- | ---------------- | ---------------------------------------------- |
| `/orchestrate [task]` | `cc-orchestrate` | Analyze task and delegate to specialist agents |

### Autonomous Iteration (Ralph)

| Command               | Shell Alias        | Description                               |
| --------------------- | ------------------ | ----------------------------------------- |
| `/ralph-loop [task]`  | `cc-ralph-loop`    | Start autonomous iteration loop           |
| `/ralph-status`       | `cc-ralph-status`  | Check current iteration and loop state    |
| `/cancel-ralph`       | `cc-cancel-ralph`  | Stop active loop immediately              |

### Session Analysis

| Command                 | Shell Alias        | Description                               |
| ----------------------- | ------------------ | ----------------------------------------- |
| `/retrospective [days]` | `cc-retrospective` | Analyze session patterns and insights     |

**Ralph Loop** enables autonomous iteration for batch tasks:

```bash
# Start loop with default 10 iterations
/ralph-loop "refactor auth module"

# Limit iterations
/ralph-loop "fix all linting errors" --max-iterations 5

# Compose with other commands
/ralph-loop "/fix issue #42"
```

**Cost Warning**: Ralph loops consume significant tokens. A 10-iteration loop
on a large codebase can cost $20-50+ in API credits.

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
- `OBSIDIAN_API_KEY` / `OBSIDIAN_HOST` / `OBSIDIAN_PORT`
