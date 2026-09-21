---
paths:
  - "**/*.nix"
  - "flake.nix"
  - "flake.lock"
---

# Nix Rules

## Style

- Format with `alejandra` (auto-applied via hooks)
- Prefer attribute sets over let bindings where possible
- Use `lib.mkIf` for conditional configurations
- Use `lib.mkOption` with proper types

## Patterns

- Use `writeShellApplication` not `writeShellScriptBin`
- Use `nix build --print-out-paths` for debugging
- Fix ShellCheck warnings, don't suppress
- Use flake-parts for complex flakes

## Module Design

- Declare options with `lib.mkEnableOption`
- Use `lib.mkDefault` for overridable defaults
- Add assertions for invalid configurations
- Document options with `description`

## Comments

Comments are the exception — see `CLAUDE.md` § Comments for what earns one.

- Option `description` is the documentation surface (see Module Design); a `#` comment is not a substitute for it
- Reserve `#` comments for what the expression cannot show: why an input is pinned, why an override exists, the upstream issue a workaround tracks — link it
- Do not comment-narrate module structure; attribute names and `alejandra` formatting already carry it

## Security

- Never store secrets in `.nix` files — use `sops-nix` or `agenix` for encrypted secrets management
- Minimise `nix.settings.trusted-users` — only users who genuinely need to build unsigned packages
- Pin flake inputs (`flake.lock`) and review `nix flake update` diff before committing
- Prefer per-package `allowUnfree` overrides over a global `allowUnfree = true`

## Validation

1. `alejandra` to format
2. `nix flake check`
3. `nix eval` to verify no errors
4. `darwin-rebuild build --flake .#` or `nixos-rebuild build --flake .#`
