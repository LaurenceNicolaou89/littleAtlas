from contextlib import asynccontextmanager

import redis.asyncio as aioredis
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from db.database import engine
from api.routes import health, places, events, weather, categories


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialise Redis connection pool
    app.state.redis = aioredis.from_url(
        settings.REDIS_URL, decode_responses=True
    )
    yield
    # Shutdown: close Redis and dispose DB engine
    await app.state.redis.aclose()
    await engine.dispose()


app = FastAPI(
    title="Little Atlas API",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS — allow all origins during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Health check lives outside the versioned prefix
app.include_router(health.router)

# All feature routers under /api/v1
app.include_router(places.router, prefix="/api/v1")
app.include_router(events.router, prefix="/api/v1")
app.include_router(weather.router, prefix="/api/v1")
app.include_router(categories.router, prefix="/api/v1")
