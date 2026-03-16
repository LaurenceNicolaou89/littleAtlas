# Little Atlas — Visual Design Standards

## Brand Identity

**Little Atlas** — a warm, trustworthy guide for family adventures. The visual identity should feel:
- **Warm** — inviting, not corporate
- **Clean** — uncluttered, easy to scan
- **Playful but mature** — subtle warmth, not cartoon-like
- **Outdoorsy** — nature-inspired palette

## Color System

### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Atlas Green** | `#2E7D5F` | Primary brand color, active tabs, buttons, links |
| **Atlas Green Dark** | `#1B5E42` | Pressed states, app bar |
| **Atlas Green Light** | `#E8F5EE` | Backgrounds, chip fills, subtle highlights |

### Weather Mode Colors

| Mode | Background Gradient | Text |
|------|-------------------|------|
| **Outdoor** | `#FFF8E1` → `#FFECB3` (warm amber) | `#5D4037` (brown) |
| **Indoor** | `#E3F2FD` → `#BBDEFB` (cool blue) | `#1565C0` (dark blue) |
| **Caution** | `#FFF3E0` → `#FFE0B2` (soft orange) | `#E65100` (dark orange) |

### Category Colors

| Category | Color | Hex |
|----------|-------|-----|
| Playgrounds | Orange | `#FF8A65` |
| Parks & Nature | Green | `#66BB6A` |
| Restaurants | Red | `#EF5350` |
| Entertainment | Purple | `#AB47BC` |
| Culture & Education | Blue | `#42A5F5` |
| Sports & Activities | Teal | `#26A69A` |
| Events | Pink | `#EC407A` |

### Neutral Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Text Primary** | `#212121` | Headlines, primary text |
| **Text Secondary** | `#616161` | Descriptions, metadata |
| **Text Tertiary** | `#9E9E9E` | Hints, placeholders |
| **Divider** | `#E0E0E0` | Lines, borders |
| **Background** | `#FAFAFA` | Screen backgrounds |
| **Surface** | `#FFFFFF` | Cards, sheets, dialogs |

### Status Colors

| Status | Hex | Usage |
|--------|-----|-------|
| **Open** | `#4CAF50` | Open now indicator |
| **Closed** | `#F44336` | Closed indicator |
| **Happening Now** | `#FF9800` | Live event highlight |
| **Warning** | `#FFC107` | Caution alerts |

## Typography

Using **Google Fonts** available in Flutter:

| Style | Font | Weight | Size | Usage |
|-------|------|--------|------|-------|
| **H1** | Nunito | Bold (700) | 24sp | Screen titles |
| **H2** | Nunito | SemiBold (600) | 20sp | Section headers |
| **H3** | Nunito | SemiBold (600) | 16sp | Card titles, place names |
| **Body** | Nunito | Regular (400) | 14sp | Descriptions, general text |
| **Caption** | Nunito | Regular (400) | 12sp | Metadata, distances, timestamps |
| **Button** | Nunito | SemiBold (600) | 14sp | Button labels |
| **Chip** | Nunito | Medium (500) | 12sp | Filter chips, tags |

**Nunito** was chosen for:
- Rounded letterforms → friendly, approachable feel
- Excellent readability at small sizes
- Good support for Latin, Greek, and Cyrillic scripts (all 3 languages)

## Spacing System

Base unit: **4dp**

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4dp | Tight spacing (between icon and label) |
| `sm` | 8dp | Chip padding, compact gaps |
| `md` | 12dp | Card internal padding |
| `lg` | 16dp | Section gaps, screen padding |
| `xl` | 24dp | Between major sections |
| `xxl` | 32dp | Top/bottom screen margins |

## Border Radius

| Element | Radius |
|---------|--------|
| Cards | 12dp |
| Buttons | 8dp |
| Chips / Tags | 20dp (pill shape) |
| Bottom Sheet | 16dp (top corners only) |
| Search Bar | 12dp |
| Map Markers | 50% (circle) |

## Elevation / Shadows

| Element | Elevation |
|---------|-----------|
| Cards | 1dp (subtle shadow) |
| Bottom Sheet | 8dp |
| Weather Banner | 2dp |
| FAB (My Location) | 4dp |
| Dialogs | 16dp |

Keep shadows subtle — `color: black12` or `opacity: 0.08`.

## Iconography

### Icon Set

Use **Material Icons** (included in Flutter) for consistency:

| Concept | Icon Name |
|---------|-----------|
| Explore tab | `explore` |
| Search tab | `search` |
| Events tab | `event` |
| Settings tab | `settings` |
| Playground | `child_care` |
| Park | `park` |
| Restaurant | `restaurant` |
| Entertainment | `attractions` |
| Museum | `museum` |
| Sports | `sports_soccer` |
| Distance | `near_me` |
| Open/Closed | `schedule` |
| Directions | `directions` |
| Phone | `phone` |
| Website | `language` |
| Filter | `tune` |
| Back | `arrow_back` |
| My Location | `my_location` |

### Map Markers

Custom circular markers per category:
- Size: 36dp diameter
- Background: category color (see above)
- Icon: white Material icon, 20dp
- Selected state: 44dp with white border (3dp)
- Cluster: gray circle with count number

```
Normal:          Selected:        Cluster:
┌────┐          ┌──────┐         ┌────┐
│ 🎪 │          │  🎪  │         │ 12 │
└────┘          └──────┘         └────┘
 36dp             44dp            36dp
```

## Component Patterns

### Place Card (List Item)

```
┌──────┬─────────────────────────────┐
│      │ Place Name              2km │
│ 📷   │ Category · 🟢 Open         │
│      │ [Amenity] [Amenity]         │
└──────┴─────────────────────────────┘
```

- Thumbnail: 80x80dp, rounded 8dp corners
- If no photo: category color background with icon
- Distance: right-aligned, caption style, text secondary color
- Amenities: max 2 shown as small chips

### Event Card

```
┌─────────────────────────────────────┐
│ 🎪 Event Title                      │
│ 🕐 10:00 - 18:00 · 📍 Venue  3km  │
│ 👶 Ages 2-12                        │
└─────────────────────────────────────┘
```

- Left accent border in Events category color (pink)
- "Happening Now" events: left border changes to orange, subtle orange background tint
- Date group headers: sticky, bold, uppercase, text secondary

### Weather Banner

```
┌─────────────────────────────────────┐
│ ☀️  28°C  Great for outdoor fun!    │
└─────────────────────────────────────┘
```

- Full width, gradient background (see Weather Mode Colors)
- Icon + temperature + recommendation text
- Height: 48dp collapsed, 120dp expanded (shows 3-hour forecast)
- Tap to toggle expanded/collapsed

### Filter Chip

```
Unselected:  ┌──────────┐    Selected:  ┌──────────┐
             │ Parks     │              │ ✓ Parks   │
             └──────────┘              └──────────┘
```

- Unselected: white fill, `#E0E0E0` border, text secondary
- Selected: Atlas Green Light fill, Atlas Green border, Atlas Green text, checkmark icon
- Pill shape (border radius 20dp)
- Height: 32dp
- Horizontal spacing between chips: 8dp

### Primary Button

```
┌─────────────────────┐
│   Get Directions     │
└─────────────────────┘
```

- Background: Atlas Green
- Text: white, SemiBold
- Height: 48dp
- Full width in detail screens
- Pressed: Atlas Green Dark
- Disabled: 50% opacity

## Dark Mode

Not in v1 scope. The app uses light theme only. Plan for dark mode in v2 by:
- Using semantic color tokens (not hardcoded hex values)
- Testing contrast ratios meet WCAG AA in both modes when implemented

## Animation & Motion

Keep animations subtle and functional:

| Animation | Duration | Curve |
|-----------|----------|-------|
| Bottom sheet drag | 300ms | `easeOutCubic` |
| Screen transition | 250ms | `easeInOut` |
| Chip select/deselect | 150ms | `easeIn` |
| Weather banner expand | 200ms | `easeOutCubic` |
| Map marker appear | 200ms | `bounceIn` (subtle) |
| Skeleton shimmer | 1500ms | `linear` (loop) |

No decorative animations. Every animation should serve a purpose (indicate state change, provide feedback, guide attention).

## Responsive Considerations

- App is mobile-only for v1 (no tablet/web optimization)
- Support both portrait and landscape for map view
- Content reflows naturally — no fixed pixel layouts
- Test on small screens (320dp width) and large phones (428dp width)
- Map always takes maximum available space

## Image Guidelines

- Place thumbnails: serve at 2x resolution for retina displays
- Photo carousel: max 10 photos per place
- Lazy load images with placeholder (category color + icon)
- Cache aggressively with `cached_network_image`
- If no photos available: show styled placeholder card with category icon
