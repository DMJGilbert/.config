---
description: Performance audit of codebase
allowed-tools:
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(find:*)
  - Bash(wc:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Performance Audit

Analyze for performance issues and optimization opportunities. This command is **read-only** - it will NOT modify any files.

Target: $ARGUMENTS

If no argument provided, audit the entire codebase. You can specify:

- A file path: `/perf src/api/handlers.ts`
- A directory: `/perf src/database/`
- A specific concern: `/perf database queries` or `/perf bundle size`

## Analysis Areas

### 1. Algorithmic Complexity

- Identify O(n²) or worse algorithms
- Look for nested loops over large datasets
- Check for recursive functions without memoization
- Find redundant computations

### 2. Database & Queries

- Look for N+1 query patterns
- Check for missing indexes (based on query patterns)
- Identify unbounded queries (no LIMIT)
- Find queries in loops

### 3. Memory Usage

- Large object allocations
- Memory leaks (unclosed resources, event listeners)
- Unnecessary data copying
- Large arrays/collections held in memory

### 4. Bundle Size (for web projects)

- Large dependencies
- Unused imports
- Missing tree-shaking opportunities
- Unoptimized assets

### 5. Network

- Unnecessary API calls
- Missing request batching
- Large payloads
- Missing caching headers

### 6. Rendering (for UI code)

- Unnecessary re-renders
- Missing virtualization for long lists
- Unoptimized images
- Layout thrashing

## Output Format

### Performance Report

#### Summary

- Overall performance health: Good/Fair/Poor
- Critical issues found: X
- Optimization opportunities: Y

#### Critical Issues

Issues that likely cause noticeable performance problems:

- **Location**: file:line
- **Issue**: Description
- **Impact**: Estimated impact (High/Medium/Low)
- **Fix**: Suggested optimization

#### Optimization Opportunities

Improvements that could enhance performance:

- **Location**: file:line
- **Current**: What's happening now
- **Suggested**: Better approach
- **Effort**: Easy/Medium/Hard

#### Metrics to Monitor

Suggest specific metrics to track based on findings.

#### Quick Wins

List low-effort, high-impact optimizations that can be done immediately.
