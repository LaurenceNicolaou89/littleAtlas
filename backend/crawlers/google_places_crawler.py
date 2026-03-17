"""CR-003: Google Places crawler for family-friendly places in Cyprus."""

from __future__ import annotations

import asyncio
import logging
from typing import Any

import httpx
from sqlalchemy.ext.asyncio import AsyncSession

from config import settings
from crawlers.base import BaseCrawler
from crawlers.constants import CYPRUS_CITIES
from crawlers.utils import get_category_id, upsert_place

logger = logging.getLogger(__name__)

NEARBY_SEARCH_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
PLACE_DETAILS_URL = "https://maps.googleapis.com/maps/api/place/details/json"
PHOTO_URL_TEMPLATE = (
    "https://maps.googleapis.com/maps/api/place/photo"
    "?maxwidth=800&photo_reference={ref}&key={key}"
)

# Google Place types to search
SEARCH_TYPES = [
    "restaurant",
    "amusement_park",
    "bowling_alley",
    "movie_theater",
    "park",
    "playground",
]

# Map Google Place types to our category slugs
GOOGLE_TYPE_TO_CATEGORY: dict[str, str] = {
    "amusement_park": "amusement-parks",
    "bowling_alley": "bowling",
    "movie_theater": "cinemas",
    "park": "parks",
    "playground": "playgrounds",
    "restaurant": "restaurants",
    "zoo": "zoos",
    "aquarium": "aquariums",
    "museum": "museums",
    "library": "libraries",
}

# Delay between API requests to respect quota (seconds)
REQUEST_DELAY = 0.3


class GooglePlacesCrawler(BaseCrawler):
    """Crawls Google Places API for family-friendly venues in Cyprus."""

    def __init__(self, db: AsyncSession) -> None:
        super().__init__(db)
        self._category_cache: dict[str, int] = {}
        self._api_key = settings.GOOGLE_PLACES_API_KEY

    def _map_types_to_category(self, types: list[str]) -> str | None:
        """Find the best category slug from Google types list."""
        for t in types:
            if t in GOOGLE_TYPE_TO_CATEGORY:
                return GOOGLE_TYPE_TO_CATEGORY[t]
        return None

    def _extract_photos(self, result: dict) -> list[str]:
        """Extract photo URLs from place result."""
        photos = result.get("photos", [])
        urls = []
        for photo in photos[:5]:
            ref = photo.get("photo_reference")
            if ref:
                urls.append(
                    PHOTO_URL_TEMPLATE.format(ref=ref, key=self._api_key)
                )
        return urls

    async def parse(self, raw_data: dict) -> dict | None:
        """Parse a Google Places result into our schema."""
        name = raw_data.get("name", "")
        if not name:
            return None

        geo = raw_data.get("geometry", {}).get("location", {})
        lat = geo.get("lat")
        lng = geo.get("lng")
        if lat is None or lng is None:
            return None

        types = raw_data.get("types", [])
        category_slug = self._map_types_to_category(types)
        category_id = (
            await get_category_id(self.db, category_slug, self._category_cache)
            if category_slug
            else None
        )

        photos = self._extract_photos(raw_data)

        opening_hours = None
        oh = raw_data.get("opening_hours")
        if oh and "weekday_text" in oh:
            opening_hours = {"weekday_text": oh["weekday_text"]}
        elif oh and "periods" in oh:
            opening_hours = {"periods": oh["periods"]}

        return {
            "name_en": name,
            "name_el": "",
            "name_ru": "",
            "lat": lat,
            "lon": lng,
            "category_id": category_id,
            "address": raw_data.get("vicinity", ""),
            "phone": "",
            "website": "",
            "opening_hours": opening_hours,
            "photos": photos,
            "amenities": [],
            "is_indoor": category_slug in ("cinemas", "bowling", "museums", "libraries", "aquariums"),
            "source": "google",
            "source_id": raw_data.get("place_id", ""),
            "rating": raw_data.get("rating"),
        }

    async def _fetch_place_details(
        self, client: httpx.AsyncClient, place_id: str
    ) -> dict[str, Any]:
        """Fetch detailed info for a single place."""
        params = {
            "place_id": place_id,
            "fields": "formatted_phone_number,website,reviews,opening_hours",
            "key": self._api_key,
        }
        resp = await client.get(PLACE_DETAILS_URL, params=params)
        resp.raise_for_status()
        return resp.json().get("result", {})

    async def _search_nearby(
        self, client: httpx.AsyncClient, city: dict, place_type: str
    ) -> list[dict]:
        """Run a Nearby Search for a given city and type."""
        params = {
            "location": f"{city['lat']},{city['lon']}",
            "radius": 15000,
            "type": place_type,
            "key": self._api_key,
        }
        results: list[dict] = []
        try:
            resp = await client.get(NEARBY_SEARCH_URL, params=params)
            resp.raise_for_status()
            body = resp.json()
            results.extend(body.get("results", []))

            # Follow up to one next_page_token
            next_token = body.get("next_page_token")
            if next_token:
                # Google requires a short delay before using next_page_token
                await asyncio.sleep(2.0)
                params_next = {"pagetoken": next_token, "key": self._api_key}
                resp2 = await client.get(NEARBY_SEARCH_URL, params=params_next)
                resp2.raise_for_status()
                results.extend(resp2.json().get("results", []))

        except httpx.HTTPStatusError as exc:
            logger.error(
                "Google Places HTTP error for %s/%s: %s",
                city["name"],
                place_type,
                exc.response.status_code,
            )
        except httpx.RequestError as exc:
            logger.error(
                "Google Places request error for %s/%s: %s",
                city["name"],
                place_type,
                exc,
            )
        return results

    async def crawl(self) -> int:
        """Run the Google Places crawler."""
        if not self._api_key:
            logger.warning("GOOGLE_PLACES_API_KEY not set — skipping Google Places crawler")
            return 0

        logger.info("Google Places crawler starting")
        processed = 0
        seen_place_ids: set[str] = set()

        try:
            async with httpx.AsyncClient(timeout=30) as client:
                for city in CYPRUS_CITIES:
                    for place_type in SEARCH_TYPES:
                        logger.info(
                            "Searching %s in %s", place_type, city["name"]
                        )
                        results = await self._search_nearby(client, city, place_type)
                        await asyncio.sleep(REQUEST_DELAY)

                        for raw in results:
                            place_id = raw.get("place_id")
                            if not place_id or place_id in seen_place_ids:
                                continue
                            seen_place_ids.add(place_id)

                            try:
                                data = await self.parse(raw)
                                if not data:
                                    continue

                                # Fetch details for top-rated places
                                rating = raw.get("rating", 0)
                                if rating and rating >= 4.0:
                                    try:
                                        details = await self._fetch_place_details(
                                            client, place_id
                                        )
                                        if details.get("formatted_phone_number"):
                                            data["phone"] = details["formatted_phone_number"]
                                        if details.get("website"):
                                            data["website"] = details["website"]
                                        if details.get("opening_hours", {}).get("weekday_text"):
                                            data["opening_hours"] = {
                                                "weekday_text": details["opening_hours"]["weekday_text"]
                                            }
                                        await asyncio.sleep(REQUEST_DELAY)
                                    except Exception:
                                        logger.exception(
                                            "Error fetching details for %s", place_id
                                        )

                                await upsert_place(self.db, data, source="google")
                                processed += 1
                            except Exception:
                                logger.exception(
                                    "Error processing Google place %s", place_id
                                )

                await self.db.commit()
                logger.info(
                    "Google Places crawler completed: %d places processed", processed
                )

        except Exception:
            logger.exception("Google Places crawler unexpected error")

        return processed
