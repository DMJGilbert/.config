# Home Assistant Dashboard Design Specification

## Overview
Mobile-first dashboard design for "Fleming Place" smart home, featuring hero imagery, clean card layouts, and intuitive navigation.

**Target Device**: iPhone (390pt width, 844pt height)
**Theme Support**: Light mode primary (Dark mode planned)
**Design Language**: Clean, image-rich, minimal

---

## Design System

### Color Palette

#### Brand Colors
| Name | Hex | Usage |
|------|-----|-------|
| Primary (Orange) | `#FC691C` | Titles, active tabs, accent highlights |
| Primary Light | `#FF8A4C` | Hover states, lighter accents |

#### Light Mode
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#FFFFFF` | Main background |
| Surface | `#FFFFFF` | Card backgrounds |
| Surface Elevated | `#F5F5F5` | Chips, overlays |
| Border | `#E5E5E5` | Card borders, dividers |
| Text Primary | `#1A1A1A` | Titles, primary text |
| Text Secondary | `#6B7280` | Subtitles, metadata, timestamps |
| Text Muted | `#9CA3AF` | Inactive tabs, placeholders |

#### Dark Mode (Planned)
| Name | Hex | Usage |
|------|-----|-------|
| Background | `#121212` | Main background |
| Surface | `#1E1E1E` | Card backgrounds |
| Surface Elevated | `#2A2A2A` | Chips, overlays |
| Border | `#333333` | Card borders, dividers |
| Text Primary | `#FFFFFF` | Titles, primary text |
| Text Secondary | `#9CA3AF` | Subtitles, metadata |

#### Status Colors
| Name | Hex | Usage |
|------|-----|-------|
| Active/On | `#FC691C` | Lights on, media playing |
| Motion | `#3B82F6` | Motion detected |
| Success | `#22C55E` | Online, connected |
| Warning | `#F59E0B` | Low battery |
| Error | `#EF4444` | Offline, unavailable |

### Typography

| Style | Size | Weight | Color | Usage |
|-------|------|--------|-------|-------|
| Page Title | 28pt | 400 | Primary Orange | "Fleming Place", room names |
| Section Label | 14pt | 500 | Text Secondary | Tab labels |
| Card Title | 16pt | 500 | Text Primary | Device names, room names |
| Card Subtitle | 13pt | 400 | Text Secondary | Status, metadata |
| Chip Label | 12pt | 500 | Text Primary | Floating chip text |
| Caption | 11pt | 400 | Text Muted | Timestamps, small labels |

**Font Family**: SF Pro Display (iOS) / System default

### Spacing Scale

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4pt | Tight spacing |
| sm | 8pt | Chip padding, inner margins |
| md | 12pt | Card padding, gaps |
| lg | 16pt | Page margins, section gaps |
| xl | 24pt | Large section separators |
| 2xl | 32pt | Hero bottom margin |

### Border Radius

| Token | Value | Usage |
|-------|-------|-------|
| pill | 50pt | Floating chips (fully rounded) |
| card | 16pt | Cards, images |
| circle | 50% | Avatar images, back button |
| button | 8pt | Buttons, small controls |

### Shadows

```
Card: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)
Floating Chip: 0 2px 8px rgba(0,0,0,0.15)
```

---

## Component Specifications

### 1. Page Header
**Height**: 60pt

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Fleming Place                              [🌙]    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

- **Title**: Page Title style, Primary Orange color
- **Action Button**: 40pt circle, right-aligned (dark mode toggle)
- **Padding**: 16pt horizontal

### 2. Hero Image Section
**Height**: 180pt (image) + floating chips

```
┌─────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────┐ │
│ │                                                 │ │
│ │              [Building/Room Photo]              │ │
│ │                                                 │ │
│ │         [💡 3]  [📹 2]  [🏃 2]                  │ │ ← Floating chips
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

#### Hero Image
- **Width**: Full width - 32pt (16pt margins)
- **Height**: 180pt
- **Border Radius**: 16pt
- **Object Fit**: Cover

#### Floating Chips (overlaid on image)
- **Position**: Bottom center of image, 12pt from bottom
- **Height**: 32pt
- **Padding**: 10pt horizontal, 6pt vertical
- **Background**: White with 0.95 opacity
- **Border Radius**: 50pt (pill)
- **Shadow**: 0 2px 8px rgba(0,0,0,0.15)
- **Gap**: 8pt between chips
- **Icon Size**: 16pt
- **Icon-Text Gap**: 6pt

### 3. Status Info Section
**Height**: Auto (content-based)

```
┌─────────────────────────────────────────────────────┐
│  📍 Partially Cloudy (0% of rain, 28.02 C)          │
│  📅 Ballet: 2 day 4 hours                           │
│  ⚽ Liverpool v Southampton: Saturday 16:00         │
└─────────────────────────────────────────────────────┘
```

- **Layout**: Vertical stack, 8pt gap
- **Icon Size**: 14pt
- **Text**: Card Subtitle style
- **Padding**: 16pt horizontal, 12pt vertical
- **Conditional**: Each row only shown when relevant

### 4. Tab Navigation
**Height**: 44pt

```
┌─────────────────────────────────────────────────────┐
│  Rooms   Peoples   Calendar   Other      Scenes     │
│  ─────                                              │
└─────────────────────────────────────────────────────┘
```

- **Layout**: Horizontal scroll
- **Tab Padding**: 0pt horizontal between tabs, 16pt page margin
- **Tab Gap**: 24pt
- **Active Tab**: Primary Orange, underline 2pt
- **Inactive Tab**: Text Muted
- **"Scenes"**: Right-aligned, always visible
- **Font**: Section Label style

### 5. Room Card (List Style)
**Height**: 72pt

```
┌─────────────────────────────────────────────────────┐
│  ┌────┐                                             │
│  │ 🖼 │  Living Room                    1 Light     │
│  │    │  Clear - 30 seconds ago         ───────     │
│  └────┘                                             │
└─────────────────────────────────────────────────────┘
```

#### Structure
- **Padding**: 12pt vertical, 16pt horizontal
- **Image**: 48pt × 48pt circle
- **Image Border Radius**: 50% (circle)
- **Content Gap**: 12pt (image to text)
- **Primary Text**: Card Title style
- **Secondary Text**: Card Subtitle style
- **Right Content**: Status badges (right-aligned)

#### Status Badges (Right Side)
- **Layout**: Vertical stack, right-aligned
- **Primary Badge**: "1 Light", "2 Lights", etc.
- **Secondary Badge**: "1 Media" (when applicable)
- **Font**: Caption style

### 6. Person Card
**Height**: 72pt

```
┌─────────────────────────────────────────────────────┐
│  ┌────┐                                             │
│  │ 👤 │  Darren                                     │
│  │    │  Home                                       │
│  └────┘                                             │
│                      ┌────┐                         │
│                      │ 👤 │  Lorraine               │
│                      │    │  Bagshot Road           │
│                      └────┘  (Sainsburys)           │
└─────────────────────────────────────────────────────┘
```

- **Layout**: 2-column grid or horizontal scroll
- **Image**: 48pt × 48pt circle (photo)
- **Primary Text**: Person name
- **Secondary Text**: Location or "Home"

### 7. Room Detail Header
**Height**: 60pt

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Living Room                                [←]     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

- **Title**: Page Title style, Primary Orange
- **Back Button**: 40pt circle, right-aligned, subtle border
- **Back Icon**: Chevron left, 20pt

### 8. Room Hero (Detail View)
**Height**: 120pt

```
┌─────────────────────────────────────────────────────┐
│ ┌─────────────────────────────────────────────────┐ │
│ │              [Room Interior Photo]              │ │
│ │                                                 │ │
│ │                    [💡 1]                       │ │
│ └─────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

- **Height**: 120pt (smaller than home hero)
- **Same floating chip style as home hero

### 9. Sub-Tab Navigation (Room Detail)
**Height**: 40pt

```
┌─────────────────────────────────────────────────────┐
│  Media   Lights   Climate   Other        Scenes     │
│  ─────                                              │
└─────────────────────────────────────────────────────┘
```

- **Same style as main tab navigation**
- **Tabs**: Media, Lights, Climate, Other
- **"Scenes"**: Right-aligned

### 10. Device Card (Media Tab)
**Height**: 72pt

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  LG Smart TV                              [📺]      │
│  HDMI 1                                             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

#### Structure
- **Background**: White
- **Border**: 1pt, Border color
- **Border Radius**: 16pt
- **Padding**: 16pt
- **Primary Text**: Card Title style
- **Secondary Text**: Card Subtitle style (state/source)
- **Device Image**: 40pt × 40pt, right-aligned, actual product image

#### Device Image Examples
- **LG TV**: TV icon or product render
- **Apple TV**: Apple TV box image (black/silver)
- **HomePod**: Orange HomePod mini image
- **Sonos**: Speaker image

### 11. Light Card (Lights Tab)
**Height**: 64pt

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  💡 Main Light                           [====] 75% │
│                                                     │
└─────────────────────────────────────────────────────┘
```

- **Icon**: 24pt, colored when on (orange), gray when off
- **Name**: Card Title style
- **Slider**: Inline, 100pt width
- **Percentage**: Caption style, right of slider

### 12. Climate Card (Climate Tab)
**Height**: 80pt

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  🌡 Temperature                           22.4°C    │
│  ────────────────────────────────────────           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

- **Icon + Label**: Left-aligned
- **Current Value**: Right-aligned, large
- **Graph**: Mini sparkline below (optional)

---

## Page Layouts

### Home Tab
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Fleming Place                              [🌙]    │ ← Header
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │                                             │   │
│  │           [Building Photo]                  │   │ ← Hero
│  │                                             │   │
│  │         [💡 3] [📹 2] [🏃 2]                │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  📍 Partially Cloudy (0% of rain, 28.02 C)         │ ← Status
│  📅 Ballet: 2 day 4 hours                          │
│  ⚽ Liverpool v Southampton: Saturday 16:00        │
│                                                     │
│  Rooms  Peoples  Calendar  Other        Scenes     │ ← Tabs
│  ─────                                             │
│                                                     │
│  ┌────┐ Living Room              1 Light           │
│  │ 🖼 │ Clear - 30 seconds ago   ───────           │ ← Room list
│  └────┘                                            │
│                                                     │
│  ┌────┐ Bedroom                  2 Lights          │
│  │ 🖼 │ Clear - 30 seconds ago   1 Media           │
│  └────┘                                            │
│                                                     │
│  ┌────┐ Bathroom                                   │
│  │ 🖼 │ 23° · 65% humidity                         │
│  └────┘                                            │
│                                                     │
│  ┌────┐ Kitchen                                    │
│  │ 🖼 │ All off                                    │
│  └────┘                                            │
│                                                     │
│  ┌────┐ Hallway                                    │
│  │ 🖼 │ 1 light · 21°                              │
│  └────┘                                            │
│                                                     │
│  ┌────┐ Robynne's Room                             │
│  │ 🖼 │ Yoto playing                               │
│  └────┘                                            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Peoples Tab
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Fleming Place                              [🌙]    │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │           [Building Photo]                  │   │
│  │         [💡 3] [📹 2] [🏃 2]                │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  📍 Partially Cloudy...                            │
│                                                     │
│  Rooms  Peoples  Calendar  Other        Scenes     │
│         ───────                                    │
│                                                     │
│  ┌─────────────────┐  ┌─────────────────┐         │
│  │ ┌────┐          │  │ ┌────┐          │         │
│  │ │ 👤 │ Darren   │  │ │ 👤 │ Lorraine │         │
│  │ └────┘ Home     │  │ └────┘ Bagshot  │         │
│  │                 │  │        Road     │         │
│  └─────────────────┘  └─────────────────┘         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Living Room (Room Detail)
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Living Room                                [←]     │ ← Header + back
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │         [Living Room Photo]                 │   │ ← Room hero
│  │                   [💡 1]                    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Media  Lights  Climate  Other          Scenes     │ ← Sub-tabs
│  ─────                                             │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ LG Smart TV                          [📺]   │   │
│  │ HDMI 1                                      │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Apple TV                             [⬛]   │   │
│  │ Playing: Alice's Wonderland Bakery          │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Homepod                              [🟠]   │   │
│  │ Playing: Alice's Wonderland Bakery          │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Calendar Tab (Planned)
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  Fleming Place                              [🌙]    │
│                                                     │
│  [Hero section...]                                 │
│                                                     │
│  Rooms  Peoples  Calendar  Other        Scenes     │
│                  ────────                          │
│                                                     │
│  Today                                             │
│  ┌─────────────────────────────────────────────┐   │
│  │ 📅 Ballet                                   │   │
│  │    2 days 4 hours                           │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  This Week                                         │
│  ┌─────────────────────────────────────────────┐   │
│  │ ⚽ Liverpool v Southampton                  │   │
│  │    Saturday 16:00                           │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### System Tab (via Other)
```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  System                                     [←]     │
│                                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ 📊 System Load             0.5              │   │
│  │ 💾 Disk Usage              45%              │   │
│  │ 📋 Entities                685              │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Low Battery                                       │
│  ┌─────────────────────────────────────────────┐   │
│  │ 🔋 Motion Sensor                      15%   │   │
│  │ 🔋 Door Sensor                        22%   │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Unavailable                                       │
│  ┌─────────────────────────────────────────────┐   │
│  │ ❌ Security Camera           unavailable    │   │
│  │ ❌ RoboVac                   unavailable    │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Interaction Patterns

### Tap Actions
| Element | Tap | Hold |
|---------|-----|------|
| Room Card | Navigate to room detail | - |
| Person Card | Show person details | - |
| Device Card | Toggle / more-info | - |
| Light Card | Toggle on/off | Open brightness slider |
| Tab | Switch tab | - |
| Floating Chip | Filter/navigate | - |
| Back Button | Navigate back | - |

### Transitions
- **Page Navigation**: Slide from right (iOS style)
- **Tab Switch**: Fade content (150ms)
- **Card Tap**: Subtle press feedback
- **Toggle**: Smooth color transition (200ms)

---

## Assets Required

### Images
| Asset | Size | Format | Usage |
|-------|------|--------|-------|
| Building Photo | 780×360 | JPG | Home hero |
| Living Room | 780×240 | JPG | Room hero |
| Bedroom | 780×240 | JPG | Room hero |
| Bathroom | 780×240 | JPG | Room hero |
| Kitchen | 780×240 | JPG | Room hero |
| Hallway | 780×240 | JPG | Room hero |
| Robynne's Room | 780×240 | JPG | Room hero |
| Room Thumbnails | 96×96 | JPG | Room list (circular crop) |
| Person Photos | 96×96 | JPG | People list (circular crop) |

### Device Icons/Images
| Device | Source |
|--------|--------|
| LG TV | Product image or icon |
| Apple TV | Apple TV box render |
| HomePod | Orange HomePod mini |
| Sonos | Speaker image |
| Dyson Fan | Product image |

---

## Implementation Notes

### Home Assistant Cards
1. **Picture Elements Card** - Hero image with floating chips overlay
2. **Custom Button Card** - Tab navigation, styled cards
3. **Mushroom Cards** - Device cards, entity rows
4. **Vertical Stack** - Page layout
5. **Horizontal Stack** - Tab bar, chip rows
6. **Conditional Card** - Status info (weather, events)

### Custom CSS Required
```yaml
card_mod:
  style: |
    ha-card {
      border-radius: 16px;
      border: 1px solid #E5E5E5;
      box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    }
```

### Theme Variables
```yaml
primary-color: "#FC691C"
accent-color: "#FC691C"
card-background-color: "#FFFFFF"
primary-text-color: "#1A1A1A"
secondary-text-color: "#6B7280"
```

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-12-15 | Initial specification |
| 2.0 | 2024-12-15 | Updated to match Figma design - hero images, orange accent, tab navigation, room/person cards |
