"""Pydantic schemas for category responses."""

from pydantic import BaseModel


class CategoryResponse(BaseModel):
    id: int
    slug: str
    name: str
    icon: str = ""

    model_config = {"from_attributes": True}


class CategoryListResponse(BaseModel):
    categories: list[CategoryResponse] = []
    total: int = 0
