from __future__ import annotations

import json
import logging

import httpx
import redis.asyncio as aioredis
from fastapi import HTTPException

from config import settings
from schemas.weather import WeatherResponse

logger = logging.getLogger(__name__)

# Cache weather data for 30 minutes per business-logic.md
WEATHER_CACHE_TTL = 1800


def _calculate_weather_mode(
    temp: float | None,
    rain: float,
    wind_speed_kmh: float,
    uv_index: float | None,
) -> str:
    """Determine weather mode per business-logic.md decision tree.

    Returns one of: "indoor", "caution", "outdoor".
    """
    # Rain > 0 -> indoor
    if rain > 0:
        return "indoor"
    # Temperature checks
    if temp is not None:
        if temp < 10:
            return "indoor"
        if temp > 38:
            return "indoor"
    # Wind > 50 km/h -> indoor
    if wind_speed_kmh > 50:
        return "indoor"
    # UV >= 8 -> caution
    if uv_index is not None and uv_index >= 8:
        return "caution"
    # Temp 10-15 -> caution
    if temp is not None and 10 <= temp <= 15:
        return "caution"
    return "outdoor"


class WeatherService:
    def __init__(self, redis: aioredis.Redis) -> None:
        self._redis = redis

    async def get_weather(self, lat: float, lon: float) -> WeatherResponse:
        """Fetch current weather, with Redis caching."""

        # Round coords to 2 decimals for cache key stability
        cache_key = f"weather:{round(lat, 2)}:{round(lon, 2)}"

        # Try cache first
        cached = await self._redis.get(cache_key)
        if cached is not None:
            data = json.loads(cached)
            return WeatherResponse(**data)

        # Fetch from OpenWeatherMap
        api_key = settings.OPENWEATHERMAP_API_KEY
        if not api_key:
            raise HTTPException(
                status_code=503,
                detail="Weather service unavailable - API key not configured",
            )

        try:
            async with httpx.AsyncClient(timeout=10) as client:
                # Fetch current weather
                weather_url = "https://api.openweathermap.org/data/2.5/weather"
                weather_params = {
                    "lat": lat,
                    "lon": lon,
                    "appid": api_key,
                    "units": "metric",
                }
                resp = await client.get(weather_url, params=weather_params)
                resp.raise_for_status()
                raw = resp.json()

                # Try to fetch UV index via onecall endpoint
                uv_index: float | None = None
                try:
                    onecall_url = "https://api.openweathermap.org/data/3.0/onecall"
                    onecall_params = {
                        "lat": lat,
                        "lon": lon,
                        "appid": api_key,
                        "units": "metric",
                        "exclude": "minutely,hourly,daily,alerts",
                    }
                    uv_resp = await client.get(onecall_url, params=onecall_params)
                    if uv_resp.status_code == 200:
                        uv_data = uv_resp.json()
                        uv_index = uv_data.get("current", {}).get("uvi")
                except Exception:
                    pass  # UV index is optional; proceed without it

        except httpx.HTTPStatusError as exc:
            logger.error("Weather API HTTP error: %s", exc.response.status_code)
            raise HTTPException(
                status_code=502,
                detail="Weather service upstream error",
            ) from exc
        except httpx.RequestError as exc:
            logger.error("Weather API request error: %s", exc)
            raise HTTPException(
                status_code=502,
                detail="Weather service unavailable",
            ) from exc

        weather_main = raw.get("weather", [{}])[0]
        main_data = raw.get("main", {})
        wind_data = raw.get("wind", {})
        rain_data = raw.get("rain", {})

        temp = main_data.get("temp")
        description = weather_main.get("description", "")
        icon = weather_main.get("icon", "")
        humidity = main_data.get("humidity")
        wind_speed_ms = wind_data.get("speed")  # m/s from API
        # Convert wind speed from m/s to km/h for mode calculation
        wind_speed_kmh = (wind_speed_ms * 3.6) if wind_speed_ms is not None else 0.0
        # Rain volume in last 1h (mm); 0 if no rain
        rain_1h = rain_data.get("1h", 0.0)

        weather_mode = _calculate_weather_mode(
            temp=temp,
            rain=rain_1h,
            wind_speed_kmh=wind_speed_kmh,
            uv_index=uv_index,
        )

        result = WeatherResponse(
            lat=lat,
            lon=lon,
            temp=temp,
            description=description,
            icon=icon,
            humidity=humidity,
            wind_speed=wind_speed_ms,
            uv_index=uv_index,
            weather_mode=weather_mode,
        )

        # Cache the result
        await self._redis.set(cache_key, result.model_dump_json(), ex=WEATHER_CACHE_TTL)

        return result
