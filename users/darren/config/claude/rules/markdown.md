---
paths:
  - "**/*.md"
  - "**/*.mdx"
---

# Markdown Rules

## Style

- Format with `prettier --write` (auto-applied via hooks)
- Lint with `markdownlint-cli2` against the repo's `.markdownlint-cli2.yaml`
- Use ATX headings (`#`/`##`/`###`); no setext underlines
- Heading hierarchy: don't skip levels (no `#` → `###`)
- One blank line before and after fenced code blocks and headings
- Use fenced code blocks (` ``` `) with a language identifier for syntax highlighting

## Patterns

- Tables: align columns; use `---` separators with no surrounding spaces
- Links: prefer reference-style for repeated URLs; inline for one-offs
- Images: always include alt text (`![description](url)`)
- Lists: consistent marker per list (`-` for unordered; `1.` numbered)
- Use `<details>`/`<summary>` for collapsible long content rather than burying it

## Security

- Never include unverified external HTML in docs you don't control the rendering of
- Sanitise / verify any embedded scripts or iframes before committing
- Treat any URL in a public README as a permanent reference — rotting links degrade trust

## Validation

1. `markdownlint-cli2 '**/*.md'` — no lint errors
2. `prettier --check '**/*.md'` — formatting clean
3. Link check (e.g. `lychee --no-progress .` or `markdown-link-check`) before publishing
4. Render preview in target viewer (GitHub, Obsidian) for any non-trivial layout
