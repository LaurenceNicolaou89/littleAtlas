from __future__ import annotations

from fastapi import HTTPException
from geoalchemy2 import functions as geo_func
from sqlalchemy import select, func, cast, Float, or_
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from models.place import Place
from models.category import Category
from schemas.place import PlaceResponse
from services.common import localized, resolve_age_range


def _escape_like(value: str) -> str:
    """Escape special LIKE/ILIKE characters in user input."""
    return value.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


class PlaceService:
    def __init__(self, db: AsyncSession, redis: aioredis.Redis) -> None:
        self._db = db
        self._redis = redis

    async def get_nearby(
        self,
        lat: float,
        lon: float,
        radius: int = 5000,
        category: str | None = None,
        age_group: str | None = None,
        indoor: bool | None = None,
        amenities: str | None = None,
        q: str | None = None,
        lang: str = "en",
        offset: int = 0,
        limit: int = 50,
    ) -> list[PlaceResponse]:
        """Return places within *radius* metres of (lat, lon) using PostGIS ST_DWithin."""

        # Reference point as Geography
        ref_point = func.ST_SetSRID(func.ST_MakePoint(lon, lat), 4326)

        # Distance column
        distance = cast(
            geo_func.ST_Distance(Place.location, ref_point),
            Float,
        ).label("distance_m")

        # Extract lat/lon in the main SELECT to avoid N+1 per-row queries
        place_lat = func.ST_Y(func.ST_GeomFromWKB(Place.location)).label("place_lat")
        place_lon = func.ST_X(func.ST_GeomFromWKB(Place.location)).label("place_lon")

        stmt = (
            select(Place, Category.slug.label("category_slug"), distance, place_lat, place_lon)
            .outerjoin(Category, Place.category_id == Category.id)
            .where(
                geo_func.ST_DWithin(Place.location, ref_point, radius)
            )
            .order_by(distance)
            .offset(offset)
            .limit(limit)
        )

        # Optional filters
        if category is not None:
            stmt = stmt.where(Category.slug == category)

        if indoor is not None:
            stmt = stmt.where(Place.is_indoor == indoor)

        if age_group is not None:
            age_range = resolve_age_range(age_group)
            if age_range is not None:
                age_min_val, age_max_val = age_range
                stmt = stmt.where(Place.age_min <= age_max_val, Place.age_max >= age_min_val)

        if amenities is not None:
            amenity_list = [a.strip() for a in amenities.split(",") if a.strip()]
            for amenity in amenity_list:
                stmt = stmt.where(Place.amenities.op("@>")(func.cast(f'["{amenity}"]', Place.amenities.type)))

        if q is not None:
            escaped = _escape_like(q)
            pattern = f"%{escaped}%"
            stmt = stmt.where(
                or_(
                    Place.name_en.ilike(pattern),
                    Place.name_el.ilike(pattern),
                    Place.name_ru.ilike(pattern),
                )
            )

        result = await self._db.execute(stmt)
        rows = result.all()

        places: list[PlaceResponse] = []
        for place, cat_slug, dist, p_lat, p_lon in rows:
            places.append(
                PlaceResponse(
                    id=place.id,
                    name=localized(place, "name", lang),
                    description=localized(place, "description", lang),
                    lat=p_lat,
                    lon=p_lon,
                    category=cat_slug,
                    distance_m=round(dist, 1) if dist else None,
                    is_indoor=place.is_indoor,
                    age_min=place.age_min,
                    age_max=place.age_max,
                    amenities=place.amenities or [],
                    photos=place.photos or [],
                    address=place.address,
                    phone=place.phone,
                    website=place.website,
                    opening_hours=place.opening_hours,
                )
            )
        return places

    async def get_by_id(self, place_id: int, lang: str = "en") -> PlaceResponse:
        """Return a single place by ID."""
        place_lat = func.ST_Y(func.ST_GeomFromWKB(Place.location)).label("place_lat")
        place_lon = func.ST_X(func.ST_GeomFromWKB(Place.location)).label("place_lon")

        stmt = (
            select(Place, Category.slug.label("category_slug"), place_lat, place_lon)
            .outerjoin(Category, Place.category_id == Category.id)
            .where(Place.id == place_id)
        )
        result = await self._db.execute(stmt)
        row = result.one_or_none()

        if row is None:
            raise HTTPException(status_code=404, detail="Place not found")

        place, cat_slug, p_lat, p_lon = row

        return PlaceResponse(
            id=place.id,
            name=localized(place, "name", lang),
            description=localized(place, "description", lang),
            lat=p_lat,
            lon=p_lon,
            category=cat_slug,
            distance_m=None,
            is_indoor=place.is_indoor,
            age_min=place.age_min,
            age_max=place.age_max,
            amenities=place.amenities or [],
            photos=place.photos or [],
            address=place.address,
            phone=place.phone,
            website=place.website,
            opening_hours=place.opening_hours,
        )
