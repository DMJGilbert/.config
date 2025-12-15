# Home Dashboard Redesign Specification

## Executive Summary

This document provides a comprehensive redesign specification for the Home Assistant home dashboard. The current design suffers from dense icon-only navigation, compact layouts that lack visual hierarchy, and cryptic status indicators. This redesign prioritizes **room status/climate** and **quick controls** while ensuring responsive design across mobile, tablet, and wall-mounted displays.

---

## Current State Analysis

### Problems Identified

| Issue | Impact | Severity |
|-------|--------|----------|
| **12+ navigation icons** with no labels | Users can't distinguish tabs without memorization | High |
| **Cryptic chip labels** ("D", "L", "0") | Status meaning unclear without context | High |
| **Flat visual hierarchy** | Everything competes for attention equally | Medium |
| **Dense 2-column room grid** | Information cramped on mobile devices | Medium |
| **Icon-only quick actions** | Users unsure what tapping will do | High |
| **No visual grouping** | Related information scattered | Medium |
| **Low contrast chips** | Hard to read status at a glance | Medium |

### Current Component Inventory

- **Header chips**: Weather, presence (D/L), lights count, temperature
- **Quick actions**: All off, party mode, movie scene, all on, vacuum
- **Room cards**: 6 rooms in 2-column grid with horizontal layout
- **Status chips**: Energy (0.3p), car (%), outdoor temp
- **Conditional**: Football match card, active media

---

## Design Principles

### 1. Progressive Disclosure
Show essential information first; details on demand via tap/expansion.

### 2. Scannable Hierarchy
Users should understand home state in < 2 seconds of glancing.

### 3. Touch-Optimized
Minimum 44×44pt touch targets; generous spacing for fat-finger friendliness.

### 4. Consistent Visual Language
Icons always paired with labels for actions; status uses color + text.

### 5. Responsive Adaptation
Mobile: single column | Tablet: 2-3 columns | Wall display: 4+ columns with larger type

---

## Information Architecture

### Priority Levels

```
┌─────────────────────────────────────────────────────────────┐
│  P1: CRITICAL (Always Visible)                              │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ • Who's home (presence)                                 ││
│  │ • Current weather/outdoor conditions                    ││
│  │ • Security status (away mode active?)                   ││
│  │ • Active alerts (motion while away, low battery)        ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  P2: PRIMARY (Main Dashboard Content)                       │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ • Room cards with temperature + active devices          ││
│  │ • Quick scene controls (movie, all off, etc.)           ││
│  │ • Active media players                                  ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  P3: SECONDARY (Contextual/On-Demand)                       │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ • Upcoming events (football matches)                    ││
│  │ • Energy rates                                          ││
│  │ • Vehicle status                                        ││
│  │ • System health                                         ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## Navigation Redesign

### Current Navigation (Problems)

```
┌──────────────────────────────────────────────────────────────┐
│ ☰ 🏠 📊 🛋️ 🛏️ 🚿 🍴 📱 🎛️ 🚗 🐟 ⚡ ⚙️ ⋮                         │
└──────────────────────────────────────────────────────────────┘
        ↑ 12 icons with no labels - impossible to distinguish
```

### Proposed Navigation

**Option A: Bottom Tab Bar (Mobile-First)**

```
┌──────────────────────────────────────────────────────────────┐
│                    [DASHBOARD CONTENT]                        │
│                                                              │
├──────────────────────────────────────────────────────────────┤
│   🏠        📍        🔌        🚗        ⋮                  │
│  Home    Rooms     Energy     Car      More                 │
└──────────────────────────────────────────────────────────────┘
```

- **Home**: Main dashboard (current home view, condensed)
- **Rooms**: Scrollable room selector → individual room views
- **Energy**: Power consumption and rates
- **Car**: Vehicle status
- **More**: System, Fish, Settings (overflow menu)

**Option B: Collapsed Sidebar (Tablet/Desktop)**

```
┌────┬───────────────────────────────────────────────────────┐
│ 🏠 │                                                       │
│Home│                                                       │
│────│              [DASHBOARD CONTENT]                      │
│ 🛋️ │                                                       │
│ 🛏️ │                                                       │
│ 🚿 │                                                       │
│ 🍴 │                                                       │
│ 🚶 │                                                       │
│ 👧 │                                                       │
│────│                                                       │
│ 🚗 │                                                       │
│ ⚡ │                                                       │
│ ⚙️ │                                                       │
└────┴───────────────────────────────────────────────────────┘
```

**Recommendation**: Use **Bubble Card's pop-up navigation** pattern with a floating action button for room quick-access.

---

## Home View Redesign

### Layout Structure

```
┌─────────────────────────────────────────────────────────────┐
│  HEADER: Status Bar                                         │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ☀️ 10°C Partly Cloudy    │    🏠 Darren, Lorraine home  ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  SECTION: Quick Actions (Scene Controls)                    │
│  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐   │
│  │    ⭕     │ │    🎬     │ │    🎉     │ │    💡     │   │
│  │  All Off  │ │   Movie   │ │   Party   │ │  All On   │   │
│  └───────────┘ └───────────┘ └───────────┘ └───────────┘   │
├─────────────────────────────────────────────────────────────┤
│  SECTION: Rooms                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  🛋️ Living Room                              23°C  🔵   ││
│  │  ├─ 2 lights on · Motion 3m ago                        ││
│  │  └─ [TV Playing: Netflix]                    ▶️        ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  🛏️ Bedroom                                  --°C  ⚫   ││
│  │  └─ All off · Last motion 45m ago                      ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  🚿 Bathroom                                 30°C  🔵   ││
│  │  └─ 61% humidity · Motion detected                     ││
│  └─────────────────────────────────────────────────────────┘│
│  ... (more rooms)                                           │
├─────────────────────────────────────────────────────────────┤
│  SECTION: At a Glance (Collapsible)                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                       │
│  │ ⚡ 0.3p │ │ 🚗 45%  │ │ 🐠 24°C │                       │
│  │ Energy  │ │  Fuel   │ │  Tank   │                       │
│  └─────────┘ └─────────┘ └─────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Specifications

### 1. Status Header Card

**Purpose**: Show home-wide status at a glance

```yaml
# Wireframe
┌───────────────────────────────────────────────────────────┐
│  ☀️ 10°C                           🏠 Darren • Lorraine   │
│  Partly cloudy                              Both home     │
└───────────────────────────────────────────────────────────┘

# Specifications
- Height: 64px (mobile), 80px (tablet+)
- Background: Surface color with subtle gradient
- Weather: Icon + temp + condition text (not abbreviated)
- Presence: Home icon color-coded (green = home, blue = away)
- Names: Full first names, not initials
- Divider: Subtle vertical line or spacing
```

**Implementation Notes**:
```yaml
type: custom:mushroom-chips-card
alignment: justify
chips:
  - type: weather
    entity: weather.forecast_home
    show_conditions: true
    show_temperature: true
  - type: spacer
  - type: template
    content: >
      {{ states.person | selectattr('state', 'eq', 'home')
         | map(attribute='attributes.friendly_name')
         | map('first') | join(' • ') }} home
    icon: mdi:home-account
    icon_color: green
```

### 2. Quick Action Buttons

**Purpose**: One-tap scene activation

```yaml
# Wireframe
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│   🔴    │ │   🎬    │ │   🎉    │ │   💡    │
│ All Off │ │  Movie  │ │  Party  │ │ All On  │
└─────────┘ └─────────┘ └─────────┘ └─────────┘

# Specifications
- Layout: Horizontal scroll on mobile, grid on tablet
- Size: 80×80px minimum touch target
- Icon: 32px, centered
- Label: 12px, below icon, max 2 lines
- States:
  - Default: Muted icon, subtle background
  - Active: Highlighted icon color, accent border
  - Pressed: Scale down 95%, darker background
- Haptic feedback on tap
```

**Recommended Actions**:
| Action | Icon | Color | Service |
|--------|------|-------|---------|
| All Off | `mdi:power-off` | Red | `light.turn_off` all |
| Movie | `mdi:movie-open` | Blue | `scene.movie` |
| Party | `mdi:party-popper` | Purple | `input_boolean.party_mode` toggle |
| All On | `mdi:lightbulb-on` | Amber | `light.turn_on` all @ 100% |
| Vacuum | `mdi:robot-vacuum` | Teal | `vacuum.start` |

### 3. Room Cards (Redesigned)

**Purpose**: Room status overview with quick toggle

```yaml
# Wireframe - Expanded State
┌─────────────────────────────────────────────────────────┐
│  🛋️  Living Room                          23°C    [💡]  │
│  ─────────────────────────────────────────────────────  │
│  💡 2 lights on    👤 Motion 3m ago    🌡️ 23°C         │
│  ─────────────────────────────────────────────────────  │
│  ▶️ TV: Watching Netflix                                │
└─────────────────────────────────────────────────────────┘

# Wireframe - Compact State (All Off)
┌─────────────────────────────────────────────────────────┐
│  🛏️  Bedroom                              --     [⚫]  │
│       All off · Last activity 45m ago                   │
└─────────────────────────────────────────────────────────┘

# Specifications
- Card height: Auto-expanding based on content
- Minimum height: 72px
- Padding: 16px
- Border radius: 12px
- Background:
  - Active room: Subtle amber tint (lights on)
  - Inactive room: Surface color
  - Motion detected: Subtle blue pulse animation

- Room Icon: 24px, left-aligned
- Room Name: 16px semibold
- Temperature: 14px, right-aligned, muted if unavailable
- Toggle Button: 44×44px touch target, right side

- Status Row (below title):
  - 12px muted text
  - Icon + text pairs separated by bullets
  - Priority: Lights > Motion > Climate

- Media Row (conditional):
  - Only show if media playing
  - Playback icon + source + title
  - Truncate with ellipsis

- Interactions:
  - Tap: Navigate to room detail view
  - Long press: Toggle all room lights
  - Swipe right: Quick toggle lights on
  - Swipe left: Quick toggle lights off
```

**Room Card Data Model**:
```yaml
room:
  name: "Living Room"
  icon: "mdi:sofa"
  light_group: "group.living_room_lights"
  temperature_sensor: "sensor.dyson_temperature"
  humidity_sensor: null
  motion_sensor: "binary_sensor.living_room_motion_sensor_occupancy"
  media_player: "media_player.living_room_tv"
  navigation_path: "/lovelace-home/living-room"
```

### 4. At-a-Glance Cards

**Purpose**: Secondary status information

```yaml
# Wireframe
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│     ⚡      │  │     🚗      │  │     🐠      │
│    0.3p    │  │    45%     │  │    24°C    │
│   Energy   │  │    Fuel    │  │    Tank    │
│  Low rate  │  │   ████░░   │  │    OK      │
└─────────────┘  └─────────────┘  └─────────────┘

# Specifications
- Layout: Horizontal scroll, 3 visible on mobile
- Card size: 100×120px
- Icon: 28px, centered, color-coded
- Value: 20px bold, primary color
- Label: 12px muted
- Subtext: 10px, status indicator

Color Coding:
- Energy: Green (low), Amber (medium), Red (high)
- Fuel: Green (>50%), Amber (25-50%), Red (<25%)
- Tank: Green (22-26°C), Amber (outside range)
```

---

## Color System

### Catppuccin Mocha Palette (Current Theme)

```css
/* Base Colors */
--background: #1e1e2e;      /* Base */
--surface: #313244;         /* Surface0 */
--surface-elevated: #45475a; /* Surface1 */
--text-primary: #cdd6f4;    /* Text */
--text-muted: #a6adc8;      /* Subtext0 */

/* Semantic Colors */
--status-on: #f9e2af;       /* Yellow - lights on */
--status-active: #a6e3a1;   /* Green - motion/playing */
--status-away: #89b4fa;     /* Blue - away/inactive */
--status-alert: #f38ba8;    /* Red - alerts/warnings */
--status-disabled: #6c7086; /* Overlay0 - off/unavailable */

/* Accent Colors */
--accent-primary: #cba6f7;  /* Mauve */
--accent-secondary: #89dceb; /* Sky */
```

### Status Color Mapping

| State | Color | Hex | Use Case |
|-------|-------|-----|----------|
| Lights On | Amber/Yellow | `#f9e2af` | Active lights, warm status |
| Motion | Blue | `#89b4fa` | Motion detected, presence |
| Playing | Green | `#a6e3a1` | Media playing, active |
| Away | Sky Blue | `#89dceb` | Person away, traveling |
| Alert | Red | `#f38ba8` | Warnings, low battery |
| Off/Disabled | Gray | `#6c7086` | Inactive, unavailable |
| Party Mode | Purple | `#cba6f7` | Special modes |

---

## Typography

```css
/* Font Stack */
font-family: -apple-system, BlinkMacSystemFont, 'SF Pro', 'Inter', sans-serif;

/* Scale */
--font-size-xs: 10px;   /* Timestamps, tertiary info */
--font-size-sm: 12px;   /* Secondary text, labels */
--font-size-md: 14px;   /* Body text, status */
--font-size-lg: 16px;   /* Card titles, primary info */
--font-size-xl: 20px;   /* Section headers */
--font-size-2xl: 24px;  /* Page titles */
--font-size-3xl: 32px;  /* Large values (wall display) */

/* Weights */
--font-weight-normal: 400;
--font-weight-medium: 500;
--font-weight-semibold: 600;
--font-weight-bold: 700;
```

---

## Responsive Breakpoints

### Mobile (< 640px)
- Single column layout
- Bottom navigation
- Room cards: Full width, stacked
- Quick actions: Horizontal scroll
- Touch targets: 48px minimum

### Tablet (640px - 1024px)
- Two column layout
- Side navigation (collapsible)
- Room cards: 2-column grid
- Quick actions: 2×2 grid
- Touch targets: 44px minimum

### Wall Display (> 1024px)
- Multi-column layout
- Persistent sidebar
- Room cards: 3-4 column grid
- Quick actions: Single row
- Larger typography (+25%)
- Glanceable from distance

---

## Spacing System

```css
/* Base unit: 4px */
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
--space-10: 40px;
--space-12: 48px;

/* Component Spacing */
--card-padding: var(--space-4);      /* 16px */
--card-gap: var(--space-3);          /* 12px */
--section-gap: var(--space-6);       /* 24px */
--page-padding: var(--space-4);      /* 16px */
```

---

## Implementation Roadmap

### Phase 1: Header & Quick Actions
1. Replace chip header with expanded status card
2. Add labels to quick action buttons
3. Implement horizontal scroll for mobile

### Phase 2: Room Cards
1. Create new room card template with expanded layout
2. Add conditional media player row
3. Implement swipe gestures
4. Add subtle animations for state changes

### Phase 3: Navigation
1. Evaluate Bubble Card pop-up pattern
2. Implement bottom tab bar for mobile
3. Add room quick-access floating button

### Phase 4: Responsive Polish
1. Test on multiple device sizes
2. Adjust typography scale for wall displays
3. Add reduced motion preference support

---

## Appendix: Mushroom Card Implementation

### Status Header Example
```yaml
type: horizontal-stack
cards:
  - type: custom:mushroom-template-card
    entity: weather.forecast_home
    primary: "{{ state_attr('weather.forecast_home', 'temperature') }}°C"
    secondary: "{{ states('weather.forecast_home') | title }}"
    icon: "{{ state_attr('weather.forecast_home', 'icon') }}"
    icon_color: >
      {% if is_state('weather.forecast_home', 'sunny') %}amber
      {% elif 'cloud' in states('weather.forecast_home') %}grey
      {% elif 'rain' in states('weather.forecast_home') %}blue
      {% else %}grey{% endif %}
    layout: vertical

  - type: custom:mushroom-template-card
    primary: >
      {% set home = states.person | selectattr('state', 'eq', 'home') | list %}
      {% if home | count == 0 %}Nobody home
      {% else %}{{ home | map(attribute='attributes.friendly_name') | join(' & ') }}
      {% endif %}
    secondary: >
      {% set home = states.person | selectattr('state', 'eq', 'home') | list %}
      {% if home | count == 0 %}Away{% else %}Home{% endif %}
    icon: >
      {% set home = states.person | selectattr('state', 'eq', 'home') | list %}
      {% if home | count == 0 %}mdi:home-export-outline{% else %}mdi:home-account{% endif %}
    icon_color: >
      {% set home = states.person | selectattr('state', 'eq', 'home') | list %}
      {% if home | count == 0 %}blue{% else %}green{% endif %}
    layout: vertical
```

### Room Card Template Example
```yaml
type: custom:mushroom-template-card
entity: group.living_room_lights
primary: Living Room
secondary: >
  {% set lights = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
  {% set on_count = lights | select('is_state', 'on') | list | count %}
  {% set temp = states('sensor.dyson_temperature') %}
  {% set motion = states.binary_sensor.living_room_motion_sensor_occupancy %}
  {% set parts = [] %}

  {% if on_count > 0 %}
    {% set parts = parts + ['💡 ' ~ on_count ~ ' light' ~ ('s' if on_count > 1 else '') ~ ' on'] %}
  {% else %}
    {% set parts = parts + ['All off'] %}
  {% endif %}

  {% if motion and motion.state == 'on' %}
    {% set parts = parts + ['👤 Motion'] %}
  {% elif motion and motion.last_changed %}
    {% set ago = ((now() - motion.last_changed).total_seconds() / 60) | int %}
    {% if ago < 60 %}
      {% set parts = parts + ['👤 ' ~ ago ~ 'm ago'] %}
    {% endif %}
  {% endif %}

  {% if temp not in ['unavailable', 'unknown'] %}
    {% set parts = parts + ['🌡️ ' ~ temp | round(0) ~ '°C'] %}
  {% endif %}

  {{ parts | join('  •  ') }}
icon: mdi:sofa
icon_color: >
  {% set lights = state_attr('group.living_room_lights', 'entity_id') | default([]) %}
  {% if lights | select('is_state', 'on') | list | count > 0 %}amber{% else %}disabled{% endif %}
layout: horizontal
multiline_secondary: true
tap_action:
  action: navigate
  navigation_path: /lovelace-home/living-room
hold_action:
  action: call-service
  service: light.toggle
  target:
    entity_id: group.living_room_lights
fill_container: true
card_mod:
  style: |
    ha-card {
      background: {% if is_state('group.living_room_lights', 'on') %}
        rgba(249, 226, 175, 0.1)
      {% else %}
        var(--card-background-color)
      {% endif %};
      border-radius: 12px;
      padding: 8px;
    }
```

---

## Figma Design Structure (Reference)

If creating mockups in Figma, organize as follows:

```
📁 Home Dashboard Redesign
├── 📄 Cover
├── 📁 Components
│   ├── 🧩 Status Header
│   ├── 🧩 Quick Action Button
│   ├── 🧩 Room Card (Active)
│   ├── 🧩 Room Card (Inactive)
│   ├── 🧩 Room Card (With Media)
│   ├── 🧩 At-a-Glance Card
│   └── 🧩 Navigation Items
├── 📁 Pages
│   ├── 📱 Mobile - Home
│   ├── 📱 Mobile - Room Detail
│   ├── 🖥️ Tablet - Home
│   └── 📺 Wall Display - Home
├── 📁 Tokens
│   ├── 🎨 Colors (Catppuccin)
│   ├── 📝 Typography
│   └── 📐 Spacing
└── 📄 Changelog
```

---

*Document Version: 1.0*
*Last Updated: 2025-12-15*
