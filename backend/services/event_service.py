from __future__ import annotations

import datetime

from geoalchemy2 import functions as geo_func
from sqlalchemy import select, func, cast, Float
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from models.event import Event
from schemas.event import EventResponse


class EventService:
    def __init__(self, db: AsyncSession, redis: aioredis.Redis) -> None:
        self.db = db
        self.redis = redis

    async def get_upcoming(
        self,
        lat: float,
        lon: float,
        radius: int = 5000,
        date_from: datetime.date | None = None,
        date_to: datetime.date | None = None,
        age_group: str | None = None,
        lang: str = "en",
    ) -> list[EventResponse]:
        """Return upcoming events near (lat, lon)."""

        ref_point = func.ST_SetSRID(func.ST_MakePoint(lon, lat), 4326)

        distance = cast(
            geo_func.ST_Distance(Event.location, ref_point),
            Float,
        ).label("distance_m")

        now = datetime.datetime.now(datetime.timezone.utc)

        stmt = (
            select(Event, distance)
            .where(
                geo_func.ST_DWithin(Event.location, ref_point, radius),
                Event.start_date >= (date_from or now),
            )
            .order_by(Event.start_date)
        )

        if date_to is not None:
            stmt = stmt.where(Event.start_date <= datetime.datetime.combine(
                date_to, datetime.time.max, tzinfo=datetime.timezone.utc
            ))

        if age_group is not None:
            parts = age_group.split("-")
            if len(parts) == 2:
                age_min_val, age_max_val = int(parts[0]), int(parts[1])
                stmt = stmt.where(Event.age_min <= age_max_val, Event.age_max >= age_min_val)

        result = await self.db.execute(stmt)
        rows = result.all()

        events: list[EventResponse] = []
        for event, dist in rows:
            ev_lat: float | None = None
            ev_lon: float | None = None
            if event.location is not None:
                wkt_result = await self.db.execute(
                    select(
                        func.ST_Y(func.ST_GeomFromWKB(event.location)),
                        func.ST_X(func.ST_GeomFromWKB(event.location)),
                    )
                )
                pt = wkt_result.one()
                ev_lat, ev_lon = pt[0], pt[1]

            events.append(
                EventResponse(
                    id=event.id,
                    title=getattr(event, f"title_{lang}", event.title_en),
                    description=getattr(event, f"description_{lang}", event.description_en),
                    lat=ev_lat,
                    lon=ev_lon,
                    venue_name=event.venue_name,
                    address=event.address,
                    start_date=event.start_date,
                    end_date=event.end_date,
                    is_indoor=event.is_indoor,
                    age_min=event.age_min,
                    age_max=event.age_max,
                    source_url=event.source_url,
                )
            )
        return events
