---
description: Five Whys root cause analysis for debugging and problem-solving
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git log:*)
  - Bash(git diff:*)
  - Bash(git blame:*)
  - mcp__sequential-thinking__sequentialthinking
  - mcp__hass-mcp__get_entity
  - mcp__hass-mcp__get_history
  - mcp__hass-mcp__list_automations
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_add_observations
---

# Five Whys Root Cause Analysis

Analyze the root cause of: $ARGUMENTS

## Kaizen Methodology

Based on Toyota's [Five Whys](https://en.wikipedia.org/wiki/Five_whys) technique and Kaizen continuous improvement philosophy. Drill from symptoms to fundamental causes.

## Analysis Process

### Step 1: Define the Problem

Clearly state the observable symptom:

```
SYMPTOM: [What is happening that shouldn't be?]
EXPECTED: [What should happen instead?]
CONTEXT: [When/where does this occur?]
```

### Step 2: Iterative Why Analysis

For each level, ask "Why?" and provide evidence:

```
WHY 1: Why is [symptom] happening?
├── Because: [First-level cause]
├── Evidence: [How do we know this?]
└── Verified: [Yes/No - did we confirm this?]

WHY 2: Why is [first-level cause] happening?
├── Because: [Second-level cause]
├── Evidence: [How do we know this?]
└── Verified: [Yes/No]

WHY 3: Why is [second-level cause] happening?
├── Because: [Third-level cause]
├── Evidence: [How do we know this?]
└── Verified: [Yes/No]

WHY 4: Why is [third-level cause] happening?
├── Because: [Fourth-level cause]
├── Evidence: [How do we know this?]
└── Verified: [Yes/No]

WHY 5: Why is [fourth-level cause] happening?
├── Because: [ROOT CAUSE]
├── Evidence: [How do we know this?]
└── Verified: [Yes/No]
```

### Step 3: Verify Root Cause

The root cause should be:

- [ ] **Actionable**: We can do something about it
- [ ] **Controllable**: It's within our influence
- [ ] **Specific**: Not vague or generic
- [ ] **Verified**: Confirmed with evidence, not assumed

### Step 4: Countermeasures

| Type | Action | Prevents Recurrence? |
|------|--------|---------------------|
| Immediate | [Quick fix for symptom] | No (temporary) |
| Corrective | [Fix the root cause] | Yes |
| Preventive | [Prevent similar issues] | Yes (broader) |

## Investigation Tools

### For Code Issues

```bash
# Find when issue was introduced
git log -p --all -S 'search_term' -- path/to/file

# Blame specific lines
git blame path/to/file

# Check recent changes
git diff HEAD~10..HEAD -- path/to/file
```

### For Home Assistant Issues

```
# Check entity state history
mcp__hass-mcp__get_history(entity_id="...", hours=24)

# Verify automation state
mcp__hass-mcp__list_automations()

# Check entity details
mcp__hass-mcp__get_entity(entity_id="...", detailed=true)
```

### For Config Issues

```
# Search for related patterns
Grep(pattern="related_term", path=".")

# Find config files
Glob(pattern="**/*.nix")
```

## Output Format

```markdown
## Root Cause Analysis: [Problem Title]

### Problem Statement
- **Symptom**: [Observable issue]
- **Expected**: [Correct behavior]
- **Impact**: [What's affected]

### Five Whys Chain

| Level | Question | Answer | Evidence |
|-------|----------|--------|----------|
| Why 1 | Why [symptom]? | [Cause 1] | [Evidence] |
| Why 2 | Why [cause 1]? | [Cause 2] | [Evidence] |
| Why 3 | Why [cause 2]? | [Cause 3] | [Evidence] |
| Why 4 | Why [cause 3]? | [Cause 4] | [Evidence] |
| Why 5 | Why [cause 4]? | **ROOT CAUSE** | [Evidence] |

### Root Cause
**[Clear statement of the fundamental cause]**

### Countermeasures
1. **Immediate**: [Action] - [Owner] - [Timeline]
2. **Corrective**: [Action] - [Owner] - [Timeline]
3. **Preventive**: [Action] - [Owner] - [Timeline]

### Lessons Learned
- [Insight to remember for future]
```

## Alternative: Fishbone Analysis

For complex issues with multiple potential causes, use Ishikawa/Fishbone diagram categories:

```
                    ┌─────────────┐
    Methods ────────┤             │
                    │             │
    Machines ───────┤   PROBLEM   │
                    │             │
    Materials ──────┤             │
                    │             │
    People ─────────┤             │
                    │             │
    Environment ────┤             │
                    │             │
    Measurement ────┤             │
                    └─────────────┘
```

Investigate each category:

- **Methods**: Process, procedures, workflow issues
- **Machines**: Tools, systems, infrastructure issues
- **Materials**: Inputs, dependencies, data issues
- **People**: Skills, communication, handoff issues
- **Environment**: External factors, context issues
- **Measurement**: Monitoring, feedback, detection issues
