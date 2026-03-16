from pydantic import BaseModel


class PlaceResponse(BaseModel):
    id: int
    name: str
    description: str
    lat: float
    lon: float
    category: str | None = None
    distance_m: float | None = None
    is_indoor: bool = False
    age_min: int = 0
    age_max: int = 18
    amenities: list[str] = []
    photos: list[str] = []
    address: str = ""
    phone: str = ""
    website: str = ""
    opening_hours: dict | None = None

    model_config = {"from_attributes": True}


class PlaceListResponse(BaseModel):
    places: list[PlaceResponse] = []
    total: int = 0
