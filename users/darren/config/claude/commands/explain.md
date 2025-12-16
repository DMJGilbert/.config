---
description: Explain code sections and document complex logic
allowed-tools:
  - Bash(git status:*)
  - Bash(git log:*)
  - Read
  - Grep
  - Glob
  - Task
---

# Explain Code

Analyze and explain code sections, documenting complex logic and algorithms. This command is **read-only** - it will NOT modify any files.

Target: $ARGUMENTS

## Usage Examples

- `/explain src/auth/oauth.ts` - Explain entire file
- `/explain src/auth/oauth.ts:45` - Explain function/block at line 45
- `/explain src/auth/oauth.ts:45-80` - Explain specific line range
- `/explain` (no args) - Explain the most recently changed files

## Analysis Steps

1. **Identify the Code**
   - Read the specified file/section
   - Determine the language and context
   - Identify related files if needed

2. **High-Level Overview**
   - What is the purpose of this code?
   - Where does it fit in the architecture?
   - What problem does it solve?

3. **Detailed Explanation**
   - Break down into logical sections
   - Explain each significant block
   - Document the flow of execution

4. **Technical Details**
   - Algorithms used and their complexity
   - Design patterns employed
   - Data structures and their purpose
   - Edge cases handled

5. **Dependencies & Interactions**
   - What does this code depend on?
   - What depends on this code?
   - Side effects and state changes

## Output Format

### Code Explanation: `<file_path>`

#### Overview

[1-2 paragraph summary of what this code does and why it exists]

#### Architecture Context

```
[Where this fits in the system - could be a simple diagram]
```

#### Detailed Breakdown

##### Section 1: [Name/Purpose]

**Lines X-Y**

```language
[relevant code snippet]
```

**Explanation**: [What this section does and why]

##### Section 2: [Name/Purpose]

[Continue for each logical section]

#### Key Concepts

**Algorithm: [Name]**

- Complexity: O(n)
- How it works: [explanation]
- Why it's used: [reasoning]

**Pattern: [Name]**

- What it is: [explanation]
- Why it's used here: [reasoning]

#### Data Flow

```
Input -> [Step 1] -> [Step 2] -> Output
```

#### Edge Cases Handled

- Case 1: How it's handled
- Case 2: How it's handled

#### Potential Improvements

[Optional suggestions for clarity or efficiency - NOT to be implemented, just noted]

#### Related Files

- `file1.ts` - [relationship]
- `file2.ts` - [relationship]

#### Suggested Documentation

[Comments that could be added to improve code clarity - for reference only]
