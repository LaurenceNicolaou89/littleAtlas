from __future__ import annotations

import json

import httpx
import redis.asyncio as aioredis

from config import settings
from schemas.weather import WeatherResponse

# Cache weather data for 15 minutes
WEATHER_CACHE_TTL = 900


class WeatherService:
    def __init__(self, redis: aioredis.Redis) -> None:
        self.redis = redis

    async def get_weather(self, lat: float, lon: float) -> WeatherResponse:
        """Fetch current weather, with Redis caching."""

        # Round coords to 2 decimals for cache key stability
        cache_key = f"weather:{round(lat, 2)}:{round(lon, 2)}"

        # Try cache first
        cached = await self.redis.get(cache_key)
        if cached is not None:
            data = json.loads(cached)
            return WeatherResponse(**data)

        # Fetch from OpenWeatherMap
        api_key = settings.OPENWEATHERMAP_API_KEY
        if not api_key:
            return WeatherResponse(lat=lat, lon=lon)

        url = "https://api.openweathermap.org/data/2.5/weather"
        params = {
            "lat": lat,
            "lon": lon,
            "appid": api_key,
            "units": "metric",
        }

        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.get(url, params=params)
            resp.raise_for_status()
            raw = resp.json()

        weather_main = raw.get("weather", [{}])[0]
        main_data = raw.get("main", {})
        wind_data = raw.get("wind", {})

        temp = main_data.get("temp")
        description = weather_main.get("description", "")
        icon = weather_main.get("icon", "")

        # Simple heuristic: not outdoor-friendly if raining or extreme temp
        is_outdoor_friendly = True
        rain_keywords = {"rain", "storm", "thunderstorm", "snow", "drizzle"}
        if any(kw in description.lower() for kw in rain_keywords):
            is_outdoor_friendly = False
        if temp is not None and (temp > 38 or temp < 5):
            is_outdoor_friendly = False

        result = WeatherResponse(
            lat=lat,
            lon=lon,
            temperature_c=temp,
            feels_like_c=main_data.get("feels_like"),
            humidity=main_data.get("humidity"),
            wind_speed_ms=wind_data.get("speed"),
            description=description,
            icon=icon,
            is_outdoor_friendly=is_outdoor_friendly,
        )

        # Cache the result
        await self.redis.set(cache_key, result.model_dump_json(), ex=WEATHER_CACHE_TTL)

        return result
