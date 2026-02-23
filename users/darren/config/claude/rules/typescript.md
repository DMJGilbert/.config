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

## Validation
1. `prettier --write`
2. `eslint --fix`
3. `tsc --noEmit`
4. Run tests
