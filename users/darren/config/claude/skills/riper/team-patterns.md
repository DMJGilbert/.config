# Agent Team Patterns

Reference for PLAN phase when deciding execution mode.

## Hybrid Routing

| Execution Pattern   | Use When                                                           |
| ------------------- | ------------------------------------------------------------------ |
| Subagents (default) | Single-layer, same-file, sequential, or < 3 files                  |
| Agent team          | Cross-layer (frontend + backend + infra), 3+ independent file sets |

## Team Conventions

- 3 teammates is the sweet spot; more adds coordination overhead
- Use delegate mode (`Shift+Tab`) to keep lead coordinating, not implementing
- Use `isolation: "worktree"` for teammates to prevent cross-contamination
- Assign file ownership per teammate to avoid overwrites
- Size tasks at 5-6 per teammate
- Use Opus for lead, Sonnet for teammates
- Require plan approval for risky changes before teammates implement
- Plan phase identifies dependency waves; team executes wave by wave

## Patterns

**Full-Stack Feature** — API endpoint + frontend UI + infrastructure:

- Teammates: backend, frontend, nix (or hass)
- Waves: 1) backend implements API → 2) frontend consumes API (parallel with nix) → 3) integration tests
- File ownership: backend owns `src/api/`, frontend owns `src/components/`, nix owns `*.nix`

**Research Sprint** — Explore 3 different implementation approaches:

- Teammates: 3x researcher (Sonnet), each explores one approach
- Process: parallel exploration → reconvene → planner selects winner

**Bug Hunt** — Critical bug with unclear root cause:

- Teammates: 3x researcher — one reproduces, one analyzes code paths, one checks recent changes
- Process: parallel investigation → share findings → single fixer implements

**Migration** — Large refactor across multiple layers:

- Teammates: domain agents per layer (e.g. rust + dart + frontend + nix)
- Waves: 1) backend breaking changes → 2) all clients update in parallel → 3) integration

## Anti-Patterns

- Don't use teams for sequential dependencies (use subagents)
- Don't assign overlapping file ownership
- Don't use >4 teammates (coordination overhead exceeds benefit)
- Don't skip plan approval for risky changes
- Don't use teams for simple/single-layer tasks
- Default to subagents unless there's a clear parallelism benefit
