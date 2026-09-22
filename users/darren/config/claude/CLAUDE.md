# Claude Code Configuration

## RIPER Workflow

All complex tasks follow strict RIPER phases (details in `riper` skill):

```
RESEARCH → INNOVATE → PLAN → [APPROVAL] → EXECUTE → REVIEW
```

**Complexity routing**: assess the task yourself before starting:

- TRIVIAL/SIMPLE → Direct action
- MEDIUM/COMPLEX → Strict RIPER with plan approval

Criteria live in `skills/riper/references/complexity.md`. This is a judgement
call made inline, not a skill to invoke.

## Skills

| Skill                      | Purpose                                                                  |
| -------------------------- | ------------------------------------------------------------------------ |
| `/commit`                  | Generate conventional commit for staged changes                          |
| `/code-review [--comment]` | Quick diff review; `--comment` posts inline PR comments                  |
| `/riper-review [ref]`      | Branch-level review: 4 reviewers + lint, findings adversarially verified |
| `/security-review`         | Security review of pending changes on the current branch                 |
| `/comments [path]`         | Comment-hygiene pass on changed files; fans out workers, never commits   |

## Conventions

**Commits**: Conventional format (`feat`, `fix`, `refactor`, `docs`, `chore`)
**Committing**: NEVER run `git commit` (or stage-and-commit) unless explicitly asked in the current turn — the user always commits manually via `/commit`. At task end, stop after verification; do not commit or offer to commit.
**Branches**: `feat/`, `fix/`, `refactor/`, `docs/`
**Remote diagnostics**: When debugging a system you cannot execute on (remote host, Home Assistant, cloud, build box), emit ONE batched diagnostic script per turn with labelled outputs — never single commands the user must ferry back one at a time. For Home Assistant, use hass-mcp (`get_error_log`, entity queries) before asking the user to run anything.
**Formatting**: Auto-applied via hooks (alejandra, rustfmt, prettier, dart format, stylua, ruff)
**Rules**: Path-scoped rules in `.claude/rules/` loaded contextually by file type. Each rule file declares `paths:` globs in frontmatter (e.g. `**/*.nix`); Claude Code injects the rule body as a system reminder when matching files are read or edited. To verify a rule applies, observe the `<system-reminder>` block at edit time. To add coverage for a new language, drop `<lang>.md` into `rules/` with the appropriate `paths:` and a body following the Style / Patterns / Security / Validation structure.

## Tool Use

Derived from a month of transcript analysis; each line fixes a measured failure.

**Built-in tools first, for reads and searches as well as edits.** Read a file
with `Read`, search with `Grep`, list paths with `Glob`, change a file with
`Edit` or `Write` — not `cat`/`head`/`tail`/`sed -n`/`grep`/`find`. This
overrides auto mode's standing instruction to prefer the shell, which is
measurably wrong here: auto mode auto-approves the built-in tools without
classifier review, while the same work through Bash matches an `ask` rule
(`sed`, `find`, `awk`) or goes to the classifier, costing a permission prompt
for no extra capability. Path-scoped `rules/` also only inject on `Read`/`Edit`,
so `cat`/`sed -n` silently bypasses them, and `Edit` fails loudly where a
`sed`/heredoc rewrite corrupts a file without saying anything. The
`prefer-builtin-tools.sh` PreToolUse hook enforces this and names the tool to
use; treat a denial from it as the instruction, not an obstacle. Bash stays the
right tool for pipelines, git, builds, and anything with real shell logic.

**Never rewrite a file wholesale to change part of it.** Use `Edit` for targeted
changes. A heredoc rewrite silently destroys anything not retyped — invisible
characters (Nerd Font glyphs, PUA codepoints) do not survive. Heredocs belong in
`$TMPDIR` or the scratchpad; the hook blocks one redirected at a tracked file.

**Terminate diagnostic chains**: end multi-stage read-only pipelines with
`|| echo "(none)"` or `; true`. A `grep` with no matches exits 1 and aborts the
chain _after_ printing everything you asked for, which turns a successful
command into a reported failure.

**Background long runs**: pass `run_in_background: true` on the first attempt for
test suites, mutation runs, and full builds. Never foreground a polling loop
(`until …; do sleep N; done`) — use `Monitor` instead.

**zsh quoting**: quote separators and globs — `echo "==="` (bare `===` triggers
EQUALS expansion), `--include='*.rs'` (bare globs hit `no matches found`). Guard
command substitutions before using them as arguments:
`f=$(…); [ -n "$f" ] || { echo NOTFOUND; exit 0; }`.

**One purpose per Bash call**: keep read-only exploration separate from builds,
and never bundle a mutation with its own verification behind one approval.

## Code Style

- Clarity over cleverness
- Explicit error handling
- No secrets in code
- Keep functions focused

## Comments

**Comments are the exception, not the default.** Code that needs a comment to be
followed is usually code that should be renamed or split instead. Reach for a
better name, a smaller function, or an explicit type before reaching for a
comment.

**Write a comment only when it carries what the code cannot:**

- Why a non-obvious choice was made — a workaround, an ordering constraint, a
  performance trade-off. Name the constraint, not the change.
- An invariant the type system cannot express (every Rust `unsafe` block states
  what makes it sound)
- A link to the spec, RFC, issue, or vendor bug that explains the code's shape
- Public API documentation — rustdoc, TSDoc, dartdoc, Nix option `description`.
  These are contracts, and are exempt from "by exception".

**Never write a comment that:**

- narrates the conversation that produced the code — "as requested", "per the
  review", "switched this to X as discussed"
- describes what the code used to do, or what was removed or renamed —
  "previously a loop", "no longer uses foo", "was broken before"
- restates the line beneath it — "increment the counter", "loop over users"
- flags the change as new — "NEW:", "UPDATED:", "added support for…". Git
  history is the changelog.
- is commented-out code. Delete it; git remembers.

**When editing**: a comment that no longer matches the code under it is a
defect — update or delete it in the same change. Never leave stale comments
behind a refactor.

**Voice**: present tense, describing the code as it is, written for a reader who
has never seen this diff and never will.

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

**Domain agent** (Sonnet, `acceptEdits`): nix
**Review agents** (Opus, `plan`, read-only): security-reviewer, bug-hunter, quality-reviewer
**Workflow agent**: researcher (Opus, `plan`). PLAN runs inline.

Domain agents inherit all tools. Review agents: security-reviewer has Read, Glob, Grep, LSP, WebSearch, WebFetch, memory. bug-hunter and quality-reviewer have Read, Glob, Grep, LSP, memory.

**Model selection rule**: Only upgrade from Sonnet to Opus when judgment accuracy outweighs cost.

## Orchestration Primitives

| Primitive   | When to Use                                                             |
| ----------- | ----------------------------------------------------------------------- |
| Subagents   | Sequential delegation, single-layer, < 3 independent file sets          |
| Skills      | Turn-by-turn guided workflows (RIPER, commit, etc.)                     |
| Agent Teams | Cross-layer (3+ languages), 3+ independent file sets in parallel        |
| Workflows   | Score ≥ 8 AND highly parallelisable; orchestration codified as a script |

`ultracode` keyword (or `/effort ultracode`) triggers dynamic workflow mode — **on by default**. Saved workflows live in `~/.claude/workflows/`. See `skills/riper/references/complexity.md` for routing criteria.

## MCP Servers

**Core**: memory, context7, obsidian
**Project** (.mcp.json): hass-mcp for Home Assistant repos

## Storage

- **Specs/Plans**: Obsidian vault (`claude/specs/`)
- **Agent Memory**: `~/.claude/agent-memory/{agent}/MEMORY.md` → Obsidian vault
- **Decisions**: AIM memory graph (project-scoped)
- **Memory strategy**: See `riper` skill supporting files

The Obsidian legs above went unnoticed-broken for a month (`mcp-obsidian`
defaults `OBSIDIAN_PROTOCOL` to `https` while the vault's REST API serves HTTP
on 27123), degrading silently to a repo-local fallback. `mcp.json` now pins the
protocol. If vault writes start failing again, check that first — and say so in
the turn rather than falling back quietly.

## Reasoning Effort

| Tier      | Trigger                        | Use When                                                    |
| --------- | ------------------------------ | ----------------------------------------------------------- |
| Medium    | Always-on baseline             | EXECUTE, PLAN, standard tasks                               |
| High      | `ultrathink` keyword in prompt | RESEARCH/INNOVATE on COMPLEX tasks, security review         |
| XHigh     | `/effort xhigh`                | Architectural decisions, multi-system reasoning             |
| Ultracode | `ultracode` keyword in prompt  | Highly parallelisable COMPLEX tasks; triggers workflow mode |
| Max       | Session-only                   | One-off deep analysis (resets after turn)                   |

Default model is Opus 5 (`claude-opus-5`). Review agents also run Opus 5; the `nix` agent runs Sonnet 5 (`claude-sonnet-5`).

## Build Commands

```bash
nh darwin switch .#ryukyu                  # macOS (shows diff, cleaner output)
nh os switch .#rubecula                    # NixOS (shows diff, cleaner output)
# Fallback without nh:
darwin-rebuild switch --flake .#ryukyu
sudo nixos-rebuild switch --flake .#rubecula
```
