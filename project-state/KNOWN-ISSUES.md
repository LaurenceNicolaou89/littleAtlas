# Little Atlas — Known Issues Registry

## Frontend Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|
| CategoryChips dual-state bug | Local state diverged from provider | Converted to StatelessWidget reading from provider | category_chips.dart | 2026-03-17 |
| Filter apply triggered 5 API calls | Sequential setter calls each triggered refetch | Added batch applyFilters() method | places_provider.dart | 2026-03-17 |
| Place detail unreachable | onTap callbacks had debugPrint instead of navigation | Implemented Navigator.push to PlaceDetailScreen | explore_screen, search_screen | 2026-03-17 |
| Fake 3-hour forecast | Banner showed fabricated temp +/- 1 | Removed expand/collapse, now compact 48dp banner | weather_banner.dart | 2026-03-17 |
| Dozens of hardcoded strings | Violated localization rule | Replaced with ARB keys, added 30+ keys in EN/EL/RU | multiple files | 2026-03-17 |
| Map pan hammered API | No debounce on gesture events | Added 500ms Timer debounce | explore_screen.dart | 2026-03-17 |
| Hive boxes opened repeatedly | Each access opened a new box handle | Open once in init(), store references | cache_service.dart | 2026-03-17 |
| Hardcoded baseUrl without HTTPS | No env override, HTTP only | Use String.fromEnvironment with default | api_config.dart | 2026-03-18 |
| Null crash on event.endDate | endDate nullable but accessed without guard | Added null checks in _formatDateRange, map, directions | event_detail_screen.dart | 2026-03-18 |
| Weather banner not localized | Hardcoded English recommendation strings | Replaced with AppLocalizations keys | weather_banner.dart | 2026-03-18 |
| Tab controller rebuild loop | Listener triggered provider which re-rendered tabs | Wrapped in addPostFrameCallback | events_screen.dart | 2026-03-18 |
| Duplicated amenity maps | Icon/label maps in 3 files | Extracted to shared amenity_utils.dart | place_detail, event_detail, filter_sheet | 2026-03-18 |
| Event card null endDate crash | _isHappeningNow and _formatTimeRange lacked null check | Added endDate != null guards | event_card.dart | 2026-03-18 |
| Refresh while loading | Search refresh didn't check loading state | Added isLoading guard | search_screen.dart | 2026-03-18 |
| Debug "Finding #N" comments | Inline references to review findings | Removed all Finding #N comments | multiple files | 2026-03-18 |
| fromJson null safety | Required fields cast without null check | Added null coalescing defaults | place.dart, event.dart | 2026-03-18 |

## Backend Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|
| Weather cache schema mismatch | Writer and reader used different JSON keys | Unified to WeatherResponse-compatible schema | weather_sync, weather_service | 2026-03-17 |
| Alembic autogenerate broken | Wrong import path for Base | Fixed to db.database.Base | migrations/env.py | 2026-03-17 |
| N+1 query on place/event results | Per-row ST_X/ST_Y subqueries | Extracted coordinates in main SELECT | place_service, event_service | 2026-03-17 |
| Migration/model schema drift | Defaults, nullability, lengths misaligned | Aligned all values | 001_initial_schema.py | 2026-03-17 |
| ILIKE wildcard injection | User input with % or _ not escaped | Added escape before interpolation | place_service.py | 2026-03-17 |
| Invalid CORS config | credentials=True with origins=* | Set credentials=False with wildcard | main.py | 2026-03-17 |
| Google API key in photo URLs | Key embedded in client-side URLs | Created /photos/{ref} proxy endpoint | photos.py, google_places_crawler.py | 2026-03-18 |
| Amenity filter f-string JSON injection | Fragile f-string JSON construction | Replaced with json.dumps() | place_service.py | 2026-03-18 |
| CORS wildcard in non-prod | Defaulted to * for non-production | Restricted to localhost origins | main.py | 2026-03-18 |
| Silent UV index exception | Exception swallowed with pass | Added logger.debug with exc_info | weather_service.py | 2026-03-18 |
| Duplicated weather mode calc | Same function in weather_service and weather_sync | Extracted to shared weather_utils.py | weather_utils.py | 2026-03-18 |
| Duplicated coord extraction | ST_Y/ST_X repeated in place_service and event_service | Extracted to shared geo_utils.py | geo_utils.py | 2026-03-18 |
| Hardcoded DB pool settings | pool_size/max_overflow not configurable | Made env-configurable via settings | config.py, database.py | 2026-03-18 |
| print() in seed.py | Used print instead of logging | Replaced with logger.info | seed.py | 2026-03-18 |
| TODO in committed code | TODO comment in entity_resolver | Replaced with inline design note | entity_resolver.py | 2026-03-18 |
| Missing file encoding | open() without encoding param | Added encoding="utf-8" | event_crawler.py | 2026-03-18 |
| Silent JSON path resolution | _resolve_json_path returned None silently | Added logger.debug | event_crawler.py | 2026-03-18 |
| Silent event truncation | Description truncated without logging | Added logger.warning | event_crawler.py | 2026-03-18 |
| 24h category cache TTL | No invalidation strategy | Reduced to 1 hour | categories.py | 2026-03-18 |
| No API key startup validation | Empty keys accepted silently | Added warning logs on startup | config.py | 2026-03-18 |

## Database Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|

## Infrastructure Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|
| Docker exposed ports + weak creds | DB/Redis ports and hardcoded atlas:atlas | Created docker-compose.prod.yml with env vars | docker-compose.prod.yml | 2026-03-18 |

## Patterns to Watch For
- Always unify cache key schemas between writers and readers
- Debounce map/scroll gesture callbacks before triggering API calls
- Use shared utility functions for duplicated formatters and launchers
- Never maintain widget-local state that duplicates provider state
- Escape user input in SQL LIKE/ILIKE patterns
- Align migration files with SQLAlchemy models after any model change
- Always null-check nullable DateTime fields before accessing properties
- Use json.dumps() for SQL JSONB parameters, never f-strings
- Never expose API keys in client-facing URLs — use backend proxies
- Wrap provider changes in addPostFrameCallback when triggered by listeners
- Use String.fromEnvironment for env-specific config in Flutter
