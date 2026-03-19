import logging
from contextlib import asynccontextmanager

import redis.asyncio as aioredis
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from config import settings
from db.database import engine
from api.routes import health, places, events, weather, categories, photos
from crawlers.scheduler import start_scheduler, stop_scheduler

logger = logging.getLogger(__name__)

# --- Rate Limiter (BE-006) ---
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: initialise Redis connection pool
    app.state.redis = aioredis.from_url(
        settings.REDIS_URL, decode_responses=True
    )

    # Start the crawler scheduler
    try:
        start_scheduler(redis=app.state.redis)
        logger.info("Crawler scheduler started")
    except Exception:
        logger.exception("Failed to start crawler scheduler")

    yield

    # Shutdown: stop scheduler, close Redis, dispose DB engine
    try:
        stop_scheduler()
    except Exception:
        logger.exception("Error stopping crawler scheduler")
    try:
        await app.state.redis.aclose()
    except Exception:
        logger.exception("Error closing Redis connection")
    await engine.dispose()


app = FastAPI(
    title="Little Atlas API",
    version="0.1.0",
    lifespan=lifespan,
)

# Attach rate limiter to app
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# --- CORS Configuration (BE-007) ---
# In development: allow all origins
# In production: restrict to configured origins
if settings.ENVIRONMENT == "production" and settings.CORS_ORIGINS:
    allowed_origins = [o.strip() for o in settings.CORS_ORIGINS.split(",") if o.strip()]
else:
    allowed_origins = ["http://localhost:3000", "http://localhost:8080"]

# allow_credentials must be False when allow_origins is ["*"] per CORS spec
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=allowed_origins != ["*"],
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
app.include_router(photos.router, prefix="/api/v1")
