import datetime

from pydantic import BaseModel


class EventResponse(BaseModel):
    id: int
    title: str
    description: str
    lat: float | None = None
    lon: float | None = None
    venue_name: str = ""
    address: str = ""
    start_date: datetime.datetime
    end_date: datetime.datetime | None = None
    is_indoor: bool = False
    age_min: int = 0
    age_max: int = 18
    source_url: str | None = None

    model_config = {"from_attributes": True}


class EventListResponse(BaseModel):
    events: list[EventResponse] = []
    total: int = 0
