"""Shared utility functions for service modules."""

from __future__ import annotations


# Age-group name -> (min, max) mapping per business-logic.md
AGE_GROUP_MAP: dict[str, tuple[int, int]] = {
    "infant": (0, 1),
    "toddler": (1, 3),
    "preschool": (3, 5),
    "school_age": (6, 12),
}


def localized(obj: object, field_base: str, lang: str) -> str:
    """Return the best available localized value with fallback: lang -> en -> first non-null."""
    # Short-circuit for English: no fallback chain needed
    if lang == "en":
        return getattr(obj, f"{field_base}_en", None) or ""

    value = getattr(obj, f"{field_base}_{lang}", None)
    if value:
        return value
    value = getattr(obj, f"{field_base}_en", None)
    if value:
        return value
    for fallback in ("el", "ru"):
        value = getattr(obj, f"{field_base}_{fallback}", None)
        if value:
            return value
    return ""


def resolve_age_range(age_group: str) -> tuple[int, int] | None:
    """Resolve an age_group string to (min, max). Supports named groups and 'X-Y' format."""
    if age_group in AGE_GROUP_MAP:
        return AGE_GROUP_MAP[age_group]
    parts = age_group.split("-")
    if len(parts) == 2:
        try:
            return int(parts[0]), int(parts[1])
        except ValueError:
            return None
    return None
