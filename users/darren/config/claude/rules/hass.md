---
paths:
  - "**/*hass*"
  - "**/*home-assistant*"
  - "**/automations*"
  - "**/dashboard*"
---

# Home Assistant Rules

## Automations

- Use meaningful automation IDs
- Add descriptions for clarity
- Prefer `choose` over multiple automations
- Use `variables` for reusable values
- Test with `developer-tools/template`

## Dashboards

- Use YAML mode for version control
- Organize with views by room/function
- Use `!include` for large configs
- Prefer semantic entity naming

## Templates

- Always handle unavailable states
- Use `default` filters
- Avoid complex logic in templates

## MCP Tools Available

- `list_entities(domain)` - Get entities by domain
- `get_entity(entity_id)` - Get entity state/attributes
- `search_entities_tool(query)` - Find entities
- `domain_summary_tool(domain)` - Overview of domain
