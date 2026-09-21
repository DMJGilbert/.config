---
name: comments
description: Comment-hygiene pass over changed files or a given path — remove comments that narrate the change or the conversation, describe prior state, restate the code, or have gone stale, and delete commented-out code. Use when asked to improve, clean up or tidy comments, to strip commented-out code, or when comments reference conversations, reviews, or earlier versions of the code.
argument-hint: "[path | --all] [--dry-run]"
---

# Comments

Bring a set of files up to the standard in `CLAUDE.md` § Comments. That section
is the spec — read it before starting and apply it verbatim; this skill only
decides scope, delegation and verification.

**This pass changes comments, never code.** If a comment is wrong because the
code is wrong, report it — do not fix the code here.

## Process

### 1. Resolve scope

| Argument             | Scope                                                                                   |
| -------------------- | --------------------------------------------------------------------------------------- |
| _(none)_             | Files changed vs `HEAD` (`git diff --name-only HEAD`)                                   |
| _(none)_, empty diff | Files changed on the branch (`git diff --name-only $(git merge-base HEAD main)...HEAD`) |
| `<path>`             | Source files under that path                                                            |
| `--all`              | All tracked source files in the repo                                                    |

Filter to source files — skip lockfiles, generated output, vendored trees, and
anything in `.gitignore`. If scope resolves to more than 40 files, state the
count and the file-type breakdown and ask before proceeding: a wide comment
rewrite is hard to review.

`--dry-run` reports what would change without editing.

### 2. Plan the fan-out

Group the files into batches of 5–8, grouped by directory and language so each
worker sees one idiom at a time. One worker per group, up to 8 running
concurrently; queue the rest. A single group runs inline — do not spawn one
worker to do one batch.

Before spawning, state the plan in one line per worker (`worker 1: 6 files under
src/api (.ts)`) so it can be vetoed cheaply. `TaskStop` each worker as soon as
its report is accepted.

### 3. Delegate

Give every worker the same instruction, with its own file list:

> Apply `CLAUDE.md` § Comments to these files. For each comment decide: keep,
> rewrite, or delete.
>
> **Delete**: narration of the change or the conversation behind it ("as
> requested", "per review", "switched to X"); descriptions of what the code used
> to do or what was removed; restatements of the line beneath; "NEW:"/"UPDATED:"
> markers; commented-out code.
>
> **Rewrite**: a comment whose text no longer matches the code under it, and a
> comment carrying real rationale buried in narration — keep the rationale, drop
> the story.
>
> **Keep**: rationale for a non-obvious choice; an invariant the type system
> cannot express (Rust `// SAFETY:`, lint suppressions); a link to a spec, issue
> or vendor bug; public API documentation (rustdoc, TSDoc, dartdoc, Nix option
> `description`).
>
> Do not change a single line of executable code — no renames, no refactors, no
> reformatting. Where a comment only exists because the code is unclear, leave
> the comment and report the location instead of refactoring.
>
> Report per file: comments deleted, rewritten, kept, and any code you believe
> needs a rename or extraction.

### 4. Verify

1. Run the formatter and the language check for each touched type (per the
   `rules/*.md` Validation lists — e.g. `cargo check`, `tsc --noEmit`,
   `dart analyze`, `nix flake check`).
2. Confirm the pass stayed in its lane: `git diff -U0` and check that every
   added or removed line is a comment line or blank. Any other line is a bug in
   the pass — revert that hunk and say so.
3. Cite both outputs in the report. Do not claim the pass is clean without them.

### 5. Report

- Per file: counts of deleted / rewritten / kept
- The "this needs a rename or extraction" list from the workers, as suggestions
  only — acting on it is a separate task, at the user's call
- Anything deliberately left alone and why

**Never commit.** The user commits manually via `/commit`.
