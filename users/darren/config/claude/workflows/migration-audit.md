---
name: migration-audit
description: Per-module parallel scan for large migrations — fans out a scanner agent per module/file-group, aggregates a migration plan
---

Audit a large codebase migration by scanning each independent module in parallel. Use when:

- A library / framework / language version is changing across many files
- Each module can be assessed independently (no shared decision state)
- The migration scope is too large to fit in one context window

## Setup

Lead identifies the set of independent modules (directories, packages, or file groups). For each, spawn a `researcher` agent with:

- The module's file paths
- The "before" state (e.g. current version, current API)
- The "after" state (target version, target API)
- The migration playbook (if one exists)

## Per-module output

Each scanner returns:

- Files that need changes
- Estimated effort (S/M/L)
- Breaking-change risk (Critical / High / Medium / Low — per the riper-review rubric)
- Dependencies on other modules' completion
- Specific test commands that prove the migration worked

## Synthesis

Aggregate into:

## Migration Audit — [migration, date]

### Wave plan

[modules grouped by dependency; wave N runs in parallel after wave N-1]

### Effort budget

[total S/M/L counts; rough hours]

### Risk hotspots

[Critical/High items requiring extra review or staging]

### Blocking unknowns

[questions to answer before any wave starts]

### Test commands per wave

[commands to run after wave N completes, before starting wave N+1]

Hand off to PLAN phase for sequencing, then EXECUTE wave-by-wave.
