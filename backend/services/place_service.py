from __future__ import annotations

from geoalchemy2 import functions as geo_func
from sqlalchemy import select, func, cast, Float
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from models.place import Place
from models.category import Category
from schemas.place import PlaceResponse


class PlaceService:
    def __init__(self, db: AsyncSession, redis: aioredis.Redis) -> None:
        self.db = db
        self.redis = redis

    async def get_nearby(
        self,
        lat: float,
        lon: float,
        radius: int = 5000,
        category: str | None = None,
        age_group: str | None = None,
        indoor: bool | None = None,
        q: str | None = None,
        lang: str = "en",
    ) -> list[PlaceResponse]:
        """Return places within *radius* metres of (lat, lon) using PostGIS ST_DWithin."""

        # Reference point as Geography
        ref_point = func.ST_SetSRID(func.ST_MakePoint(lon, lat), 4326)

        # Distance column
        distance = cast(
            geo_func.ST_Distance(Place.location, ref_point),
            Float,
        ).label("distance_m")

        name_col = getattr(Place, f"name_{lang}", Place.name_en)
        desc_col = getattr(Place, f"description_{lang}", Place.description_en)

        stmt = (
            select(Place, Category.slug.label("category_slug"), distance)
            .outerjoin(Category, Place.category_id == Category.id)
            .where(
                geo_func.ST_DWithin(Place.location, ref_point, radius)
            )
            .order_by(distance)
        )

        # Optional filters
        if category is not None:
            stmt = stmt.where(Category.slug == category)

        if indoor is not None:
            stmt = stmt.where(Place.is_indoor == indoor)

        if age_group is not None:
            parts = age_group.split("-")
            if len(parts) == 2:
                age_min_val, age_max_val = int(parts[0]), int(parts[1])
                stmt = stmt.where(Place.age_min <= age_max_val, Place.age_max >= age_min_val)

        if q is not None:
            pattern = f"%{q}%"
            stmt = stmt.where(name_col.ilike(pattern) | desc_col.ilike(pattern))

        result = await self.db.execute(stmt)
        rows = result.all()

        places: list[PlaceResponse] = []
        for place, cat_slug, dist in rows:
            # Extract lat/lon from the geography point
            wkt_result = await self.db.execute(
                select(
                    func.ST_Y(func.ST_GeomFromWKB(place.location)),
                    func.ST_X(func.ST_GeomFromWKB(place.location)),
                )
            )
            pt = wkt_result.one()

            places.append(
                PlaceResponse(
                    id=place.id,
                    name=getattr(place, f"name_{lang}", place.name_en),
                    description=getattr(place, f"description_{lang}", place.description_en),
                    lat=pt[0],
                    lon=pt[1],
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
        stmt = (
            select(Place, Category.slug.label("category_slug"))
            .outerjoin(Category, Place.category_id == Category.id)
            .where(Place.id == place_id)
        )
        result = await self.db.execute(stmt)
        row = result.one_or_none()

        if row is None:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail="Place not found")

        place, cat_slug = row

        wkt_result = await self.db.execute(
            select(
                func.ST_Y(func.ST_GeomFromWKB(place.location)),
                func.ST_X(func.ST_GeomFromWKB(place.location)),
            )
        )
        pt = wkt_result.one()

        return PlaceResponse(
            id=place.id,
            name=getattr(place, f"name_{lang}", place.name_en),
            description=getattr(place, f"description_{lang}", place.description_en),
            lat=pt[0],
            lon=pt[1],
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
