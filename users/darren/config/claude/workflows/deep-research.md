---
name: deep-research
description: Multi-source research fan-out — parallel researcher agents across docs, web, memory, and codebase, synthesising a single brief
---

Perform deep research on a topic by fanning out across independent sources. Spawn the following agents concurrently:

- **researcher (codebase)**: grep + LSP + Read in the current repo for prior implementations, existing patterns, related modules
- **researcher (memory)**: query agent memories (`~/.claude/agent-memory/`) and AIM graph for past decisions and learnings
- **researcher (docs)**: query context7 for library / framework docs relevant to the topic
- **researcher (web)**: WebSearch + WebFetch for public sources, RFCs, blog posts, vendor docs not in context7

Each researcher returns a structured brief:

- Sources consulted
- Key facts discovered
- Open questions
- Confidence level

## Synthesis

After all four return, produce a single unified brief structured as:

## Research Brief — [topic, date]

### Established facts

[items every source agreed on, with source attribution]

### Conflicting evidence

[items where sources disagreed, with the conflict and likely resolution]

### Open questions

[items no source could answer; flag what would resolve them]

### Recommended next step

[one paragraph: what to do with this research]

Use this synthesis as RESEARCH-phase input for downstream RIPER work, or as standalone output if research itself was the goal.
