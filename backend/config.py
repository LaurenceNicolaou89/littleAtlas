from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@db:5432/littleatlas"
    REDIS_URL: str = "redis://redis:6379/0"
    OPENWEATHERMAP_API_KEY: str = ""
    GOOGLE_PLACES_API_KEY: str = ""
    ENVIRONMENT: str = "development"
    CORS_ORIGINS: str = ""  # Comma-separated origins for production, e.g. "https://app.littleatlas.com"

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
    }


settings = Settings()
