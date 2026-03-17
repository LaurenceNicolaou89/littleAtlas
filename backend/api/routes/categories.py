import json

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import redis.asyncio as aioredis

from api.dependencies import get_db, get_redis
from models.category import Category
from schemas.category import CategoryResponse, CategoryListResponse
from services.common import localized

router = APIRouter(tags=["categories"])

# Cache categories for 24 hours
CATEGORIES_CACHE_TTL = 86400


@router.get("/categories", response_model=CategoryListResponse)
async def list_categories(
    lang: str = Query("en", pattern="^(en|el|ru)$", description="Response language"),
    db: AsyncSession = Depends(get_db),
    redis_conn: aioredis.Redis = Depends(get_redis),
) -> CategoryListResponse:
    cache_key = f"categories:{lang}"

    # Try cache first
    cached = await redis_conn.get(cache_key)
    if cached is not None:
        items = json.loads(cached)
        return CategoryListResponse(
            categories=[CategoryResponse(**c) for c in items],
            total=len(items),
        )

    result = await db.execute(select(Category).order_by(Category.slug))
    categories = result.scalars().all()

    data = [
        CategoryResponse(
            id=cat.id,
            slug=cat.slug,
            name=localized(cat, "name", lang),
            icon=cat.icon,
        )
        for cat in categories
    ]

    # Cache the result
    await redis_conn.set(
        cache_key,
        json.dumps([c.model_dump() for c in data]),
        ex=CATEGORIES_CACHE_TTL,
    )

    return CategoryListResponse(categories=data, total=len(data))
