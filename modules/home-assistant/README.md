# Home Assistant Module

Declarative Home Assistant configuration for NixOS with automations and Lovelace dashboards.

## Structure

```
modules/home-assistant/
├── automations.nix   # Automation definitions
├── components.nix    # Integrations and custom components
├── dashboard.nix     # Lovelace dashboard layout
└── README.md
```

## Files

| File              | Purpose                                                       |
| ----------------- | ------------------------------------------------------------- |
| `automations.nix` | Motion-activated lights, notifications, scene triggers        |
| `components.nix`  | Integrations (Zigbee, Matter, etc.) and custom Lovelace cards |
| `dashboard.nix`   | Lovelace views, cards, and layout                             |

## Adding Automations

Edit `automations.nix`. Use the helper function for motion-activated lights:

```nix
mkMotionLightAutomation {
  alias = "Kitchen Motion Light";
  motion_sensor = "binary_sensor.kitchen_motion";
  target.area_id = ["kitchen"];
  brightness_pct = 80;
  delay_seconds = 120;
  time_condition = {
    after = "18:00:00";
    before = "23:00:00";
  };
}
```

Or create a custom automation:

```nix
{
  alias = "My Automation";
  trigger = [{
    platform = "state";
    entity_id = "sensor.example";
    to = "on";
  }];
  action = [{
    service = "light.turn_on";
    target.entity_id = "light.example";
  }];
}
```

## Customizing Dashboard

Edit `dashboard.nix`. The dashboard uses Mushroom cards.

**Add a card to a view:**

```nix
{
  type = "custom:mushroom-entity-card";
  entity = "sensor.temperature";
  name = "Temperature";
  icon = "mdi:thermometer";
}
```

**Add a new view (tab):**

```nix
{
  title = "My View";
  path = "my-view";
  cards = [
    # cards here
  ];
}
```

## Custom Cards

Custom Lovelace cards are defined in `overlays/` and referenced in `components.nix`:

| Card             | Package                  | Description             |
| ---------------- | ------------------------ | ----------------------- |
| Bubble Card      | `hass-bubble-card`       | Floating action buttons |
| Layout Card      | `lovelace-layout-card`   | Grid-based layouts      |
| Auto Entities    | `lovelace-auto-entities` | Dynamic entity lists    |
| Tabbed Card      | `lovelace-tabbed-card`   | Tabbed card containers  |
| Catppuccin Theme | `hass-catppuccin`        | Catppuccin color theme  |

To add a new card, see [overlays/README.md](../../overlays/README.md).

## Service Management

```bash
# View logs
journalctl -u home-assistant -f

# Restart
systemctl restart home-assistant

# Status
systemctl status home-assistant
```
