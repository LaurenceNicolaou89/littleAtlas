"""Photo proxy endpoint — serves Google Places photos without exposing API key."""

import logging

import httpx
from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from config import settings

logger = logging.getLogger(__name__)

router = APIRouter(tags=["photos"])

GOOGLE_PHOTO_URL = "https://maps.googleapis.com/maps/api/place/photo"


@router.get("/photos/{reference}")
async def get_photo(reference: str) -> Response:
    """Proxy a Google Places photo by its reference string."""
    api_key = settings.GOOGLE_PLACES_API_KEY
    if not api_key:
        raise HTTPException(status_code=503, detail="Photo service unavailable")

    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            resp = await client.get(
                GOOGLE_PHOTO_URL,
                params={
                    "maxwidth": 800,
                    "photo_reference": reference,
                    "key": api_key,
                },
            )
            resp.raise_for_status()
            content_type = resp.headers.get("content-type", "image/jpeg")
            return Response(content=resp.content, media_type=content_type)
    except httpx.HTTPStatusError as exc:
        logger.error("Google photo proxy HTTP error: %s", exc.response.status_code)
        raise HTTPException(status_code=502, detail="Photo service upstream error") from exc
    except httpx.RequestError as exc:
        logger.error("Google photo proxy request error: %s", exc)
        raise HTTPException(status_code=502, detail="Photo service unavailable") from exc
