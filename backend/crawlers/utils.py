"""Shared crawler utilities — DRY extraction of common crawler helpers."""

from __future__ import annotations

import logging
from typing import Any

from geoalchemy2.elements import WKTElement
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from models.category import Category
from models.place import Place

logger = logging.getLogger(__name__)


async def get_category_id(
    db: AsyncSession, slug: str, cache: dict[str, int]
) -> int | None:
    """Look up category ID by slug, with caller-provided cache dict."""
    if slug in cache:
        return cache[slug]
    result = await db.execute(select(Category).where(Category.slug == slug))
    cat = result.scalar_one_or_none()
    if cat:
        cache[slug] = cat.id
        return cat.id
    return None


async def upsert_place(db: AsyncSession, data: dict[str, Any], source: str) -> None:
    """Insert or update a place based on source + source_id."""
    try:
        lat = float(data["lat"])
        lon = float(data["lon"])
    except (ValueError, TypeError, KeyError):
        logger.warning("Skipping place %s: invalid lat/lon: lat=%r, lon=%r",
                        data.get("source_id"), data.get("lat"), data.get("lon"))
        return

    result = await db.execute(
        select(Place).where(Place.source == source, Place.source_id == data["source_id"])
    )
    existing = result.scalar_one_or_none()

    location = WKTElement(f"POINT({lon} {lat})", srid=4326)

    if existing:
        existing.name_en = data["name_en"]
        existing.name_el = data.get("name_el", "")
        existing.name_ru = data.get("name_ru", "")
        existing.location = location
        existing.address = data.get("address", "")
        existing.phone = data.get("phone", "")
        existing.website = data.get("website", "")
        existing.is_indoor = data.get("is_indoor", False)
        existing.amenities = data.get("amenities", [])
        if data.get("opening_hours") is not None:
            existing.opening_hours = data["opening_hours"]
        if data.get("photos") is not None:
            existing.photos = data["photos"]
        if data.get("category_id"):
            existing.category_id = data["category_id"]
    else:
        place = Place(
            name_en=data["name_en"],
            name_el=data.get("name_el", ""),
            name_ru=data.get("name_ru", ""),
            location=location,
            address=data.get("address", ""),
            phone=data.get("phone", ""),
            website=data.get("website", ""),
            opening_hours=data.get("opening_hours"),
            photos=data.get("photos"),
            amenities=data.get("amenities", []),
            is_indoor=data.get("is_indoor", False),
            category_id=data.get("category_id"),
            source=source,
            source_id=data["source_id"],
        )
        db.add(place)
