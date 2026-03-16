# Little Atlas — Project Specification

## Overview

Little Atlas is a mobile app for parents in Cyprus to discover family-friendly places and activities nearby. It aggregates data from multiple sources (Google Places, OpenStreetMap, social media, local websites) and provides weather-aware recommendations so parents always know where to take their kids.

## Target Market

- **Primary users:** Parents with children (ages 0-12) living in or visiting Cyprus
- **Geographic scope:** Cyprus only (initial launch)
- **Platform:** iOS and Android

## Core Features

### 1. Place Discovery

Browse and search family-friendly places across categories:

| Category | Examples |
|----------|----------|
| Playgrounds | Public playgrounds, indoor play areas |
| Parks & Nature | Parks, nature trails, beaches, botanical gardens |
| Restaurants | Family-friendly restaurants, cafes with play areas |
| Entertainment | Luna parks, arcades, bowling, mini golf |
| Culture & Education | Museums, libraries, aquariums, zoos |
| Sports & Activities | Swimming pools, trampoline parks, climbing walls |
| Events | Story times, festivals, markets, seasonal events |

Each place includes:
- Name, address, phone, website
- Category and subcategories
- Photos
- Opening hours
- Family-specific amenities (changing tables, high chairs, stroller access, fenced areas, kid menus)
- Age suitability tags (infant, toddler, preschool, school-age)
- Indoor/outdoor classification
- Distance from user

### 2. Map-Based Exploration

- Interactive map showing nearby family-friendly places
- Cluster markers at zoom levels
- Filter by category, distance, age suitability, indoor/outdoor
- "Near me" quick search
- Map uses OpenStreetMap tiles via Leaflet/flutter_map

### 3. Weather-Aware Recommendations

- Current weather + 3-hour forecast displayed in app
- Automatic recommendation adjustment:
  - Rain/cold/extreme heat → surface indoor places (museums, indoor playgrounds, malls)
  - Sunny/mild → parks, playgrounds, beaches, outdoor events
- UV index and air quality alerts (relevant for child safety)
- Seasonal awareness (splash pads open in summer, etc.)

### 4. Search & Filtering

- Text search by name or keyword
- Category filters
- Distance radius (1km, 5km, 10km, 25km)
- Age suitability filter
- Indoor/outdoor filter
- Open now filter
- Amenity filters (changing table, parking, wheelchair access)

### 5. Place Detail View

- Full place information
- Photo gallery
- Map with directions link (open in Google Maps/Apple Maps)
- Opening hours with "open now" indicator
- List of family amenities
- Age suitability badges

### 6. Events Feed

- Upcoming family events in Cyprus
- Filterable by date, location, age group
- Calendar view and list view
- Events sourced from crawled local websites and social media

## Data Sources

### Places
- **OpenStreetMap (Overpass API)** — playgrounds, parks, amenities (free)
- **Google Places API** — businesses, restaurants, ratings, photos, hours (paid, cached aggressively)
- **Manual curation** — local Cyprus-specific places added by the team

### Events
- **Web crawling** — local Cyprus event websites, municipality sites, Facebook pages
- **Manual entry** — for high-quality local events not found online

### Weather
- **OpenWeatherMap API** — current conditions, forecasts, UV index (free tier: 1,000 calls/day)

## Data Architecture

### Crawling Pipeline
1. **Scheduled crawlers** run on backend (configurable intervals per source)
2. **Entity resolution** — deduplicate places found across multiple sources (match on name + coordinates within 100m radius)
3. **Data enrichment** — merge attributes from multiple sources into single place record
4. **Freshness tracking** — flag stale entries, track last-verified date

### Data Refresh Rates
| Data Type | Refresh Rate |
|-----------|-------------|
| Weather | Every app open / every 30 min |
| Events | Daily |
| Place details (hours, status) | Daily |
| Place database (new places) | Weekly |
| Photos, amenities | Monthly / community-reported |

## Non-Functional Requirements

### Performance
- App cold start: < 3 seconds
- Place search results: < 1 second
- Map rendering: smooth 60fps scrolling/zooming

### Privacy & Compliance
- No user accounts or personal data collection (v1)
- No child data collected (no COPPA concerns for v1)
- Location used only for proximity search, never stored server-side
- GDPR compliant — no tracking, no analytics cookies

### Offline Support
- Cache last-viewed area's places for offline browsing
- Show cached weather with "last updated" timestamp when offline

### Accessibility
- WCAG 2.1 AA compliance
- Screen reader support
- High contrast mode support
- Minimum touch target sizes (48x48dp)

## Out of Scope (v1)

- User accounts / authentication
- User reviews and ratings
- User-submitted places
- Push notifications
- Social features (sharing, friends)
- AI/ML recommendations
- Personalization / child profiles
- Monetization / premium features

### Localization (v1)
- Three languages: English, Greek, Russian
- App UI fully translated in all three languages
- Language selection in app settings (default: device language)
- Place names stored in original language with optional translations
- Right-to-left support not needed (none of the three languages require it)

## Success Metrics

- App loads and displays nearby places within 3 seconds
- At least 500 family-friendly places in Cyprus indexed at launch
- Weather recommendations correctly switch indoor/outdoor based on conditions
- All major cities in Cyprus covered (Nicosia, Limassol, Larnaca, Paphos, Famagusta)
