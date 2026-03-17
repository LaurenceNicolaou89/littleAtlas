"""CR-006: Weather sync service — pre-caches weather for major Cyprus cities."""

from __future__ import annotations

import json
import logging

import httpx
import redis.asyncio as aioredis

from config import settings

logger = logging.getLogger(__name__)

# Pre-cache TTL: 30 minutes (matches the scheduler interval)
WEATHER_CACHE_TTL = 1800

OPENWEATHERMAP_URL = "https://api.openweathermap.org/data/2.5/weather"

# Major Cyprus cities to pre-cache
CYPRUS_CITIES = [
    {"name": "Nicosia", "lat": 35.1856, "lon": 33.3823},
    {"name": "Limassol", "lat": 34.6786, "lon": 33.0413},
    {"name": "Larnaca", "lat": 34.9003, "lon": 33.6232},
    {"name": "Paphos", "lat": 34.7754, "lon": 32.4218},
    {"name": "Famagusta", "lat": 35.1174, "lon": 33.9391},
    {"name": "Ayia Napa", "lat": 34.9826, "lon": 33.9988},
]


async def sync_weather(redis: aioredis.Redis) -> int:
    """Fetch and cache weather for all major Cyprus cities.

    Returns the number of cities successfully cached.
    """
    api_key = settings.OPENWEATHERMAP_API_KEY
    if not api_key:
        logger.warning("OPENWEATHERMAP_API_KEY not set — skipping weather sync")
        return 0

    logger.info("Weather sync starting for %d cities", len(CYPRUS_CITIES))
    cached_count = 0

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            for city in CYPRUS_CITIES:
                try:
                    params = {
                        "lat": city["lat"],
                        "lon": city["lon"],
                        "appid": api_key,
                        "units": "metric",
                    }
                    resp = await client.get(OPENWEATHERMAP_URL, params=params)
                    resp.raise_for_status()
                    raw = resp.json()

                    weather_main = raw.get("weather", [{}])[0]
                    main_data = raw.get("main", {})
                    wind_data = raw.get("wind", {})

                    temp = main_data.get("temp")
                    description = weather_main.get("description", "")
                    icon = weather_main.get("icon", "")

                    # Simple outdoor-friendly heuristic
                    is_outdoor_friendly = True
                    rain_keywords = {"rain", "storm", "thunderstorm", "snow", "drizzle"}
                    if any(kw in description.lower() for kw in rain_keywords):
                        is_outdoor_friendly = False
                    if temp is not None and (temp > 38 or temp < 5):
                        is_outdoor_friendly = False

                    cache_data = {
                        "lat": city["lat"],
                        "lon": city["lon"],
                        "temperature_c": temp,
                        "feels_like_c": main_data.get("feels_like"),
                        "humidity": main_data.get("humidity"),
                        "wind_speed_ms": wind_data.get("speed"),
                        "description": description,
                        "icon": icon,
                        "is_outdoor_friendly": is_outdoor_friendly,
                    }

                    # Use the same cache key format as weather_service.py
                    cache_key = f"weather:{round(city['lat'], 2)}:{round(city['lon'], 2)}"
                    await redis.set(cache_key, json.dumps(cache_data), ex=WEATHER_CACHE_TTL)
                    cached_count += 1
                    logger.debug("Cached weather for %s", city["name"])

                except httpx.HTTPStatusError as exc:
                    logger.error(
                        "Weather API HTTP error for %s: %s",
                        city["name"],
                        exc.response.status_code,
                    )
                except httpx.RequestError as exc:
                    logger.error(
                        "Weather API request error for %s: %s", city["name"], exc
                    )
                except Exception:
                    logger.exception("Error syncing weather for %s", city["name"])

    except Exception:
        logger.exception("Weather sync unexpected error")

    logger.info("Weather sync completed: %d/%d cities cached", cached_count, len(CYPRUS_CITIES))
    return cached_count
