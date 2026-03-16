# Little Atlas — Coding Style Guide

## General Principles

- Keep it simple — no premature abstractions
- Prefer readability over cleverness
- Small files — if a file exceeds 300 lines, consider splitting
- No dead code — delete unused code, don't comment it out
- No TODO comments in committed code — create a ticket instead

## Dart / Flutter

### Style Reference

Follow the [Effective Dart](https://dart.dev/effective-dart) guidelines with these project-specific additions.

### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `PlaceCard`, `WeatherProvider` |
| Files | snake_case | `place_card.dart`, `weather_provider.dart` |
| Variables / functions | camelCase | `fetchPlaces()`, `distanceKm` |
| Constants | camelCase | `defaultRadius`, `maxSearchResults` |
| Enums | PascalCase (type), camelCase (values) | `WeatherMode.indoor` |
| Private members | prefix with `_` | `_isLoading`, `_fetchData()` |

### Widget Structure

```dart
class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  final Place place;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
```

Rules:
- Use `const` constructors wherever possible
- Declare `key` as first parameter using `super.key`
- `required` parameters before optional ones
- Extract sub-widgets into methods only when they need their own parameters; otherwise keep inline
- Prefer `StatelessWidget` unless state is needed
- One public widget per file

### State Management (Provider)

```dart
class PlacesProvider extends ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNearby(double lat, double lon, {int radius = 10000}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await _apiService.getPlaces(lat, lon, radius: radius);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

Rules:
- Private fields with public getters
- Set `_isLoading` before async work, clear in `finally`
- Always call `notifyListeners()` after state changes
- One provider per domain concern

### Models

```dart
class Place {
  const Place({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    this.photos = const [],
  });

  final int id;
  final String name;
  final LatLng location;
  final String? description;
  final List<String> photos;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      location: LatLng(json['lat'], json['lon']),
      description: json['description'],
      photos: List<String>.from(json['photos'] ?? []),
    );
  }
}
```

Rules:
- Immutable models (`final` fields, `const` constructors)
- `factory fromJson` for API deserialization
- Nullable fields for optional data, default values for lists

### Imports

Order:
1. Dart SDK (`dart:async`, `dart:convert`)
2. Flutter SDK (`package:flutter/material.dart`)
3. External packages (`package:dio/dio.dart`)
4. Project imports (`package:little_atlas/...`)

Separate each group with a blank line.

### Formatting

- Use `dart format` (default settings, line length 80)
- Trailing commas on all multi-line parameter lists (enables better auto-formatting)
- Prefer `const` wherever the analyzer suggests it

## Python / FastAPI

### Style Reference

Follow [PEP 8](https://peps.python.org/pep-0008/) with these project-specific additions.

### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Files / modules | snake_case | `place_service.py` |
| Classes | PascalCase | `PlaceService`, `PlaceResponse` |
| Functions / methods | snake_case | `get_nearby_places()` |
| Variables | snake_case | `distance_km`, `place_count` |
| Constants | UPPER_SNAKE_CASE | `DEFAULT_RADIUS`, `MAX_RESULTS` |
| Private | prefix with `_` | `_parse_hours()` |

### API Routes

```python
from fastapi import APIRouter, Depends, Query

router = APIRouter(prefix="/places", tags=["places"])

@router.get("")
async def get_places(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    radius: int = Query(10000, ge=100, le=100000),
    category: str | None = Query(None),
    lang: str = Query("en", regex="^(en|el|ru)$"),
    service: PlaceService = Depends(get_place_service),
) -> list[PlaceResponse]:
    return await service.get_nearby(lat, lon, radius, category, lang)
```

Rules:
- Always use type hints on parameters and return types
- Use `Query(...)` for required params, `Query(default)` for optional
- Add validation constraints (`ge`, `le`, `regex`) on all inputs
- One router per resource, mounted in `main.py`
- Use dependency injection via `Depends()` for services

### Pydantic Schemas

```python
from pydantic import BaseModel

class PlaceResponse(BaseModel):
    id: int
    name: str
    lat: float
    lon: float
    category: str
    distance_m: float
    is_indoor: bool
    amenities: list[str]
    photos: list[str]

    model_config = {"from_attributes": True}
```

Rules:
- Request schemas: suffix `Request` (if needed)
- Response schemas: suffix `Response`
- Use `model_config = {"from_attributes": True}` for ORM compatibility
- Keep schemas flat — avoid deep nesting in API responses

### SQLAlchemy Models

```python
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB
from geoalchemy2 import Geography

class Place(Base):
    __tablename__ = "places"

    id = Column(Integer, primary_key=True)
    name_en = Column(String(255), nullable=False)
    name_el = Column(String(255))
    name_ru = Column(String(255))
    location = Column(Geography("POINT", srid=4326), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"))
    is_indoor = Column(Boolean, default=False)
    amenities = Column(JSONB, default=[])
```

Rules:
- One model per file in `models/`
- Use `Geography` type (not `Geometry`) for lat/lon data — gives distance in meters
- Use `JSONB` for flexible/array fields (amenities, photos, hours)

### Services

```python
class PlaceService:
    def __init__(self, db: AsyncSession, redis: Redis):
        self._db = db
        self._redis = redis

    async def get_nearby(
        self, lat: float, lon: float, radius: int, category: str | None, lang: str
    ) -> list[PlaceResponse]:
        # Query logic here
        ...
```

Rules:
- Services receive dependencies via constructor
- All DB operations are `async`
- Business logic lives in services, not in routes
- Routes are thin — validate input, call service, return response

### Error Handling

```python
from fastapi import HTTPException

# In services — raise HTTPException for client errors
raise HTTPException(status_code=404, detail="Place not found")

# In crawlers — log and continue (don't crash the pipeline)
try:
    await crawl_source()
except Exception:
    logger.exception("Crawler failed for source X")
```

Rules:
- Use `HTTPException` for API errors
- Crawlers: catch broadly, log, and continue — never crash the scheduler
- Use Python `logging` module, not `print()`

### Formatting

- Use `ruff` for linting and formatting (replaces black + isort + flake8)
- Line length: 100 characters
- Use `ruff check --fix` before committing

## Git Conventions

### Branch Naming

```
feature/FE-001-map-view
feature/BE-001-places-api
bugfix/FE-010-marker-overlap
chore/setup-docker-compose
```

### Commit Messages

```
feat(places): add nearby search endpoint with PostGIS

fix(map): resolve marker clustering at low zoom

chore(docker): add Redis to compose setup

docs(spec): update weather classification rules
```

Format: `type(scope): description`

Types: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`

Scope: component name (`places`, `map`, `events`, `weather`, `docker`, `crawler`)

### PR Conventions

- PR title matches commit message format
- PR description includes: what changed, why, how to test
- One feature/fix per PR — keep PRs small and focused

## Project-Wide Rules

- No hardcoded strings in UI — all user-facing text goes through localization (ARB files)
- No hardcoded URLs or API keys — use config/environment variables
- No `print()` statements — use proper logging
- All API responses include proper HTTP status codes
- All list endpoints support pagination (when data grows)
- Every new endpoint gets a corresponding test
