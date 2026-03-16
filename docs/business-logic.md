# Little Atlas — Business Logic

## Weather-Based Recommendations

### Weather Classification

The app classifies current weather into three modes that drive recommendations:

| Mode | Conditions | Recommendation |
|------|-----------|----------------|
| **Outdoor** | Clear/cloudy, temp 15-35°C, no rain, UV < 8 | Show all places, prioritize outdoor |
| **Indoor** | Rain, temp < 10°C or > 38°C, UV >= 8, strong wind (> 50 km/h) | Show indoor places first, outdoor places demoted |
| **Caution** | Temp 10-15°C, light drizzle, UV 6-8, moderate wind | Show all places, display weather warning banner |

### Weather Decision Tree

```
Is it raining? (rain > 0.5mm/hr)
  YES → INDOOR mode
  NO →
    Temperature < 10°C?
      YES → INDOOR mode
      NO →
        Temperature > 38°C?
          YES → INDOOR mode
          NO →
            UV Index >= 8?
              YES → CAUTION mode ("High UV — consider indoor or shaded areas")
              NO →
                Wind > 50 km/h?
                  YES → INDOOR mode
                  NO →
                    Temperature 10-15°C?
                      YES → CAUTION mode ("Cool weather — dress warmly")
                      NO → OUTDOOR mode
```

### Weather Data Caching

- Weather fetched per major Cyprus city (Nicosia, Limassol, Larnaca, Paphos, Famagusta, Ayia Napa)
- User's location mapped to nearest city for weather data
- Cache TTL: 30 minutes
- If weather API is down, use last cached data with "last updated" timestamp shown

## Place Search & Ranking

### Default Ranking (no text search)

Places are ranked by a combined score:

```
score = (1 / (distance_km + 0.1)) * category_weight * freshness_factor
```

- **distance_km**: Distance from user in kilometers
- **category_weight**: 1.0 for most categories, 1.2 for places matching current weather mode
- **freshness_factor**: 1.0 if verified within 30 days, 0.8 if 30-90 days, 0.6 if > 90 days

### Text Search Ranking

When user types a search query:
1. Search `name_en`, `name_el`, `name_ru` columns using PostgreSQL `ILIKE`
2. Also match against category names
3. Results still filtered by distance radius
4. Rank by: text match relevance first, then distance

### Distance Radius Defaults

| Context | Default Radius |
|---------|---------------|
| Home screen "Near me" | 10 km |
| Search with no radius set | 25 km |
| Events feed | 50 km (events are worth traveling for) |
| Maximum allowed | 100 km (covers all of Cyprus) |

## Category System

### Category Hierarchy

```
playgrounds
  ├── outdoor_playground
  └── indoor_playground

parks_nature
  ├── park
  ├── beach
  ├── nature_trail
  └── botanical_garden

restaurants
  ├── family_restaurant
  ├── cafe_with_play_area
  └── fast_food_with_playground

entertainment
  ├── luna_park
  ├── arcade
  ├── bowling
  ├── mini_golf
  ├── cinema
  └── trampoline_park

culture_education
  ├── museum
  ├── library
  ├── aquarium
  └── zoo

sports_activities
  ├── swimming_pool
  ├── climbing_wall
  ├── sports_center
  └── water_park

events (dynamic, not stored as subcategories)
```

### Category-to-Weather Mapping

Each category has an `is_indoor` property that drives weather filtering:

| Category | Indoor/Outdoor | Shown in INDOOR mode | Shown in OUTDOOR mode |
|----------|---------------|---------------------|----------------------|
| outdoor_playground | Outdoor | Demoted (shown at bottom) | Prioritized |
| indoor_playground | Indoor | Prioritized | Shown normally |
| park | Outdoor | Demoted | Prioritized |
| beach | Outdoor | Hidden (unsafe in bad weather) | Prioritized |
| museum | Indoor | Prioritized | Shown normally |
| family_restaurant | Indoor | Prioritized | Shown normally |
| luna_park | Outdoor | Demoted | Prioritized |
| swimming_pool | Both | Shown normally | Shown normally |

"Demoted" means the place is still shown but appears after all weather-appropriate places.
"Hidden" means the place is filtered out entirely (e.g., beaches during storms).

## Age Suitability

### Age Groups

| Group | Age Range | Label (EN) | Label (EL) | Label (RU) |
|-------|-----------|------------|------------|------------|
| infant | 0-1 | Infant | Βρέφος | Младенец |
| toddler | 1-3 | Toddler | Νήπιο | Малыш |
| preschool | 3-5 | Preschool | Προσχολικό | Дошкольник |
| school_age | 6-12 | School Age | Σχολική Ηλικία | Школьный возраст |

### Age Filtering Logic

- Each place has `age_min` and `age_max` fields
- When user filters by age group, show places where the age group overlaps with the place's range
- Example: User selects "Toddler (1-3)" → show places where `age_min <= 3 AND age_max >= 1`
- If no age filter is set, show all places regardless of age range

## Amenity System

### Standard Amenities

| Amenity Slug | Label (EN) | Icon |
|-------------|------------|------|
| `changing_table` | Changing Table | baby_changing_station |
| `high_chair` | High Chair | chair |
| `kids_menu` | Kids Menu | restaurant_menu |
| `stroller_access` | Stroller Accessible | accessible |
| `fenced_area` | Fenced Area | fence |
| `parking` | Parking | local_parking |
| `wheelchair_access` | Wheelchair Accessible | wheelchair |
| `nursing_room` | Nursing Room | breastfeeding |
| `shade` | Shaded Area | umbrella |
| `water_fountain` | Water Fountain | water_drop |
| `toilets` | Toilets | wc |
| `wifi` | Free WiFi | wifi |

### Amenity Data Sources

- **OSM tags** → mapped to amenity slugs (e.g., `diaper=yes` → `changing_table`)
- **Google Places** → extracted from place types and attributes
- **Manual curation** → for Cyprus-specific places

## Events Logic

### Event Lifecycle

```
Crawled → Active → Happening Now → Past (archived)
```

- **Crawled**: Event found by crawler, stored in DB
- **Active**: `start_date` is in the future, shown in events feed
- **Happening Now**: `start_date <= now <= end_date`, highlighted in feed
- **Past**: `end_date < now`, hidden from feed, kept in DB for 90 days then deleted

### Event Deduplication

Same event may appear on multiple sources. Deduplicate by:
1. Normalize title (lowercase, strip punctuation)
2. Match on normalized title + date + location within 500m
3. If match found, merge descriptions, keep earliest source

### Event Sorting

Default sort: by start date (soonest first), with "Happening Now" events pinned to top.

## Entity Resolution (Place Deduplication)

### Matching Algorithm

When a crawler finds a new place:

1. **Exact source match**: Same `source` + `source_id` → update existing record
2. **Name + location match**: Normalize name (lowercase, strip "the", common words) + coordinates within 100m → likely duplicate
3. **No match** → create new place record

### Merge Strategy

When two records match:

| Field | Priority |
|-------|----------|
| Name | Google > Manual > OSM |
| Location (coordinates) | Google > OSM |
| Opening hours | Google (most accurate) |
| Photos | Google > Manual |
| Amenities | OSM > Manual > Google |
| Category | Manual > Google > OSM |
| Description | Manual > Google |

The `source` field on the final record reflects the primary source. All source IDs are stored for future deduplication.

## Data Freshness

### Staleness Rules

| Age of Data | Status | UI Treatment |
|-------------|--------|-------------|
| < 30 days | Fresh | No indicator |
| 30-90 days | Aging | Show "info may be outdated" subtle note |
| > 90 days | Stale | Show "not recently verified" warning |
| > 180 days | Expired | Flag for re-crawl, demote in results |

### Verification

- Crawler re-verifies existing places on each run
- If a place is no longer found in source, mark as `unverified` (don't delete — may be temporary API issue)
- After 3 consecutive failed verifications, mark as `possibly_closed`
- Places marked `possibly_closed` are hidden from results after 30 days

## Localization Logic

### Language Resolution

1. App sends `lang` parameter with every API request (`en`, `el`, `ru`)
2. Backend returns the requested language column
3. Fallback chain: requested language → English → first non-null language
4. Example: if `name_ru` is null, return `name_en` instead

### Translatable Content

- Category names (stored in categories table)
- Place names and descriptions (stored per-place)
- Event titles and descriptions (stored per-event)
- App UI strings (stored in Flutter ARB files)
- Amenity labels (stored in Flutter ARB files)
- Age group labels (stored in Flutter ARB files)

### Non-Translatable Content

- Addresses (kept in original language / transliterated)
- Phone numbers
- URLs
- Coordinates
