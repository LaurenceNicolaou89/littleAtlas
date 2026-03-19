# Little Atlas UI Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Little Atlas from a map-first explorer into a warm, browsable "what to do today" family activity discovery app with event sub-types (cinema, theatre, workshops, festivals).

**Architecture:** Two-phase approach — (A) Backend adds `event_type` field + cinema/theatre crawlers, (B) Frontend redesign: new Discovery home feed, event sub-type sections, demoted map tab, warm Mediterranean editorial theme. Existing providers/services are refactored, not rewritten.

**Tech Stack:** Flutter/Dart (frontend), FastAPI/PostGIS (backend), Playwright (testing), Provider (state management), Google Fonts Nunito (typography)

---

## Phase A: Backend — Event Sub-Types

### Task 1: Add event_type to Event model + migration

**Files:**
- Modify: `backend/models/event.py`
- Modify: `backend/schemas/event.py`
- Modify: `backend/services/event_service.py`
- Modify: `backend/api/routes/events.py`
- Modify: `backend/crawlers/event_crawler.py` (upsert method)
- Create: Alembic migration (auto-generated filename via `alembic revision --autogenerate`)

- [ ] **Step 1: Add event_type column to Event model**

In `backend/models/event.py`, add after `source`:
```python
event_type = mapped_column(String(50), nullable=True, default=None)
# Values: "cinema", "theatre", "workshop", "festival", "general"
```

- [ ] **Step 2: Create Alembic migration**

```bash
cd backend && alembic revision --autogenerate -m "add event_type column"
```

Verify the generated migration adds `event_type` column. Run:
```bash
alembic upgrade head
```

- [ ] **Step 3: Add event_type to EventResponse schema**

In `backend/schemas/event.py`, add to EventResponse:
```python
event_type: str | None = None
```

- [ ] **Step 4: Add event_type filter to events API**

In `backend/api/routes/events.py`, add query param:
```python
event_type: str | None = Query(None, description="Filter by type: cinema, theatre, workshop, festival")
```

Pass to service. In `backend/services/event_service.py`, add filter:
```python
if event_type is not None:
    stmt = stmt.where(Event.event_type == event_type)
```

- [ ] **Step 5: Add event_type to EventResponse in event_service.py**

In the response builder, add:
```python
event_type=event.event_type,
```

- [ ] **Step 6: Update _upsert_event() in event_crawler.py to handle event_type**

In `backend/crawlers/event_crawler.py`, update `_upsert_event()` method to accept and set `event_type`:
- Add `event_type` to the data dict the method reads
- Set `event.event_type = data.get("event_type")` on both insert and update paths
- This is required so cinema/theatre crawlers (Tasks 2-3) can propagate their type

- [ ] **Step 7: Add Playwright test for event_type filter**

In `tests/api.spec.ts`, add:
```typescript
test.describe('Event Type Filter', () => {
  test('accepts event_type parameter', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000, event_type: 'cinema' }
    });
    expect(res.status()).toBe(200);
  });
});
```

- [ ] **Step 8: Run tests, commit**

```bash
npx playwright test tests/api.spec.ts
git add backend/models/event.py backend/schemas/event.py backend/services/event_service.py backend/api/routes/events.py backend/crawlers/event_crawler.py backend/db/migrations/ tests/api.spec.ts
git commit -m "feat(backend): add event_type field with API filter"
```

---

### Task 2: Cinema crawler (K-Cineplex Cyprus)

**Files:**
- Create: `backend/crawlers/cinema_crawler.py`
- Modify: `backend/crawlers/scheduler.py`

- [ ] **Step 1: Create cinema crawler**

Create `backend/crawlers/cinema_crawler.py` that:
- Fetches movie listings from K-Cineplex Cyprus (or configured cinema URLs)
- Parses movie title, showtime, venue, description
- Sets `event_type = "cinema"` on all events
- Uses the existing `EventCrawler._upsert_event()` pattern
- Stores showtimes as individual events (one per movie per showtime)

- [ ] **Step 2: Register in scheduler**

Add cinema crawler to `backend/crawlers/scheduler.py` with daily schedule.

- [ ] **Step 3: Test and commit**

```bash
git commit -m "feat(crawler): add cinema crawler for Cyprus movie listings"
```

---

### Task 3: Theatre/cultural events crawler

**Files:**
- Create: `backend/crawlers/theatre_crawler.py`
- Modify: `backend/crawlers/scheduler.py`

- [ ] **Step 1: Create theatre crawler**

Create `backend/crawlers/theatre_crawler.py` that:
- Targets Cyprus theatre venues (Rialto, Pattichion, Municipal Theatre Nicosia)
- Parses show title, dates, venue, description
- Sets `event_type = "theatre"`
- Follows same patterns as cinema crawler

- [ ] **Step 2: Register in scheduler and commit**

```bash
git commit -m "feat(crawler): add theatre crawler for Cyprus cultural events"
```

---

## Phase B: Frontend — UI Redesign

### Task 4: Update theme — warm Mediterranean editorial

**Files:**
- Modify: `mobile/lib/app.dart`

- [ ] **Step 1: Update color palette**

Replace current colors in `app.dart`:
```dart
// --- Atlas Design Palette (Mediterranean Editorial) ---
static const Color atlasGreen = Color(0xFF2E7D5F);
static const Color atlasGreenDark = Color(0xFF1B5E42);
static const Color atlasGreenLight = Color(0xFFE8F5EE);

// New warm palette
static const Color sand = Color(0xFFFFF8F0);
static const Color warmGrey = Color(0xFFF5F0EB);
static const Color sunsetCoral = Color(0xFFFF8A65);
static const Color medBlue = Color(0xFF42A5F5);
static const Color charcoal = Color(0xFF2D2D2D);

static const Color textPrimary = Color(0xFF2D2D2D);   // was #212121
static const Color textSecondary = Color(0xFF6B6B6B);  // warmer grey
static const Color textTertiary = Color(0xFFA0A0A0);

static const Color background = Color(0xFFFFF8F0);     // sand, was #FAFAFA
static const Color surface = Color(0xFFFFFFFF);
```

- [ ] **Step 2: Update scaffoldBackgroundColor to sand**

Change `scaffoldBackgroundColor: background` (now sand).

- [ ] **Step 3: Update AppBar theme**

Change AppBar to light/transparent style (no more dark green bar):
```dart
appBarTheme: AppBarTheme(
  backgroundColor: Colors.transparent,
  foregroundColor: charcoal,
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: false,
  titleTextStyle: GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: charcoal,
  ),
),
```

- [ ] **Step 4: Run app, verify theme, commit**

```bash
cd mobile && flutter run -d chrome --web-port=3000
git commit -m "feat(theme): warm Mediterranean editorial palette"
```

---

### Task 5: New Discovery home screen

**Files:**
- Create: `mobile/lib/screens/discover/discover_screen.dart`
- Create: `mobile/lib/widgets/weather_card.dart`
- Create: `mobile/lib/widgets/category_grid.dart`
- Create: `mobile/lib/widgets/place_card_large.dart`
- Modify: `mobile/lib/screens/home/home_screen.dart`

- [ ] **Step 1: Create weather_card.dart**

A warm, rounded card replacing the old banner. Shows:
- Weather icon + temp + description
- Weather mode recommendation (localized)
- Gradient background matching mode (sunny gold, rainy blue, caution amber)
- Height: 100dp, full width with 16dp margins, 16dp border radius

- [ ] **Step 2: Create category_grid.dart**

A 2-column grid of tappable category cards:
- Each card: 120dp tall, rounded 16dp, subtle shadow
- Category emoji/icon + name + count of nearby places
- Cards have a warm tinted background per category
- Categories: Playgrounds, Parks, Restaurants, Cinema, Theatre, Museums, Sports, Beach, Indoor Play, Cafes
- On tap: navigates to filtered search results

- [ ] **Step 3: Create place_card_large.dart**

A horizontal card (like Instagram story cards) for "Near You" section:
- 160dp wide, 200dp tall, rounded 12dp
- Background: place photo (or category color placeholder)
- Bottom overlay: place name, distance, category chip
- On tap: navigate to place detail

- [ ] **Step 4: Create discover_screen.dart**

> **Data fetching:** On `initState`, get user location via `LocationService`, then call:
> - `context.read<PlacesProvider>().fetchNearby(lat, lon)` for "Near You"
> - `context.read<WeatherProvider>().fetchWeather(lat, lon)` for weather card
> - `context.read<EventsProvider>().fetchUpcoming(lat, lon)` for "Happening Today"
>
> Use `Consumer` widgets for each section to react to provider state.
> Create the `mobile/lib/screens/discover/` directory before the file.

ScrollView layout:
```
[Greeting: "Good morning!" / time-based]
[Weather Card]
[Section: "Near You" — horizontal scroll of place_card_large]
[Section: "Categories" — category_grid]
[Section: "Happening Today" — horizontal scroll of event cards]
```

Each section has a header with title + "See All" button.

- [ ] **Step 5: Replace Explore with Discover in home_screen.dart**

Update `home_screen.dart`:
- Tab 0: Discover (home icon) → `DiscoverScreen`
- Tab 1: Search (search icon) → `SearchScreen`
- Tab 2: Events (event icon) → `EventsScreen`
- Tab 3: Map (map icon) → `ExploreScreen` (demoted)
- Tab 4: Settings (settings icon) → `SettingsScreen`

- [ ] **Step 6: Run, verify, commit**

```bash
git commit -m "feat(ui): new Discovery home screen with feed layout"
```

---

### Task 6: Events screen overhaul — sub-type sections

**Files:**
- Modify: `mobile/lib/models/event.dart`
- Modify: `mobile/lib/services/api_service.dart`
- Modify: `mobile/lib/providers/events_provider.dart`
- Modify: `mobile/lib/screens/events/events_screen.dart`
- Create: `mobile/lib/widgets/event_type_section.dart`
- Create: `mobile/lib/widgets/cinema_card.dart`
- Create: `mobile/lib/widgets/theatre_card.dart`

- [ ] **Step 1: Add eventType to Event model**

In `mobile/lib/models/event.dart`, add field:
```dart
final String? eventType;
```
Add to constructor. Parse from `json['event_type']` in `fromJson`.

> **Note:** Also verify that `CacheService` round-trips this field correctly. The cache serializes Event via `_eventToJson()` — ensure `eventType` is included in both serialization and deserialization.

- [ ] **Step 2: Add event_type parameter to ApiService.getEvents()**

In `mobile/lib/services/api_service.dart`, add optional `eventType` param to `getEvents()`:
```dart
Future<List<Event>> getEvents(
  double lat, double lon, {
  String? dateFrom, String? dateTo, String? ageGroup, String? eventType,
}) async {
  ...
  if (eventType != null) params['event_type'] = eventType;
  ...
}
```

- [ ] **Step 3: Update events_provider.dart**

Add grouped getters (client-side filtering — fetch all events once, filter locally since Cyprus dataset is small):
```dart
List<Event> get cinemaEvents => _events.where((e) => e.eventType == 'cinema').toList();
List<Event> get theatreEvents => _events.where((e) => e.eventType == 'theatre').toList();
List<Event> get workshopEvents => _events.where((e) => e.eventType == 'workshop').toList();
List<Event> get festivalEvents => _events.where((e) => e.eventType == 'festival').toList();
List<Event> get generalEvents => _events.where((e) => e.eventType == null || e.eventType == 'general').toList();
```

- [ ] **Step 3: Create cinema_card.dart**

Visual card for movies:
- Movie poster placeholder (category color if no photo)
- Title bold, venue below
- **Showtime pills**: small rounded chips showing times (e.g., "14:00", "17:30", "20:00")
- Coral accent color for cinema

- [ ] **Step 4: Create theatre_card.dart**

Visual card for theatre/plays:
- Similar to cinema but with Med Blue accent
- Show dates instead of showtimes
- Venue name prominent

- [ ] **Step 5: Create event_type_section.dart**

A reusable section widget:
- Header: emoji + type name + count + "See All"
- Horizontal scrollable list of typed cards
- Empty state: "No [type] events this week"

- [ ] **Step 6: Rebuild events_screen.dart**

Replace tab-based layout with vertical scroll of type sections:
```
[Header: "What's On"]
[Filter chips: This Week / This Month / All]
[Section: "Cinema" — cinema_cards horizontal]
[Section: "Theatre & Plays" — theatre_cards horizontal]
[Section: "Workshops" — general event cards]
[Section: "Festivals" — general event cards]
[Section: "All Events" — full list, date-grouped]
```

- [ ] **Step 7: Run, verify, commit**

```bash
git commit -m "feat(events): sub-type sections with cinema and theatre cards"
```

---

### Task 7: Improve Search screen with rich cards

**Files:**
- Modify: `mobile/lib/screens/search/search_screen.dart`
- Modify: `mobile/lib/widgets/filter_sheet.dart`

- [ ] **Step 1: Add prominent filter bar**

Replace the "+" add filter chip with a visible filter row:
- Distance slider (compact, inline)
- Indoor/Outdoor toggle pills
- Age group dropdown
- "More Filters" button opens full sheet

- [ ] **Step 2: Improve result cards**

Make place cards richer:
- Larger photo thumbnail (100dp instead of 80dp)
- Show 2-line description snippet
- Amenity icons row (first 3)
- "Show on Map" mini-button per card

- [ ] **Step 3: Add "Show on Map" navigation**

When user taps "Show on Map" on any card, navigate to the Map tab centered on that place with the preview card open.

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(search): improved filters and rich result cards"
```

---

### Task 8: Add localization keys for new UI

**Files:**
- Modify: `mobile/lib/l10n/app_en.arb`
- Modify: `mobile/lib/l10n/app_el.arb`
- Modify: `mobile/lib/l10n/app_ru.arb`

- [ ] **Step 1: Add new ARB keys**

```json
"discover": "Discover",
"goodMorning": "Good morning!",
"goodAfternoon": "Good afternoon!",
"goodEvening": "Good evening!",
"nearYou": "Near You",
"categories": "Categories",
"happeningToday": "Happening Today",
"seeAll": "See All",
"whatsOn": "What's On",
"cinema": "Cinema",
"theatre": "Theatre & Plays",
"workshops": "Workshops",
"festivals": "Festivals",
"allEvents": "All Events",
"showOnMap": "Show on Map",
"showtime": "Showtime",
"noEventsThisWeek": "No events this week"
```

- [ ] **Step 2: Add Greek and Russian translations**

- [ ] **Step 3: Run flutter gen-l10n, commit**

```bash
cd mobile && flutter gen-l10n
git commit -m "feat(l10n): add keys for redesigned UI in EN/EL/RU"
```

---

### Task 9: Playwright tests for new event_type API

**Files:**
- Modify: `tests/api.spec.ts`

- [ ] **Step 1: Add tests for event_type filter**

```typescript
test.describe('Event Sub-Types', () => {
  test('filters by cinema type', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000, event_type: 'cinema' }
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const event of body.events) {
      expect(event.event_type).toBe('cinema');
    }
  });

  test('filters by theatre type', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000, event_type: 'theatre' }
    });
    expect(res.status()).toBe(200);
  });

  test('returns event_type field in response', async ({ request }) => {
    const res = await request.get(`${V1}/events`, {
      params: { lat: LAT, lon: LON, radius: 50000 }
    });
    expect(res.status()).toBe(200);
    const body = await res.json();
    for (const event of body.events) {
      expect(event).toHaveProperty('event_type');
    }
  });
});
```

- [ ] **Step 2: Run tests, commit**

```bash
npx playwright test tests/api.spec.ts
git commit -m "test: add Playwright tests for event sub-type filtering"
```

---

### Task 10: Final integration + cleanup

**Files:**
- Modify: `project-state/STATUS.md`
- Modify: `project-state/TICKETS.md`
- Modify: `project-state/KNOWN-ISSUES.md`

- [ ] **Step 1: Full app test**

Run backend tests:
```bash
npx playwright test tests/api.spec.ts
```

Run dart analyze:
```bash
cd mobile && dart analyze lib/
```

- [ ] **Step 2: Update project state files**

- [ ] **Step 3: Final commit**

```bash
git commit -m "feat: Little Atlas UI redesign — discovery feed, event sub-types, Mediterranean theme"
```

---

## Execution Order

1. Tasks 1-3 (Backend) — event_type field + crawlers
2. Task 8 (Localization) — **MUST run before Task 5** (Discover screen uses new l10n keys)
3. Task 4 (Theme) — first frontend visual change
4. Task 5 (Discovery screen) — core UI pivot (requires Task 8)
5. Task 6 (Events overhaul) — depends on Task 1 (backend event_type)
6. Task 7 (Search improvement) — independent of 5-6
7. Task 9 (Tests) — after backend tasks
8. Task 10 (Integration) — last

## Design Reference

**Color Tokens:**
| Token | Hex | Usage |
|-------|-----|-------|
| atlasGreen | #2E7D5F | Primary accent, buttons, links |
| sand | #FFF8F0 | Background, page fill |
| warmGrey | #F5F0EB | Card backgrounds, dividers |
| sunsetCoral | #FF8A65 | Cinema accent, highlights, CTAs |
| medBlue | #42A5F5 | Theatre accent, info elements |
| charcoal | #2D2D2D | Primary text |

**Navigation (5 tabs):**
| Tab | Icon | Screen |
|-----|------|--------|
| Discover | home_rounded | DiscoverScreen (NEW) |
| Search | search | SearchScreen (improved) |
| Events | celebration | EventsScreen (overhauled) |
| Map | map_outlined | ExploreScreen (demoted) |
| Settings | settings | SettingsScreen (unchanged) |
