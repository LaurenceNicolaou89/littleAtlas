from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from api.dependencies import get_db
from models.category import Category

router = APIRouter(tags=["categories"])


@router.get("/categories")
async def list_categories(
    lang: str = Query("en", regex="^(en|el|ru)$", description="Response language"),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Category).order_by(Category.slug))
    categories = result.scalars().all()

    name_field = f"name_{lang}"
    return [
        {
            "id": cat.id,
            "slug": cat.slug,
            "name": getattr(cat, name_field, cat.name_en),
            "icon": cat.icon,
        }
        for cat in categories
    ]
