import datetime

from geoalchemy2 import Geography
from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db.database import Base


class Place(Base):
    __tablename__ = "places"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)

    # Trilingual fields
    name_en: Mapped[str] = mapped_column(String(256), nullable=False)
    name_el: Mapped[str] = mapped_column(String(256), nullable=False, default="")
    name_ru: Mapped[str] = mapped_column(String(256), nullable=False, default="")
    description_en: Mapped[str] = mapped_column(Text, nullable=False, default="")
    description_el: Mapped[str] = mapped_column(Text, nullable=False, default="")
    description_ru: Mapped[str] = mapped_column(Text, nullable=False, default="")

    # Category FK
    category_id: Mapped[int | None] = mapped_column(
        Integer, ForeignKey("categories.id"), nullable=True
    )
    category = relationship("Category", back_populates="places")

    # Geography
    location = mapped_column(
        Geography(geometry_type="POINT", srid=4326), nullable=False
    )

    # Details
    address: Mapped[str] = mapped_column(String(512), nullable=False, default="")
    phone: Mapped[str] = mapped_column(String(32), nullable=False, default="")
    website: Mapped[str] = mapped_column(String(512), nullable=False, default="")
    opening_hours = mapped_column(JSONB, nullable=True)

    # Family-specific
    is_indoor: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    age_min: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    age_max: Mapped[int] = mapped_column(Integer, nullable=False, default=18)
    amenities = mapped_column(JSONB, nullable=False, server_default="[]")
    photos = mapped_column(JSONB, nullable=False, server_default="[]")

    # Data source tracking
    source: Mapped[str] = mapped_column(String(64), nullable=False, default="manual")
    source_id: Mapped[str] = mapped_column(String(256), nullable=True)
    last_verified_at: Mapped[datetime.datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Timestamps
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime.datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
    )

    def __repr__(self) -> str:
        return f"<Place {self.name_en}>"
