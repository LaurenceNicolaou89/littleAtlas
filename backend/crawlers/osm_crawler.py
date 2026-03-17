"""CR-002: OpenStreetMap crawler for family-friendly places in Cyprus."""

from __future__ import annotations

import logging
import re
from typing import Any

import httpx
from geoalchemy2.elements import WKTElement
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from crawlers.base import BaseCrawler
from models.category import Category
from models.place import Place

logger = logging.getLogger(__name__)

# Cyprus bounding box
CYPRUS_BBOX = {"south": 34.5, "north": 35.7, "west": 32.2, "east": 34.6}

OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Mapping of OSM tag combos to our category slugs
OSM_TAG_TO_CATEGORY: dict[str, str] = {
    "leisure=playground": "playgrounds",
    "leisure=park": "parks",
    "tourism=museum": "museums",
    "tourism=zoo": "zoos",
    "tourism=aquarium": "aquariums",
    "amenity=library": "libraries",
    "sport=swimming": "swimming-pools",
    "leisure=water_park": "water-parks",
}

# The Overpass query filters
OSM_FILTERS = [
    '["leisure"="playground"]',
    '["leisure"="park"]',
    '["tourism"="museum"]',
    '["tourism"="zoo"]',
    '["tourism"="aquarium"]',
    '["amenity"="library"]',
    '["sport"="swimming"]',
    '["leisure"="water_park"]',
]


def _build_overpass_query() -> str:
    """Build an Overpass QL query for all family-friendly node types in Cyprus."""
    bbox = f"{CYPRUS_BBOX['south']},{CYPRUS_BBOX['west']},{CYPRUS_BBOX['north']},{CYPRUS_BBOX['east']}"
    parts = []
    for filt in OSM_FILTERS:
        parts.append(f"  node{filt}({bbox});")
        parts.append(f"  way{filt}({bbox});")
    query = "[out:json][timeout:120];\n(\n" + "\n".join(parts) + "\n);\nout center tags;"
    return query


def _extract_name(tags: dict[str, str]) -> tuple[str, str, str]:
    """Extract English, Greek, and Russian names from OSM tags."""
    name_en = tags.get("name:en", "")
    name_el = tags.get("name:el", "")
    name_ru = tags.get("name:ru", "")
    fallback = tags.get("name", "")

    if not name_en:
        name_en = fallback
    if not name_el:
        name_el = fallback if fallback != name_en else ""
    if not name_ru:
        name_ru = ""

    return name_en, name_el, name_ru


def _determine_category_slug(tags: dict[str, str]) -> str | None:
    """Map OSM tags to our category slug."""
    for tag_combo, slug in OSM_TAG_TO_CATEGORY.items():
        key, value = tag_combo.split("=")
        if tags.get(key) == value:
            return slug
    return None


def _extract_amenities(tags: dict[str, str]) -> list[str]:
    """Map OSM amenity tags to our amenity list."""
    amenities: list[str] = []
    if tags.get("wheelchair") == "yes":
        amenities.append("wheelchair_access")
    if tags.get("diaper") == "yes" or tags.get("changing_table") == "yes":
        amenities.append("changing_table")
    if tags.get("toilets") == "yes":
        amenities.append("toilets")
    if tags.get("drinking_water") == "yes":
        amenities.append("drinking_water")
    if tags.get("fee") == "no":
        amenities.append("free_entry")
    if tags.get("covered") == "yes":
        amenities.append("covered")
    if tags.get("lit") == "yes":
        amenities.append("lit")
    return amenities


def _is_indoor(tags: dict[str, str]) -> bool:
    """Determine if the place is indoor based on tags."""
    if tags.get("indoor") == "yes":
        return True
    if tags.get("building") and tags.get("building") != "no":
        return True
    indoor_types = {"museum", "library", "aquarium"}
    for key in ("tourism", "amenity"):
        if tags.get(key) in indoor_types:
            return True
    return False


class OSMCrawler(BaseCrawler):
    """Crawls OpenStreetMap via Overpass API for family-friendly places in Cyprus."""

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)
        self._category_cache: dict[str, int] = {}

    async def _get_category_id(self, slug: str) -> int | None:
        """Look up category ID by slug, with caching."""
        if slug in self._category_cache:
            return self._category_cache[slug]
        result = await self.db.execute(select(Category).where(Category.slug == slug))
        cat = result.scalar_one_or_none()
        if cat:
            self._category_cache[slug] = cat.id
            return cat.id
        return None

    async def parse(self, raw_data: dict) -> dict | None:
        """Parse a single OSM element into our Place schema dict."""
        tags = raw_data.get("tags", {})
        name_en, name_el, name_ru = _extract_name(tags)
        if not name_en:
            return None

        # Get coordinates: for ways with center, use center coords
        lat = raw_data.get("lat") or raw_data.get("center", {}).get("lat")
        lon = raw_data.get("lon") or raw_data.get("center", {}).get("lon")
        if lat is None or lon is None:
            return None

        category_slug = _determine_category_slug(tags)
        category_id = await self._get_category_id(category_slug) if category_slug else None

        amenities = _extract_amenities(tags)
        indoor = _is_indoor(tags)

        address_parts = []
        for key in ("addr:street", "addr:housenumber", "addr:city"):
            val = tags.get(key)
            if val:
                address_parts.append(val)
        address = ", ".join(address_parts)

        return {
            "name_en": name_en,
            "name_el": name_el,
            "name_ru": name_ru,
            "lat": lat,
            "lon": lon,
            "category_id": category_id,
            "amenities": amenities,
            "is_indoor": indoor,
            "address": address,
            "website": tags.get("website", ""),
            "phone": tags.get("phone", tags.get("contact:phone", "")),
            "source": "osm",
            "source_id": str(raw_data["id"]),
        }

    async def _upsert_place(self, data: dict[str, Any]) -> None:
        """Insert or update a place based on source + source_id."""
        result = await self.db.execute(
            select(Place).where(Place.source == "osm", Place.source_id == data["source_id"])
        )
        existing = result.scalar_one_or_none()

        location = WKTElement(f"POINT({data['lon']} {data['lat']})", srid=4326)

        if existing:
            existing.name_en = data["name_en"]
            existing.name_el = data["name_el"]
            existing.name_ru = data["name_ru"]
            existing.location = location
            existing.address = data["address"]
            existing.phone = data["phone"]
            existing.website = data["website"]
            existing.is_indoor = data["is_indoor"]
            existing.amenities = data["amenities"]
            if data["category_id"]:
                existing.category_id = data["category_id"]
        else:
            place = Place(
                name_en=data["name_en"],
                name_el=data["name_el"],
                name_ru=data["name_ru"],
                location=location,
                address=data["address"],
                phone=data["phone"],
                website=data["website"],
                is_indoor=data["is_indoor"],
                amenities=data["amenities"],
                category_id=data["category_id"],
                source="osm",
                source_id=data["source_id"],
            )
            self.db.add(place)

    async def crawl(self) -> int:
        """Run the OSM crawler and return count of items processed."""
        logger.info("OSM crawler starting")
        query = _build_overpass_query()
        processed = 0

        try:
            async with httpx.AsyncClient(timeout=180) as client:
                logger.info("Sending Overpass API query")
                resp = await client.post(OVERPASS_URL, data={"data": query})
                resp.raise_for_status()
                raw = resp.json()

            elements = raw.get("elements", [])
            logger.info("OSM crawler received %d elements", len(elements))

            for element in elements:
                try:
                    data = await self.parse(element)
                    if data:
                        await self._upsert_place(data)
                        processed += 1
                except Exception:
                    logger.exception("Error processing OSM element %s", element.get("id"))
                    continue

            await self.db.commit()
            logger.info("OSM crawler completed: %d places processed", processed)

        except httpx.HTTPStatusError as exc:
            logger.error("Overpass API HTTP error: %s", exc.response.status_code)
        except httpx.RequestError as exc:
            logger.error("Overpass API request error: %s", exc)
        except Exception:
            logger.exception("OSM crawler unexpected error")

        return processed
