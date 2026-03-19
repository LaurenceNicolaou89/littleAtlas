"""CR-006: Weather sync service — pre-caches weather for major Cyprus cities."""

from __future__ import annotations

import json
import logging

import httpx
import redis.asyncio as aioredis

from config import settings
from crawlers.constants import CYPRUS_CITIES
from services.weather_utils import calculate_weather_mode

logger = logging.getLogger(__name__)

# Pre-cache TTL: 30 minutes (matches the scheduler interval)
WEATHER_CACHE_TTL = 1800

OPENWEATHERMAP_URL = "https://api.openweathermap.org/data/2.5/weather"


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
                    rain_data = raw.get("rain", {})

                    temp = main_data.get("temp")
                    description = weather_main.get("description", "")
                    icon = weather_main.get("icon", "")
                    humidity = main_data.get("humidity")
                    wind_speed_ms = wind_data.get("speed")  # m/s from API
                    wind_speed_kmh = (wind_speed_ms * 3.6) if wind_speed_ms is not None else 0.0
                    rain_1h = rain_data.get("1h", 0.0)

                    weather_mode = calculate_weather_mode(
                        temp=temp,
                        rain=rain_1h,
                        wind_speed_kmh=wind_speed_kmh,
                        uv_index=None,  # UV not available from basic endpoint
                    )

                    # Cache using WeatherResponse-compatible schema
                    cache_data = {
                        "lat": city["lat"],
                        "lon": city["lon"],
                        "temp": temp,
                        "description": description,
                        "icon": icon,
                        "humidity": humidity,
                        "wind_speed": wind_speed_ms,
                        "uv_index": None,
                        "weather_mode": weather_mode,
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
