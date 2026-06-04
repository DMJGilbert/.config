---
name: riper-review
description: RIPER REVIEW phase — fan out security-reviewer, bug-hunter, and quality-reviewer in parallel, then return an aggregated severity report
---

Perform a complete RIPER review of the change set using dynamic workflow mode.

**Diff scope** (in priority order):

1. If the user passed a ref argument (`/riper-review main`), review `git diff <ref>...HEAD`
2. Otherwise, if on a branch other than main, review `git diff main...HEAD` (full branch divergence)
3. Otherwise, review uncommitted changes: `git diff` + staged (`git diff --cached`) + untracked files relevant to the PR

State which scope was used at the top of the report so the user can sanity-check coverage.

Spawn three reviewers concurrently:

- **security-reviewer**: identify security vulnerabilities, auth gaps, injection risks, secrets exposure, OWASP Top 10
- **bug-hunter**: identify logic errors, edge cases, race conditions, null handling issues, off-by-ones
- **quality-reviewer**: identify performance issues, maintainability problems, code smells, test coverage gaps

## Severity Rubric (canonical)

All three reviewers use this scale:

- **Critical**: Active exploit path, data loss, production-breaking. Block merge; immediate action required.
- **High**: Confirmed bug or vulnerability with significant impact; correctness issue likely to surface in production. Fix before merge.
- **Medium**: Notable concern (performance, maintainability, edge case). Address in normal cycle; do not block merge if isolated.
- **Low**: Minor improvement — style, naming, small refactor, nice-to-have. Informational.

Collect all findings from each reviewer. Return a unified report structured as:

## RIPER Review — [date]

### Critical Issues

[list with reviewer attribution]

### High Issues

[list with reviewer attribution]

### Medium Issues

[consolidated list]

### Low / Informational

[consolidated list]

### Overall Assessment

[one-paragraph summary; merge recommendation: ready / needs fixes / block]
