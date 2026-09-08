# Agent Team Patterns

Reference for PLAN phase when deciding execution mode.

## Routing

Execution-mode selection (`direct` / `subagent` / `team` / `workflow`) is canonical in `skills/riper/references/complexity.md` (§ Execution Mode Selection). This file covers conventions specific to `team` mode.

## Team Conventions

- 3 teammates is the sweet spot; more adds coordination overhead
- Spawn teammates via the Agent tool (`subagent_type`) or natural-language instructions to the lead
- Worktree isolation is the default; to allow teammates to edit the working copy directly, set `worktree.bgIsolation: "none"` in settings.json
- Assign file ownership per teammate to avoid overwrites
- Size tasks at 5-6 per teammate
- Use Opus for lead, Sonnet for teammates
- Require plan approval for risky changes before teammates implement
- Plan phase identifies dependency waves; team executes wave by wave
- **Caveat**: `skills:` and `mcpServers:` frontmatter fields in agent definitions are **not applied** when that agent runs as a teammate (only when run as a subagent)

## Patterns

**Full-Stack Feature** — API endpoint + frontend UI + infrastructure:

- Teammates: backend, frontend, nix (or hass)
- Waves: 1) backend implements API → 2) frontend consumes API (parallel with nix) → 3) integration tests
- File ownership: backend owns `src/api/`, frontend owns `src/components/`, nix owns `*.nix`

**Research Sprint** — Explore 3 different implementation approaches:

- Teammates: 3x researcher (Sonnet), each explores one approach
- Process: parallel exploration → reconvene → the lead selects winner

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
