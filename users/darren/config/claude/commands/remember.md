---
description: Manage persistent memory (knowledge graph)
allowed-tools:
  - mcp__memory__aim_read_graph
  - mcp__memory__aim_search_nodes
  - mcp__memory__aim_open_nodes
  - mcp__memory__aim_create_entities
  - mcp__memory__aim_create_relations
  - mcp__memory__aim_add_observations
  - mcp__memory__aim_delete_entities
  - mcp__memory__aim_delete_relations
  - mcp__memory__aim_delete_observations
---

# Memory Management

Manage Claude's persistent knowledge graph memory.

Command: $ARGUMENTS

## Usage

- `/remember` - Show current memory contents
- `/remember search <query>` - Search memory for relevant information
- `/remember add <entity>` - Add a new entity to memory
- `/remember note <observation>` - Add observation to existing entity
- `/remember forget <entity>` - Remove an entity from memory
- `/remember clear` - Clear all memory (with confirmation)

## Commands

### View Memory

```
/remember
```

Runs `aim_read_graph()` and displays all entities, relations, and observations in a readable format.

### Search Memory

```
/remember search authentication
/remember search "home assistant dashboard"
```

Runs `aim_search_nodes(query)` to find relevant stored knowledge.

### Add Entity

```
/remember add auth-service
```

Interactive: Will ask for entity type and initial observations, then run:

```
aim_create_entities([{
  "name": "auth-service",
  "entityType": "[prompted]",
  "observations": ["[prompted observations]"]
}])
```

### Add Observation

```
/remember note auth-service "Added rate limiting to login endpoint"
```

Adds observation to existing entity:

```
aim_add_observations([{
  "entityName": "auth-service",
  "contents": ["Added rate limiting to login endpoint"]
}])
```

### Link Entities

```
/remember link auth-service api-gateway "authenticates"
```

Creates relation:

```
aim_create_relations([{
  "from": "auth-service",
  "to": "api-gateway",
  "relationType": "authenticates"
}])
```

### Remove Entity

```
/remember forget old-component
```

Removes entity (with confirmation):

```
aim_delete_entities(["old-component"])
```

### Clear All Memory

```
/remember clear
```

**Requires confirmation** - removes all entities, relations, and observations.

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

*Memory persists across sessions in `.aim/` directory*
