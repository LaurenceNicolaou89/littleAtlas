# Little Atlas — System Architecture

## High-Level Overview

```
┌──────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                │
│  ┌──────────┐ ┌──────────┐ ┌───────┐ ┌────────────┐ │
│  │ Map View │ │ Search/  │ │Events │ │  Settings  │ │
│  │ (OSM)    │ │ Filters  │ │ Feed  │ │ (Language)  │ │
│  └────┬─────┘ └────┬─────┘ └───┬───┘ └────────────┘ │
│       └─────────────┴───────────┘                     │
│                     │ REST API                        │
└─────────────────────┼────────────────────────────────┘
                      │ HTTPS
┌─────────────────────┼────────────────────────────────┐
│              FastAPI Backend (Monolith)                │
│                     │                                 │
│  ┌──────────────────┴──────────────────┐              │
│  │           REST API Layer            │              │
│  │  /places  /events  /weather  /health│              │
│  └──────────────────┬──────────────────┘              │
│                     │                                 │
│  ┌─────────┐ ┌──────┴──────┐ ┌───────────────┐       │
│  │ Weather │ │   Place     │ │    Event      │       │
│  │ Service │ │   Service   │ │    Service    │       │
│  └────┬────┘ └──────┬──────┘ └───────┬───────┘       │
│       │             │                │                │
│  ┌────┴────┐ ┌──────┴──────┐ ┌──────┴───────┐       │
│  │  Redis  │ │ PostgreSQL  │ │  Crawlers    │       │
│  │ (cache) │ │ + PostGIS   │ │ (scheduled)  │       │
│  └─────────┘ └─────────────┘ └──────────────┘       │
└──────────────────────────────────────────────────────┘

External Data Sources:
  ├── OpenStreetMap (Overpass API)
  ├── Google Places API
  ├── OpenWeatherMap API
  └── Web Scrapers (Cyprus event sites)
```

## Mobile App (Flutter)

### Project Structure

```
lib/
├── main.dart                  # App entry point
├── app.dart                   # MaterialApp configuration, routing
├── l10n/                      # Localization (EN, EL, RU)
│   ├── app_en.arb
│   ├── app_el.arb
│   └── app_ru.arb
├── config/
│   └── api_config.dart        # API base URL, endpoints
├── models/
│   ├── place.dart
│   ├── event.dart
│   ├── weather.dart
│   └── category.dart
├── services/
│   ├── api_service.dart       # HTTP client (dio)
│   ├── location_service.dart  # GPS/location handling
│   └── cache_service.dart     # Local caching (Hive)
├── providers/
│   ├── places_provider.dart
│   ├── events_provider.dart
│   ├── weather_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── home/
│   │   └── home_screen.dart   # Map + nearby places
│   ├── search/
│   │   └── search_screen.dart # Search + filters
│   ├── place_detail/
│   │   └── place_detail_screen.dart
│   ├── events/
│   │   └── events_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── place_card.dart
│   ├── event_card.dart
│   ├── weather_banner.dart
│   ├── category_chips.dart
│   ├── filter_sheet.dart
│   └── map/
│       ├── place_map.dart
│       └── place_marker.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_map` | OpenStreetMap map rendering |
| `latlong2` | Geographic coordinate handling |
| `dio` | HTTP client for API calls |
| `provider` | State management |
| `hive` / `hive_flutter` | Local cache / offline storage |
| `geolocator` | Device GPS location |
| `flutter_localizations` | i18n support (EN, EL, RU) |
| `intl` | Date/number formatting per locale |
| `cached_network_image` | Image caching |

### State Management

Using **Provider** for simplicity:
- `PlacesProvider` — nearby places, search results, filters
- `EventsProvider` — upcoming events, event filters
- `WeatherProvider` — current weather, forecast, indoor/outdoor mode
- `SettingsProvider` — language preference, distance unit

### Offline Strategy

- **Hive** local database caches last-fetched places for the user's area
- Weather cached with timestamp, shown as "last updated X min ago" when offline
- Map tiles cached by `flutter_map`'s built-in tile caching
- Graceful degradation: show cached data with "offline" banner

### Navigation

Bottom navigation bar with 4 tabs:
1. **Explore** (Map + nearby places)
2. **Search** (Text search + filters)
3. **Events** (Upcoming events feed)
4. **Settings** (Language, about)

## Backend (FastAPI)

### Project Structure

```
backend/
├── main.py                    # FastAPI app entry, lifespan events
├── config.py                  # Settings from environment variables
├── requirements.txt
├── Dockerfile
├── api/
│   ├── __init__.py
│   ├── routes/
│   │   ├── places.py          # GET /places, GET /places/{id}
│   │   ├── events.py          # GET /events
│   │   ├── weather.py         # GET /weather
│   │   └── health.py          # GET /health
│   └── dependencies.py        # DB session, Redis connection
├── models/
│   ├── __init__.py
│   ├── place.py               # SQLAlchemy + PostGIS models
│   ├── event.py
│   └── category.py
├── schemas/
│   ├── __init__.py
│   ├── place.py               # Pydantic response schemas
│   ├── event.py
│   └── weather.py
├── services/
│   ├── __init__.py
│   ├── place_service.py       # Place queries with PostGIS
│   ├── event_service.py       # Event queries
│   └── weather_service.py     # Weather fetch + cache
├── crawlers/
│   ├── __init__.py
│   ├── scheduler.py           # APScheduler setup
│   ├── osm_crawler.py         # OpenStreetMap Overpass API
│   ├── google_places_crawler.py # Google Places API
│   ├── event_crawler.py       # Web scraping for events
│   └── entity_resolver.py     # Deduplication logic
└── db/
    ├── __init__.py
    ├── database.py            # Engine, session factory
    └── migrations/            # Alembic migrations
        ├── alembic.ini
        ├── env.py
        └── versions/
```

### API Endpoints

| Method | Path | Description | Query Params |
|--------|------|-------------|-------------|
| GET | `/places` | Search nearby places | `lat`, `lon`, `radius`, `category`, `age_group`, `indoor`, `amenities`, `q` (text search), `lang` |
| GET | `/places/{id}` | Place details | `lang` |
| GET | `/events` | Upcoming events | `lat`, `lon`, `radius`, `date_from`, `date_to`, `age_group`, `lang` |
| GET | `/weather` | Current weather + forecast | `lat`, `lon` |
| GET | `/health` | Health check | — |
| GET | `/categories` | List all categories | `lang` |

### Database Schema (PostgreSQL + PostGIS)

```sql
-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(50) UNIQUE NOT NULL,      -- 'playground', 'park', 'restaurant'
    name_en VARCHAR(100) NOT NULL,
    name_el VARCHAR(100),
    name_ru VARCHAR(100),
    icon VARCHAR(50)                        -- icon identifier
);

-- Places
CREATE TABLE places (
    id SERIAL PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_el VARCHAR(255),
    name_ru VARCHAR(255),
    description_en TEXT,
    description_el TEXT,
    description_ru TEXT,
    category_id INTEGER REFERENCES categories(id),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    address VARCHAR(500),
    phone VARCHAR(50),
    website VARCHAR(500),
    opening_hours JSONB,                    -- structured hours per day
    is_indoor BOOLEAN DEFAULT FALSE,
    age_min INTEGER DEFAULT 0,             -- minimum age suitability
    age_max INTEGER DEFAULT 12,            -- maximum age suitability
    amenities JSONB DEFAULT '[]',          -- ['changing_table', 'high_chair', 'parking', ...]
    photos JSONB DEFAULT '[]',             -- array of photo URLs
    source VARCHAR(50),                    -- 'osm', 'google', 'manual'
    source_id VARCHAR(255),                -- external ID for deduplication
    last_verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Spatial index for fast nearby queries
CREATE INDEX idx_places_location ON places USING GIST (location);
CREATE INDEX idx_places_category ON places (category_id);

-- Events
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    title_en VARCHAR(255) NOT NULL,
    title_el VARCHAR(255),
    title_ru VARCHAR(255),
    description_en TEXT,
    description_el TEXT,
    description_ru TEXT,
    location GEOGRAPHY(POINT, 4326),
    venue_name VARCHAR(255),
    address VARCHAR(500),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    is_indoor BOOLEAN DEFAULT FALSE,
    age_min INTEGER DEFAULT 0,
    age_max INTEGER DEFAULT 12,
    source_url VARCHAR(500),
    source VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_events_location ON events USING GIST (location);
CREATE INDEX idx_events_dates ON events (start_date, end_date);
```

### Key Queries

**Nearby places with filters:**
```sql
SELECT p.*, c.slug as category_slug,
       ST_Distance(p.location, ST_MakePoint(:lon, :lat)::GEOGRAPHY) AS distance_m
FROM places p
JOIN categories c ON p.category_id = c.id
WHERE ST_DWithin(p.location, ST_MakePoint(:lon, :lat)::GEOGRAPHY, :radius)
  AND (:category IS NULL OR c.slug = :category)
  AND (:indoor IS NULL OR p.is_indoor = :indoor)
ORDER BY distance_m
LIMIT 50;
```

### Crawling Pipeline

```
┌─────────────┐    ┌─────────────┐    ┌───────────────┐
│  Scheduler  │───>│   Crawler   │───>│   Entity      │
│ (APScheduler)│   │ (per source)│    │   Resolver    │
└─────────────┘    └──────┬──────┘    └───────┬───────┘
                          │                    │
                   Raw place data      Deduplicated &
                                       enriched places
                                              │
                                    ┌─────────┴─────────┐
                                    │   PostgreSQL +    │
                                    │   PostGIS         │
                                    └───────────────────┘
```

**Crawler schedules:**
| Crawler | Schedule | Scope |
|---------|----------|-------|
| OSM Crawler | Weekly | All of Cyprus — playgrounds, parks, amenities |
| Google Places | Weekly | Cyprus cities — restaurants, entertainment |
| Event Crawler | Daily | Cyprus event websites, Facebook pages |
| Weather Sync | Every 30 min | Cache weather for major Cyprus cities |

**Entity Resolution:**
- Match places across sources by: normalized name + coordinates within 100m
- Merge strategy: prefer Google for hours/photos, OSM for amenities/geometry, manual for curated data
- Flag conflicts for manual review

### Caching (Redis)

| Key Pattern | TTL | Purpose |
|-------------|-----|---------|
| `weather:{lat}:{lon}` | 30 min | Weather data per location |
| `places:{query_hash}` | 5 min | Search result caching |
| `categories` | 24 hours | Category list |

## Infrastructure

### Local Development (Docker Compose)

```yaml
services:
  api:
    build: ./backend
    ports: ["8000:8000"]
    depends_on: [db, redis]
    environment:
      - DATABASE_URL=postgresql://atlas:atlas@db:5432/littleatlas
      - REDIS_URL=redis://redis:6379
      - OPENWEATHERMAP_API_KEY=${OPENWEATHERMAP_API_KEY}
      - GOOGLE_PLACES_API_KEY=${GOOGLE_PLACES_API_KEY}

  db:
    image: postgis/postgis:16-3.4
    ports: ["5432:5432"]
    environment:
      POSTGRES_DB: littleatlas
      POSTGRES_USER: atlas
      POSTGRES_PASSWORD: atlas
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

volumes:
  pgdata:
```

### Production (Render Free Tier)

- **Web Service:** FastAPI app (free, sleeps after 15min inactivity)
- **PostgreSQL:** Render managed PostgreSQL (free, 90-day limit)
- **Redis:** Render managed Redis (free tier, 25MB)

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `REDIS_URL` | Yes | Redis connection string |
| `OPENWEATHERMAP_API_KEY` | Yes | OpenWeatherMap free tier key |
| `GOOGLE_PLACES_API_KEY` | No | Google Places (optional, for enrichment) |
| `ENVIRONMENT` | No | `development` / `production` (default: development) |

## Security Considerations (v1)

- No authentication needed (no user accounts)
- Rate limiting on API endpoints (prevent abuse)
- API keys stored in environment variables, never in code
- CORS configured for mobile app only
- Input validation on all query parameters (Pydantic)
- SQL injection prevented by SQLAlchemy ORM (parameterized queries)
