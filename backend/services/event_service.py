from __future__ import annotations

import datetime

from geoalchemy2 import functions as geo_func
from sqlalchemy import select, func, cast, Float, case, or_
from sqlalchemy.ext.asyncio import AsyncSession
import redis.asyncio as aioredis

from models.event import Event
from schemas.event import EventResponse
from services.common import localized, resolve_age_range
from services.geo_utils import extract_lat, extract_lon


class EventService:
    def __init__(self, db: AsyncSession, redis: aioredis.Redis) -> None:
        self._db = db
        self._redis = redis

    async def get_upcoming(
        self,
        lat: float,
        lon: float,
        radius: int = 5000,
        date_from: datetime.date | None = None,
        date_to: datetime.date | None = None,
        age_group: str | None = None,
        event_type: str | None = None,
        lang: str = "en",
        offset: int = 0,
        limit: int = 50,
    ) -> tuple[list[EventResponse], int]:
        """Return upcoming events near (lat, lon).

        Events that are "Happening Now" (start_date <= now <= end_date)
        are sorted first, then upcoming events by start_date ascending.
        """

        ref_point = func.ST_SetSRID(func.ST_MakePoint(lon, lat), 4326)

        distance = cast(
            geo_func.ST_Distance(Event.location, ref_point),
            Float,
        ).label("distance_m")

        now = datetime.datetime.now(datetime.timezone.utc)

        # "Happening Now" flag: 0 = happening now (sorted first), 1 = upcoming
        happening_now = case(
            (
                (Event.start_date <= now) & (
                    (Event.end_date >= now) | (Event.end_date.is_(None))
                ),
                0,
            ),
            else_=1,
        ).label("happening_now")

        # Extract lat/lon in the main SELECT to avoid N+1 per-row queries
        event_lat = extract_lat(Event.location).label("event_lat")
        event_lon = extract_lon(Event.location).label("event_lon")

        # Include events that are either happening now OR upcoming
        if date_from is not None:
            date_filter_start = datetime.datetime.combine(
                date_from, datetime.time.min, tzinfo=datetime.timezone.utc
            )
        else:
            date_filter_start = now

        # Build base query with all WHERE clauses first
        stmt = (
            select(Event, distance, happening_now, event_lat, event_lon)
            .where(
                geo_func.ST_DWithin(Event.location, ref_point, radius),
                or_(
                    # Upcoming: starts on or after the filter date
                    Event.start_date >= date_filter_start,
                    # Happening now: started in the past but not yet ended
                    (Event.start_date <= now) & (
                        (Event.end_date >= now) | (Event.end_date.is_(None))
                    ),
                ),
            )
        )

        # Optional filters — applied BEFORE ordering/pagination
        if date_to is not None:
            stmt = stmt.where(Event.start_date <= datetime.datetime.combine(
                date_to, datetime.time.max, tzinfo=datetime.timezone.utc
            ))

        if event_type is not None:
            stmt = stmt.where(Event.event_type == event_type)

        if age_group is not None:
            age_range = resolve_age_range(age_group)
            if age_range is not None:
                age_min_val, age_max_val = age_range
                stmt = stmt.where(Event.age_min <= age_max_val, Event.age_max >= age_min_val)

        # Count query using the same filters (no limit/offset)
        count_stmt = select(func.count()).select_from(stmt.subquery())
        total = (await self._db.execute(count_stmt)).scalar_one()

        # Now add ordering and pagination
        stmt = stmt.order_by(happening_now, Event.start_date).offset(offset).limit(limit)

        result = await self._db.execute(stmt)
        rows = result.all()

        events: list[EventResponse] = []
        for event, dist, _happening, ev_lat, ev_lon in rows:
            events.append(
                EventResponse(
                    id=event.id,
                    title=localized(event, "title", lang),
                    description=localized(event, "description", lang),
                    lat=ev_lat,
                    lon=ev_lon,
                    distance_m=round(dist, 1) if dist else None,
                    venue_name=event.venue_name,
                    address=event.address,
                    start_date=event.start_date,
                    end_date=event.end_date,
                    is_indoor=event.is_indoor,
                    age_min=event.age_min,
                    age_max=event.age_max,
                    source_url=event.source_url,
                    event_type=event.event_type,
                )
            )
        return events, total
