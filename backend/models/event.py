import datetime

from geoalchemy2 import Geography
from sqlalchemy import Boolean, DateTime, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from db.database import Base


class Event(Base):
    __tablename__ = "events"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)

    # Trilingual fields
    title_en: Mapped[str] = mapped_column(String(256), nullable=False)
    title_el: Mapped[str] = mapped_column(String(256), nullable=False, default="")
    title_ru: Mapped[str] = mapped_column(String(256), nullable=False, default="")
    description_en: Mapped[str] = mapped_column(Text, nullable=False, default="")
    description_el: Mapped[str] = mapped_column(Text, nullable=False, default="")
    description_ru: Mapped[str] = mapped_column(Text, nullable=False, default="")

    # Geography
    location = mapped_column(
        Geography(geometry_type="POINT", srid=4326), nullable=True
    )
    venue_name: Mapped[str] = mapped_column(String(256), nullable=False, default="")
    address: Mapped[str] = mapped_column(String(512), nullable=False, default="")

    # Date range
    start_date: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    end_date: Mapped[datetime.datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Family-specific
    is_indoor: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    age_min: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    age_max: Mapped[int] = mapped_column(Integer, nullable=False, default=18)

    # Source
    source_url: Mapped[str] = mapped_column(String(512), nullable=True)
    source: Mapped[str] = mapped_column(String(64), nullable=False, default="manual")

    # Timestamps
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    def __repr__(self) -> str:
        return f"<Event {self.title_en}>"
