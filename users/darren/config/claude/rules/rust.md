---
paths:
  - "**/*.rs"
  - "Cargo.toml"
  - "Cargo.lock"
---

# Rust Rules

## Style

- Format with `rustfmt` (auto-applied via hooks)
- Follow Rust API Guidelines
- Prefer iterators over manual loops
- Use `clippy` lints

## Error Handling

- Use `?` operator for propagation
- Create domain-specific error types with `thiserror`
- Use `anyhow` for application code, `thiserror` for libraries
- Provide context with `.context()`

## Ownership

- Prefer borrowing over cloning
- Use `Cow` for flexible ownership
- Avoid unnecessary `Arc`/`Mutex`
- Understand move vs copy semantics

## Comments

Comments are the exception — see `CLAUDE.md` § Comments for what earns one.

- `///` and `//!` rustdoc on public items is a contract, not commentary — write it, and keep it accurate through refactors
- Every `unsafe` block carries a `// SAFETY:` comment naming the invariant that makes it sound (see Security)
- Every `#[allow(…)]` / `#[expect(…)]` carries a comment saying why the lint does not apply here
- Prefer a named binding or an extracted function over a `//` comment explaining a dense expression

## Security

- Minimise `unsafe` blocks; every `unsafe` requires a comment stating the invariant that makes it sound
- Never implement cryptography from scratch — use `ring`, `rustls`, or `aes-gcm`
- Sanitise file paths from external input — `canonicalize` then verify the result is within the expected root
- Use checked arithmetic (`checked_add`, `saturating_add`) for untrusted numeric input in release builds
- Deserialise untrusted data defensively — apply size limits and use `#[serde(deny_unknown_fields)]` where appropriate

## Sandbox

- If a cargo command fails with `.cargo-lock ... Operation not permitted` (or similar write denial in a sibling repo's `target/`), that is a Claude Code sandbox allowlist gap — report it and ask for the directory to be added to `sandbox.filesystem.allowWrite`. Do NOT improvise `CARGO_TARGET_DIR` redirections or other workarounds.

## Validation

1. `cargo fmt`
2. `cargo clippy`
3. `cargo check`
4. `cargo test`
