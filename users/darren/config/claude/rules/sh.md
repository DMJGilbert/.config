---
paths:
  - "**/*.sh"
  - "**/*.bash"
  - "**/.bashrc"
  - "**/.zshrc"
---

# Shell Rules

## Style

- Format with `shfmt -i 2 -ci` (2-space indent, switch-case indented)
- Lint with `shellcheck`; fix warnings rather than `# shellcheck disable=...`
- Use `#!/usr/bin/env bash` shebang (or `#!/bin/sh` if strictly POSIX)
- Always start scripts with `set -euo pipefail` (bash) or `set -eu` (POSIX)

## Patterns

- Quote every variable expansion: `"$var"`, not `$var`
- Use `[[ … ]]` for tests (bash); `[ … ]` only for POSIX scripts
- Use `$(cmd)` over backticks
- Use `mktemp` for temp files; trap to clean up
- Prefer `printf` over `echo -e` for portability
- Check exit codes explicitly; do not rely on `$?` long after the fact
- For arg parsing, use `getopts` (POSIX) or `case` (bash)

## Security

- Never `eval` on user input
- Validate / sanitise any argument used in a path or shell expansion
- Use `--` to terminate option parsing before user-supplied args (e.g. `rm -- "$file"`)
- Never store secrets in script files — read from env, file, or vault at runtime
- Avoid `sudo` inside scripts unless explicitly required and documented

## Validation

1. `shellcheck script.sh` — no warnings
2. `shfmt -d script.sh` — formatting clean
3. Run with `bash -n script.sh` for syntax check before testing
4. Test edge cases: empty input, missing files, paths with spaces / special chars
