from pydantic import BaseModel


class WeatherResponse(BaseModel):
    lat: float
    lon: float
    temp: float | None = None
    description: str = ""
    icon: str = ""
    humidity: int | None = None
    wind_speed: float | None = None
    uv_index: float | None = None
    weather_mode: str = "outdoor"  # "indoor", "caution", or "outdoor"
