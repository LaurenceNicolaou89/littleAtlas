# Little Atlas — UI/UX Design Guidelines

## Design Philosophy

- **Parents are busy** — every interaction should be fast and require minimal taps
- **Glanceable** — key info (weather, distance, open/closed) visible without tapping into details
- **Friendly but not childish** — the app is for parents, not kids. Clean, modern, warm aesthetic
- **Map-first** — the map is the hero. Discovery starts visually on the map

## App Structure

### Navigation

Bottom navigation bar with 4 tabs:

```
┌─────────────────────────────────────────┐
│                                         │
│            [Screen Content]             │
│                                         │
│                                         │
├────────┬──────────┬─────────┬───────────┤
│  🗺️    │  🔍      │  📅     │  ⚙️       │
│Explore │ Search   │ Events  │ Settings  │
└────────┴──────────┴─────────┴───────────┘
```

- **Explore** — map with nearby places, weather banner at top
- **Search** — text search with filter chips and list results
- **Events** — chronological feed of upcoming events
- **Settings** — language picker, about, data sources

### Screen Flow

```
Explore (Map) ──tap marker──> Place Detail
     │
     └──tap category chip──> Filtered Map View

Search ──type query──> Results List ──tap──> Place Detail

Events ──tap event──> Event Detail

Settings ──tap language──> Language Picker
```

## Screen Designs

### 1. Explore Screen (Home)

```
┌─────────────────────────────────┐
│ ☀️ 28°C Sunny — Great for      │  ← Weather banner (dynamic color)
│ outdoor activities!             │
├─────────────────────────────────┤
│ [Playgrounds] [Parks] [Food]   │  ← Category chips (horizontal scroll)
│ [Fun] [Culture] [Sports]       │
├─────────────────────────────────┤
│                                 │
│         ┌───┐                   │
│    📍   │ 🏖️│    📍             │  ← Map with place markers
│         └───┘                   │
│   📍              📍            │
│              📍                 │
│                                 │
│     📍       📍                 │
│                                 │
├─────────────────────────────────┤
│ ↑ Pull up for nearby places    │  ← Bottom sheet (draggable)
│ ┌─────────────────────────────┐│
│ │ 🏖️ Mackenzie Beach    1.2km││  ← Place cards in bottom sheet
│ │    Beach · Open · 0-12 yrs  ││
│ ├─────────────────────────────┤│
│ │ 🎪 Luna Park Larnaca  2.5km││
│ │    Entertainment · Open     ││
│ └─────────────────────────────┘│
└─────────────────────────────────┘
```

**Weather Banner:**
- Spans full width at top of map
- Dynamic background color based on weather mode:
  - Outdoor: warm gradient (amber/yellow)
  - Indoor: cool gradient (blue/indigo)
  - Caution: subtle orange gradient
- Shows: icon + temp + short recommendation text
- Tappable to expand to 3-hour forecast

**Category Chips:**
- Horizontal scrollable row overlaid on map
- Unselected: white with outline
- Selected: filled with category color
- Tap to filter map markers
- Multiple selection allowed

**Map:**
- Full screen behind weather banner and chips
- Custom markers per category (colored circles with category icon)
- Cluster markers when zoomed out
- "My location" button (bottom right)
- Tap marker → show place preview card

**Bottom Sheet (Draggable):**
- Collapsed: shows "Pull up for nearby places" handle
- Half-expanded: shows 2-3 place cards
- Full-expanded: scrollable list of all nearby places
- Place cards show: icon, name, category, distance, open/closed status, age range

### 2. Search Screen

```
┌─────────────────────────────────┐
│ 🔍 Search places...            │  ← Search bar
├─────────────────────────────────┤
│ [< 5km] [Indoor] [0-3 yrs]    │  ← Active filter chips
│ [+ Add filter]                  │
├─────────────────────────────────┤
│ ┌─────────────────────────────┐│
│ │ 🖼️ │ Pirate Park            ││  ← Results with thumbnails
│ │    │ Playground · 0.8km     ││
│ │    │ ⭐ Fenced · Shade      ││
│ ├────┼────────────────────────┤│
│ │ 🖼️ │ Happy Kids Cafe        ││
│ │    │ Restaurant · 1.3km     ││
│ │    │ ⭐ Kids Menu · Highchair││
│ └────┴────────────────────────┘│
└─────────────────────────────────┘
```

**Search Bar:**
- Auto-focus on tab tap
- Search as you type (300ms debounce)
- Recent searches shown when empty

**Filter System:**
- Tap "+ Add filter" → shows filter bottom sheet with sections:
  - Distance: 1km / 5km / 10km / 25km
  - Category: multi-select checkboxes
  - Age: infant / toddler / preschool / school-age
  - Type: indoor / outdoor / both
  - Amenities: multi-select checkboxes
- Active filters shown as removable chips below search bar
- "Clear all" button when filters are active

**Results:**
- Vertical scrollable list
- Each result shows: thumbnail, name, category, distance, top 2 amenities
- Empty state: "No places found. Try adjusting your filters."

### 3. Place Detail Screen

```
┌─────────────────────────────────┐
│ ← Back                         │
│ ┌─────────────────────────────┐│
│ │                             ││
│ │      [Photo Carousel]      ││  ← Swipeable photos
│ │                             ││
│ └─────────────────────────────┘│
│                                 │
│ Mackenzie Beach                 │  ← Title
│ Beach · Larnaca                 │  ← Category + city
│                                 │
│ 🟢 Open now · Closes 8:00 PM  │  ← Status
│ 📍 1.2 km away                 │  ← Distance
│ 👶 Ages 0-12                   │  ← Age suitability
│                                 │
│ ─── Amenities ───              │
│ [🚻 Toilets] [🅿️ Parking]     │  ← Amenity chips
│ [♿ Accessible] [🚿 Showers]   │
│                                 │
│ ─── About ───                  │
│ Beautiful sandy beach with      │  ← Description
│ shallow waters, perfect for...  │
│                                 │
│ ─── Details ───                │
│ 📍 Mackenzie Beach Rd, Larnaca │  ← Address (tappable → maps)
│ 📞 +357 24 123456             │  ← Phone (tappable → dial)
│ 🌐 www.example.com            │  ← Website (tappable → browser)
│                                 │
│ [🗺️ Get Directions]            │  ← Opens native maps app
└─────────────────────────────────┘
```

### 4. Events Screen

```
┌─────────────────────────────────┐
│ Events                          │
│ [This Week] [This Month] [All] │  ← Time filter tabs
├─────────────────────────────────┤
│ ── TODAY ──                     │
│ ┌─────────────────────────────┐│
│ │ 🎪 Carnival at Limassol     ││
│ │ 🕐 10:00 - 18:00           ││
│ │ 📍 Limassol Marina · 5.2km ││
│ │ 👶 Ages 2-12               ││
│ ├─────────────────────────────┤│
│ │ 📖 Story Time at Library    ││
│ │ 🕐 16:00 - 17:00           ││
│ │ 📍 Larnaca Library · 1.1km ││
│ │ 👶 Ages 3-8                ││
│ └─────────────────────────────┘│
│                                 │
│ ── TOMORROW ──                  │
│ ┌─────────────────────────────┐│
│ │ ...                         ││
│ └─────────────────────────────┘│
└─────────────────────────────────┘
```

**Events Feed:**
- Grouped by date with sticky date headers
- "Happening Now" events highlighted with accent border
- Each event card: title, time, venue + distance, age range
- Time filter tabs: This Week / This Month / All
- Empty state: "No upcoming events nearby."

### 5. Settings Screen

```
┌─────────────────────────────────┐
│ Settings                        │
├─────────────────────────────────┤
│                                 │
│ Language                        │
│ ┌─────────────────────────────┐│
│ │ 🇬🇧 English          ✓     ││
│ │ 🇬🇷 Ελληνικά               ││
│ │ 🇷🇺 Русский                ││
│ └─────────────────────────────┘│
│                                 │
│ About                           │
│ ┌─────────────────────────────┐│
│ │ Version 1.0.0               ││
│ │ Data Sources                ││
│ │ Privacy Policy              ││
│ │ Terms of Service            ││
│ └─────────────────────────────┘│
└─────────────────────────────────┘
```

## User Flows

### Primary Flow: "What's nearby?"

1. User opens app → Explore tab loads with current location
2. Weather banner shows current conditions + recommendation
3. Map shows nearby family-friendly places
4. User pulls up bottom sheet → sees sorted list
5. User taps a place → sees detail with photos, amenities, directions

### Flow: "Where to go when it's raining?"

1. App detects rain → weather banner turns blue, says "Rainy — try indoor places!"
2. Map automatically filters to show indoor places prominently
3. Outdoor places are faded/demoted on map and in list
4. User browses indoor options and picks one

### Flow: "Any events this weekend?"

1. User taps Events tab
2. Defaults to "This Week" filter
3. Scrolls through chronological event list
4. Taps event → sees details with directions

### Flow: "Find a restaurant with a play area"

1. User taps Search tab
2. Types "restaurant" → sees results
3. Taps "+ Add filter" → selects "Restaurants" category
4. Adds amenity filter → selects "Kids Menu" and "Fenced Area"
5. Results narrow to matching restaurants

## Interaction Patterns

### Map Interactions
- **Pan & zoom**: standard gestures
- **Tap marker**: show place preview card above marker
- **Tap preview card**: navigate to place detail
- **Tap cluster**: zoom in to expand cluster
- **Long press on map**: no action (keep simple)

### Bottom Sheet
- **Drag up**: expand to see more places
- **Drag down**: collapse
- **Scroll inside**: scroll the place list when fully expanded
- **Tap place card**: navigate to place detail

### Pull to Refresh
- Available on Search results and Events feed
- Refreshes data from API

### Loading States
- Map: show map immediately, markers appear as they load
- Lists: skeleton cards (gray shimmer placeholders)
- Place detail: skeleton layout with photo placeholder

### Empty States
- Search no results: illustration + "No places found" + suggestion to adjust filters
- Events no results: illustration + "No upcoming events"
- Offline: banner at top "You're offline — showing cached data"

### Error States
- API error: toast/snackbar "Couldn't load places. Pull to retry."
- Location denied: full screen prompt explaining why location is needed + settings link
- No internet on first launch: full screen "Connect to the internet to get started"

## Accessibility

- All interactive elements: minimum 48x48dp touch targets
- All images: content descriptions for screen readers
- Color is never the only indicator — always pair with icon or text
- Weather mode indicated by both color AND text
- Support system font size scaling
- Test with TalkBack (Android) and VoiceOver (iOS)
