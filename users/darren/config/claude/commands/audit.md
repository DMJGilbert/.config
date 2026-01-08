---
description: Deep code audit (entire codebase, file, or function)
allowed-tools:
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git blame:*)
  - Bash(find:*)
  - Bash(wc:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Code Audit

Perform a professional code audit. This command is **read-only** - it will NOT modify any files.

Target: $ARGUMENTS

## Scope Detection

Based on the argument provided, determine the audit scope:

- **No argument**: Audit the entire codebase (high-level overview with deep dives into problem areas)
- **File path** (e.g., `src/api/handler.ts`): Deep audit of that specific file
- **Function/class name** (e.g., `processPayment` or `UserService`): Find and audit that specific symbol
- **Directory** (e.g., `src/services/`): Audit all files in that directory
- **Pattern** (e.g., `*.controller.ts`): Audit files matching the pattern

## Analysis Framework

### 1. Structural Analysis

**Code Organization**

- File/module structure and naming
- Import organization and dependency graph
- Separation of concerns
- Layer boundaries (presentation, business, data)

**Architecture Patterns**

- Identify patterns in use (MVC, Repository, Factory, etc.)
- Check for pattern consistency
- Find anti-patterns (God objects, spaghetti code, circular dependencies)

### 2. Bug Risk Assessment

**High-Risk Patterns**

- Race conditions and concurrency issues
- Null/undefined handling gaps
- Off-by-one errors
- Resource leaks (unclosed handles, connections, subscriptions)
- Unhandled promise rejections
- Type coercion bugs

**Edge Cases**

- Empty collections/strings handling
- Boundary conditions
- Error propagation paths
- Timeout and retry logic

**State Management**

- Mutable shared state
- Side effects in unexpected places
- State synchronization issues

### 3. Complexity Analysis

**Metrics to Assess**

- Cyclomatic complexity (flag >10)
- Cognitive complexity
- Nesting depth (flag >3)
- Function length (flag >50 lines)
- Parameter count (flag >5)
- File length (flag >400 lines)

**Simplification Opportunities**

- Extract method candidates
- Guard clause opportunities
- Early return patterns
- Strategy pattern candidates
- Decomposition targets

### 4. Code Smells

**Common Smells**

- Long parameter lists
- Feature envy (method using other class's data)
- Data clumps (recurring groups of parameters)
- Primitive obsession
- Refused bequest (unused inherited methods)
- Speculative generality (unused abstractions)
- Dead code
- Commented-out code
- Magic numbers/strings

### 5. Maintainability Assessment

**Readability**

- Naming clarity (variables, functions, classes)
- Function/method purpose clarity
- Complex logic explanation
- Consistent formatting

**Changeability**

- Coupling assessment
- Cohesion evaluation
- Single Responsibility adherence
- Open/Closed principle compliance

**Testability**

- Dependency injection usage
- Pure functions identification
- Side effect isolation
- Mock boundaries

### 6. Language-Specific Checks

**TypeScript/JavaScript**

- Type safety (any usage, type assertions)
- Async/await patterns
- Error handling in promises
- Module system usage

**Nix**

- Attribute set organization
- Function purity
- Override patterns
- Module option structure

**Rust**

- Ownership patterns
- Error handling (Result/Option)
- Lifetime annotations
- Unsafe usage

**Swift**

- Optionals handling
- Value vs reference types
- Protocol conformance
- Memory management

**Python**

- Type hints usage
- Exception handling
- Context managers
- Dataclass patterns

## Output Format

### Audit Report: [Target]

#### Executive Summary

- **Scope**: What was audited
- **Overall Health**: Healthy / Needs Attention / Critical Issues
- **Key Findings**: 2-3 sentence summary

#### Metrics Overview

```
Files Analyzed:    X
Total Lines:       X
Functions/Methods: X
Complexity Score:  X (Low/Medium/High)
```

#### Critical Issues

Issues that will likely cause bugs or failures:

**[BUG-001] Issue Title**

- **Location**: `file:line`
- **Risk**: What can go wrong
- **Evidence**: Code snippet or pattern found
- **Recommendation**: Specific fix

#### High Priority

Significant issues affecting quality or maintainability:

**[HIGH-001] Issue Title**

- **Location**: `file:line`
- **Issue**: What's wrong
- **Impact**: How it affects the codebase
- **Recommendation**: How to address

#### Medium Priority

Code quality concerns:

**[MED-001] Issue Title**

- **Location**: `file:line`
- **Issue**: What could be improved
- **Recommendation**: Suggested improvement

#### Low Priority / Suggestions

Minor improvements and style considerations:

**[LOW-001] Issue Title**

- **Location**: `file:line`
- **Suggestion**: Optional improvement

#### Positive Observations

Highlight well-written code patterns worth preserving or replicating.

#### Recommended Refactors

Ranked list of refactoring opportunities with effort/impact assessment:

| Priority | Refactor    | Location | Effort       | Impact       |
| -------- | ----------- | -------- | ------------ | ------------ |
| 1        | Description | file     | Low/Med/High | Low/Med/High |

#### Next Steps

1. Immediate action items
2. Short-term improvements
3. Long-term considerations

## Execution Patterns

For comprehensive audits, dispatch specialist agents in parallel:

### Full Codebase Audit (Parallel)

Launch multiple agents in a **single message** for automatic parallel execution:

```
Task(code-reviewer, prompt="Structural audit: patterns, architecture, code smells, maintainability")
Task(security-auditor, prompt="Security audit: vulnerabilities, injection risks, auth gaps, secrets")
Task(test-engineer, prompt="Testability audit: coverage gaps, mock boundaries, side effect isolation")
# Claude waits for all to complete, then merges findings
```

### Targeted Audit by Scope

| Scope Type      | Primary Agent        | Secondary (Parallel)                |
| --------------- | -------------------- | ----------------------------------- |
| Single file     | code-reviewer        | security-auditor (if auth/data)     |
| API endpoints   | backend-developer    | security-auditor                    |
| UI components   | frontend-developer   | ui-ux-designer                      |
| Database layer  | database-specialist  | security-auditor                    |
| Full codebase   | code-reviewer        | security-auditor + test-engineer    |

### Merging Parallel Results

After parallel agents complete:

1. Collect all specialist findings
2. Deduplicate overlapping issues
3. Assign unified severity (Critical > High > Medium > Low)
4. Order by impact and effort
5. Generate consolidated report with cross-references
