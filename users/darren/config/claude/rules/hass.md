---
paths:
  - "**/home-assistant/**/*.{nix,yaml,yml}"
  - "**/configuration.yaml"
  - "**/automations.{yaml,yml,nix}"
  - "**/scripts.yaml"
  - "**/scenes.yaml"
  - "**/dashboard.{yaml,yml}"
  - "**/views/*.{yaml,yml}"
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

## Security

- Never hardcode tokens, passwords, or API keys in YAML — use `secrets.yaml` with `!secret` references
- Restrict external network exposure; disable unused integrations and cloud-relay features
- Use fine-grained, short-lived tokens for integrations rather than long-lived admin tokens
- Audit automations that call scripts or shell commands for injection vectors in templated values

## Validation

1. `hass --script check_config -c <config-dir>` — validates YAML, integrations, templates
2. Reload the affected integration via `developer-tools/yaml` rather than full restart when possible
3. After deploy, verify the entity exists: `mcp__hass-mcp__get_entity` or HA Dev Tools → States
4. For automations, trace the run via Settings → Automations & Scenes → trace UI

## MCP Tools Available

- `list_entities(domain)` - Get entities by domain
- `get_entity(entity_id)` - Get entity state/attributes
- `search_entities_tool(query)` - Find entities
- `domain_summary_tool(domain)` - Overview of domain
