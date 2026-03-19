"""Shared geographic utility functions for PostGIS queries."""

from __future__ import annotations

from sqlalchemy import func


def extract_lat(location_column):
    """Extract latitude from a PostGIS geography/geometry column."""
    return func.ST_Y(func.ST_GeomFromWKB(location_column))


def extract_lon(location_column):
    """Extract longitude from a PostGIS geography/geometry column."""
    return func.ST_X(func.ST_GeomFromWKB(location_column))
