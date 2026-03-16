from pydantic import BaseModel


class WeatherResponse(BaseModel):
    lat: float
    lon: float
    temperature_c: float | None = None
    feels_like_c: float | None = None
    humidity: int | None = None
    wind_speed_ms: float | None = None
    description: str = ""
    icon: str = ""
    is_outdoor_friendly: bool = True
