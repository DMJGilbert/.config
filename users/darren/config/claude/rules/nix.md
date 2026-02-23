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

## Validation
1. `alejandra` to format
2. `nix flake check`
3. `nix eval` to verify no errors
4. `darwin-rebuild build --flake .#` or `nixos-rebuild build --flake .#`
