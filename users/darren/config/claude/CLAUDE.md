# Claude Code Configuration

## RIPER Workflow

All complex tasks follow strict RIPER phases (details in `riper` skill):

```
RESEARCH → INNOVATE → PLAN → [APPROVAL] → EXECUTE → REVIEW
```

**Complexity routing**: `complexity-gate` skill assesses tasks:

- TRIVIAL/SIMPLE → Direct action
- MEDIUM/COMPLEX → Strict RIPER with plan approval

## Skills

| Skill            | Purpose                                                |
| ---------------- | ------------------------------------------------------ |
| `/commit`        | Generate conventional commit for staged changes        |
| `/fix [problem]` | Problem-solving with RIPER workflow                    |
| `/retrospective` | Review session for learnings, update agent memories    |
| `/simplify`      | Review changed code for reuse, quality, and efficiency |
| `/review`        | Code review (built-in)                                 |

## Conventions

**Commits**: Conventional format (`feat`, `fix`, `refactor`, `docs`, `chore`)
**Branches**: `feat/`, `fix/`, `refactor/`, `docs/`
**Formatting**: Auto-applied via hooks (alejandra, rustfmt, prettier, dart format, stylua, ruff)
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

## Receiving Review Feedback

When domain agents receive findings from review agents:

1. **Read all feedback** before reacting
2. **Verify each suggestion** against the actual codebase
3. **Implement one fix at a time** with testing between each
4. **Push back technically** when a suggestion is wrong for this context
5. **Show fixes through code**, not acknowledgment phrases

**Prohibited**: "Great point!", "You're absolutely right!", batch-implementing without testing.

## Agents

**Domain agents** (Sonnet, `acceptEdits`): nix, hass, rust, dart, frontend, backend, ui
**Review agents** (Opus, `plan`, read-only): security-reviewer, bug-hunter, quality-reviewer
**Workflow agents**: researcher (Opus, `plan`), planner (Sonnet, `plan`)

Domain agents inherit all tools. Review agents: security-reviewer has Read, Glob, Grep, LSP, WebSearch, WebFetch, memory. bug-hunter and quality-reviewer have Read, Glob, Grep, LSP, memory.

**Model selection rule**: Only upgrade from Sonnet to Opus when judgment accuracy outweighs cost.

## MCP Servers

**Core**: memory, context7, sequential-thinking, obsidian
**Project** (.mcp.json): hass-mcp for Home Assistant repos

## Storage

- **Specs/Plans**: Obsidian vault (`claude/specs/`)
- **Agent Memory**: `~/.claude/agent-memory/{agent}/MEMORY.md` → Obsidian vault
- **Decisions**: AIM memory graph (project-scoped)
- **Memory strategy**: See `riper` skill supporting files

## Reasoning Effort

| Tier   | Trigger                        | Use When                                            |
| ------ | ------------------------------ | --------------------------------------------------- |
| Medium | Always-on baseline             | EXECUTE, PLAN, standard tasks                       |
| High   | `ultrathink` keyword in prompt | RESEARCH/INNOVATE on COMPLEX tasks, security review |
| XHigh  | Opus 4.7 default               | Architectural decisions, multi-system reasoning     |
| Max    | Session-only                   | One-off deep analysis (resets after turn)           |

## Build Commands

```bash
darwin-rebuild switch --flake .#ryukyu     # macOS
sudo nixos-rebuild switch --flake .#rubecula  # NixOS
```
