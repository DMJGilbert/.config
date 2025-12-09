# Project Guidelines

## Git Workflow

### Conventional Commits
All commits must follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `build`: Build system or dependencies

**Examples:**
```
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
refactor(utils): extract date formatting to helper
```

### Branch Naming
- `feat/short-description` - New features
- `fix/issue-number-description` - Bug fixes
- `refactor/description` - Refactoring
- `docs/description` - Documentation

## Code Review Standards

### Must Check
1. **Security**: No hardcoded secrets, proper input validation, safe SQL queries
2. **Performance**: No N+1 queries, efficient algorithms, proper caching
3. **Tests**: Adequate coverage, edge cases handled
4. **Architecture**: Follows existing patterns, no circular dependencies

### Severity Levels
- **Critical**: Security vulnerabilities, data loss risks, breaking changes
- **High**: Performance issues, missing error handling, test gaps
- **Medium**: Code smells, maintainability concerns, documentation gaps
- **Low**: Style issues, minor improvements, suggestions

## Code Style

### General
- Prefer clarity over cleverness
- Keep functions small and focused (single responsibility)
- Use meaningful names (no abbreviations)
- Handle errors explicitly

### Language-Specific

**Nix:**
- Use `alejandra` for formatting
- Prefer attribute sets over let bindings where possible
- Use `lib.mkIf` for conditional configurations

**TypeScript/JavaScript:**
- Use `biome` or `prettier` for formatting
- Prefer `const` over `let`
- Use TypeScript strict mode

**Swift:**
- Use `swiftformat` for formatting
- Follow Swift API Design Guidelines
- Prefer value types over reference types

**Rust:**
- Use `rustfmt` for formatting
- Handle all `Result` and `Option` types explicitly
- Prefer iterators over manual loops

## Security Baselines

- No secrets in code (use environment variables or secret managers)
- Validate all external input
- Use parameterized queries for database access
- Keep dependencies updated
- Follow principle of least privilege

## Performance Baselines

- Database queries should be indexed
- API responses should be paginated
- Large lists should be virtualized
- Images should be optimized and lazy-loaded
- Bundle size should be monitored
