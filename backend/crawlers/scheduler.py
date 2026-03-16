from apscheduler.schedulers.asyncio import AsyncIOScheduler

scheduler = AsyncIOScheduler()


def start_scheduler() -> None:
    """Start the APScheduler instance. Add jobs here as crawlers are implemented."""
    # Example (uncomment when crawlers are ready):
    # scheduler.add_job(some_crawler_job, "interval", hours=6, id="some_crawler")
    scheduler.start()


def stop_scheduler() -> None:
    """Shut down the scheduler gracefully."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
