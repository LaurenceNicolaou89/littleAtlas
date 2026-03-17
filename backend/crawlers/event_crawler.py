"""CR-005: Event crawler framework for scraping Cyprus event sources."""

from __future__ import annotations

import datetime
import hashlib
import json
import logging
from pathlib import Path
from typing import Any

import httpx
from bs4 import BeautifulSoup
from geoalchemy2.elements import WKTElement
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from crawlers.base import BaseCrawler
from models.event import Event

logger = logging.getLogger(__name__)

# Known Cyprus venues / cities with approximate coordinates for geocoding
VENUE_GEOCODE_TABLE: dict[str, tuple[float, float]] = {
    # Cities
    "nicosia": (35.1856, 33.3823),
    "lefkosia": (35.1856, 33.3823),
    "limassol": (34.6786, 33.0413),
    "lemesos": (34.6786, 33.0413),
    "larnaca": (34.9003, 33.6232),
    "larnaka": (34.9003, 33.6232),
    "paphos": (34.7754, 32.4218),
    "pafos": (34.7754, 32.4218),
    "famagusta": (35.1174, 33.9391),
    "ammochostos": (35.1174, 33.9391),
    "ayia napa": (34.9826, 33.9988),
    "agia napa": (34.9826, 33.9988),
    "protaras": (35.0123, 34.0579),
    "paralimni": (35.0393, 33.9822),
    "kyrenia": (35.3408, 33.3197),
    "troodos": (34.9275, 32.8756),
    # Well-known venues
    "municipal theatre nicosia": (35.1725, 33.3617),
    "rialto theatre": (34.6786, 33.0413),
    "pattichion theatre": (34.6786, 33.0413),
    "thalassa museum": (34.9826, 33.9988),
    "cyprus museum": (35.1725, 33.3617),
    "kourion amphitheatre": (34.6650, 32.8867),
    "fasouri watermania": (34.6500, 33.0000),
}


def _generate_source_id(title: str, date: str, venue: str) -> str:
    """Generate a deterministic source_id from title + date + venue."""
    raw = f"{title}|{date}|{venue}".lower().strip()
    return hashlib.sha256(raw.encode()).hexdigest()[:32]


def _geocode_venue(venue: str) -> tuple[float, float] | None:
    """Try to geocode a venue name using the lookup table."""
    if not venue:
        return None
    venue_lower = venue.lower().strip()
    # Exact match
    if venue_lower in VENUE_GEOCODE_TABLE:
        return VENUE_GEOCODE_TABLE[venue_lower]
    # Partial match: check if any known venue/city is a substring
    for key, coords in VENUE_GEOCODE_TABLE.items():
        if key in venue_lower or venue_lower in key:
            return coords
    return None


# ---------- Source configuration schema ----------

# Each source config describes how to scrape one event listing page.
# Fields:
#   name:            Human-readable name
#   url:             URL to fetch
#   type:            "html" or "json"
#   selectors:       (for HTML) CSS selectors mapping to event fields
#   json_paths:      (for JSON) JSON key paths mapping to event fields
#   date_format:     strptime format string for parsing dates

SAMPLE_SOURCE_CONFIG: list[dict[str, Any]] = [
    {
        "name": "Cyprus Events Sample (HTML)",
        "url": "https://www.visitcyprus.com/index.php/en/events",
        "type": "html",
        "selectors": {
            "event_list": "div.event-item",
            "title": "h3.event-title",
            "date": "span.event-date",
            "venue": "span.event-venue",
            "description": "p.event-description",
            "link": "a.event-link",
        },
        "date_format": "%d/%m/%Y",
        "enabled": False,  # Disabled by default — enable when selectors are verified
    },
    {
        "name": "Cyprus Events Sample (JSON API)",
        "url": "https://example.com/api/events",
        "type": "json",
        "json_paths": {
            "event_list": "data.events",
            "title": "title",
            "date": "start_date",
            "venue": "venue.name",
            "description": "description",
            "link": "url",
        },
        "date_format": "%Y-%m-%dT%H:%M:%S",
        "enabled": False,
    },
]

# Path for external JSON config override
CONFIG_FILE = Path(__file__).parent / "event_sources.json"


def _load_sources() -> list[dict[str, Any]]:
    """Load event source configurations."""
    if CONFIG_FILE.exists():
        try:
            with open(CONFIG_FILE) as f:
                sources = json.load(f)
                logger.info("Loaded %d event sources from %s", len(sources), CONFIG_FILE)
                return sources
        except Exception:
            logger.exception("Failed to load event sources config from %s", CONFIG_FILE)
    return SAMPLE_SOURCE_CONFIG


def _resolve_json_path(data: Any, path: str) -> Any:
    """Resolve a dotted path like 'data.events' from a nested dict."""
    parts = path.split(".")
    current = data
    for part in parts:
        if isinstance(current, dict):
            current = current.get(part)
        elif isinstance(current, list) and part.isdigit():
            current = current[int(part)]
        else:
            return None
        if current is None:
            return None
    return current


class EventCrawler(BaseCrawler):
    """Crawls configurable event sources and upserts into the events table."""

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)
        self.sources = _load_sources()

    async def parse(self, raw_data: dict) -> dict | None:
        """Parse a raw event dict into our Event schema dict."""
        title = (raw_data.get("title") or "").strip()
        if not title:
            return None

        date_str = raw_data.get("date", "")
        date_format = raw_data.get("_date_format", "%Y-%m-%d")
        start_date = None
        if date_str:
            try:
                start_date = datetime.datetime.strptime(date_str.strip(), date_format)
                start_date = start_date.replace(tzinfo=datetime.timezone.utc)
            except (ValueError, TypeError):
                logger.debug("Could not parse date '%s' with format '%s'", date_str, date_format)
                return None

        if not start_date:
            return None

        venue = (raw_data.get("venue") or "").strip()
        description = (raw_data.get("description") or "").strip()
        link = (raw_data.get("link") or "").strip()

        source_id = _generate_source_id(title, date_str, venue)
        coords = _geocode_venue(venue)

        return {
            "title_en": title,
            "description_en": description[:2000] if description else "",
            "venue_name": venue,
            "start_date": start_date,
            "location": coords,
            "source_url": link,
            "source": "web",
            "source_id": source_id,
        }

    async def _scrape_html_source(
        self, client: httpx.AsyncClient, source: dict
    ) -> list[dict]:
        """Scrape an HTML event listing page."""
        events_raw: list[dict] = []
        selectors = source.get("selectors", {})
        date_format = source.get("date_format", "%Y-%m-%d")

        try:
            resp = await client.get(source["url"], follow_redirects=True)
            resp.raise_for_status()
        except httpx.HTTPError as exc:
            logger.error("Failed to fetch %s: %s", source["url"], exc)
            return []

        soup = BeautifulSoup(resp.text, "lxml")
        event_items = soup.select(selectors.get("event_list", "div.event"))

        for item in event_items:
            try:
                title_el = item.select_one(selectors.get("title", "h3"))
                date_el = item.select_one(selectors.get("date", "span.date"))
                venue_el = item.select_one(selectors.get("venue", "span.venue"))
                desc_el = item.select_one(selectors.get("description", "p"))
                link_el = item.select_one(selectors.get("link", "a"))

                events_raw.append({
                    "title": title_el.get_text(strip=True) if title_el else "",
                    "date": date_el.get_text(strip=True) if date_el else "",
                    "venue": venue_el.get_text(strip=True) if venue_el else "",
                    "description": desc_el.get_text(strip=True) if desc_el else "",
                    "link": link_el.get("href", "") if link_el else "",
                    "_date_format": date_format,
                })
            except Exception:
                logger.exception("Error parsing event item from %s", source["name"])

        return events_raw

    async def _scrape_json_source(
        self, client: httpx.AsyncClient, source: dict
    ) -> list[dict]:
        """Fetch a JSON event API."""
        events_raw: list[dict] = []
        json_paths = source.get("json_paths", {})
        date_format = source.get("date_format", "%Y-%m-%dT%H:%M:%S")

        try:
            resp = await client.get(source["url"], follow_redirects=True)
            resp.raise_for_status()
            data = resp.json()
        except httpx.HTTPError as exc:
            logger.error("Failed to fetch %s: %s", source["url"], exc)
            return []
        except ValueError:
            logger.error("Invalid JSON from %s", source["url"])
            return []

        event_list = _resolve_json_path(data, json_paths.get("event_list", "events"))
        if not isinstance(event_list, list):
            return []

        for item in event_list:
            try:
                events_raw.append({
                    "title": _resolve_json_path(item, json_paths.get("title", "title")) or "",
                    "date": _resolve_json_path(item, json_paths.get("date", "date")) or "",
                    "venue": _resolve_json_path(item, json_paths.get("venue", "venue")) or "",
                    "description": _resolve_json_path(item, json_paths.get("description", "description")) or "",
                    "link": _resolve_json_path(item, json_paths.get("link", "url")) or "",
                    "_date_format": date_format,
                })
            except Exception:
                logger.exception("Error parsing event from JSON source %s", source["name"])

        return events_raw

    async def _upsert_event(self, data: dict) -> None:
        """Insert or update an event."""
        # Look up by source + source_id (stored in source_url as secondary identifier)
        result = await self.db.execute(
            select(Event).where(
                Event.source == "web",
                Event.source_url == data.get("source_url", ""),
                Event.title_en == data["title_en"],
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
            if location:
                existing.location = location
        else:
            event = Event(
                title_en=data["title_en"],
                description_en=data["description_en"],
                venue_name=data["venue_name"],
                start_date=data["start_date"],
                location=location,
                source_url=data.get("source_url", ""),
                source="web",
            )
            self.db.add(event)

    async def _cleanup_old_events(self) -> int:
        """Delete events older than 90 days."""
        cutoff = datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=90)
        result = await self.db.execute(
            delete(Event).where(Event.start_date < cutoff)
        )
        deleted = result.rowcount
        if deleted:
            logger.info("Cleaned up %d past events older than 90 days", deleted)
        return deleted

    async def crawl(self) -> int:
        """Run the event crawler across all configured sources."""
        logger.info("Event crawler starting with %d sources", len(self.sources))
        processed = 0

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                for source in self.sources:
                    if not source.get("enabled", True):
                        logger.debug("Skipping disabled source: %s", source.get("name"))
                        continue

                    source_type = source.get("type", "html")
                    source_name = source.get("name", source.get("url", "unknown"))
                    logger.info("Scraping event source: %s (%s)", source_name, source_type)

                    if source_type == "html":
                        raw_events = await self._scrape_html_source(client, source)
                    elif source_type == "json":
                        raw_events = await self._scrape_json_source(client, source)
                    else:
                        logger.warning("Unknown source type '%s' for %s", source_type, source_name)
                        continue

                    logger.info("Found %d raw events from %s", len(raw_events), source_name)

                    for raw in raw_events:
                        try:
                            data = await self.parse(raw)
                            if data:
                                await self._upsert_event(data)
                                processed += 1
                        except Exception:
                            logger.exception("Error processing event from %s", source_name)

            # Clean up old events
            await self._cleanup_old_events()

            await self.db.commit()
            logger.info("Event crawler completed: %d events processed", processed)

        except Exception:
            logger.exception("Event crawler unexpected error")

        return processed
