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

## Backend Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|
| Weather cache schema mismatch | Writer and reader used different JSON keys | Unified to WeatherResponse-compatible schema | weather_sync, weather_service | 2026-03-17 |
| Alembic autogenerate broken | Wrong import path for Base | Fixed to db.database.Base | migrations/env.py | 2026-03-17 |
| N+1 query on place/event results | Per-row ST_X/ST_Y subqueries | Extracted coordinates in main SELECT | place_service, event_service | 2026-03-17 |
| Migration/model schema drift | Defaults, nullability, lengths misaligned | Aligned all values | 001_initial_schema.py | 2026-03-17 |
| ILIKE wildcard injection | User input with % or _ not escaped | Added escape before interpolation | place_service.py | 2026-03-17 |
| Invalid CORS config | credentials=True with origins=* | Set credentials=False with wildcard | main.py | 2026-03-17 |

## Database Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|

## Infrastructure Issues
| Bug | Root Cause | Fix | Component | Date |
|-----|-----------|-----|-----------|------|

## Patterns to Watch For
- Always unify cache key schemas between writers and readers
- Debounce map/scroll gesture callbacks before triggering API calls
- Use shared utility functions for duplicated formatters and launchers
- Never maintain widget-local state that duplicates provider state
- Escape user input in SQL LIKE/ILIKE patterns
- Align migration files with SQLAlchemy models after any model change
