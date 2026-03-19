import logging

from pydantic_settings import BaseSettings

logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@db:5432/littleatlas"
    REDIS_URL: str = "redis://redis:6379/0"
    OPENWEATHERMAP_API_KEY: str = ""
    GOOGLE_PLACES_API_KEY: str = ""
    ENVIRONMENT: str = "development"
    CORS_ORIGINS: str = ""  # Comma-separated origins for production, e.g. "https://app.littleatlas.com"
    DB_POOL_SIZE: int = 10
    DB_MAX_OVERFLOW: int = 20

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
    }


settings = Settings()

if not settings.OPENWEATHERMAP_API_KEY:
    logger.warning("OPENWEATHERMAP_API_KEY is not set — weather features will be unavailable")
if not settings.GOOGLE_PLACES_API_KEY:
    logger.warning("GOOGLE_PLACES_API_KEY is not set — Google Places features will be unavailable")
