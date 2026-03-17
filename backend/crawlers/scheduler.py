"""CR-001: APScheduler setup and crawler job registration."""

from __future__ import annotations

import logging

import redis.asyncio as aioredis
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from db.database import async_session_factory

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()


# --------------- Job functions ---------------

async def run_osm_crawler() -> None:
    """Scheduled job: run OpenStreetMap crawler."""
    from crawlers.osm_crawler import OSMCrawler
    from crawlers.entity_resolver import EntityResolver

    logger.info("[scheduler] OSM crawler job starting")
    try:
        async with async_session_factory() as session:
            crawler = OSMCrawler(db=session)
            count = await crawler.crawl()
            logger.info("[scheduler] OSM crawler job finished — %d items", count)

            # Run entity resolution after crawl
            resolver = EntityResolver(db=session)
            merges = await resolver.resolve()
            logger.info("[scheduler] Entity resolution after OSM — %d merges", merges)
    except Exception:
        logger.exception("[scheduler] OSM crawler job failed")


async def run_google_places_crawler() -> None:
    """Scheduled job: run Google Places crawler."""
    from crawlers.google_places_crawler import GooglePlacesCrawler
    from crawlers.entity_resolver import EntityResolver

    logger.info("[scheduler] Google Places crawler job starting")
    try:
        async with async_session_factory() as session:
            crawler = GooglePlacesCrawler(db=session)
            count = await crawler.crawl()
            logger.info("[scheduler] Google Places crawler job finished — %d items", count)

            # Run entity resolution after crawl
            resolver = EntityResolver(db=session)
            merges = await resolver.resolve()
            logger.info("[scheduler] Entity resolution after Google — %d merges", merges)
    except Exception:
        logger.exception("[scheduler] Google Places crawler job failed")


async def run_event_crawler() -> None:
    """Scheduled job: run event crawler."""
    from crawlers.event_crawler import EventCrawler

    logger.info("[scheduler] Event crawler job starting")
    try:
        async with async_session_factory() as session:
            crawler = EventCrawler(db=session)
            count = await crawler.crawl()
            logger.info("[scheduler] Event crawler job finished — %d items", count)
    except Exception:
        logger.exception("[scheduler] Event crawler job failed")


async def run_weather_sync(redis: aioredis.Redis) -> None:
    """Scheduled job: sync weather for major Cyprus cities."""
    from crawlers.weather_sync import sync_weather

    logger.info("[scheduler] Weather sync job starting")
    try:
        count = await sync_weather(redis)
        logger.info("[scheduler] Weather sync job finished — %d cities cached", count)
    except Exception:
        logger.exception("[scheduler] Weather sync job failed")


# --------------- Scheduler lifecycle ---------------

def start_scheduler(redis: aioredis.Redis | None = None) -> None:
    """Start the APScheduler instance and register all crawler jobs."""
    # OSM crawler: weekly on Sunday at 3:00 AM
    scheduler.add_job(
        run_osm_crawler,
        "cron",
        day_of_week="sun",
        hour=3,
        minute=0,
        id="osm_crawler",
        replace_existing=True,
        misfire_grace_time=3600,
    )

    # Google Places crawler: weekly on Sunday at 5:00 AM
    scheduler.add_job(
        run_google_places_crawler,
        "cron",
        day_of_week="sun",
        hour=5,
        minute=0,
        id="google_places_crawler",
        replace_existing=True,
        misfire_grace_time=3600,
    )

    # Event crawler: daily at 6:00 AM
    scheduler.add_job(
        run_event_crawler,
        "cron",
        hour=6,
        minute=0,
        id="event_crawler",
        replace_existing=True,
        misfire_grace_time=3600,
    )

    # Weather sync: every 30 minutes
    if redis is not None:
        scheduler.add_job(
            run_weather_sync,
            "interval",
            minutes=30,
            id="weather_sync",
            replace_existing=True,
            args=[redis],
            misfire_grace_time=300,
        )
    else:
        logger.warning("Redis not available — weather sync job not registered")

    scheduler.start()
    logger.info("[scheduler] Started with all crawler jobs registered")


def stop_scheduler() -> None:
    """Shut down the scheduler gracefully."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("[scheduler] Stopped")


# --------------- Manual trigger ---------------

async def trigger_crawler(name: str, redis: aioredis.Redis | None = None) -> str:
    """Manually trigger a crawler by name. Returns a status message."""
    runners = {
        "osm": run_osm_crawler,
        "google": run_google_places_crawler,
        "events": run_event_crawler,
    }

    if name == "weather":
        if redis is None:
            return "Cannot run weather sync: Redis not available"
        await run_weather_sync(redis)
        return "Weather sync completed"

    runner = runners.get(name)
    if runner is None:
        return f"Unknown crawler: {name}. Available: {', '.join(list(runners.keys()) + ['weather'])}"

    await runner()
    return f"{name} crawler completed"
