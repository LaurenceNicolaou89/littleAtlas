"""CR-004: Entity resolution / deduplication for places from multiple sources."""

from __future__ import annotations

import logging
import re
import unicodedata

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from models.place import Place

logger = logging.getLogger(__name__)

# Articles to strip during name normalization (English, Greek)
ARTICLES = {"the", "a", "an", "o", "ο", "η", "το", "ένα", "μια"}

# Merge priority: higher index wins.  "manual" always wins where applicable.
SOURCE_PRIORITY = {"osm": 0, "google": 1, "manual": 2}


def normalize_name(name: str) -> str:
    """Normalize a place name for comparison.

    Steps: lowercase, strip accents, remove articles, remove punctuation,
    collapse whitespace.
    """
    if not name:
        return ""
    # Lowercase
    name = name.lower()
    # Strip accents / diacritics
    nfkd = unicodedata.normalize("NFKD", name)
    name = "".join(c for c in nfkd if not unicodedata.combining(c))
    # Remove punctuation
    name = re.sub(r"[^\w\s]", "", name)
    # Remove articles
    tokens = name.split()
    tokens = [t for t in tokens if t not in ARTICLES]
    return " ".join(tokens).strip()


def _source_rank(source: str) -> int:
    return SOURCE_PRIORITY.get(source, -1)


def _pick_winner(place_a: Place, place_b: Place) -> tuple[Place, Place]:
    """Return (winner, loser) based on source priority.

    Google > Manual > OSM for the primary record.  Manual sources are
    preserved when they exist (manual always wins for category/amenities).
    """
    rank_a = _source_rank(place_a.source)
    rank_b = _source_rank(place_b.source)
    if rank_a >= rank_b:
        return place_a, place_b
    return place_b, place_a


def _merge_fields(winner: Place, loser: Place) -> None:
    """Apply merge strategy per business-logic.md.

    Name:          Google > Manual > OSM
    Location:      Google > OSM
    Opening hours: Google
    Photos:        Google > Manual
    Amenities:     OSM > Manual > Google
    Category:      Manual > Google > OSM
    """
    w_rank = _source_rank(winner.source)
    l_rank = _source_rank(loser.source)

    # --- Name ---
    # Prefer Google, then Manual, then OSM
    name_priority = {"google": 2, "manual": 1, "osm": 0}
    if name_priority.get(loser.source, -1) > name_priority.get(winner.source, -1):
        if loser.name_en:
            winner.name_en = loser.name_en
    # Always fill in missing translations
    if not winner.name_el and loser.name_el:
        winner.name_el = loser.name_el
    if not winner.name_ru and loser.name_ru:
        winner.name_ru = loser.name_ru

    # --- Location --- Google > OSM (winner already has better or equal)
    loc_priority = {"google": 2, "osm": 1, "manual": 0}
    if loc_priority.get(loser.source, -1) > loc_priority.get(winner.source, -1):
        if loser.location is not None:
            winner.location = loser.location

    # --- Opening hours --- Google wins
    if loser.source == "google" and loser.opening_hours:
        winner.opening_hours = loser.opening_hours
    elif not winner.opening_hours and loser.opening_hours:
        winner.opening_hours = loser.opening_hours

    # --- Photos --- Google > Manual
    photo_priority = {"google": 2, "manual": 1, "osm": 0}
    if photo_priority.get(loser.source, -1) > photo_priority.get(winner.source, -1):
        loser_photos = loser.photos or []
        if loser_photos:
            winner.photos = loser_photos
    elif not (winner.photos or []):
        winner.photos = loser.photos or []

    # --- Amenities --- OSM > Manual > Google
    amenity_priority = {"osm": 2, "manual": 1, "google": 0}
    if amenity_priority.get(loser.source, -1) > amenity_priority.get(winner.source, -1):
        loser_amenities = loser.amenities or []
        if loser_amenities:
            winner.amenities = loser_amenities
    else:
        # Merge unique amenities
        winner_set = set(winner.amenities or [])
        loser_set = set(loser.amenities or [])
        combined = list(winner_set | loser_set)
        if combined:
            winner.amenities = combined

    # --- Category --- Manual > Google > OSM
    cat_priority = {"manual": 2, "google": 1, "osm": 0}
    if loser.category_id and not winner.category_id:
        winner.category_id = loser.category_id
    elif (
        loser.category_id
        and cat_priority.get(loser.source, -1) > cat_priority.get(winner.source, -1)
    ):
        winner.category_id = loser.category_id

    # Fill other missing fields
    if not winner.address and loser.address:
        winner.address = loser.address
    if not winner.phone and loser.phone:
        winner.phone = loser.phone
    if not winner.website and loser.website:
        winner.website = loser.website
    if not winner.description_en and loser.description_en:
        winner.description_en = loser.description_en
    if not winner.description_el and loser.description_el:
        winner.description_el = loser.description_el
    if not winner.description_ru and loser.description_ru:
        winner.description_ru = loser.description_ru


class EntityResolver:
    """Resolves duplicate places from different data sources."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    async def resolve(self) -> int:
        """Run deduplication and return the number of merges performed.

        Steps:
        1. Same source + source_id -> already handled by upsert in crawlers.
        2. Cross-source: find places within 100m with similar normalised names.
        """
        logger.info("Entity resolver starting")
        merged_count = 0

        try:
            merged_count = await self._cross_source_merge()
            await self.db.commit()
            logger.info("Entity resolver completed: %d merges", merged_count)
        except Exception:
            logger.exception("Entity resolver error")
            await self.db.rollback()

        return merged_count

    async def _cross_source_merge(self) -> int:
        """Find and merge cross-source duplicates within 100m with similar names."""
        merged_count = 0

        # TODO: This loads all places into memory. For Cyprus-only scope this is
        # acceptable, but if the dataset grows significantly this should be
        # refactored to use batched/streaming reads.
        result = await self.db.execute(
            select(Place).where(Place.source.in_(["osm", "google", "manual"]))
        )
        all_places = list(result.scalars().all())

        if not all_places:
            return 0

        # Build index of normalized names to places
        name_groups: dict[str, list[Place]] = {}
        for place in all_places:
            norm = normalize_name(place.name_en)
            if norm:
                name_groups.setdefault(norm, []).append(place)

        # For groups with the same normalized name and multiple sources,
        # check spatial proximity using ST_DWithin
        for norm_name, places in name_groups.items():
            if len(places) < 2:
                continue

            # Group by source — only merge across different sources
            sources = {p.source for p in places}
            if len(sources) < 2:
                continue

            # Check all pairs for proximity
            merged_ids: set[int] = set()
            for i, pa in enumerate(places):
                if pa.id in merged_ids:
                    continue
                for pb in places[i + 1 :]:
                    if pb.id in merged_ids:
                        continue
                    if pa.source == pb.source:
                        continue

                    # Check if within 100 meters using PostGIS
                    proximity_query = select(
                        func.ST_DWithin(
                            Place.location,
                            select(Place.location)
                            .where(Place.id == pb.id)
                            .correlate(None)
                            .scalar_subquery(),
                            100,  # 100 meters (geography type uses meters)
                        )
                    ).where(Place.id == pa.id)

                    prox_result = await self.db.execute(proximity_query)
                    is_near = prox_result.scalar()

                    if is_near:
                        winner, loser = _pick_winner(pa, pb)
                        logger.info(
                            "Merging place '%s' (source=%s, id=%d) into '%s' (source=%s, id=%d)",
                            loser.name_en,
                            loser.source,
                            loser.id,
                            winner.name_en,
                            winner.source,
                            winner.id,
                        )
                        _merge_fields(winner, loser)
                        # Mark loser as merged by pointing source_id to winner
                        loser.source_id = f"merged:{winner.id}"
                        loser.source = f"merged_{loser.source}"
                        merged_ids.add(loser.id)
                        merged_count += 1

        return merged_count
