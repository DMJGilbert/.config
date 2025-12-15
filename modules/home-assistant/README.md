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

The dashboard follows a modern, clean design with consistent styling and responsive layout.

#### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Orange | `#E85D04` | Page title, accents |
| Text Dark | `#333333` | Primary text on light backgrounds |
| Chip Background | `rgba(255,255,255,0.95)` | Status chip backgrounds |
| Card Shadow | `rgba(0,0,0,0.1)` | Subtle card elevation |
| Chip Shadow | `rgba(0,0,0,0.15)` | Chip elevation |
| Amber | `amber` | Lights chip icon |
| Blue | `blue` | Media chip icon |
| Green | `green` | Motion chip icon |

#### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Page Title | Helvetica Neue | 30px | 500 |
| Card Title | System | 1.25rem | 500 |
| Body Text | System | 14px | 400 |
| Chip Text | System | 14px | 500 |

#### Spacing & Layout

| Property | Value |
|----------|-------|
| Card Border Radius | `24px` |
| Chip Border Radius | `24px` |
| Card Margin | `16px` (phone), `0` (tablet+) |
| Card Padding | `16px-24px` |
| Content Gap | `8px` |

#### Responsive Breakpoints

| Breakpoint | Max Width | Hero Height |
|------------|-----------|-------------|
| Phone (default) | 600px | 200px |
| Tablet (768px+) | 800px | 240px |
| Desktop (1200px+) | 1200px | 280px |

### Required Custom Cards

The dashboard requires these custom cards (installed via Nix overlays):

| Card | Package | Purpose |
|------|---------|---------|
| `button-card` | `button-card` | Custom styled buttons and title |
| `mushroom` | `mushroom` | Status chips with conditional visibility |
| `stack-in-card` | `lovelace-stack-in-card` | Combine hero image with chips overlay |
| `card-mod` | `card-mod` | Custom CSS styling and media queries |
| `auto-entities` | `lovelace-auto-entities` | Dynamic entity lists in popups |
| `bubble-card` | `hass-bubble-card` | Slide-up popup cards |
| `layout-card` | `lovelace-layout-card` | Responsive grid layout |
| `tabbed-card` | `lovelace-tabbed-card` | Tabbed card containers |

---

## Dashboard Components

### 1. Responsive Layout

The view uses `layout-card` with `grid-layout` for responsive behavior:

```yaml
type: custom:layout-card
layout_type: custom:grid-layout
layout:
  grid-template-columns: 1fr
  max_width: 600px
  margin: 0 auto
  mediaquery:
    "(min-width: 768px)":
      grid-template-columns: 1fr
      max_width: 800px
    "(min-width: 1200px)":
      grid-template-columns: 1fr
      max_width: 1200px
```

**Behavior:**
- Single column layout at all breakpoints
- Content centered with `margin: 0 auto`
- Max width scales up on larger screens

---

### 2. Hero Image with Title Overlay and Status Chips

A hero image card with overlaid title and status chips. The title is positioned over the image with a dark gradient overlay for readability, saving vertical space.

#### Structure

```
┌─────────────────────────────────────┐
│ Fleming Place                       │
│                                     │
│           Hero Image                │
│      (dark gradient overlay)        │
│      ┌─────┐ ┌─────┐ ┌─────┐       │
│      │ 💡 5│ │ 📺 2│ │ 🏃 1│       │
│      └─────┘ └─────┘ └─────┘       │
└─────────────────────────────────────┘
```

#### Complete Code

```yaml
- type: custom:stack-in-card
  mode: vertical
  card_mod:
    style:
      hui-vertical-stack-card $: |
        #root { row-gap: 0px !important; }
      .: |
        :host { row-gap: 0px; }
        ha-card {
          border-radius: 24px;
          margin: 16px 16px 16px 16px;
          box-shadow: 0 4px 24px rgba(0,0,0,0.15);
          overflow: hidden;
          background: var(--card-background-color, #fff);
        }
        @media (min-width: 768px) {
          ha-card { margin: 16px 0 16px 0; }
        }
  cards:
    # Hero Image with Dark Overlay and Title
    - type: custom:button-card
      name: Fleming Place
      show_icon: false
      show_state: false
      tap_action:
        action: none
      card_mod:
        style: |
          ha-card {
            height: 200px !important;
            border-radius: 0;
            box-shadow: none;
            margin-bottom: 8px;
            background-image: linear-gradient(to bottom, rgba(0,0,0,0.4) 0%, rgba(0,0,0,0.2) 40%, rgba(0,0,0,0.1) 60%, rgba(0,0,0,0.3) 100%), url("https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=1200&h=600&fit=crop") !important;
            background-size: cover !important;
            background-position: center !important;
          }
          @media (min-width: 768px) {
            ha-card { height: 240px !important; }
          }
          @media (min-width: 1200px) {
            ha-card { height: 280px !important; }
          }
      styles:
        card:
          - height: 100%
          - border-radius: 0
        name:
          - font-family: "'Helvetica Neue', Helvetica, Arial, sans-serif"
          - font-size: 36px
          - font-weight: 500
          - color: "#E85D04"
          - text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5)
          - position: absolute
          - top: 24px
          - left: 24px
          - letter-spacing: -0.5px

    # Status Chips Container
    - type: custom:mushroom-chips-card
      card_mod:
        style: |
          ha-card {
            --chip-background: rgba(255,255,255,0.95);
            --chip-box-shadow: 0 2px 8px rgba(0,0,0,0.15);
            --chip-border-radius: 24px;
            --chip-padding: 0 12px;
            --chip-height: 36px;
            background: transparent;
            margin-top: -50px;
            position: relative;
            z-index: 1;
          }
      alignment: center
      chips:
        # Lights Chip
        - type: conditional
          conditions:
            - entity: sensor.total_turned_on_lights_count_template
              state_not: "0"
          chip:
            type: template
            entity: sensor.total_turned_on_lights_count_template
            icon: mdi:lightbulb
            icon_color: amber
            content: "{{ states('sensor.total_turned_on_lights_count_template') }}"
            tap_action:
              action: navigate
              navigation_path: "#lights-popup"

        # Media Players Chip
        - type: conditional
          conditions:
            - entity: sensor.total_media_players_playing_template
              state_not: "0"
          chip:
            type: template
            entity: sensor.total_media_players_playing_template
            icon: mdi:television
            icon_color: blue
            content: "{{ states('sensor.total_media_players_playing_template') }}"
            tap_action:
              action: navigate
              navigation_path: "#media-popup"

        # Motion Sensors Chip
        - type: conditional
          conditions:
            - entity: sensor.total_active_motion_sensors_count_template
              state_not: "0"
          chip:
            type: template
            entity: sensor.total_active_motion_sensors_count_template
            icon: mdi:run
            icon_color: green
            content: "{{ states('sensor.total_active_motion_sensors_count_template') }}"
            tap_action:
              action: navigate
              navigation_path: "#motion-popup"
```

**Design Decisions:**
- Title integrated into hero image to save vertical space
- Dark gradient overlay (40% top, 20-10% middle, 30% bottom) ensures title readability
- Orange (#E85D04) title text maintains brand consistency with darker text-shadow for contrast
- 36px font size (increased from 30px) for better visibility over image
- `stack-in-card` merges image and chips into seamless card
- Chips use negative margin (-50px) to overlay on image
- Conditional visibility hides chips when count is 0
- Frosted glass effect on chips (white background with shadow)
- Responsive image height scales with screen size
- Background image defined in `card_mod` (not `styles.card`) with `!important` to prevent resets on re-render
- No entity binding on hero card to avoid unnecessary re-renders

#### Removing Default Gap in stack-in-card

By default, `stack-in-card` adds `row-gap: 8px` between child cards via `hui-vertical-stack-card`. To remove this gap, use card_mod's shadow DOM piercing syntax (`$`):

```yaml
- type: custom:stack-in-card
  mode: vertical
  card_mod:
    style:
      hui-vertical-stack-card $: |
        #root { row-gap: 0px !important; }
      .: |
        ha-card {
          /* your ha-card styles here */
        }
```

**How it works:**
- `hui-vertical-stack-card $:` pierces into the shadow DOM of the internal vertical stack component
- `#root` is the container element that applies the default `row-gap`
- `.` targets the host element for regular ha-card styling

---

### 4. Tabbed Section

A tabbed navigation section allowing users to switch between different content areas: Rooms, Peoples, Calendar, and Other.

#### Structure

```
┌─────────────────────────────────────────────────────────┐
│  Rooms    Peoples    Calendar    Other                  │
│  ─────                                                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│           [Tab Content Area]                            │
│                                                         │
╰─────────────────────────────────────────────────────────╯
```

#### Complete Code

```yaml
- type: custom:tabbed-card
  card_mod:
    style: |
      ha-card {
        margin: 0 16px 16px 16px;
        border-radius: 24px;
        box-shadow: 0 4px 24px rgba(0,0,0,0.15);
        overflow: hidden;
        background: var(--card-background-color, #fff);
      }
      @media (min-width: 768px) {
        ha-card { margin: 0 0 16px 0; }
      }
  styles:
    --mdc-theme-primary: "#E85D04"
    --mdc-tab-text-label-color-default: var(--secondary-text-color)
  options:
    defaultTabIndex: 0
  tabs:
    - attributes:
        label: Rooms
      card:
        type: vertical-stack
        cards:
          # Room cards go here
    - attributes:
        label: Peoples
      card:
        type: vertical-stack
        cards:
          # Person tracking cards go here
    - attributes:
        label: Calendar
      card:
        type: vertical-stack
        cards:
          # Calendar views go here
    - attributes:
        label: Other
      card:
        type: vertical-stack
        cards:
          # Miscellaneous controls go here
```

**Design Decisions:**
- Uses `custom:tabbed-card` for tab navigation
- Orange (`#E85D04`) active tab indicator to match brand color
- Secondary text color for inactive tabs
- Card styling matches hero card (24px radius, shadow, responsive margins)
- Each tab contains a `vertical-stack` for flexible content

**Tab Contents (Planned):**
| Tab | Content |
|-----|---------|
| Rooms | Room cards with thumbnails, status indicators |
| Peoples | Person presence tracking, device trackers |
| Calendar | Calendar events, schedules |
| Other | Miscellaneous controls, settings |

---

### 5. Room Cards

Pill-shaped cards displaying room information with circular images, motion status, and device icons.

#### Structure

```
╭──────────────────────────────────────────────────────────────╮
│ ┌──────┐                                                     │
│ │      │  Living Room                      📺  💡            │
│ │ 📷   │  Clear - 5m ago                                    │
│ └──────┘                                                     │
╰──────────────────────────────────────────────────────────────╯
   80px      Room Name (16px bold)           TV  Light
  circular   Status (13px secondary)         icons
   image
```

#### Template Definition

The `room_card` template is defined in `dashboard.yaml`:

```yaml
room_card:
  show_icon: false
  show_name: false
  show_state: false
  card_mod:
    style: |
      ha-card {
        background: #ffffff !important;
        border-radius: 50px !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.12) !important;
        border: none !important;
      }
      :host-context(html.darkmode) ha-card,
      :host-context(html[data-theme="dark"]) ha-card {
        background: #1c1c1e !important;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3) !important;
      }
  styles:
    card:
      - padding: 0 20px 0 0
      - margin-bottom: 12px
      - height: 80px
    grid:
      - grid-template-areas: '"room_image room_info device_icons"'
      - grid-template-columns: 80px 1fr auto
      - grid-template-rows: 1fr
      - align-items: center
```

#### Variables

| Variable | Type | Required | Description | Example |
|----------|------|----------|-------------|---------|
| `room_name` | string | Yes | Display name | `"Living Room"` |
| `room_icon` | string | No | Fallback MDI icon | `"mdi:sofa"` |
| `room_image` | string | No | Unsplash/image URL | `"https://images.unsplash.com/..."` |
| `light_entity` | entity_id | Yes | Light group | `"group.living_room_lights"` |
| `motion_entity` | entity_id | No | Motion sensor | `"binary_sensor.living_room_motion"` |
| `media_entity` | entity_id | No | Media player | `"media_player.living_room_tv"` |

#### Usage Example

```yaml
- type: custom:button-card
  template: room_card
  variables:
    room_name: Living Room
    room_icon: mdi:sofa
    room_image: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&h=200&fit=crop"
    light_entity: group.living_room_lights
    motion_entity: binary_sensor.living_room_motion_sensor_occupancy
    media_entity: media_player.living_room_tv
```

#### Configured Rooms

| Room | Icon | Image | Light Group | Motion Sensor | Media Player |
|------|------|-------|-------------|---------------|--------------|
| Living Room | mdi:sofa | Unsplash interior | group.living_room_lights | living_room_motion_sensor_occupancy | living_room_tv |
| Bedroom | mdi:bed | Unsplash bedroom | group.bedroom_lights | bedroom_motion_sensor_occupancy | apple_tv |
| Kitchen | mdi:silverware-fork-knife | Unsplash kitchen | group.kitchen_lights | - | - |
| Bathroom | mdi:shower | Unsplash bathroom | group.bathroom_lights | motion_sensor_motion | - |
| Hallway | mdi:door | Unsplash hallway | group.hallway_lights | hallway_motion_sensor_occupancy | - |
| Robynne's Room | mdi:teddy-bear | Unsplash nursery | group.robynne_lights | aarlo_motion_nursery | yoto_player |

#### Motion Status Display

| Sensor State | Display | Color |
|--------------|---------|-------|
| `on` | "Motion detected" | Green (#4CAF50) |
| `off` | "Clear - Xm ago" | Secondary text |
| `unavailable` | "Sensor unavailable" | Secondary text |
| `null` | "No motion sensor" | Secondary text |

Time format: `Xs ago`, `Xm ago`, `Xh ago`, `Xd ago`

#### Device Icons

Icons appear in order: **TV first, then lightbulb**

| Icon | Entity State | Color |
|------|--------------|-------|
| mdi:television | playing/on | Dark (#1a1a1a) |
| mdi:television | off | Light (#d1d1d1) |
| mdi:lightbulb | on | Dark (#1a1a1a) |
| mdi:lightbulb | off | Light (#d1d1d1) |

#### Design Specifications

| Property | Value |
|----------|-------|
| Card height | 80px |
| Border radius | 50px (pill shape) |
| Image size | 80px circular |
| Shadow | 0 2px 8px rgba(0,0,0,0.12) |
| Dark mode background | #1c1c1e |
| Light mode background | #ffffff |
| Room name font | 16px, weight 600 |
| Status font | 13px, secondary color |
| Icon size | 28px |
| Icon spacing | 16px between icons |

#### Tap Action

Tapping a room card opens the more-info dialog for the light group entity.

---

### 6. Popup Cards (Bubble Card)

Each chip opens a slide-up popup showing active entities.

```yaml
# Lights Popup
- type: vertical-stack
  cards:
    - type: custom:bubble-card
      card_type: pop-up
      hash: "#lights-popup"
      name: Active Lights
      icon: mdi:lightbulb
      styles: |
        .bubble-pop-up-container {
          background: var(--card-background-color);
        }
    - type: custom:auto-entities
      card:
        type: entities
        title: Lights On
      filter:
        include:
          - domain: light
            state: "on"
      sort:
        method: friendly_name
```

**Popup Hashes:**
| Chip | Hash | Filter |
|------|------|--------|
| Lights | `#lights-popup` | `domain: light, state: "on"` |
| Media | `#media-popup` | `domain: media_player, state: playing` |
| Motion | `#motion-popup` | `domain: binary_sensor, device_class: motion/occupancy, state: "on"` |

**How it works:**
1. Chip tap action navigates to hash (e.g., `#lights-popup`)
2. Bubble-card listens for hash and slides up popup
3. `auto-entities` dynamically lists matching entities
4. Popup dismisses when tapping outside or swiping down

---

### 7. Info Lines (Weather, Calendar, Liverpool)

Three text lines grouped with the hero image, displaying weather, calendar, and Liverpool FC fixture information. All elements share a single card with rounded corners and drop shadow.

#### Structure

```
┌─────────────────────────────────────────────────────────┐
│ Fleming Place                                           │
└─────────────────────────────────────────────────────────┘
╭─────────────────────────────────────────────────────────╮
│                    [Hero Image]                         │
│                  [Status Chips]                         │
│─────────────────────────────────────────────────────────│
│ ☁️  Cloudy (82% humidity, 11.3°C)                      │
│ 📅 Work holiday: Now                                    │
│ ⚽ Tottenham Hotspur v Liverpool: Saturday 17:30       │
╰─────────────────────────────────────────────────────────╯
        ↑ Grouped card with 24px radius + drop shadow
```

**Icons:** Each line has an 18px icon with 8px right margin
**Bold text:** Condition, event name, and matchup are bold

#### Weather Line

Displays current weather with dynamic icon in format: `[icon] **Condition** (humidity%, temp°C)`

**Entity:** `weather.forecast_home`

**Output Examples:**
- `☁️ **Cloudy** (82% humidity, 11.3°C)`
- `⛅ **Partly Cloudy** (65% humidity, 18.5°C)`
- `☀️ **Sunny** (45% humidity, 24.0°C)`

**Weather Icon Mapping:**
| Condition | Icon |
|-----------|------|
| sunny | mdi:weather-sunny |
| cloudy | mdi:weather-cloudy |
| partlycloudy | mdi:weather-partly-cloudy |
| rainy | mdi:weather-rainy |
| pouring | mdi:weather-pouring |
| snowy | mdi:weather-snowy |
| fog | mdi:weather-fog |
| lightning | mdi:weather-lightning |

#### Calendar Line

Shows the next upcoming event with countdown in format: `📅 **Event**: X days Y hours`

**Icon:** `mdi:calendar`

**Data Sources:**
- `calendar.family`
- `calendar.events`
- `calendar.calendar`
- `calendar.home`

**Output Examples:**
- `📅 **Ballet**: 2 days 4 hours`
- `📅 **Work holiday**: Now`
- `📅 **Doctor appointment**: 1 day`
- `📅 No upcoming events`

**Countdown Logic:**
- Scans all calendars to find earliest event
- Shows "Now" for current/past events
- Shows hours only if less than 1 day
- Shows days and hours combined otherwise

#### Liverpool Line

Displays next fixture in format: `⚽ **HomeTeam v AwayTeam**: Day HH:MM`

**Icon:** `mdi:soccer`

**Data Sources:**
- `sensor.liverpool` (Premier League)
- `sensor.liverpool_cl` (Champions League)
- `sensor.liverpool_fa` (FA Cup)
- `sensor.liverpool_lc` (League Cup)

**Output Examples:**
- `⚽ **Liverpool v Tottenham Hotspur**: Saturday 17:30` (home game)
- `⚽ **Manchester City v Liverpool**: Sunday 16:30` (away game)
- `⚽ No upcoming fixtures`

**Features:**
- Combines all competition sensors to find next match
- Always uses "v" format with home team first
- Shows full opponent name
- Displays day of week and kickoff time

#### Complete Code

```yaml
- type: custom:button-card
  entity: weather.forecast_home
  show_name: false
  show_state: false
  show_icon: false
  triggers_update:
    - weather.forecast_home
    - calendar.family
    - calendar.events
    - calendar.calendar
    - calendar.home
    - sensor.liverpool
    - sensor.liverpool_cl
    - sensor.liverpool_fa
    - sensor.liverpool_lc
  styles:
    card:
      - background: transparent
      - box-shadow: none
      - border: none
      - padding: 0 16px 16px 16px
    grid:
      - grid-template-areas: '"weather" "calendar" "liverpool"'
      - grid-template-columns: 1fr
      - grid-template-rows: auto auto auto
      - gap: 4px
    custom_fields:
      weather:
        - font-size: 14px
        - color: "var(--secondary-text-color)"
        - text-align: left
      # calendar and liverpool styles identical
  custom_fields:
    weather: |
      [[[
        // JavaScript template for weather formatting
      ]]]
    calendar: |
      [[[
        // JavaScript template for calendar countdown
      ]]]
    liverpool: |
      [[[
        // JavaScript template for fixture info
      ]]]
```

**Design Decisions:**
- Info lines grouped with hero image in single `stack-in-card`
- Shared container with 24px rounded corners and drop shadow
- Card background: `var(--card-background-color, #fff)`
- Drop shadow: `0 4px 24px rgba(0,0,0,0.15)`
- 18px icons with 8px right margin for visual hierarchy
- Key information (condition, event, matchup) in bold `<b>` tags
- 14px secondary text color for subtle appearance
- 6px gap between lines, 16px padding
- Uses `triggers_update` to react to all data sources

---

### 8. Required Template Sensors

These sensors power the status chips. Defined in `rubecula.nix`:

```yaml
template:
  - sensor:
      name: "Total Turned On Lights Count Template"
      state: >
        {{ states.light
           | rejectattr('attributes.entity_id', 'defined')
           | selectattr('state', 'eq', 'on')
           | list | count }}

  - sensor:
      name: "Total Media Players Playing Template"
      state: >
        {{ states.media_player
           | selectattr('state', 'eq', 'playing')
           | list | count }}

  - sensor:
      name: "Total Active Motion Sensors Count Template"
      state: >
        {{ states.binary_sensor
           | selectattr('attributes.device_class', 'eq', 'motion')
           | selectattr('state', 'eq', 'on')
           | list | count
           + states.binary_sensor
           | selectattr('attributes.device_class', 'eq', 'occupancy')
           | selectattr('state', 'eq', 'on')
           | list | count }}
```

**Entity IDs:**
- `sensor.total_turned_on_lights_count_template`
- `sensor.total_media_players_playing_template`
- `sensor.total_active_motion_sensors_count_template`

---

### Component Dependency Graph

```
┌─────────────────────────────────────────────────────────┐
│                    layout-card                          │
│                  (responsive grid)                      │
└─────────────────────────────────────────────────────────┘
                          │
     ┌────────────────────┼────────────────────┐
     ▼                    ▼                    ▼
┌─────────────┐    ┌─────────────┐      ┌─────────────┐
│ button-card │    │stack-in-card│      │ bubble-card │
│   (title)   │    │ (hero+chips)│      │  (popups)   │
└─────────────┘    └─────────────┘      └─────────────┘
                          │                    │
                   ┌──────┴──────┐             │
                   ▼             ▼             ▼
            ┌──────────┐  ┌──────────┐  ┌──────────┐
            │ picture  │  │ mushroom │  │  auto-   │
            │  card    │  │  chips   │  │ entities │
            └──────────┘  └──────────┘  └──────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │  template   │
                        │  sensors    │
                        └─────────────┘

┌─────────────────────────────────────────────────────────┐
│              button-card (info lines)                   │
│         vertically stacked custom_fields                │
└─────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
   │   weather   │ │  calendar   │ │  liverpool  │
   │custom_field │ │custom_field │ │custom_field │
   └─────────────┘ └─────────────┘ └─────────────┘
          │               │               │
          ▼               ▼               ▼
   ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
   │   weather.  │ │  calendar.  │ │   sensor.   │
   │forecast_home│ │   family    │ │  liverpool  │
   └─────────────┘ │   events    │ │ liverpool_cl│
                   │   calendar  │ │ liverpool_fa│
                   │   home      │ │ liverpool_lc│
                   └─────────────┘ └─────────────┘
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
