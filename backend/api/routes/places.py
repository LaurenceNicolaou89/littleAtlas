from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from api.dependencies import get_db, get_redis
from schemas.place import PlaceListResponse, PlaceResponse
from services.place_service import PlaceService

router = APIRouter(tags=["places"])


@router.get("/places", response_model=PlaceListResponse)
async def list_places(
    lat: float = Query(..., ge=-90, le=90, description="Latitude"),
    lon: float = Query(..., ge=-180, le=180, description="Longitude"),
    radius: int = Query(5000, ge=100, le=50000, description="Search radius in metres"),
    category: str | None = Query(None, description="Category slug filter"),
    age_group: str | None = Query(None, description="Age group: infant, toddler, preschool, school_age, or '0-3'"),
    indoor: bool | None = Query(None, description="Filter indoor/outdoor"),
    amenities: str | None = Query(None, description="Comma-separated amenity slugs, e.g. 'changing_table,parking'"),
    q: str | None = Query(None, max_length=200, description="Free-text search query"),
    lang: str = Query("en", pattern="^(en|el|ru)$", description="Response language"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    limit: int = Query(50, ge=1, le=100, description="Pagination limit"),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
) -> PlaceListResponse:
    service = PlaceService(db=db, redis=redis)
    places = await service.get_nearby(
        lat=lat,
        lon=lon,
        radius=radius,
        category=category,
        age_group=age_group,
        indoor=indoor,
        amenities=amenities,
        q=q,
        lang=lang,
        offset=offset,
        limit=limit,
    )
    return PlaceListResponse(places=places, total=len(places))


@router.get("/places/{place_id}", response_model=PlaceResponse)
async def get_place(
    place_id: int,
    lang: str = Query("en", pattern="^(en|el|ru)$", description="Response language"),
    db: AsyncSession = Depends(get_db),
    redis: aioredis.Redis = Depends(get_redis),
) -> PlaceResponse:
    service = PlaceService(db=db, redis=redis)
    return await service.get_by_id(place_id=place_id, lang=lang)
