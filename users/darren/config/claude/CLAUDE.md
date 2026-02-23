# Claude Code Configuration

## RIPER Workflow

All complex tasks follow strict RIPER phases:

```
RESEARCH → INNOVATE → PLAN → [APPROVAL] → EXECUTE → REVIEW
```

| Phase | Agent | Purpose |
|-------|-------|---------|
| RESEARCH | researcher (subagent) | Explore codebase, gather context |
| INNOVATE | researcher (subagent) | Brainstorm approaches |
| PLAN | planner (subagent) | Create spec, define tasks |
| EXECUTE | domain agents (subagent) | Single-layer: sequential subagents |
| EXECUTE | agent team (swarm) | Cross-layer: parallel teammates with file ownership |
| REVIEW | 3 reviewers (subagent) | Security, bugs, quality (parallel) |

**Complexity routing**: `complexity-gate` skill assesses tasks:
- TRIVIAL/SIMPLE → Direct action
- MEDIUM/COMPLEX → Strict RIPER with plan approval

## Commands

| Command | Purpose |
|---------|---------|
| `/commit` | Generate conventional commit for staged changes |
| `/review` | Code review (staged default, `--branch` for full branch) |
| `/fix [problem]` | Problem-solving with RIPER workflow |
| `/retrospective` | Review session for learnings, update agent memories |

## Conventions

**Commits**: Conventional format (`feat`, `fix`, `refactor`, `docs`, `chore`)
**Branches**: `feat/`, `fix/`, `refactor/`, `docs/`
**Formatting**: Auto-applied via hooks (alejandra, rustfmt, prettier, dart format)
**Rules**: Path-scoped rules in `.claude/rules/` loaded contextually by file type

## Code Style

- Clarity over cleverness
- Explicit error handling
- No secrets in code
- Keep functions focused

## Verification Gate

All agents must verify claims with evidence before reporting completion.

**Process**: IDENTIFY → RUN → READ → VERIFY → CLAIM
1. **IDENTIFY** the command that proves your claim (test, build, check)
2. **RUN** the command fresh (not from memory or prior output)
3. **READ** the full output including exit codes
4. **VERIFY** that output actually confirms the claim
5. **CLAIM** completion only with evidence cited

**Prohibited language** (before verification):
- "should work", "probably fixed", "seems correct"
- "Done!", "All good!", "Everything passes!" (without test output)
- "I believe this fixes...", "This should resolve..."

**What requires verification**:
- Test pass claims → show test output with 0 failures
- Build success → show exit code 0
- Bug fixes → show the original symptom no longer reproduces
- Requirements met → line-by-line checklist with evidence

## Receiving Review Feedback

When domain agents receive findings from review agents:

1. **Read all feedback** before reacting
2. **Verify each suggestion** against the actual codebase — don't assume it's correct
3. **Implement one fix at a time** with testing between each
4. **Push back technically** when a suggestion is wrong for this context
5. **Show fixes through code**, not acknowledgment phrases

**Prohibited responses**:
- "Great point!", "You're absolutely right!", "Thanks for catching that!"
- Implementing suggestions without verifying they apply
- Batch-implementing all feedback without testing between fixes
- Avoiding legitimate technical disagreement

## Agent Model Selection

| Role | Model | Rationale |
|------|-------|-----------|
| Lead/orchestrator | Opus | Coordination complexity, multi-agent reasoning |
| Review agents | Opus | Judgment quality, security/bug detection accuracy |
| Domain agents | Sonnet | Code generation quality, cost-effective for execution |
| Researcher | Sonnet | Reasoning depth + breadth, research quality |
| Planner | Sonnet | Structured planning, spec writing |
| Swarm teammates | Sonnet | Parallel cost control, code generation |

**Rule**: Only upgrade from Sonnet to Opus when judgment accuracy outweighs cost.

## Domain Agents

| Agent | Languages/Focus | Tools |
|-------|-----------------|-------|
| nix | Nix, Flakes, home-manager, nix-darwin | Edit + context7 + memory |
| hass | Home Assistant, YAML, automations | Edit + context7 + memory + hass-mcp |
| rust | Rust, Cargo, systems programming | Edit + context7 + memory |
| dart | Dart, Flutter, cross-platform | Edit + context7 + memory |
| frontend | TypeScript, React, state management | Edit + context7 + memory |
| backend | TypeScript, Node.js, APIs | Edit + context7 + memory |
| ui | HTML, CSS, Tailwind, accessibility | Edit + context7 + memory |

## Review Agents

| Agent | Focus | Tools |
|-------|-------|-------|
| security-reviewer | Vulnerabilities, auth, injection, secrets | Read-only (Read, Glob, Grep, LSP, memory) |
| bug-hunter | Logic errors, edge cases, race conditions | Read-only (Read, Glob, Grep, LSP, memory) |
| quality-reviewer | Performance, maintainability, code smells | Read-only (Read, Glob, Grep, LSP, memory) |

## Agent Teams (Swarms)

Multi-session orchestration where a lead spawns independent teammate instances.
Subagents handle RESEARCH/INNOVATE/PLAN/REVIEW; teams handle parallel EXECUTE.

**Hybrid routing** (decided during PLAN phase):

| Execution Pattern | Use When |
|-------------------|----------|
| Subagents (default) | Single-layer, same-file, sequential, or < 3 files |
| Agent team | Cross-layer (frontend + backend + infra), 3+ independent file sets, competing hypotheses |

**Team conventions**:
- 3 teammates is the sweet spot; more adds coordination overhead
- Use delegate mode (`Shift+Tab`) to keep lead coordinating, not implementing
- Assign file ownership per teammate to avoid overwrites
- Size tasks at 5-6 per teammate
- Use Opus for lead, Sonnet for teammates
- Require plan approval for risky changes before teammates implement
- Plan phase identifies dependency waves; team executes wave by wave

### Team Patterns

**Full-Stack Feature** — API endpoint + frontend UI + infrastructure:
- Teammates: backend, frontend, nix (or hass)
- Waves: 1) backend implements API contract → 2) frontend consumes API (parallel with nix) → 3) integration tests
- File ownership: backend owns `src/api/`, frontend owns `src/components/`, nix owns `*.nix`

**Research Sprint** — Explore 3 different implementation approaches:
- Teammates: 3x researcher (Sonnet), each explores one approach
- Process: parallel exploration → reconvene findings → planner selects winner
- File ownership: read-only (no conflicts)

**Bug Hunt** — Critical bug with unclear root cause:
- Teammates: 3x researcher — one reproduces, one analyzes code paths, one checks recent changes
- Process: parallel investigation → share findings → single fixer implements solution
- File ownership: read-only during hunt, single writer for fix

**Migration** — Large refactor across multiple layers:
- Teammates: domain agents per layer (e.g. rust + dart + frontend + nix)
- Waves: 1) backend breaking changes → 2) all clients update in parallel → 3) integration + deployment
- File ownership: each agent owns their language files

### Team Anti-Patterns

- Don't use teams for sequential dependencies (use subagents)
- Don't assign overlapping file ownership
- Don't use >4 teammates (coordination overhead exceeds benefit)
- Don't skip plan approval for risky changes
- Don't use teams for simple/single-layer tasks
- Default to subagents unless there's a clear parallelism benefit

## MCP Servers

**Core** (always loaded): memory, context7, sequential-thinking, obsidian
**Project** (.mcp.json): hass-mcp for Home Assistant repos

## Storage

- **Specs/Plans**: Obsidian vault (`claude/specs/`)
- **Agent Memory**: Obsidian vault (`claude/memory/{agent}/MEMORY.md`) - symlinked from `~/.claude/agent-memory/`
- **Decisions**: AIM memory graph
- **Context**: Memory graph (project-scoped)

## Memory Strategy

### When to Store

**Agent Memory** (Obsidian vault `claude/memory/{agent}/MEMORY.md`):
- Persistent patterns confirmed across 2+ interactions
- Project conventions (file locations, build commands, naming)
- Proven solutions to recurring problems
- Anti-patterns discovered

**AIM Memory Graph**:
- Key decisions with rationale
- Entity relationships (components, dependencies)
- User preferences
- Task context linking related decisions

### When to Query

**Before task**: Check for related past decisions, known patterns, previous issues
**During research**: Query for prior implementations, design decisions, constraint history

### When to Forget

- Information proven incorrect
- Pattern superseded by new approach
- Project structure changed significantly
- Information duplicates what's already in CLAUDE.md

## Build Commands

```bash
darwin-rebuild switch --flake .#ryukyu     # macOS
sudo nixos-rebuild switch --flake .#rubecula  # NixOS
```
