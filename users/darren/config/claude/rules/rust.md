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

## Validation

1. `cargo fmt`
2. `cargo clippy`
3. `cargo check`
4. `cargo test`
