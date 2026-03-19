"""Cinema crawler for Cyprus cinemas (K-Cineplex, Rio, etc.)."""

from __future__ import annotations

import datetime
import hashlib
import logging
from typing import Any

import httpx
from bs4 import BeautifulSoup
from geoalchemy2.elements import WKTElement
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from crawlers.base import BaseCrawler
from models.event import Event

logger = logging.getLogger(__name__)

# Cyprus cinema venues with name, city, and coordinates
CINEMA_VENUES: list[dict[str, Any]] = [
    {
        "name": "K-Cineplex Larnaca",
        "city": "Larnaca",
        "lat": 34.9180,
        "lon": 33.6250,
        "url": "https://www.kcineplex.com/en/program/larnaca",
    },
    {
        "name": "K-Cineplex Paphos",
        "city": "Paphos",
        "lat": 34.7720,
        "lon": 32.4297,
        "url": "https://www.kcineplex.com/en/program/paphos",
    },
    {
        "name": "K-Cineplex Limassol",
        "city": "Limassol",
        "lat": 34.6916,
        "lon": 33.0260,
        "url": "https://www.kcineplex.com/en/program/limassol",
    },
    {
        "name": "K-Cineplex Nicosia",
        "city": "Nicosia",
        "lat": 35.1590,
        "lon": 33.3590,
        "url": "https://www.kcineplex.com/en/program/nicosia",
    },
    {
        "name": "Rio Cinemas Limassol",
        "city": "Limassol",
        "lat": 34.6840,
        "lon": 33.0370,
        "url": "https://www.riocinemas.com.cy/en/programme",
    },
]

# CSS selectors for parsing cinema listings — update if site structure changes
CINEMA_SELECTORS: dict[str, dict[str, str]] = {
    "kcineplex": {
        "movie_list": "div.movie-item, div.film-item, article.movie",
        "title": "h2, h3, .movie-title, .film-title",
        "showtime": ".showtime, .time, .screening-time, time",
    },
    "riocinemas": {
        "movie_list": "div.movie-item, div.film-item, article.movie",
        "title": "h2, h3, .movie-title, .film-title",
        "showtime": ".showtime, .time, .screening-time, time",
    },
}


def _generate_source_id(title: str, date: str, venue: str) -> str:
    """Generate a deterministic source_id from title + date + venue."""
    raw = f"{title}|{date}|{venue}".lower().strip()
    return hashlib.sha256(raw.encode()).hexdigest()[:32]


def _detect_selector_set(url: str) -> dict[str, str]:
    """Pick the right CSS selector set based on the URL."""
    if "kcineplex" in url:
        return CINEMA_SELECTORS["kcineplex"]
    if "riocinemas" in url:
        return CINEMA_SELECTORS["riocinemas"]
    return CINEMA_SELECTORS["kcineplex"]


class CinemaCrawler(BaseCrawler):
    """Crawls Cyprus cinema websites for movie showtimes."""

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)
        self.venues = CINEMA_VENUES

    async def parse(self, raw_data: dict) -> dict | None:
        """Parse a raw movie dict into our Event schema dict."""
        title = (raw_data.get("title") or "").strip()
        if not title:
            return None

        venue_name = raw_data.get("venue_name", "")
        start_date = raw_data.get("start_date")
        if not start_date:
            return None

        date_str = start_date.isoformat() if isinstance(start_date, datetime.datetime) else str(start_date)
        source_id = _generate_source_id(title, date_str, venue_name)

        lat = raw_data.get("lat")
        lon = raw_data.get("lon")
        location = (lat, lon) if lat and lon else None

        return {
            "title_en": title,
            "description_en": "",
            "venue_name": venue_name,
            "start_date": start_date,
            "location": location,
            "source_url": raw_data.get("source_url", ""),
            "source": "cinema_crawler",
            "source_id": source_id,
            "event_type": "cinema",
        }

    async def _upsert_event(self, data: dict) -> None:
        """Insert or update a cinema event using source + source_id as dedup key."""
        source_id = data.get("source_id", "")
        result = await self.db.execute(
            select(Event).where(
                Event.source == data.get("source", "cinema_crawler"),
                Event.source_url == source_id,
            )
        )
        existing = result.scalar_one_or_none()

        location = None
        if data.get("location"):
            lat, lon = data["location"]
            location = WKTElement(f"POINT({lon} {lat})", srid=4326)

        if existing:
            existing.title_en = data["title_en"]
            existing.description_en = data["description_en"]
            existing.venue_name = data["venue_name"]
            existing.start_date = data["start_date"]
            existing.event_type = data.get("event_type")
            if location:
                existing.location = location
        else:
            event = Event(
                title_en=data["title_en"],
                description_en=data["description_en"],
                venue_name=data["venue_name"],
                start_date=data["start_date"],
                location=location,
                source_url=source_id,
                source="cinema_crawler",
                event_type=data.get("event_type"),
            )
            self.db.add(event)

    async def _scrape_venue(
        self, client: httpx.AsyncClient, venue: dict
    ) -> list[dict]:
        """Scrape movie listings from a single cinema venue page."""
        url = venue["url"]
        venue_name = venue["name"]
        selectors = _detect_selector_set(url)
        raw_movies: list[dict] = []

        try:
            resp = await client.get(url, follow_redirects=True)
            resp.raise_for_status()
        except httpx.HTTPError as exc:
            logger.warning(
                "Cinema crawler: failed to fetch %s (%s): %s",
                venue_name, url, exc,
            )
            return []

        soup = BeautifulSoup(resp.text, "lxml")
        movie_items = soup.select(selectors["movie_list"])

        if not movie_items:
            logger.warning(
                "Cinema crawler: no movie items found at %s — "
                "site structure may have changed",
                venue_name,
            )
            return []

        today = datetime.datetime.now(datetime.timezone.utc).replace(
            hour=0, minute=0, second=0, microsecond=0,
        )

        for item in movie_items:
            try:
                title_el = item.select_one(selectors["title"])
                title = title_el.get_text(strip=True) if title_el else ""
                if not title:
                    continue

                showtime_els = item.select(selectors["showtime"])
                if showtime_els:
                    for st_el in showtime_els:
                        st_text = st_el.get_text(strip=True)
                        showtime = self._parse_showtime(st_text, today)
                        if showtime:
                            raw_movies.append({
                                "title": title,
                                "venue_name": venue_name,
                                "start_date": showtime,
                                "lat": venue["lat"],
                                "lon": venue["lon"],
                                "source_url": url,
                            })
                else:
                    # No showtime found — create one entry for today
                    raw_movies.append({
                        "title": title,
                        "venue_name": venue_name,
                        "start_date": today,
                        "lat": venue["lat"],
                        "lon": venue["lon"],
                        "source_url": url,
                    })
            except Exception:
                logger.exception(
                    "Cinema crawler: error parsing movie item at %s",
                    venue_name,
                )

        return raw_movies

    @staticmethod
    def _parse_showtime(
        text: str, base_date: datetime.datetime
    ) -> datetime.datetime | None:
        """Try to parse a showtime string like '14:30' or '2:30 PM'."""
        text = text.strip()
        if not text:
            return None

        formats = ["%H:%M", "%I:%M %p", "%I:%M%p", "%H.%M"]
        for fmt in formats:
            try:
                parsed = datetime.datetime.strptime(text, fmt)
                return base_date.replace(
                    hour=parsed.hour,
                    minute=parsed.minute,
                    second=0,
                    microsecond=0,
                )
            except ValueError:
                continue

        logger.debug("Cinema crawler: could not parse showtime '%s'", text)
        return None

    async def crawl(self) -> int:
        """Run the cinema crawler across all configured venues."""
        logger.info(
            "Cinema crawler starting with %d venues", len(self.venues)
        )
        processed = 0

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                for venue in self.venues:
                    raw_movies = await self._scrape_venue(client, venue)
                    logger.info(
                        "Cinema crawler: %d movies found at %s",
                        len(raw_movies), venue["name"],
                    )

                    for raw in raw_movies:
                        try:
                            data = await self.parse(raw)
                            if data:
                                await self._upsert_event(data)
                                processed += 1
                        except Exception:
                            logger.exception(
                                "Cinema crawler: error processing movie "
                                "from %s",
                                venue["name"],
                            )

            await self.db.commit()
            logger.info(
                "Cinema crawler completed: %d movies processed", processed
            )

        except Exception:
            logger.exception("Cinema crawler unexpected error")

        return processed
