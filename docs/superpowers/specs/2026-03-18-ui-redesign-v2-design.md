# Little Atlas — UI Redesign v2 Design Spec

Full visual redesign covering color palette, typography, layout, navigation, components, micro-interactions, and all 7 app screens. Moves from the nature-inspired Atlas Green palette to a Soft Modern aesthetic with vibrant violet, pink, and teal accents while keeping the app warm, family-friendly, and approachable.

## Agent Workflow

**Sequential handoff:** [UI/UX] designs the full theme, design system, and widget library first. [Frontend Dev] then implements each screen using the completed design system. This prevents rework and ensures visual consistency.

---

## 1. Color System

### Primary Brand Colors

| Name | Hex | Usage |
|------|-----|-------|
| Atlas Violet | `#6C5CE7` | Primary brand, active tabs, CTAs, links |
| Violet Dark | `#5A4BD1` | Pressed states, app bar |
| Violet Light | `#A29BFE` | Highlights, selected chip borders, secondary accents |
| Violet Wash | `#F0EDFF` | Tinted backgrounds, chip fills, selected states |

### Accent Colors

| Name | Hex | Usage |
|------|-----|-------|
| Rose Pink | `#FD79A8` | Events, LIVE badges, favorites |
| Aqua Teal | `#00CEC9` | Maps, directions, distance indicators |
| Honey Gold | `#FDCB6E` | Ratings, "Popular" tags, outdoor weather |
| Coral Red | `#FF7675` | Errors, closed status |

### Category Colors

| Category | Hex |
|----------|-----|
| Playgrounds | `#FF9F43` |
| Parks & Nature | `#00B894` |
| Restaurants | `#E17055` |
| Entertainment | `#6C5CE7` |
| Culture & Education | `#74B9FF` |
| Sports & Activities | `#00CEC9` |
| Events | `#FD79A8` |

### Surfaces & Neutrals

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#FBF9FF` | Screen background (soft lavender-white) |
| Surface | `#FFFFFF` | Cards, sheets, dialogs |
| Text Primary | `#2D3436` | Headlines, primary text |
| Text Secondary | `#636E72` | Descriptions, metadata |
| Text Tertiary | `#B2BEC3` | Hints, placeholders |
| Divider | `#DFE6E9` | Lines, borders |

### Weather Mode Gradients

| Mode | Gradient | Text Color |
|------|----------|------------|
| Outdoor | `#FFEAA7` → `#FDCB6E` | `#6C5100` |
| Indoor | `#DFE6E9` → `#A29BFE` | `#2D3436` |
| Caution | `#FFECD2` → `#FAB1A0` | `#6C3A00` |

### Status Colors

| Status | Hex | Extra |
|--------|-----|-------|
| Open | `#00B894` | — |
| Closed | `#FF7675` | — |
| Happening Now | `#FD79A8` | + glow shadow |
| Warning | `#FDCB6E` | — |

---

## 2. Typography

Font: **Nunito** (Google Fonts) — all weights. Chosen for rounded letterforms, family-friendly feel, and Latin/Greek/Cyrillic support.

| Style | Weight | Size | Usage |
|-------|--------|------|-------|
| Screen Title | Bold 700 | 22sp | Screen headers ("Discover", "Events") |
| Section Header | Bold 700 | 12sp | ALL CAPS, letter-spacing +1.0, text secondary color `#636E72` |
| Card Title | SemiBold 600 | 15sp | Place/event names on cards |
| Body | Regular 400 | 13sp | Descriptions, about text |
| Caption | Medium 500 | 12sp | Metadata, distances, timestamps |
| Small Caption | Regular 400 | 11sp | Secondary metadata, age ranges |
| Chip Text | SemiBold 600 | 12sp | Filter chips, category chips |
| Button | Bold 700 | 15sp | CTA buttons |
| Badge | Bold 700 | 9-10sp | LIVE, Popular, Open/Closed |
| "See all" Link | SemiBold 600 | 12sp | Atlas Violet color |

---

## 3. Shape & Spacing

### Border Radius

| Element | Radius |
|---------|--------|
| Cards | 18dp (squircle-like) |
| Buttons | 14dp |
| Chips / Pills | 20dp (full pill) |
| Bottom Sheet | 24dp (top corners) |
| Search Bar | 24dp (full pill) |
| Date Blocks | 14dp |
| Floating Nav Bar | 20dp |
| Thumbnails | 14dp |
| Weather Hero | 18dp |
| Badges | 10dp |
| Icon containers | 12dp |

### Spacing (4dp base)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4dp | Icon-label gaps |
| sm | 8dp | Chip gaps, compact padding |
| md | 12dp | Card internal padding |
| lg | 16dp | Screen padding, section gaps |
| xl | 24dp | Between major sections |
| xxl | 32dp | Top/bottom screen margins |

### Elevation

| Element | Shadow |
|---------|--------|
| Cards | `0 3px 12px rgba(108,92,231,0.06)` |
| Floating Nav | `0 4px 16px rgba(0,0,0,0.1)` |
| Weather Hero | `0 3px 12px` using weather gradient color at 25% opacity |
| Buttons (CTA) | `0 4px 14px rgba(108,92,231,0.3)` |
| LIVE events | `0 3px 12px rgba(253,121,168,0.12)` |

---

## 4. Navigation

### Floating Bottom Nav Bar

- 5 tabs: Discover / Search / Events / Map / Settings
- 12px margin from screen edges and bottom
- 20px border radius, white background
- Shadow: `0 4px 16px rgba(0,0,0,0.1)`
- Active tab: Atlas Violet dot (4px circle) above icon, violet-colored icon and label
- Inactive tabs: 40% opacity icons, `#B2BEC3` labels
- Icon + label always visible (no icon-only tabs)
- Touch targets: minimum 48x48dp

---

## 5. Screen Designs

### 5.1 Discover (Home)

Top to bottom:
1. **Contextual greeting** — "Good morning, Larnaca!" with time-of-day awareness (morning 5-12, afternoon 12-17, evening 17-21). City from reverse geocode. Fade-in on load.
2. **Weather hero card** — Full-width, 18px radius, gradient background per weather mode. Contains: Lottie animated weather icon (48x48 in white circle), temperature + condition (20sp Bold), friendly suggestion ("Perfect day for the beach!"). Single line, no expand/collapse.
3. **Category chips** — Horizontal scroll row. "All" chip filled violet when active. Others white with border when inactive, Violet Wash fill + violet border when selected.
4. **"Happening Now" section** — Section header (12sp Bold ALL CAPS) + "See all" link (violet). Horizontal scroll `EventCardHorizontal` cards (160dp wide, 210dp tall): gradient hero image (110dp), LIVE badge, event name, time, distance, age range below.
5. **"Nearby [Category]" sections** — Same pattern. Dynamic category name based on what's nearby. Horizontal scroll `PlaceCardHorizontal` cards (160dp wide, 210dp tall): gradient placeholder (category colors) or photo with gradient overlay, place name, distance, open status.
6. **"Popular This Week" section** — Shown when 3+ places exist nearby. Full-width `PlaceCardFullWidth` stacked vertically. Omit section if insufficient data.

### 5.2 Search

1. **Pill search bar** — 24px radius, white fill, subtle shadow. Search icon left, filter icon right (opens filter sheet). Auto-focus on tab tap, 300ms debounce.
2. **Active filter chips** — Below search bar. Violet Wash background, violet text, X to remove. "Clear all" link when 2+ active.
3. **Photo-forward result cards** — Full-width `PlaceCardFullWidth`. Image area 160dp with bottom gradient overlay (`rgba(0,0,0,0.6)` → transparent). White title + subtitle on gradient. "Show on Map" badge top-right — tapping switches to Map tab centered on that place with its marker selected. Amenity chips below image in card body.
4. **Filter bottom sheet** — Modal. Distance (single-select pills), Age (multi-select chips), Type (indoor/outdoor/both), Amenities (multi-select). "Show N results" primary button with count.

### 5.3 Events

1. **Header** — "Events" title (22sp Bold).
2. **Time filter tabs** — "This Week" / "This Month" / "All". Selected: violet fill, white text, 12px radius. Unselected: white fill, border.
3. **Date group headers** — Sticky. "TODAY", "TOMORROW", or date. 12sp Bold ALL CAPS, text secondary. Uses the same `SectionHeader` style without the "See all" link.
4. **Event cards** — White card, 18px radius. Left: date block (56x56, gradient fill matching category/event color, white text: month/day/weekday). Right: event title (15sp SemiBold), time + venue (12sp), age + distance pills. LIVE events: left rose-pink border, pink glow shadow, animated LIVE badge.

### 5.4 Map

Same as current Explore screen structure but with updated styling:
- Map fills screen behind floating nav
- Category chips overlay map top (same chip style as Discover)
- Custom markers: 36dp circles with category color, white icon. Selected: 44dp with white border
- Cluster markers: 36dp gray circle (`#B2BEC3`) with white count number (13sp Bold). Tap to zoom in and expand
- Bottom sheet: 24px top radius, collapsed/half/full states
- Place cards in sheet use the same card component as Discover sections
- "My location" FAB: white circle, violet icon, bottom-right above nav bar

### 5.5 Place Detail

1. **Photo carousel hero** — Full-width, 220dp height. Swipeable with page indicator dots. Bottom gradient overlay with place name (22sp ExtraBold white) and category + city subtitle.
2. **Back button** — White circle (36dp), top-left, subtle shadow.
3. **Quick info pills** — Row below hero. Open status (green tint), distance (violet tint), age range (pink tint), closing time (gold tint). All 12px radius.
4. **Amenities section** — `SectionHeader` (12sp Bold ALL CAPS, no "See all" link). Gray-tinted chips (12dp radius) with emoji icons.
5. **About section** — Header + body text (13sp, 1.6 line height).
6. **Details section** — Address, phone, website. Each with violet icon. Website in violet as tappable link.
7. **"Get Directions" CTA** — Full-width gradient button (violet → violet light). 14px radius, 16px vertical padding. Shadow.

### 5.6 Event Detail

1. **Hero image/gradient** — 220dp (same height as Place Detail for consistency). Gradient overlay with event title (20sp ExtraBold white), LIVE badge if active, category subtitle.
2. **Date/time card** — White card with date block (60x60, violet gradient) + "Today, 10:00 - 18:00" text + duration.
3. **Info pills** — Age range, distance, price (green "Free!" if free).
4. **About section** — Event description.
5. **Venue section** — Mini-map placeholder (100dp, gradient background) with venue name overlay. Venue name + address below.
6. **"Get Directions" CTA** — Same as Place Detail.

### 5.7 Settings (Playful Cards)

1. **Header** — "Settings" (22sp Bold) + "Make Little Atlas yours" subtitle.
2. **Language card** — Gradient background (Violet Wash → pink tint). Globe gradient icon (40x40). Three language tiles side-by-side: flag emoji + language name. Selected: white card with violet border. Unselected: white card, no border.
3. **Data Sources card** — White card with teal gradient icon. Data source names as colored pills (OpenStreetMap=teal, Google Places=violet, OpenWeather=gold).
4. **Legal card** — White card with gold gradient icon. "Privacy" and "Terms" as two tappable gray tiles side-by-side.
5. **Branding footer** — Centered. "Little Atlas" (18sp ExtraBold violet) + version from package info + " · Made with love in Cyprus". Version must be read dynamically from app build config, never hardcoded.

---

## 6. Micro-interactions & Animations

| Interaction | Implementation | Duration |
|-------------|---------------|----------|
| Lottie weather animation | Animated sun/clouds/rain in weather hero. ~10KB per animation via `lottie` package. Source from LottieFiles (free tier). Bundle as assets in `assets/lottie/` for offline support. | Loop |
| LIVE pulse | Pink dot scales 0.8→1.2 on 1s loop. Map markers for live events get fading pink ring. Glow shadow animates. | 1000ms loop |
| Haptic feedback | `HapticFeedback.lightImpact()` on: chip select, bottom sheet snap, nav tab switch, pull-to-refresh release. | Instant |
| Staggered card entry | Cards fade-in + slide up. 50ms stagger between cards, 300ms per card, easeOutCubic. Horizontal cards slide from right. | 300ms + 50ms stagger |
| Contextual greeting | Time-of-day greeting fades in on Discover load. City name from reverse geocode. | 400ms fade |
| Branded skeleton loading | Shimmer uses Violet Wash (`#F0EDFF`) base with soft white highlight instead of generic gray. | 1500ms loop |
| Chip select | Scale 1.0 → 1.05 → 1.0 + haptic. | 150ms |
| Screen transitions | Slide + fade, easeInOut. | 250ms |
| Bottom sheet drag | Spring physics on snap points. | 300ms |
| Map marker appear | Scale from 0 + subtle bounce. | 200ms |

---

## 7. Component Library

### Shared Widgets (UI/UX builds first)

| Widget | Description |
|--------|-------------|
| `FloatingNavBar` | 5-tab floating bottom nav with dot indicator |
| `WeatherHeroCard` | Gradient card with Lottie animation, temp, suggestion |
| `PlaceCardHorizontal` | 160x210 photo-forward card for horizontal scroll sections |
| `PlaceCardFullWidth` | Full-width photo card, 160dp image height with gradient overlay, amenity chips below. For search results and "Popular This Week" |
| `EventCard` | Vertical date block + event info + LIVE badge (for Events feed) |
| `EventCardHorizontal` | 160x210dp compact event card for horizontal scroll sections (Discover) |
| `CategoryChip` | Selectable pill chip with icon |
| `FilterChip` | Removable violet chip with X |
| `InfoPill` | Colored tinted pill for quick info (open/distance/age) |
| `GradientButton` | Violet gradient CTA with shadow |
| `SectionHeader` | ALL CAPS label + "See all" link |
| `DateBlock` | Colored square with month/day/weekday |
| `LiveBadge` | Animated pulsing LIVE badge |
| `BrandedSkeleton` | Violet-tinted shimmer loading placeholder |
| `LanguageTile` | Flag + language name selectable card |
| `SettingsCard` | White card with gradient icon header |

### Design Tokens (Dart constants)

All colors, radii, spacing, typography styles, and shadows defined as Dart constants in a single theme file. No hardcoded values in widgets.

---

## 8. Accessibility

- All interactive elements: minimum 48x48dp touch targets
- Color never the only indicator — always paired with icon or text
- Weather mode: gradient + text + icon (triple encoding)
- LIVE status: color + badge text + pulse animation
- Open/Closed: color + text label
- Content descriptions on all images for screen readers
- Support system font size scaling
- Test with TalkBack (Android) and VoiceOver (iOS)

---

## 9. Empty States & Error States

Adapt existing patterns from the current design to the new palette:

| State | Design |
|-------|--------|
| Search no results | Violet Wash background, friendly illustration, "No places found — try adjusting your filters" + button to clear filters |
| Events no results | "Quiet week! Here are some places to explore anytime." + show top-rated places as fallback |
| Offline | Top banner: Violet Wash background, "You're offline — showing cached data" |
| API error | Snackbar: "Couldn't load places. Pull to retry." |
| Location denied | Full-screen: friendly illustration + "We need your location to find places near you" + settings button |
| No outdoor places (rainy) | "Rainy day? Check out indoor activities!" + one-tap filter switch |

---

## 10. What Does NOT Change

- Backend API — no changes needed
- Data models — no schema changes
- Business logic — same filters, same sorting, same weather modes
- Localization keys — existing keys stay, new ones added for greeting/suggestions
- Map provider — still flutter_map with OpenStreetMap tiles

### What DOES Change

- Navigation: 4 tabs → 5 tabs (Explore split into Discover + Map, tab renamed)
- Weather hero: expand-to-3-hour-forecast behavior intentionally removed — single-line card only
- Dark mode: still deferred to v2. All colors defined as semantic tokens to support future dark mode
