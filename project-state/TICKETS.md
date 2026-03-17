# Little Atlas — Tickets

## Epic 1: Infrastructure

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| INF-001 | Docker Compose setup (API + PostgreSQL + Redis) | DevOps | done | `docker compose up` starts all 3 services, API responds on :8000 |
| INF-002 | FastAPI project scaffold | Backend Dev | done | Project structure matches architecture.md, `/health` endpoint returns 200 |
| INF-003 | PostgreSQL + PostGIS schema and migrations | DBA | done | All tables created (categories, places, events), PostGIS extension enabled, spatial indexes created |
| INF-004 | Redis connection and caching layer | Backend Dev | done | Redis connects, basic get/set/delete cache helpers work |
| INF-005 | Environment config management | Backend Dev | done | All env vars loaded from `.env`, config.py validates required vars |
| INF-006 | Flutter project scaffold | Frontend Dev | done | Flutter project created, folder structure matches architecture.md, runs on emulator |
| INF-007 | Localization setup (EN, EL, RU) | Frontend Dev | done | ARB files created for all 3 languages, language switching works |
| INF-008 | Alembic migration setup | DBA | done | Alembic initialized, initial migration creates all tables, `alembic upgrade head` works |

## Epic 2: Backend API

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| BE-001 | GET /places endpoint with PostGIS nearby search | Backend Dev | done | Returns places within radius, sorted by distance, filters by category/indoor/age/amenities, supports `lang` param |
| BE-002 | GET /places/{id} endpoint | Backend Dev | done | Returns full place detail with all fields, supports `lang` param, 404 for invalid ID |
| BE-003 | GET /events endpoint | Backend Dev | done | Returns upcoming events sorted by date, filters by radius/date_range/age, supports `lang` param |
| BE-004 | GET /weather endpoint | Backend Dev | done | Returns current weather + 3-hour forecast for given lat/lon, cached in Redis (30min TTL) |
| BE-005 | GET /categories endpoint | Backend Dev | done | Returns all categories with translated names, cached in Redis (24hr TTL) |
| BE-006 | API rate limiting | Backend Dev | done | Rate limiting configured (100 req/min per IP), returns 429 when exceeded |
| BE-007 | CORS configuration | Backend Dev | done | CORS allows mobile app origin only |
| BE-008 | Seed database with Cyprus categories | DBA | done | All 7 top-level categories and subcategories seeded with EN/EL/RU names |

## Epic 3: Data Crawlers

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| CR-001 | APScheduler setup and crawler framework | Backend Dev | done | Scheduler starts with app, supports cron-style schedules, logs crawler runs |
| CR-002 | OpenStreetMap crawler (Cyprus playgrounds, parks, amenities) | Backend Dev | done | Fetches all playground/park/amenity nodes in Cyprus via Overpass API, maps OSM tags to our schema |
| CR-003 | Google Places crawler (Cyprus restaurants, entertainment) | Backend Dev | done | Fetches family-relevant places in Cyprus cities, extracts hours/photos/ratings, respects API quota |
| CR-004 | Entity resolution / deduplication | Backend Dev | done | Matches places across sources by normalized name + 100m proximity, merges per priority rules in business-logic.md |
| CR-005 | Event crawler (Cyprus event websites) | Backend Dev | done | Scrapes configured Cyprus event sources, extracts title/date/location/description, deduplicates events |
| CR-006 | Weather sync service | Backend Dev | done | Fetches weather for 6 Cyprus cities every 30min, caches in Redis, serves via /weather endpoint |

## Epic 4: Flutter App Shell

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| APP-001 | App theme setup (colors, typography, spacing) | Frontend Dev | done | Theme matches design-style.md exactly — Atlas Green primary, Nunito font, 4dp spacing |
| APP-002 | Bottom navigation bar (4 tabs) | Frontend Dev | done | Explore/Search/Events/Settings tabs with correct icons, state preserved on tab switch |
| APP-003 | API service (Dio HTTP client) | Frontend Dev | done | Dio configured with base URL, error handling, lang param auto-added from settings |
| APP-004 | Location service (Geolocator) | Frontend Dev | done | Requests permission, gets current location, handles denial gracefully |
| APP-005 | Local cache service (Hive) | Frontend Dev | done | Hive initialized, stores/retrieves places and weather data for offline use |
| APP-006 | Provider setup (all 4 providers) | Frontend Dev | done | PlacesProvider, EventsProvider, WeatherProvider, SettingsProvider created and wired in app root |

## Epic 5: Explore Screen

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| EX-001 | Map view with OpenStreetMap (flutter_map) | Frontend Dev | done | Full-screen map centered on user location, pan/zoom gestures, "my location" FAB |
| EX-002 | Weather banner | Frontend Dev | done | Shows current weather with dynamic gradient per mode, tappable to expand 3-hour forecast |
| EX-003 | Category filter chips on map | Frontend Dev | done | Horizontal scrollable chips, multi-select, filters map markers |
| EX-004 | Place markers on map (custom per category) | Frontend Dev | done | Colored circle markers with category icons, cluster at low zoom, tap shows preview |
| EX-005 | Draggable bottom sheet with nearby places | Frontend Dev | done | Collapsed/half/full states, shows sorted place cards, pull up to expand |
| EX-006 | Place card widget | Frontend Dev | done | Thumbnail, name, category, distance, open/closed, age range, top 2 amenities |

## Epic 6: Search Screen

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| SE-001 | Search bar with debounced text search | Frontend Dev | done | Auto-focus on tab, 300ms debounce, searches as user types |
| SE-002 | Filter bottom sheet | Frontend Dev | done | Distance, category, age, indoor/outdoor, amenity filters with multi-select |
| SE-003 | Active filter chips | Frontend Dev | done | Show active filters as removable chips below search bar, "clear all" button |
| SE-004 | Search results list | Frontend Dev | done | Vertical scrollable list with place cards, empty state when no results |

## Epic 7: Place Detail Screen

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| PD-001 | Place detail screen layout | Frontend Dev | done | Photo carousel, title, status, distance, age, description, details section |
| PD-002 | Photo carousel | Frontend Dev | done | Swipeable photos with page indicator, placeholder when no photos |
| PD-003 | Amenity chips display | Frontend Dev | done | Shows all amenities as chips with icons |
| PD-004 | Get Directions button (open native maps) | Frontend Dev | done | Opens Google Maps / Apple Maps with place coordinates |

## Epic 8: Events Screen

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| EV-001 | Events feed with date grouping | Frontend Dev | done | Chronological list grouped by date, sticky date headers |
| EV-002 | Event card widget | Frontend Dev | done | Title, time, venue + distance, age range, "Happening Now" highlight |
| EV-003 | Time filter tabs (This Week / This Month / All) | Frontend Dev | done | Tab bar filters events by time range |
| EV-004 | Event detail screen | Frontend Dev | done | Full event info with description, venue map, directions link |

## Epic 9: Settings Screen

| ID | Title | Agent | Status | Acceptance Criteria |
|----|-------|-------|--------|-------------------|
| ST-001 | Language picker (EN, EL, RU) | Frontend Dev | done | Shows 3 languages with flags, selection persists, app reloads in new language |
| ST-002 | About section | Frontend Dev | done | Version, data sources, privacy policy, terms of service links |

---

**Summary: 9 Epics, 38 Tickets**
- Infrastructure: 8 tickets
- Backend API: 8 tickets
- Data Crawlers: 6 tickets
- App Shell: 6 tickets
- Explore Screen: 6 tickets
- Search Screen: 4 tickets
- Place Detail: 4 tickets
- Events Screen: 4 tickets
- Settings Screen: 2 tickets
