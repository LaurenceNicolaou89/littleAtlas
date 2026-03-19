"""Theatre crawler for major Cyprus theatre venues."""

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

# Major Cyprus theatre venues with coordinates and programme URLs
THEATRE_VENUES: list[dict[str, Any]] = [
    {
        "name": "Rialto Theatre",
        "city": "Limassol",
        "lat": 34.6749,
        "lon": 33.0440,
        "url": "https://www.rialto.com.cy/en/programme",
        "selectors": {
            "event_list": (
                "div.event-item, div.performance-item, "
                "article.event, div.show-item"
            ),
            "title": "h2, h3, .event-title, .show-title",
            "date": ".event-date, .show-date, time, .date",
            "description": "p, .event-description, .show-description",
            "link": "a",
        },
        "date_format": "%d/%m/%Y",
    },
    {
        "name": "Pattichion Theatre",
        "city": "Limassol",
        "lat": 34.6786,
        "lon": 33.0413,
        "url": "https://www.pattihio.com.cy/en/programme",
        "selectors": {
            "event_list": (
                "div.event-item, div.performance-item, "
                "article.event, div.show-item"
            ),
            "title": "h2, h3, .event-title, .show-title",
            "date": ".event-date, .show-date, time, .date",
            "description": "p, .event-description, .show-description",
            "link": "a",
        },
        "date_format": "%d/%m/%Y",
    },
    {
        "name": "Municipal Theatre Nicosia",
        "city": "Nicosia",
        "lat": 35.1725,
        "lon": 33.3617,
        "url": "https://www.nicosia.org.cy/en-GB/discover/events/",
        "selectors": {
            "event_list": (
                "div.event-item, div.performance-item, "
                "article.event, div.show-item"
            ),
            "title": "h2, h3, .event-title, .show-title",
            "date": ".event-date, .show-date, time, .date",
            "description": "p, .event-description, .show-description",
            "link": "a",
        },
        "date_format": "%d/%m/%Y",
    },
    {
        "name": "Markideion Theatre",
        "city": "Paphos",
        "lat": 34.7570,
        "lon": 32.4220,
        "url": "https://www.markideion.com/en/programme",
        "selectors": {
            "event_list": (
                "div.event-item, div.performance-item, "
                "article.event, div.show-item"
            ),
            "title": "h2, h3, .event-title, .show-title",
            "date": ".event-date, .show-date, time, .date",
            "description": "p, .event-description, .show-description",
            "link": "a",
        },
        "date_format": "%d/%m/%Y",
    },
    {
        "name": "Satiriko Theatre",
        "city": "Nicosia",
        "lat": 35.1700,
        "lon": 33.3650,
        "url": "https://www.satiriko.com/en/programme",
        "selectors": {
            "event_list": (
                "div.event-item, div.performance-item, "
                "article.event, div.show-item"
            ),
            "title": "h2, h3, .event-title, .show-title",
            "date": ".event-date, .show-date, time, .date",
            "description": "p, .event-description, .show-description",
            "link": "a",
        },
        "date_format": "%d/%m/%Y",
    },
]


def _generate_source_id(title: str, date: str, venue: str) -> str:
    """Generate a deterministic source_id from title + date + venue."""
    raw = f"{title}|{date}|{venue}".lower().strip()
    return hashlib.sha256(raw.encode()).hexdigest()[:32]


class TheatreCrawler(BaseCrawler):
    """Crawls Cyprus theatre venue websites for show listings."""

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)
        self.venues = THEATRE_VENUES

    async def parse(self, raw_data: dict) -> dict | None:
        """Parse a raw show dict into our Event schema dict."""
        title = (raw_data.get("title") or "").strip()
        if not title:
            return None

        venue_name = raw_data.get("venue_name", "")
        start_date = raw_data.get("start_date")
        if not start_date:
            return None

        description = (raw_data.get("description") or "").strip()
        if description and len(description) > 2000:
            logger.warning(
                "Theatre crawler: description truncated from %d chars",
                len(description),
            )
            description = description[:2000]

        date_str = (
            start_date.isoformat()
            if isinstance(start_date, datetime.datetime)
            else str(start_date)
        )
        source_id = _generate_source_id(title, date_str, venue_name)

        lat = raw_data.get("lat")
        lon = raw_data.get("lon")
        location = (lat, lon) if lat and lon else None

        return {
            "title_en": title,
            "description_en": description,
            "venue_name": venue_name,
            "start_date": start_date,
            "location": location,
            "source_url": raw_data.get("source_url", ""),
            "source": "theatre_crawler",
            "source_id": source_id,
            "event_type": "theatre",
        }

    async def _upsert_event(self, data: dict) -> None:
        """Insert or update a theatre event using source + source_id."""
        source_id = data.get("source_id", "")
        result = await self.db.execute(
            select(Event).where(
                Event.source == data.get("source", "theatre_crawler"),
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
                source="theatre_crawler",
                event_type=data.get("event_type"),
            )
            self.db.add(event)

    async def _scrape_venue(
        self, client: httpx.AsyncClient, venue: dict
    ) -> list[dict]:
        """Scrape show listings from a single theatre venue page."""
        url = venue["url"]
        venue_name = venue["name"]
        selectors = venue.get("selectors", {})
        date_format = venue.get("date_format", "%d/%m/%Y")
        raw_shows: list[dict] = []

        try:
            resp = await client.get(url, follow_redirects=True)
            resp.raise_for_status()
        except httpx.HTTPError as exc:
            logger.warning(
                "Theatre crawler: failed to fetch %s (%s): %s",
                venue_name, url, exc,
            )
            return []

        soup = BeautifulSoup(resp.text, "lxml")
        event_items = soup.select(selectors.get("event_list", "div.event"))

        if not event_items:
            logger.warning(
                "Theatre crawler: no show items found at %s — "
                "site structure may have changed",
                venue_name,
            )
            return []

        for item in event_items:
            try:
                title_el = item.select_one(selectors.get("title", "h3"))
                title = title_el.get_text(strip=True) if title_el else ""
                if not title:
                    continue

                date_el = item.select_one(selectors.get("date", "time"))
                date_text = date_el.get_text(strip=True) if date_el else ""
                start_date = self._parse_date(date_text, date_format)

                desc_el = item.select_one(
                    selectors.get("description", "p")
                )
                description = (
                    desc_el.get_text(strip=True) if desc_el else ""
                )

                link_el = item.select_one(selectors.get("link", "a"))
                link = link_el.get("href", "") if link_el else ""
                if link and not link.startswith("http"):
                    # Make relative URLs absolute
                    from urllib.parse import urljoin
                    link = urljoin(url, link)

                raw_shows.append({
                    "title": title,
                    "venue_name": venue_name,
                    "start_date": start_date,
                    "description": description,
                    "lat": venue["lat"],
                    "lon": venue["lon"],
                    "source_url": link or url,
                })
            except Exception:
                logger.exception(
                    "Theatre crawler: error parsing show item at %s",
                    venue_name,
                )

        return raw_shows

    @staticmethod
    def _parse_date(
        text: str, date_format: str
    ) -> datetime.datetime | None:
        """Try to parse a date string with the given format and fallbacks."""
        text = text.strip()
        if not text:
            return None

        formats = [
            date_format,
            "%d/%m/%Y",
            "%d-%m-%Y",
            "%Y-%m-%d",
            "%d %B %Y",
            "%d %b %Y",
            "%d/%m/%Y %H:%M",
            "%Y-%m-%dT%H:%M:%S",
        ]
        for fmt in formats:
            try:
                parsed = datetime.datetime.strptime(text, fmt)
                return parsed.replace(tzinfo=datetime.timezone.utc)
            except ValueError:
                continue

        logger.debug(
            "Theatre crawler: could not parse date '%s'", text
        )
        return None

    async def crawl(self) -> int:
        """Run the theatre crawler across all configured venues."""
        logger.info(
            "Theatre crawler starting with %d venues",
            len(self.venues),
        )
        processed = 0

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                for venue in self.venues:
                    raw_shows = await self._scrape_venue(client, venue)
                    logger.info(
                        "Theatre crawler: %d shows found at %s",
                        len(raw_shows), venue["name"],
                    )

                    for raw in raw_shows:
                        try:
                            data = await self.parse(raw)
                            if data:
                                await self._upsert_event(data)
                                processed += 1
                        except Exception:
                            logger.exception(
                                "Theatre crawler: error processing show "
                                "from %s",
                                venue["name"],
                            )

            await self.db.commit()
            logger.info(
                "Theatre crawler completed: %d shows processed",
                processed,
            )

        except Exception:
            logger.exception("Theatre crawler unexpected error")

        return processed
