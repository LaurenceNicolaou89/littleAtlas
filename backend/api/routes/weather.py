from fastapi import APIRouter, Depends, Query, Request
import redis.asyncio as aioredis

from api.dependencies import get_redis
from schemas.weather import WeatherResponse
from services.weather_service import WeatherService

router = APIRouter(tags=["weather"])


@router.get("/weather", response_model=WeatherResponse)
async def get_weather(
    request: Request,
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lon: float = Query(..., ge=-180, le=180, description="Longitude"),
    redis: aioredis.Redis = Depends(get_redis),
) -> WeatherResponse:
    service = WeatherService(redis=redis)
    return await service.get_weather(lat=lat, lon=lon)
