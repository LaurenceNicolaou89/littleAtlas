from sqlalchemy import Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from db.database import Base


class Category(Base):
    __tablename__ = "categories"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    slug: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    name_en: Mapped[str] = mapped_column(String(128), nullable=False)
    name_el: Mapped[str] = mapped_column(String(128), nullable=False, default="")
    name_ru: Mapped[str] = mapped_column(String(128), nullable=False, default="")
    icon: Mapped[str] = mapped_column(String(64), nullable=False, default="")

    places = relationship("Place", back_populates="category")

    def __repr__(self) -> str:
        return f"<Category {self.slug}>"
