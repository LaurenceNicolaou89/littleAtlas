from typing import AsyncGenerator

import redis.asyncio as aioredis
from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession

from db.database import async_session_factory


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Yield an async database session, ensuring it is closed after use."""
    async with async_session_factory() as session:
        yield session


async def get_redis(request: Request) -> aioredis.Redis:
    """Return the Redis connection stored on app state."""
    return request.app.state.redis
