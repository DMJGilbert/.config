# Home Assistant Module

Declarative Home Assistant configuration for NixOS with automations and Lovelace dashboards.

## Structure

```
modules/home-assistant/
├── automations.nix   # Automation definitions
├── components.nix    # Integrations and custom components
├── dashboard.nix     # Nix wrapper for dashboard config
├── dashboard.yaml    # Lovelace dashboard YAML config
├── floorplan.svg     # SVG floorplan for picture-elements
└── README.md
```

## Files

| File | Purpose |
|------|---------|
| `automations.nix` | Motion-activated lights, notifications, scene triggers |
| `components.nix` | Integrations (Zigbee, Matter, etc.) and custom Lovelace cards |
| `dashboard.nix` | Nix module that includes the YAML dashboard |
| `dashboard.yaml` | Main Lovelace dashboard configuration |
| `floorplan.svg` | SVG floorplan for interactive floor map |

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

| Card | Package | Description |
|------|---------|-------------|
| Bubble Card | `hass-bubble-card` | Floating action buttons |
| Layout Card | `lovelace-layout-card` | Grid-based layouts |
| Auto Entities | `lovelace-auto-entities` | Dynamic entity lists |
| Tabbed Card | `lovelace-tabbed-card` | Tabbed card containers |
| Catppuccin Theme | `hass-catppuccin` | Catppuccin color theme |

To add a new card, see [overlays/README.md](../../overlays/README.md).

## Dashboard Style Guide

### Design System

The dashboard follows a modern, clean design with consistent styling.

#### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Orange | `#E85D04` | Headings, accents, dividers |
| Text Dark | `#333333` | Primary text on light backgrounds |
| Background Light | `rgba(255,255,255,0.95)` | Chip backgrounds, cards |
| Shadow | `rgba(0,0,0,0.1-0.15)` | Card shadows, chip shadows |

#### Typography

| Element | Size | Weight |
|---------|------|--------|
| Page Title | `2.5rem` | 600 |
| Card Title | `1.25rem` | 500 |
| Body Text | `14px` | 400 |
| Chip Text | `14px` | 500 |

#### Spacing & Layout

| Property | Value |
|----------|-------|
| Card Border Radius | `24px` |
| Chip Border Radius | `24px` |
| Card Margin | `16px` |
| Card Padding | `16px-24px` |
| Content Gap | `8px` |

### Required Custom Cards (HACS)

The dashboard requires these custom cards installed via HACS:

| Card | Repository | Purpose |
|------|------------|---------|
| `button-card` | `custom-cards/button-card` | Custom styled buttons and cards |
| `mushroom` | `piitaya/lovelace-mushroom` | Modern chip and entity cards |
| `stack-in-card` | `custom-cards/stack-in-card` | Combine cards without borders |
| `card-mod` | `thomasloven/lovelace-card-mod` | Custom CSS styling |
| `auto-entities` | `thomasloven/lovelace-auto-entities` | Dynamic entity lists |
| `browser-mod` | `thomasloven/hass-browser_mod` | Popups and browser control |

### Dashboard Components

#### Header Card

The header displays the home title with an orange accent.

```yaml
- type: custom:button-card
  name: Fleming Place
  show_icon: false
  show_state: false
  styles:
    card:
      - background: transparent
      - box-shadow: none
      - padding: 24px 16px 0 16px
    name:
      - font-size: 2.5rem
      - font-weight: 600
      - color: "#E85D04"
      - justify-self: start
      - padding-bottom: 16px
      - border-bottom: 3px solid #E85D04
      - width: 100%
```

#### Hero Image with Status Chips

A hero image with overlaid status chips showing active devices.

**Required Template Sensors:**
- `sensor.total_turned_on_lights_count_template` - Count of lights that are on
- `sensor.total_media_players_playing_template` - Count of media players playing
- `sensor.total_active_motion_sensors_count_template` - Count of motion sensors detecting motion

**Chip Behavior:**
- Chips automatically hide when count is 0
- Tap on chip opens popup with list of active entities
- Uses `browser_mod.popup` for interactive popups

**Popup Configuration:**
```yaml
tap_action:
  action: fire-dom-event
  browser_mod:
    service: browser_mod.popup
    data:
      title: Active Lights
      content:
        type: custom:auto-entities
        card:
          type: entities
        filter:
          include:
            - domain: light
              state: "on"
        sort:
          method: friendly_name
```

### Helper Sensors Setup

Create these template sensors in Home Assistant for the dashboard:

```yaml
# configuration.yaml or templates.yaml
template:
  - sensor:
      - name: "Total Turned On Lights Count Template"
        state: >
          {{ states.light | selectattr('state', 'eq', 'on') | list | count }}

      - name: "Total Media Players Playing Template"
        state: >
          {{ states.media_player | selectattr('state', 'eq', 'playing') | list | count }}

      - name: "Total Active Motion Sensors Count Template"
        state: >
          {{ states.binary_sensor
             | selectattr('attributes.device_class', 'defined')
             | selectattr('attributes.device_class', 'eq', 'motion')
             | selectattr('state', 'eq', 'on')
             | list | count }}
```

## Service Management

```bash
# View logs
journalctl -u home-assistant -f

# Restart
systemctl restart home-assistant

# Status
systemctl status home-assistant
```
