"""Shared weather utility functions."""

from __future__ import annotations


def calculate_weather_mode(
    temp: float | None,
    rain: float,
    wind_speed_kmh: float,
    uv_index: float | None,
) -> str:
    """Determine weather mode per business-logic.md decision tree.

    Returns one of: "indoor", "caution", "outdoor".
    """
    if rain > 0:
        return "indoor"
    if temp is not None:
        if temp < 10:
            return "indoor"
        if temp > 38:
            return "indoor"
    if wind_speed_kmh > 50:
        return "indoor"
    if uv_index is not None and uv_index >= 8:
        return "caution"
    if temp is not None and 10 <= temp <= 15:
        return "caution"
    return "outdoor"
