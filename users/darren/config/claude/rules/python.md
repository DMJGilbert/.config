---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
---

# Python Rules

## Style

- Format with `ruff format` (auto-applied via hooks)
- Lint with `ruff check`; treat warnings as errors in CI
- Follow PEP 8 line length (88 chars, ruff default)
- Type-hint public APIs; prefer concrete types over `Any`
- Prefer f-strings over `%`/`.format()`

## Patterns

- Use `pathlib.Path` for filesystem ops, not raw strings
- Use `logging` (not `print`) for diagnostics
- Prefer `dataclasses`/`pydantic` over ad-hoc dicts for structured data
- Use context managers (`with`) for file/socket/lock resources
- Iterate with comprehensions when expression-shaped; for-loops for side effects
- Use `pytest` fixtures over setUp/tearDown boilerplate
- Stdlib first — only add a dependency when it removes substantial code

## Security

- Never `eval`/`exec` on user input; never `pickle.loads` untrusted data
- Parameterise SQL — never f-string user input into queries
- Use `secrets` (not `random`) for tokens / passwords
- Validate file paths against a known root before opening (path traversal)
- Use `requests`/`httpx` `verify=True`; never disable TLS verification in production code

## Validation

1. `ruff format --check` — formatting clean
2. `ruff check` — no lint errors
3. `mypy` (if type-hinted project) or `pyright` — no type errors
4. `pytest` — tests pass
