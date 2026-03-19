# UI Redesign v2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign all Little Atlas Flutter screens with the Soft Modern palette (violet/pink/teal), floating nav bar, photo-forward cards, weather hero, Lottie animations, and micro-interactions.

**Architecture:** Sequential agent handoff — [UI/UX] builds the design system, theme, and all shared widgets first (Tasks 1-6). [Frontend Dev] then rewires all screens to use the new components (Tasks 7-13). No backend changes needed.

**Tech Stack:** Flutter, Provider, Google Fonts (Nunito), Lottie, flutter_map, Hive

**Spec:** `docs/superpowers/specs/2026-03-18-ui-redesign-v2-design.md`

---

## File Structure

### New Files

| File | Responsibility |
|------|---------------|
| `mobile/lib/theme/design_tokens.dart` | All color, spacing, radius, shadow, and typography constants |
| `mobile/lib/theme/app_theme.dart` | ThemeData builder consuming design tokens |
| `mobile/lib/widgets/floating_nav_bar.dart` | 5-tab floating bottom navigation bar |
| `mobile/lib/widgets/weather_hero_card.dart` | Gradient weather card with Lottie animation |
| `mobile/lib/widgets/place_card_horizontal.dart` | 160x210dp photo-forward card for horizontal scroll |
| `mobile/lib/widgets/place_card_full_width.dart` | Full-width photo card with gradient overlay |
| `mobile/lib/widgets/event_card_horizontal.dart` | 160x210dp compact event card for Discover |
| `mobile/lib/widgets/event_card_redesign.dart` | Date block event card for Events feed |
| `mobile/lib/widgets/info_pill.dart` | Colored tinted pill (open/distance/age) |
| `mobile/lib/widgets/gradient_button.dart` | Violet gradient CTA button |
| `mobile/lib/widgets/section_header.dart` | ALL CAPS label + optional "See all" link |
| `mobile/lib/widgets/date_block.dart` | Colored square with month/day/weekday |
| `mobile/lib/widgets/live_badge.dart` | Animated pulsing LIVE badge |
| `mobile/lib/widgets/branded_skeleton.dart` | Violet-tinted shimmer loading placeholder |
| `mobile/lib/widgets/language_tile.dart` | Flag + language name selectable card |
| `mobile/lib/widgets/settings_card.dart` | White card with gradient icon header |
| `mobile/assets/lottie/weather_sunny.json` | Lottie animation for sunny weather |
| `mobile/assets/lottie/weather_cloudy.json` | Lottie animation for cloudy weather |
| `mobile/assets/lottie/weather_rainy.json` | Lottie animation for rainy weather |
| `mobile/lib/widgets/filter_chip_removable.dart` | Removable violet filter chip with X icon |

### Modified Files

| File | What Changes |
|------|-------------|
| `mobile/lib/app.dart` | Replace inline theme with AppTheme import, remove color constants |
| `mobile/lib/screens/home/home_screen.dart` | Replace BottomNavigationBar with FloatingNavBar |
| `mobile/lib/screens/discover/discover_screen.dart` | Rewrite with weather hero, section headers, horizontal scroll cards |
| `mobile/lib/screens/search/search_screen.dart` | Pill search bar, photo-forward cards, new filter chips |
| `mobile/lib/screens/events/events_screen.dart` | Date block cards, LIVE badges, new time filter tabs |
| `mobile/lib/screens/explore/explore_screen.dart` | Updated chip/marker/banner styling, cluster markers |
| `mobile/lib/screens/place_detail/place_detail_screen.dart` | Photo hero with gradient, info pills, gradient CTA |
| `mobile/lib/screens/event_detail/event_detail_screen.dart` | Hero with gradient, date/time card, venue map, gradient CTA |
| `mobile/lib/screens/settings/settings_screen.dart` | Playful cards layout with language tiles |
| `mobile/lib/widgets/category_chips.dart` | Updated colors and styling to new palette |
| `mobile/lib/l10n/app_en.arb` | Add greeting and weather suggestion keys |
| `mobile/lib/l10n/app_el.arb` | Add greeting and weather suggestion keys |
| `mobile/lib/l10n/app_ru.arb` | Add greeting and weather suggestion keys |
| `mobile/pubspec.yaml` | Add `lottie` dependency, declare asset paths |

### Deleted Files

| File | Reason |
|------|--------|
| `mobile/lib/widgets/weather_banner.dart` | Replaced by `weather_hero_card.dart` |
| `mobile/lib/widgets/weather_card.dart` | Replaced by `weather_hero_card.dart` |
| `mobile/lib/widgets/event_card.dart` | Replaced by `event_card_redesign.dart` |
| `mobile/lib/widgets/place_card.dart` | Replaced by `place_card_full_width.dart` |
| `mobile/lib/widgets/place_card_large.dart` | Replaced by `place_card_horizontal.dart` |
| `mobile/lib/widgets/cinema_card.dart` | Consolidated into `event_card_horizontal.dart` |
| `mobile/lib/widgets/theatre_card.dart` | Consolidated into `event_card_horizontal.dart` |
| `mobile/lib/widgets/skeleton_card.dart` | Replaced by `branded_skeleton.dart` |
| `mobile/lib/widgets/event_type_section.dart` | No longer needed — Events screen uses date-grouped feed |
| `mobile/lib/widgets/category_grid.dart` | Discover screen uses category chips instead |

---

## Phase 1: [UI/UX] Design System & Widgets (Tasks 1-6)

---

### Task 1: Design Tokens & Theme

**Agent:** [UI/UX]
**Files:**
- Create: `mobile/lib/theme/design_tokens.dart`
- Create: `mobile/lib/theme/app_theme.dart`
- Modify: `mobile/lib/app.dart`

- [ ] **Step 1: Create design_tokens.dart**

Define all constants from the spec: primary colors (Atlas Violet `#6C5CE7`, Violet Dark `#5A4BD1`, Violet Light `#A29BFE`, Violet Wash `#F0EDFF`), accent colors (Rose Pink `#FD79A8`, Aqua Teal `#00CEC9`, Honey Gold `#FDCB6E`, Coral Red `#FF7675`), category colors (7 categories), surfaces (Background `#FBF9FF`, Surface white, Text Primary `#2D3436`, Text Secondary `#636E72`, Text Tertiary `#B2BEC3`, Divider `#DFE6E9`), weather gradients, status colors, spacing tokens (xs=4, sm=8, md=12, lg=16, xl=24, xxl=32), border radii (cards=18, buttons=14, chips=20, sheet=24, searchBar=24, dateBlock=14, navBar=20, thumbnails=14, weatherHero=18, badges=10, iconContainers=12), shadow definitions for cards/nav/weather/buttons/liveEvents.

- [ ] **Step 2: Create app_theme.dart**

Build `AppTheme.lightTheme` using tokens. Set scaffold background to `AppColors.background`, card theme with 18dp radius and card shadow, chip theme with 20dp pill radius and Violet Wash selected, input decoration with 24dp pill radius, button themes with 14dp radius and violet gradient, text theme with Nunito at all specified sizes/weights. Use `useMaterial3: true`.

- [ ] **Step 3: Update app.dart**

Remove all inline color constants (`atlasGreen`, `atlasGreenDark`, etc.) and the inline `ThemeData` block. Import `app_theme.dart` and set `theme: AppTheme.lightTheme`. Keep providers, localization, and routing unchanged.

- [ ] **Step 4: Verify app still compiles**

Run: `cd mobile && flutter analyze`
Expected: No errors related to theme (existing widget files will have color reference errors — that's expected and will be fixed in later tasks).

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/theme/ mobile/lib/app.dart
git commit -m "feat(mobile): add Soft Modern design tokens and theme"
```

---

### Task 2: Foundation Widgets — InfoPill, GradientButton, SectionHeader, DateBlock, FilterChipRemovable

**Agent:** [UI/UX]
**Files:**
- Create: `mobile/lib/widgets/info_pill.dart`
- Create: `mobile/lib/widgets/gradient_button.dart`
- Create: `mobile/lib/widgets/section_header.dart`
- Create: `mobile/lib/widgets/date_block.dart`
- Create: `mobile/lib/widgets/filter_chip_removable.dart`

- [ ] **Step 1: Create info_pill.dart**

Stateless widget. Props: `label` (String), `icon` (String/IconData, optional), `backgroundColor` (Color), `textColor` (Color). Renders a Container with 12dp radius, tinted background, row of icon + label in specified color. Height ~28dp. Used for open/closed status, distance, age range, closing time.

- [ ] **Step 2: Create gradient_button.dart**

Stateless widget. Props: `label` (String), `onTap` (VoidCallback), `icon` (IconData, optional), `enabled` (bool, default true). Full-width container, 14dp radius, linear gradient from Atlas Violet to Violet Light, white text (15sp Bold Nunito), 16dp vertical padding. Shadow: `0 4px 14dp rgba(108,92,231,0.3)`. Disabled state: 45% opacity. Haptic feedback on tap via `HapticFeedback.lightImpact()`.

- [ ] **Step 3: Create section_header.dart**

Stateless widget. Props: `title` (String), `onSeeAll` (VoidCallback?, optional). Row: left side = title in 12sp Bold ALL CAPS, letter-spacing 1.0, Text Secondary color. Right side = "See all" in 12sp SemiBold Atlas Violet (only shown if `onSeeAll` is non-null). Bottom padding 8dp.

- [ ] **Step 4: Create date_block.dart**

Stateless widget. Props: `date` (DateTime), `gradient` (List<Color>, default violet gradient). Container 56x56dp, 14dp radius, gradient background. Column centered: month (8sp Bold uppercase, 85% opacity white), day (20sp ExtraBold white), weekday abbreviation (8sp SemiBold, 85% opacity white).

- [ ] **Step 5: Create filter_chip_removable.dart**

Stateless widget. Props: `label` (String), `onRemove` (VoidCallback), `backgroundColor` (Color, default Violet Wash), `textColor` (Color, default Atlas Violet). Container with specified background, 20dp pill radius. Row: label text (12sp SemiBold) + X icon (50% opacity, tappable, calls `onRemove`). Used in Search screen for active filters. Haptic feedback on remove.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/widgets/info_pill.dart mobile/lib/widgets/gradient_button.dart mobile/lib/widgets/section_header.dart mobile/lib/widgets/date_block.dart mobile/lib/widgets/filter_chip_removable.dart
git commit -m "feat(mobile): add foundation widgets — InfoPill, GradientButton, SectionHeader, DateBlock, FilterChipRemovable"
```

---

### Task 3: LiveBadge, BrandedSkeleton, FloatingNavBar

**Agent:** [UI/UX]
**Files:**
- Create: `mobile/lib/widgets/live_badge.dart`
- Create: `mobile/lib/widgets/branded_skeleton.dart`
- Create: `mobile/lib/widgets/floating_nav_bar.dart`

- [ ] **Step 1: Create live_badge.dart**

Stateful widget with `SingleTickerProviderStateMixin`. Animates a pink dot that scales 0.8→1.2 on a 1-second loop (repeat). Container with Rose Pink gradient background, 10dp border radius, row of animated dot + "LIVE" text (9sp Bold white). Glow shadow: `BoxShadow(color: FD79A8 at 40%, blurRadius animates 4→8)`.

- [ ] **Step 2: Create branded_skeleton.dart**

Stateful widget with shimmer animation. Uses `AnimationController` with 1500ms duration, linear, repeat. `ShaderMask` or gradient that slides across the widget. Base color: Violet Wash `#F0EDFF`. Highlight color: white. Props: `width`, `height`, `borderRadius` (default 18dp). Can render card-shaped, text-line-shaped, or circle-shaped skeletons.

- [ ] **Step 3: Create floating_nav_bar.dart**

Stateless widget. Props: `currentIndex` (int), `onTap` (Function(int)). Positioned at bottom of screen with 12dp margin all sides. White container, 20dp radius, shadow `0 4px 16dp rgba(0,0,0,0.1)`. Row of 5 items: Discover (explore icon), Search (search icon), Events (event icon), Map (map icon), Settings (settings icon). Active tab: Atlas Violet colored icon + label + 4dp violet dot above. Inactive: 40% opacity icon + `#B2BEC3` label. All items use Material Icons. Touch targets minimum 48x48dp. Haptic feedback on tab switch.

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/widgets/live_badge.dart mobile/lib/widgets/branded_skeleton.dart mobile/lib/widgets/floating_nav_bar.dart
git commit -m "feat(mobile): add LiveBadge, BrandedSkeleton, FloatingNavBar widgets"
```

---

### Task 4: Weather Hero Card + Lottie Setup

**Agent:** [UI/UX]
**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/assets/lottie/weather_sunny.json`
- Create: `mobile/assets/lottie/weather_cloudy.json`
- Create: `mobile/assets/lottie/weather_rainy.json`
- Create: `mobile/lib/widgets/weather_hero_card.dart`

- [ ] **Step 1: Add lottie dependency and create assets directory**

Add `lottie: ^3.3.1` to `pubspec.yaml` dependencies. Create the `mobile/assets/lottie/` directory. Add a `flutter.assets` section to `pubspec.yaml` if one doesn't exist, then add `- assets/lottie/` to it. Run `flutter pub get`.

- [ ] **Step 2: Download and bundle Lottie weather animations**

Source free weather animations from LottieFiles. Save as `weather_sunny.json`, `weather_cloudy.json`, `weather_rainy.json` in `mobile/assets/lottie/`. Target ~10KB each, maximum 15KB. These are bundled assets for offline support.

- [ ] **Step 3: Create weather_hero_card.dart**

Stateless widget. Props: `temperature` (double), `description` (String), `weatherMode` (String: outdoor/indoor/caution), `suggestion` (String). Full-width container, 18dp radius, gradient background based on mode (outdoor: `#FFEAA7`→`#FDCB6E`, indoor: `#DFE6E9`→`#A29BFE`, caution: `#FFECD2`→`#FAB1A0`). Shadow using gradient color at 25% opacity. Row: Lottie animation (48x48 in white circle, 35% opacity background) + Column of temperature + condition (20sp Bold) and suggestion text (13sp). Text colors per mode from spec. Select Lottie file based on weather description (contains "rain" → rainy, "cloud" → cloudy, else → sunny).

- [ ] **Step 4: Commit**

```bash
git add mobile/pubspec.yaml mobile/assets/lottie/ mobile/lib/widgets/weather_hero_card.dart
git commit -m "feat(mobile): add WeatherHeroCard with Lottie animations"
```

---

### Task 5: Place Cards (Horizontal + Full-Width)

**Agent:** [UI/UX]
**Files:**
- Create: `mobile/lib/widgets/place_card_horizontal.dart`
- Create: `mobile/lib/widgets/place_card_full_width.dart`

- [ ] **Step 1: Create place_card_horizontal.dart**

Stateless widget. Props: `place` (Place model), `onTap` (VoidCallback). Fixed 160dp wide, white card, 18dp radius, shadow. Top: 110dp image area — if place has photos use `CachedNetworkImage`, else gradient using category color. Open status badge top-left (white pill, green dot + "Open"/"Closed"). Bottom gradient overlay with name (14sp SemiBold white) + distance. Below image: category pill (pink tint) + age pill (violet tint) + up to 2 amenity pills (gray tint, use `amenity_utils.dart` for emoji resolution). Staggered fade-in animation on build (slide up 20dp + fade, 300ms, easeOutCubic).

- [ ] **Step 2: Create place_card_full_width.dart**

Stateless widget. Props: `place` (Place model), `onTap` (VoidCallback), `onShowOnMap` (VoidCallback?). Full-width, 18dp radius, shadow. Image area: 160dp height, `CachedNetworkImage` or category gradient placeholder. Bottom gradient overlay (`rgba(0,0,0,0.6)` → transparent) with name (18sp Bold white) + category + distance + open status. "Show on Map" badge top-right (white pill, 10sp SemiBold) — calls `onShowOnMap`. Below image: amenity chips row (Violet Wash background, violet text, 12dp radius). Import `amenity_utils.dart` for emoji resolution.

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/widgets/place_card_horizontal.dart mobile/lib/widgets/place_card_full_width.dart
git commit -m "feat(mobile): add PlaceCardHorizontal and PlaceCardFullWidth widgets"
```

---

### Task 6: Event Cards (Horizontal + Redesigned Feed) + Settings Widgets

**Agent:** [UI/UX]
**Files:**
- Create: `mobile/lib/widgets/event_card_horizontal.dart`
- Create: `mobile/lib/widgets/event_card_redesign.dart`
- Create: `mobile/lib/widgets/language_tile.dart`
- Create: `mobile/lib/widgets/settings_card.dart`

- [ ] **Step 1: Create event_card_horizontal.dart**

Stateless widget. Props: `event` (Event model), `onTap` (VoidCallback). Fixed 160dp wide, 210dp tall. White card, 18dp radius. Top: 110dp gradient image (event-type-based gradient colors). LIVE badge overlay (bottom-left) if event is happening now. Below: event name (12sp SemiBold), time range (10sp, Text Secondary), distance (10sp, Text Tertiary), age pill.

- [ ] **Step 2: Create event_card_redesign.dart**

Stateless widget. Props: `event` (Event model), `onTap` (VoidCallback). White card, 18dp radius. Row: DateBlock (56x56, gradient from event category color) + Column of event title (15sp SemiBold), time + venue (12sp), age + distance InfoPills. If happening now: left border 4dp Rose Pink, pink glow shadow, LiveBadge next to title. Uses `HapticFeedback.lightImpact()` on tap.

- [ ] **Step 3: Create language_tile.dart**

Stateless widget. Props: `flag` (String emoji), `languageName` (String), `isSelected` (bool), `onTap` (VoidCallback). Expanded flex child. White card, 18dp radius. Selected: violet border (2.5dp), Violet Wash gradient top, violet dot below. Unselected: Divider border. Center: flag emoji (36sp) + language name (13sp, weight varies by selected state).

- [ ] **Step 4: Create settings_card.dart**

Stateless widget. Props: `icon` (IconData), `iconGradient` (List<Color>), `title` (String), `subtitle` (String?), `child` (Widget). White card, 18dp radius, shadow. Top row: gradient icon container (40x40, 12dp radius) + title (15sp Bold) + optional subtitle (11sp, Text Secondary). Below: child widget slot for content.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/widgets/event_card_horizontal.dart mobile/lib/widgets/event_card_redesign.dart mobile/lib/widgets/language_tile.dart mobile/lib/widgets/settings_card.dart
git commit -m "feat(mobile): add EventCardHorizontal, EventCardRedesign, LanguageTile, SettingsCard widgets"
```

---

## Phase 2: [Frontend Dev] Screen Implementation (Tasks 7-13)

---

### Task 7: Home Screen + Floating Nav Bar Integration

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/home/home_screen.dart`

- [ ] **Step 1: Read current home_screen.dart**

Understand the current tab controller, IndexedStack, and BottomNavigationBar setup.

- [ ] **Step 2: Replace BottomNavigationBar with FloatingNavBar**

Change the Scaffold body to a `Stack`. Bottom layer: `IndexedStack` with the 5 tab screens (same as before). Top layer: `Positioned(bottom: 0, left: 0, right: 0, child: FloatingNavBar(...))`. Remove the old `bottomNavigationBar` property. Wire `currentIndex` and `onTap` to the existing tab state. Ensure `IndexedStack` has bottom padding (80dp) so content doesn't hide behind the floating nav.

- [ ] **Step 3: Update tab labels**

Tab 0: "Discover" (was already), Tab 3: "Map" (was "Explore"). Ensure icons match spec: explore, search, event, map, settings.

- [ ] **Step 4: Verify navigation works**

Run: `cd mobile && flutter analyze`
Verify all 5 tabs switch correctly and state is preserved.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/screens/home/home_screen.dart
git commit -m "feat(mobile): integrate FloatingNavBar in home screen"
```

---

### Task 8: Discover Screen Rewrite

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/discover/discover_screen.dart`
- Modify: `mobile/lib/l10n/app_en.arb`
- Modify: `mobile/lib/l10n/app_el.arb`
- Modify: `mobile/lib/l10n/app_ru.arb`

- [ ] **Step 1: Add localization keys for greetings and weather suggestions**

Add to all 3 ARB files: `greetingMorning` ("Good morning"), `greetingAfternoon` ("Good afternoon"), `greetingEvening` ("Good evening"), `weatherSuggestionOutdoor` ("Perfect day for the beach!"), `weatherSuggestionIndoor` ("Cozy indoor day! Try a museum"), `weatherSuggestionCaution` ("Stay cool — indoor fun today!"), `happeningNow` ("Happening Now"), `nearbyCategory` ("Nearby {category}"), `popularThisWeek` ("Popular This Week"). Translate to Greek and Russian.

- [ ] **Step 2: Rewrite discover_screen.dart**

Replace entire body with a `SingleChildScrollView` containing:
1. **Greeting** — time-based text using `DateTime.now().hour` to select greeting key. City name uses hardcoded "Cyprus" for v1 (reverse geocoding deferred to avoid adding a new dependency). Fade-in with `AnimatedOpacity` on first load.
2. **WeatherHeroCard** — reads from `WeatherProvider`, passes temp/description/mode/suggestion. 16dp horizontal margin.
3. **Category chips** — horizontal scroll row using existing `CategoryChips` widget (update its colors in a later step).
4. **"Happening Now" SectionHeader** + horizontal `ListView.builder` of `EventCardHorizontal` cards. Data from `EventsProvider.happeningNow`. Only show section if events exist.
5. **"Nearby [Category]" SectionHeader** + horizontal `ListView.builder` of `PlaceCardHorizontal`. Data from `PlacesProvider`. Dynamic category name from most common category nearby.
6. **"Popular This Week" SectionHeader** (if 3+ places) + vertical list of `PlaceCardFullWidth`.

Each section wrapped in `Padding(xl)` spacing between them. Use `BrandedSkeleton` for loading states. Handle empty/error states: offline banner (Violet Wash background, "You're offline — showing cached data"), location denied (full-screen friendly message + settings button), rainy-day suggestion ("Rainy day? Check out indoor activities!" + one-tap filter to indoor).

- [ ] **Step 3: Wire navigation**

`PlaceCardHorizontal.onTap` → `Navigator.push` to `PlaceDetailScreen`. `EventCardHorizontal.onTap` → `Navigator.push` to `EventDetailScreen`. `SectionHeader.onSeeAll` for events → switch to Events tab. `SectionHeader.onSeeAll` for places → switch to Search tab with category pre-filtered.

- [ ] **Step 4: Commit**

```bash
git add mobile/lib/screens/discover/discover_screen.dart mobile/lib/l10n/
git commit -m "feat(mobile): rewrite Discover screen with weather hero and curated sections"
```

---

### Task 9: Search Screen Redesign

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/search/search_screen.dart`

- [ ] **Step 1: Read current search_screen.dart**

Understand existing search, filter, and results state management.

- [ ] **Step 2: Redesign search bar**

Replace current search bar with pill-shaped: 24dp radius, white fill, shadow `0 2px 8dp rgba(0,0,0,0.06)`, border `1dp #DFE6E9`. Search icon left (`#B2BEC3`), filter icon right (Atlas Violet, taps open FilterSheet). Auto-focus on tab tap, 300ms debounce (keep existing logic).

- [ ] **Step 3: Redesign active filter chips**

Replace current filter chips with new styling: Violet Wash background, Atlas Violet text, X icon to remove (50% opacity). "Clear all" link in Atlas Violet when 2+ filters active. Row below search bar with horizontal scroll + wrap.

- [ ] **Step 4: Replace result cards with PlaceCardFullWidth**

Replace current `PlaceCard` usage with `PlaceCardFullWidth`. Wire `onTap` to place detail navigation. Wire `onShowOnMap` to switch to Map tab (`HomeScreen.switchTab(context, 3)`) centered on place coordinates (pass via provider or navigator argument).

- [ ] **Step 5: Update loading/empty/error states**

Loading: use `BrandedSkeleton` (3 stacked full-width card skeletons). Empty: violet-wash background, friendly text "No places found — try adjusting your filters" + clear filters button. Error: snackbar "Couldn't load places. Pull to retry."

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/search/search_screen.dart
git commit -m "feat(mobile): redesign Search screen with pill bar and photo-forward cards"
```

---

### Task 10: Events Screen Redesign

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/events/events_screen.dart`

- [ ] **Step 1: Read current events_screen.dart**

Understand existing tab controller, event type sections, date grouping logic.

- [ ] **Step 2: Rewrite header and time filter tabs**

Title: "Events" (22sp Bold). Below: row of 3 filter pills — "This Week" / "This Month" / "All". Selected: Atlas Violet fill, white text, 12dp radius. Unselected: white fill, Divider border. Wire to existing `EventsProvider.setTimeFilter()`. Add haptic feedback on selection.

- [ ] **Step 3: Replace event type sections with date-grouped feed**

Remove the Cinema/Theatre/Workshops/Festivals horizontal sections. Replace with a single chronological feed grouped by date. Date group headers: use `SectionHeader` style (12sp Bold ALL CAPS, no "See all" link). Show "TODAY", "TOMORROW", or formatted date. Each event renders as `EventCardRedesign` with `DateBlock`. LIVE events get `LiveBadge` and pink border/shadow.

- [ ] **Step 4: Add empty state for no events**

When no events match the time filter, show: "Quiet week! Here are some places to explore anytime." with a `GradientButton` that switches to the Discover tab. Use Violet Wash background.

- [ ] **Step 5: Wire navigation and add pull-to-refresh haptic**

`EventCardRedesign.onTap` → `Navigator.push` to `EventDetailScreen`. Add `HapticFeedback.lightImpact()` on pull-to-refresh release.

- [ ] **Step 6: Commit**

```bash
git add mobile/lib/screens/events/events_screen.dart
git commit -m "feat(mobile): redesign Events screen with date blocks and LIVE badges"
```

---

### Task 11: Map (Explore) Screen Update

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/explore/explore_screen.dart`
- Modify: `mobile/lib/widgets/category_chips.dart`

- [ ] **Step 1: Update category_chips.dart colors and animations**

Replace all Atlas Green references with new palette. Unselected: white fill, Divider border. Selected: Violet Wash fill, Atlas Violet border, checkmark. Update category color map to use new hex values from design tokens (Playgrounds=#FF9F43, Parks=#00B894, Restaurants=#E17055, Entertainment=#6C5CE7, Culture=#74B9FF, Sports=#00CEC9). Add haptic feedback on toggle via `HapticFeedback.lightImpact()`. Add chip select scale animation: wrap each chip in `AnimatedScale` (1.0 → 1.05 → 1.0, 150ms, easeIn).

- [ ] **Step 2: Update explore_screen.dart styling**

Replace `WeatherBanner` import with `WeatherHeroCard` (compact variant or just use the same card with reduced padding). Update bottom sheet top radius to 24dp. Update "My location" FAB: white circle, Atlas Violet icon. Update bottom sheet content padding for new card sizes.

- [ ] **Step 3: Update map markers**

Update marker colors to new category palette. Cluster markers: 36dp gray circle (`#B2BEC3`), white count text (13sp Bold). Selected marker: 44dp with white border (3dp). For LIVE event markers: add a fading pink ring animation around the marker (Rose Pink at 40% opacity, scale 1.0→1.5 + fade out, 1.5s loop).

- [ ] **Step 4: Replace place cards in bottom sheet**

Replace `PlaceCard` usage in the bottom sheet's scrollable list with `PlaceCardHorizontal` or a compact list variant using the new design tokens. Wire `onTap` to `PlaceDetailScreen`.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/screens/explore/explore_screen.dart mobile/lib/widgets/category_chips.dart
git commit -m "feat(mobile): update Map screen and category chips to new palette"
```

---

### Task 12: Place Detail + Event Detail Screens

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/place_detail/place_detail_screen.dart`
- Modify: `mobile/lib/screens/event_detail/event_detail_screen.dart`

- [ ] **Step 1: Redesign place_detail_screen.dart**

Rewrite the screen layout:
1. **Photo carousel hero** — 220dp, existing `PageView` for photos, add bottom gradient overlay (`rgba(0,0,0,0.7)` → transparent). White place name (22sp ExtraBold) + category + city on gradient. Back button: white circle (36dp), top-left, shadow.
2. **Quick info pills** — Row of `InfoPill` widgets: open status (green tint), distance (violet tint), age range (pink tint), closing time (gold tint).
3. **Amenities** — `SectionHeader` (no "See all") + Wrap of amenity chips (gray `#F8F9FA` background, 12dp radius, emoji + text).
4. **About** — `SectionHeader` + body text (13sp, 1.6 line height).
5. **Details** — Address/phone/website rows with violet icons. Website tappable in violet.
6. **CTA** — `GradientButton` "Get Directions" at bottom.

- [ ] **Step 2: Redesign event_detail_screen.dart**

Rewrite:
1. **Hero** — 220dp gradient (event category colors). Back button. Title (20sp ExtraBold white) + `LiveBadge` if active + category subtitle.
2. **Date/time card** — White card, `DateBlock` (60x60, violet gradient) + "Today, 10:00-18:00" (15sp Bold) + duration.
3. **Info pills** — Age, distance, price (`InfoPill` with green "Free!" if applicable).
4. **About** — `SectionHeader` + description.
5. **Venue** — `SectionHeader` + mini-map placeholder (100dp, gradient background) with venue name. Address below.
6. **CTA** — `GradientButton` "Get Directions".

- [ ] **Step 3: Commit**

```bash
git add mobile/lib/screens/place_detail/place_detail_screen.dart mobile/lib/screens/event_detail/event_detail_screen.dart
git commit -m "feat(mobile): redesign Place Detail and Event Detail screens"
```

---

### Task 13: Settings Screen + Cleanup + Final Polish

**Agent:** [Frontend Dev]
**Files:**
- Modify: `mobile/lib/screens/settings/settings_screen.dart`
- Delete: old widget files (see file structure above)

- [ ] **Step 1: Rewrite settings_screen.dart**

Playful Cards layout:
1. **Header** — "Settings" (22sp Bold) + "Make Little Atlas yours" (13sp, Text Secondary).
2. **Language card** — `SettingsCard` with globe icon (violet gradient). Content: Row of 3 `LanguageTile` widgets. Wire to `SettingsProvider.changeLanguage()`. Read current locale from provider to set `isSelected`.
3. **Data Sources card** — `SettingsCard` with chart icon (teal gradient). Content: Row of colored pills — "OpenStreetMap" (teal), "Google Places" (violet), "OpenWeather" (gold).
4. **Legal card** — `SettingsCard` with document icon (gold gradient). Content: Row of 2 tappable gray tiles — "Privacy" and "Terms". Wire to `url_launcher`.
5. **Branding footer** — "Little Atlas" (18sp ExtraBold violet) + version from `PackageInfo` + " · Made with love in Cyprus".

- [ ] **Step 2: Add package_info_plus dependency**

Add `package_info_plus: ^8.2.1` to pubspec.yaml for dynamic version. Run `flutter pub get`.

- [ ] **Step 3: Delete old widget files**

Remove: `weather_banner.dart`, `weather_card.dart`, `event_card.dart`, `place_card.dart`, `place_card_large.dart`, `cinema_card.dart`, `theatre_card.dart`, `skeleton_card.dart`, `event_type_section.dart`, `category_grid.dart`. Verify no remaining imports reference these files.

- [ ] **Step 4: Run full analysis and fix any remaining issues**

Run: `cd mobile && flutter analyze`
Fix any import errors, unused imports, or type mismatches. Ensure all files compile clean.

- [ ] **Step 5: Commit**

```bash
git add -A mobile/
git commit -m "feat(mobile): redesign Settings screen, remove old widgets, final cleanup"
```

---

### Task 14: Accessibility & Micro-interaction Polish

**Agent:** [Frontend Dev]
**Files:**
- Modify: multiple screen and widget files

- [ ] **Step 1: Add Semantics wrappers to images**

Add `Semantics(label: ...)` to all `CachedNetworkImage` and photo carousel images in `place_card_horizontal.dart`, `place_card_full_width.dart`, `place_detail_screen.dart`, `event_detail_screen.dart`. Label should describe the place/event name.

- [ ] **Step 2: Add custom page route transitions**

Create a shared `SlideUpRoute` or modify `Navigator.push` calls across all screens to use `PageRouteBuilder` with slide + fade transition (250ms, easeInOut) per spec §6. Apply to all `Navigator.push` calls in home, discover, search, events screens.

- [ ] **Step 3: Add bottom sheet spring physics**

In `explore_screen.dart`, update `DraggableScrollableSheet` to use spring-based snap physics (300ms). Add `HapticFeedback.lightImpact()` on snap point changes.

- [ ] **Step 4: Verify text scaling**

Run app with system font size set to largest. Verify no text overflows or layout breaks. Fix any `overflow: TextOverflow.ellipsis` or `maxLines` issues.

- [ ] **Step 5: Commit**

```bash
git add -A mobile/
git commit -m "feat(mobile): add accessibility semantics and micro-interaction polish"
```

---

## Task 15: Playwright API Tests Verification

**Agent:** [QA]
**Files:**
- Existing: `tests/api.spec.ts`

- [ ] **Step 1: Run existing Playwright tests**

Run: `npx playwright test`
Expected: All 32 existing tests pass (no backend changes were made).

- [ ] **Step 2: Commit any test fixes if needed**

```bash
git commit -m "test: verify API tests pass after UI redesign"
```

---

## Summary

| Phase | Tasks | Agent | Description |
|-------|-------|-------|-------------|
| 1 | 1-6 | [UI/UX] | Design tokens, theme, all 17 shared widgets |
| 2 | 7-14 | [Frontend Dev] | All 7 screens rewired + accessibility polish |
| 3 | 15 | [QA] | Verify existing tests still pass |

**Total: 15 tasks, ~65 steps**
