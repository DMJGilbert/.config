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

## Agent Orchestration

For complex tasks, use specialist agents to handle domain-specific work efficiently.

### Invocation Methods

- **Orchestrator**: `use orchestrator` or `/orchestrate [task]` for multi-domain tasks
- **Direct**: `use [agent-name]` for specific domain work

### Available Specialists

| Domain | Agent | Trigger Keywords |
|--------|-------|------------------|
| Frontend | frontend-developer | react, component, tailwind, shadcn, tsx |
| Backend | backend-developer | api, endpoint, server, express, route |
| Database | database-specialist | sql, schema, query, migration, prisma |
| UI/UX | ui-ux-designer | design, accessibility, ux, layout, figma |
| Security | security-auditor | security, vulnerability, owasp, audit |
| Docs | documentation-expert | document, readme, api-docs, jsdoc |
| Architecture | architect | architecture, pattern, scale, design |
| Rust | rust-developer | rust, cargo, tokio, systems |
| Dart | dart-developer | dart, flutter, widget, riverpod |
| Nix | nix-specialist | nix, flake, home-manager, darwin |
| Review | code-reviewer | review, pr, quality, lint |
| Testing | test-engineer | test, vitest, playwright, coverage |

### MCP Integration

- `use context7` - Fetch up-to-date library documentation
- `use magic-ui` - Access Magic UI components (layouts, motion, effects)
- `use figma` - Access Figma design files and assets

### Workflow Example

```
User: "Add a new user profile page with authentication"

1. use orchestrator → Analyzes task, identifies agents needed
2. Delegates to frontend-developer → Creates React components
3. Delegates to backend-developer → Creates API endpoints
4. Delegates to test-engineer → Writes tests
5. Delegates to code-reviewer → Reviews final implementation
```
