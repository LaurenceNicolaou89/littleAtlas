import datetime

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from api.dependencies import get_db, get_redis
from schemas.event import EventListResponse
from services.event_service import EventService

router = APIRouter(tags=["events"])


@router.get("/events", response_model=EventListResponse)
async def list_events(
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lon: float = Query(..., ge=-180, le=180, description="Longitude"),
    radius: int = Query(5000, ge=100, le=50000, description="Search radius in metres"),
    date_from: datetime.date | None = Query(None, description="Start date filter"),
    date_to: datetime.date | None = Query(None, description="End date filter"),
    age_group: str | None = Query(None, description="Age group, e.g. '0-3', '4-8'"),
    lang: str = Query("en", regex="^(en|el|ru)$", description="Response language"),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
):
    service = EventService(db=db, redis=redis)
    events = await service.get_upcoming(
        lat=lat,
        lon=lon,
        radius=radius,
        date_from=date_from,
        date_to=date_to,
        age_group=age_group,
        lang=lang,
    )
    return EventListResponse(events=events, total=len(events))
