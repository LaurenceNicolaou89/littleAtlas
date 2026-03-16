from __future__ import annotations

import abc

from sqlalchemy.ext.asyncio import AsyncSession


class BaseCrawler(abc.ABC):
    """Abstract base class for all data crawlers."""

    def __init__(self, db: AsyncSession) -> None:
        self.db = db

    @abc.abstractmethod
    async def crawl(self) -> int:
        """Run the crawler and return the number of items processed."""
        ...

    @abc.abstractmethod
    async def parse(self, raw_data: dict) -> dict:
        """Parse raw API/HTML data into a normalised dictionary."""
        ...
