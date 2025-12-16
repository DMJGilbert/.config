---
description: Manage persistent memory (knowledge graph)
allowed-tools:
  - Bash(git:*)
  - mcp__memory__aim_read_graph
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_open_nodes
  - mcp__memory__aim_create_entities
  - mcp__memory__aim_create_relations
  - mcp__memory__aim_add_observations
  - mcp__memory__aim_delete_entities
  - mcp__memory__aim_delete_relations
  - mcp__memory__aim_delete_observations
  - mcp__memory__aim_list_databases
---

# Memory Management

Manage Claude's persistent knowledge graph memory.

Command: $ARGUMENTS

## Context System

Memory is organized into contexts:

| Context | Purpose | Storage |
|---------|---------|---------|
| (default) | Personal conventions, preferences | `memory.jsonl` |
| `[project]` | Project-specific knowledge | `memory-[project].jsonl` |
| `work` | Cross-project work patterns | `memory-work.jsonl` |
| `client-[name]` | Isolated client data | `memory-client-[name].jsonl` |

## Usage

- `/remember` - Show current memory (default + project contexts)
- `/remember --context=work` - Show specific context
- `/remember --global` - Show only default context
- `/remember search <query>` - Search across all contexts
- `/remember add <entity>` - Add entity to project context
- `/remember add --global <entity>` - Add to default context
- `/remember note <observation>` - Add observation to existing entity
- `/remember forget <entity>` - Remove an entity from memory
- `/remember contexts` - List all available contexts

## Commands

### View Memory

```
/remember
```

1. Detect project name from git
2. Load default context: `aim_read_graph()`
3. Load project context: `aim_read_graph(context="[project]")`
4. Display merged view with context indicators

### View Specific Context

```
/remember --context=work
/remember --global
```

Load only the specified context.

### List Contexts

```
/remember contexts
```

Runs `aim_list_databases()` to show all available contexts.

### Search Memory

```
/remember search authentication
/remember search "home assistant dashboard"
```

Searches across default + project contexts:

```
aim_search_nodes(query)  # default
aim_search_nodes(query, context="[project]")  # project
```

### Add Entity

```
/remember add auth-service
/remember add --global coding-style
```

Without `--global`: adds to project context.
With `--global`: adds to default context.

```
aim_create_entities({
  context: "[project]",  # or omit for default
  entities: [{
    "name": "auth-service",
    "entityType": "[prompted]",
    "observations": ["[prompted observations]"]
  }]
})
```

### Add Observation

```
/remember note auth-service "Added rate limiting to login endpoint"
```

Searches for entity in project context first, then default:

```
aim_add_observations({
  context: "[where entity was found]",
  observations: [{
    "entityName": "auth-service",
    "contents": ["Added rate limiting to login endpoint"]
  }]
})
```

### Link Entities

```
/remember link auth-service api-gateway "authenticates"
```

Creates relation in same context as entities:

```
aim_create_relations({
  context: "[project]",
  relations: [{
    "from": "auth-service",
    "to": "api-gateway",
    "relationType": "authenticates"
  }]
})
```

### Remove Entity

```
/remember forget old-component
```

Removes entity (with confirmation) from the context where it exists.

### Clear Context

```
/remember clear
/remember clear --context=work
```

**Requires confirmation** - removes all entities from specified context.

## Entity Types

Suggested entity types for consistency:

| Type | Use For |
|------|---------|
| `project` | The main project |
| `service` | Backend services, APIs |
| `component` | UI components, modules |
| `directory` | Key directories |
| `pattern` | Code patterns, conventions |
| `decision` | Architecture decisions (ADRs) |
| `config` | Configuration files/systems |
| `integration` | External integrations |
| `person` | Team members, stakeholders |

## Relation Types

| Type | Use For |
|------|---------|
| `part_of` | Component belongs to larger system |
| `uses` | Service A uses Service B |
| `depends_on` | Hard dependency |
| `affects` | Decision affects component |
| `describes` | Pattern describes component |
| `authenticates` | Auth relationship |
| `stores_data_in` | Data storage relationship |

## Output Format

### Memory Contents

**Entities:**

- `project` (project): Nix configuration for macOS and NixOS
- `home-assistant` (service): Smart home automation
- `rubecula` (service): NixOS home server

**Relations:**

- home-assistant → rubecula (runs_on)
- rubecula → project (part_of)

**Recent Observations:**

- [project] "Added floorplan dashboard views"
- [home-assistant] "Using Catppuccin theme"

---

## Memory Location

Memory is stored globally at `~/.local/share/claude-memory/`:

- `memory.jsonl` - Default context (personal conventions)
- `memory-[project].jsonl` - Project-specific contexts

*Memory persists across sessions and is available in all projects.*
