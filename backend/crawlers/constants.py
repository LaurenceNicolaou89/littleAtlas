"""Shared constants for crawler modules."""

from __future__ import annotations

# Major Cyprus cities with coordinates — used by weather_sync and google_places_crawler
CYPRUS_CITIES: list[dict[str, object]] = [
    {"name": "Nicosia", "lat": 35.1856, "lon": 33.3823},
    {"name": "Limassol", "lat": 34.6786, "lon": 33.0413},
    {"name": "Larnaca", "lat": 34.9003, "lon": 33.6232},
    {"name": "Paphos", "lat": 34.7754, "lon": 32.4218},
    {"name": "Famagusta", "lat": 35.1174, "lon": 33.9391},
    {"name": "Ayia Napa", "lat": 34.9826, "lon": 33.9988},
]
