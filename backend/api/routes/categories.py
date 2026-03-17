import json

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import redis.asyncio as aioredis

from api.dependencies import get_db, get_redis
from models.category import Category
from services.place_service import _localized

router = APIRouter(tags=["categories"])

# Cache categories for 24 hours
CATEGORIES_CACHE_TTL = 86400


@router.get("/categories")
async def list_categories(
    lang: str = Query("en", regex="^(en|el|ru)$", description="Response language"),
    db: AsyncSession = Depends(get_db),
    redis_conn: aioredis.Redis = Depends(get_redis),
):
    cache_key = f"categories:{lang}"

    # Try cache first
    cached = await redis_conn.get(cache_key)
    if cached is not None:
        return json.loads(cached)

    result = await db.execute(select(Category).order_by(Category.slug))
    categories = result.scalars().all()

    data = [
        {
            "id": cat.id,
            "slug": cat.slug,
            "name": _localized(cat, "name", lang),
            "icon": cat.icon,
        }
        for cat in categories
    ]

    # Cache the result
    await redis_conn.set(cache_key, json.dumps(data), ex=CATEGORIES_CACHE_TTL)

    return data
