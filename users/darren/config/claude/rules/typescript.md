---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "tsconfig.json"
  - "package.json"
---

# TypeScript Rules

## Style

- Format with `prettier` (auto-applied via hooks)
- Enable strict mode
- Avoid `any`, use `unknown`
- Use discriminated unions
- Prefer interfaces for objects

## React

- Prefer function components
- Use hooks correctly (deps array)
- Memoize expensive computations
- Keep components pure
- Colocate state with usage

## API Design

- Use proper HTTP methods and status codes
- Validate all inputs at boundaries with zod or joi
- Use parameterized queries (never string concatenation)
- Return consistent error format

## Security

- Never use `eval()`, `Function()`, or `innerHTML` with user data — use `textContent`, DOM APIs, or DOMPurify
- Store secrets in environment variables, never in source; `.env` files must be gitignored
- Avoid `prototype` pollution — never merge untrusted objects into bare `{}` with spread or `Object.assign`
- Use `dangerouslySetInnerHTML` only as a last resort and always with DOMPurify sanitisation
- Review `npm audit` before adding dependencies; prefer maintained packages with minimal transitive deps
- Use `Content-Security-Policy` headers; avoid inline scripts

## Validation

1. `prettier --write`
2. `eslint --fix`
3. `tsc --noEmit`
4. Run tests
