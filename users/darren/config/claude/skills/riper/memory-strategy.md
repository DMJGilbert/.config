# Memory Strategy

## Memory Systems

| System       | Location                                   | Purpose                                    |
| ------------ | ------------------------------------------ | ------------------------------------------ |
| Auto-memory  | `~/.claude/projects/.../memory/MEMORY.md`  | Session context, auto-saved by Claude Code |
| Agent memory | Obsidian `claude/memory/{agent}/MEMORY.md` | Persistent patterns per agent role         |
| AIM graph    | Project-scoped memory graph                | Decisions, entity relationships            |

## When to Store

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

## When to Query

- **Before task**: Check for related past decisions, known patterns, previous issues
- **During research**: Query for prior implementations, design decisions, constraint history

## When to Forget

- Information proven incorrect
- Pattern superseded by new approach
- Project structure changed significantly
- Information duplicates what's already in CLAUDE.md
