# Little Atlas — User Stories

## US-001: Health Check
**As a** developer
**I want** the API to have a health endpoint
**So that** I can verify the service is running
**Acceptance:** GET /health returns 200 with {"status": "ok"}

## US-002: Nearby Places Search
**As a** parent in Larnaca
**I want** to find family-friendly places near me
**So that** I can take my kids somewhere fun
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=10000 returns a list of places sorted by distance, each with name, category, distance_m, lat, lon

## US-003: Place Filtering by Category
**As a** parent looking for a playground
**I want** to filter places by category
**So that** I only see relevant results
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=10000&category=outdoor_playground returns only playground places

## US-004: Place Filtering by Age Group
**As a** parent of a toddler
**I want** to filter places by age suitability
**So that** I find places appropriate for my child
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=10000&age_group=toddler returns places where age_min<=3 AND age_max>=1

## US-005: Place Text Search
**As a** parent
**I want** to search places by name
**So that** I can find a specific place
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=25000&q=park returns places with "park" in the name

## US-006: Place Detail
**As a** parent
**I want** to see full details of a place
**So that** I can decide if it's worth visiting
**Acceptance:** GET /api/v1/places/1 returns full place info including name, description, amenities, photos, address, phone, website

## US-007: Trilingual Support
**As a** Russian-speaking parent in Cyprus
**I want** to see place names in Russian
**So that** I can understand the information
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=10000&lang=ru returns names in Russian (with fallback to English)

## US-008: Weather Data
**As a** parent
**I want** to see current weather
**So that** I can decide between indoor and outdoor activities
**Acceptance:** GET /api/v1/weather?lat=34.9003&lon=33.6232 returns temp, description, weather_mode (outdoor/indoor/caution)

## US-009: Categories List
**As a** parent
**I want** to see all available categories
**So that** I can browse by category
**Acceptance:** GET /api/v1/categories returns all categories with translated names

## US-010: Upcoming Events
**As a** parent
**I want** to see upcoming family events nearby
**So that** I can plan activities
**Acceptance:** GET /api/v1/events?lat=34.9003&lon=33.6232&radius=50000 returns upcoming events sorted by date

## US-011: Rate Limiting
**As a** system operator
**I want** the API to be rate limited
**So that** it's protected from abuse
**Acceptance:** More than 100 requests per minute from the same IP returns 429 Too Many Requests

## US-012: Pagination
**As a** parent browsing many places
**I want** results to be paginated
**So that** the app loads quickly
**Acceptance:** GET /api/v1/places?lat=34.9003&lon=33.6232&radius=25000&limit=10&offset=0 returns max 10 results, offset=10 returns the next page
