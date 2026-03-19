# Little Atlas — UI/UX Design Research & Trend Analysis (March 2026)

Research compiled from analysis of top family/kids activity apps, event discovery platforms, and current mobile UI/UX design trends for 2025-2026.

---

## 1. Competitive App Analysis

### Family/Kids Activity Apps

**Winnie (Parents + Local Discovery)**
- "Yelp for parents" model — browse local playgrounds, parks, restaurants, libraries
- Clean, minimal interface with search + filters for childcare, activities, amenities
- Community-driven "Stories" (parent reviews and tips) per location
- Key pattern: location-based directory with amenity filtering (changing tables, high chairs, fenced areas)
- Takeaway for Little Atlas: Winnie proves parents want **amenity-level filtering**, not just category browsing

**KidPass (Activity Booking)**
- Credit-based system: parents get credits to try different kids' classes
- Key pattern: activity cards with age range, class type, and schedule prominently shown
- Takeaway: showing **age suitability front-and-center** on every card is essential for parent trust

**Sawyer (Class Marketplace)**
- Subscription model for kids' activity vendors
- Membership packages with schedule views
- Takeaway: schedule/calendar integration matters for recurring activities

**Kinedu (Baby Development)**
- Daily personalized content based on child's age and developmental stage
- Redesigned Library tab with AI-powered search for activities, articles, lessons
- Key pattern: **personalized daily plan** — content surfaced proactively, not just searched
- Takeaway: a "suggested for today" section based on weather + child age could differentiate Little Atlas

**Tinybeans (Family Sharing)**
- Photo/milestone journal with private family sharing
- Clean, card-based timeline feed
- Takeaway: the warm, family-oriented visual tone (soft colors, generous whitespace) resonates with parent audiences

### Event Discovery Apps

**Eventbrite (2025 Redesign — "Discovery First")**
- Shifted from ticketing platform to discovery-first event platform
- **Dynamic card-based interface**: modular cards that blend visual storytelling with systems thinking
- **Discover tab**: personalized feed with AI-curated recommendations based on past interactions, location, interests
- **"It-Lists"**: curated guides by cultural tastemakers and local experts — users engaging with these were 2x more likely to purchase
- **Category organization**: selected showcase cards per category with "See all" — avoids overwhelming endless scrolling
- **Visual system**: vibrant colors, expressive gradients, bold typography bringing "emotion and joy"
- Takeaway for Little Atlas: the **curated showcase per category** pattern (3-4 highlighted cards + "See all") is superior to dumping all results

**Fever (Events & Tickets)**
- Horizontal scrolling event icons to save screen space
- Proprietary recommendation algorithm for personalized suggestions
- Filter by date/time, category
- Favorite/save events functionality
- Card-based UI kit with consistent typography, buttons, color palette
- Takeaway: **horizontal scroll carousels per category** are the dominant discovery pattern

**ClassPass (Fitness Discovery)**
- Chip paradigm with custom iconography for activity types
- Map + list dual-view for nearby classes
- Schedule-driven browsing (book by time slot)
- Takeaway: the **chip + icon** combination for categories is both compact and scannable

---

## 2. Layout Patterns — Specific Recommendations

### Home Screen / Discovery Feed

**Pattern: "Sectioned Discovery Feed" (Eventbrite/Fever/Airbnb model)**

Instead of a flat list, structure the home screen as themed sections:

```
┌─────────────────────────────────────┐
│ [Weather Banner — full width]       │  48dp height
├─────────────────────────────────────┤
│ [Category row — horizontal scroll]  │  Icons + labels, pill-shaped
├─────────────────────────────────────┤
│ Happening Now                       │  Section header
│ ┌────────┐ ┌────────┐ ┌────────┐  │  Horizontal scroll cards
│ │ Event1 │ │ Event2 │ │ Event3 │  │  160x200dp per card
│ └────────┘ └────────┘ └────────┘  │
├─────────────────────────────────────┤
│ Nearby Playgrounds            See all│  Section header + link
│ ┌────────┐ ┌────────┐ ┌────────┐  │  Horizontal scroll cards
│ │ Place1 │ │ Place2 │ │ Place3 │  │  160x180dp per card
│ └────────┘ └────────┘ └────────┘  │
├─────────────────────────────────────┤
│ [Map Preview — tap to expand]       │  200dp height mini-map
│                                     │
├─────────────────────────────────────┤
│ Popular This Week             See all│
│ ┌─────────────────────────────────┐ │  Full-width stacked cards
│ │ [Image]  Place Name      1.2km │ │  80dp height
│ │          Category · Open       │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

**Why this works**: Eventbrite's redesign proved that curated sections with 3-4 showcase cards per category dramatically reduce cognitive load versus an unstructured list. Users scan section headers and swipe only the categories they care about.

### Card Sizes — Specific Dimensions

| Card Type | Width | Height | Image Area | Corner Radius |
|-----------|-------|--------|------------|---------------|
| Horizontal scroll (place) | 160dp | 180dp | 160x100dp (top) | 12dp |
| Horizontal scroll (event) | 160dp | 200dp | 160x100dp (top) | 12dp |
| Full-width list item | full - 32dp padding | 88dp | 80x80dp (left) | 12dp |
| Featured/hero card | full - 32dp padding | 220dp | full width, 140dp | 16dp (top only) |
| Mini map card | full - 32dp padding | 200dp | full | 12dp |

### Grid Layout: Bento Grid for Categories (Alternative to Current Chips)

The 2025-2026 trend is **bento grids** — asymmetric, grouped layouts:

```
┌──────────────┬──────────────┐
│              │              │
│  Playgrounds │  Parks       │  Larger tiles: 2 primary categories
│  🎪          │  🌳          │  with illustration + icon
│              │              │
├───────┬──────┴──────┬───────┤
│Museums│ Restaurants │Sports │  Smaller tiles: secondary categories
│  🏛️   │  🍕         │ ⚽    │
└───────┴─────────────┴───────┘
```

Each tile: category color background (at 10% opacity), centered icon, label below. Tap navigates to filtered view. This is more visually engaging than plain chips for a home/explore screen, while chips remain ideal for inline filter bars.

---

## 3. Color Palette Trends (2025-2026)

### Current Industry Direction

The 2025-2026 palette trend for family/lifestyle apps emphasizes:

- **Warm, human, intentional** — moving away from cold tech blues
- **Soft pastels as accents** with one "hero" saturated color
- **Mocha Mousse and Lemon Grass** (Pantone-influenced) for friendly warmth
- **Calm neutrals + refined jewel tones + soft-tech pastels**

### Assessment of Little Atlas Current Palette

The existing Atlas Green (`#2E7D5F`) palette is **well-aligned** with 2026 trends:
- Nature-inspired green reads as warm, trustworthy, outdoorsy
- The category color system (orange, green, red, purple, blue, teal, pink) provides good variety
- Weather mode gradients (amber, blue, orange) are smart contextual color

### Recommended Enhancements

| Enhancement | Current | Proposed | Rationale |
|-------------|---------|----------|-----------|
| Background warmth | `#FAFAFA` (cool gray) | `#FFFBF5` (warm off-white) | Warmer background feels more inviting for a family app |
| Card surface | `#FFFFFF` (pure white) | Keep `#FFFFFF` | Clean contrast against warm background |
| Category colors | Flat, single tone | Add 10% opacity fills for category sections | Creates visual zones without overwhelming |
| Accent for "wow" | None | `#FFD54F` (warm gold) for highlights, badges, "Popular" tags | Adds energy and draws attention to key elements |
| Gradient on cards | None | Subtle bottom-to-top dark gradient on image cards | Ensures text readability over photos (60% → 0% black) |

### Recommended Image Card Gradient Overlay

For any card with a photo background and overlaid text:
- Bottom gradient: `rgba(0,0,0,0.6)` at bottom edge to `rgba(0,0,0,0)` at 40% height
- Text on gradient: white, semibold
- Padding: 12dp from bottom and sides
- This follows the Material Design scrim pattern and is used by Eventbrite, Fever, and Airbnb

---

## 4. Typography Patterns

### Current Industry Trends (2025-2026)

- **Large, expressive headers** — oversized text that makes messages impossible to miss
- **Variable fonts** gaining adoption (Roboto Flex, Inter Variable)
- **Rounded typefaces** for family/lifestyle (Nunito, Poppins, Quicksand)
- Material 3 Expressive: moving beyond static weights to variable font axes

### Assessment of Little Atlas Typography

**Nunito is an excellent choice** and aligns perfectly with 2026 trends:
- Rounded letterforms = friendly and approachable
- Good trilingual support (Latin, Greek, Cyrillic)
- Available as a Google Font in Flutter

### Recommended Refinements

| Change | Current | Proposed | Why |
|--------|---------|----------|-----|
| Screen titles | 24sp Bold | 28sp Bold | Trend toward larger, more expressive headings |
| Section headers | 20sp SemiBold | 18sp Bold + ALL CAPS tracking +0.5 | Differentiates section headers from card titles |
| Card titles | 16sp SemiBold | 15sp SemiBold | Slightly tighter for card density |
| Distance/meta | 12sp Regular | 12sp Medium | Medium weight improves legibility at small size |
| "See all" links | (new) | 13sp SemiBold, Atlas Green | Consistent interactive text pattern |

### Type Hierarchy in Practice

```
Explore                          ← 28sp Bold, Text Primary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HAPPENING NOW                    ← 12sp Bold, ALL CAPS, Text Secondary, tracking +1.0
┌──────────────────────┐
│ [Photo]              │
│ Limassol Carnival    │         ← 15sp SemiBold, Text Primary
│ Today, 10:00 · 5km  │         ← 12sp Medium, Text Secondary
│ Ages 2-12           │         ← 12sp Regular, Text Tertiary
└──────────────────────┘

NEARBY PARKS              See all ← 12sp Bold ALL CAPS + 13sp SemiBold Atlas Green
```

---

## 5. Category Display Patterns

### Three Proven Approaches

**A. Horizontal Scroll Pills (Current Little Atlas approach)**
- Best for: inline filtering on map/list screens
- Pattern: single row, horizontally scrollable, pill-shaped chips
- When to use: Explore screen filter bar, Search screen active filters
- Size: 32dp height, 8dp horizontal gap, 12dp horizontal padding

**B. Icon Grid Tiles (Airbnb/Eventbrite approach)**
- Best for: home screen category discovery, "What are you looking for?" section
- Pattern: 2-column or 3-column grid of tappable tiles with icon + label
- When to use: dedicated browse/discover section
- Tile size: (screen_width - 48dp) / 2 for 2-column, square or 3:4 ratio
- Airbnb's 2025 "Lava" icons: 3D illustrations with soft shadows, glows, transparency — high visual fidelity

**C. Horizontal Scroll Icon Row (Fever model)**
- Best for: compact category selection at top of discovery feed
- Pattern: circular icon + label below, horizontally scrollable
- Circle size: 56dp diameter, icon 28dp inside
- Background: category color at 15% opacity
- Label: 11sp Medium, centered below

### Recommendation for Little Atlas

Use **two patterns** in combination:
1. **Explore screen (map)**: keep horizontal scroll pills (current design) — they overlay the map cleanly
2. **Add a "Browse" section** (new): icon grid tiles when the bottom sheet is pulled up or on a future home/discover tab — more visually engaging for browsing

---

## 6. Event/Activity Card Patterns

### Best-in-Class Event Card (Synthesized from Eventbrite, Fever, Time Out)

**Horizontal Scroll Event Card (for "Happening Now" / "This Weekend")**
```
┌──────────────────────┐
│ ┌──────────────────┐ │  Image: full card width, 100dp height
│ │   [Event Photo]  │ │  Corner radius: 12dp top
│ │                  │ │
│ └──────────────────┘ │
│ 🎪 Limassol Carnival │  15sp SemiBold
│ Sat, Mar 20 · 10-18  │  12sp Medium, Text Secondary
│ 📍 Limassol · 5.2km  │  12sp Regular, Text Tertiary
│ ┌────────┐           │
│ │Ages 2-12│          │  Pill badge: 10sp, category color bg at 15%
│ └────────┘           │
└──────────────────────┘
 Width: 160dp  Height: 210dp
```

**Full-Width Event Card (for Events feed/list)**
```
┌─────────────────────────────────────────┐
│ ┌──────┐                                │
│ │ SAT  │  Limassol Carnival             │  Date block: 48x48dp, Atlas Green bg
│ │  20  │  10:00-18:00 · Limassol Marina │  White text, centered
│ │ MAR  │  👶 Ages 2-12  · 📍 5.2km     │
│ └──────┘                                │
└─────────────────────────────────────────┘
 Left date block replaces left accent border — more informative
```

### Key Principles for Event Cards
- **Date is the #1 scannable element** — make it visually prominent (date block, bold, or colored)
- **Time + venue on one line** — parents scan "when + where" as a unit
- **Age range always visible** — this is the deciding factor for parents
- **Distance always visible** — parents won't drive 30 minutes for a 1-hour event

### Time/Date Display Pattern
- Today/Tomorrow: use relative labels ("Today, 10:00" not "Mar 18, 10:00")
- This week: "Sat, Mar 20"
- Further out: "Mar 20"
- Time: 24h or 12h based on device locale
- Duration: show range "10:00-18:00" not "8 hours"

---

## 7. Bottom Navigation Patterns

### 2025-2026 Trends

- **Floating tab bars**: detached from the screen edge, creates an illusion of more space
- **Center action button**: odd-numbered tabs (3 or 5) with a prominent center CTA
- **Icon + label always**: research confirms icon-only tabs cause confusion for non-universal icons
- **Active state**: tint with primary color + optional indicator dot/line above
- **Touch targets**: minimum 48x48dp (44x44 Apple HIG minimum)
- **Maximum items**: 5 (3-5 is optimal; Airbnb uses 5)
- **Real-world data**: Airbnb's bottom tab bar showed 40% faster task completion vs hamburger menu

### Assessment of Little Atlas Navigation

Current: 4 tabs (Explore, Search, Events, Settings)

**Recommendation: Keep 4 tabs but enhance the visual treatment**

```
Current (standard):
┌────────┬──────────┬─────────┬───────────┐
│  🗺️    │  🔍      │  📅     │  ⚙️       │
│Explore │ Search   │ Events  │ Settings  │
└────────┴──────────┴─────────┴───────────┘

Enhanced (floating with active indicator):
         ┌──────────────────────────────────┐
         │ ●                                │
         │ 🗺️      🔍       📅       ⚙️    │
         │Explore  Search  Events  Settings │
         └──────────────────────────────────┘
         ↑ 12dp margin from screen edges and bottom
         ↑ 16dp border radius
         ↑ Small dot above active tab
         ↑ Surface color with subtle shadow (elevation 4dp)
```

The floating tab bar is a strong 2026 trend that adds visual polish with minimal effort. The 12dp margin from edges + rounded corners makes the app feel more premium.

### Alternative: Consider Adding a 5th Tab

If scope allows, a **Favorites/Saved** tab would round out the navigation:
- Explore | Search | Saved | Events | Settings
- "Saved" gives parents a quick list of bookmarked places (no account needed — local storage)
- This matches Fever's favorite/save pattern and is a common parent request

---

## 8. Filter UX Patterns

### 2025-2026 Best Practices

**Chip Filters (Horizontal Row)**
- Best for: 3-8 options, single-select or light multi-select
- Place in horizontally scrollable row near screen top
- Text inside chips: single words, brief
- Show active state immediately (filled background, checkmark)
- Little Atlas already uses this correctly for category filtering

**Bottom Sheet Filters (Multi-Faceted)**
- Best for: complex filtering (distance + category + age + amenities)
- Slide up from bottom, within thumb reach
- Modal vs non-modal: use **modal** for complex filter forms, **non-modal** for quick adjustments
- Show "Apply" button with result count: "Show 23 results"
- Show "Clear all" option

**Active Filter Display**
- Show active filters as removable chips below the search/filter bar
- Each chip has an "X" to remove
- "Clear all" link when 2+ filters active

### Recommended Filter Architecture for Little Atlas

```
Layer 1: Quick Filters (always visible)
┌─────────────────────────────────────────┐
│ [All] [Playgrounds] [Parks] [Food] [+]  │  Horizontal scroll chips
└─────────────────────────────────────────┘
                                      ↑ "+" opens bottom sheet

Layer 2: Advanced Filters (bottom sheet)
┌─────────────────────────────────────────┐
│ ──── Filters ────                  Clear│
│                                         │
│ Distance                                │
│ (○ 1km) (● 5km) (○ 10km) (○ 25km)    │  Single-select pills
│                                         │
│ Age Range                               │
│ [● Infant] [○ Toddler] [● Preschool]  │  Multi-select chips
│ [○ School-age]                          │
│                                         │
│ Type                                    │
│ (○ Indoor) (○ Outdoor) (● Both)        │  Single-select pills
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │     Show 23 results                 │ │  Primary button with count
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 9. "Wow Factor" Elements — Specific Implementable Ideas

### A. Weather-Reactive Interface (Unique to Little Atlas)

Little Atlas already has weather integration — push this further:

- **Dynamic background tint**: entire app background shifts subtly warm (sunny) or cool (overcast)
- **Animated weather icon in banner**: use Lottie animations for sun, clouds, rain — small file size, high impact
- **Weather-aware category reordering**: on rainy days, auto-move "Indoor" categories first in the chip row
- **"Perfect day for..." prompt**: "Perfect day for the beach" with a one-tap filter to show beaches

**Implementation**: Lottie weather animations are ~5-20KB each. Use the `lottie` Flutter package. Free weather animations available from LottieFiles.

### B. Micro-Interactions That Parents Will Notice

| Interaction | Animation | Duration | Tool |
|-------------|-----------|----------|------|
| Pull-to-refresh | Custom weather icon spins | 1000ms | Lottie |
| Favorite/save a place | Heart icon fills with bounce | 300ms | Built-in Flutter |
| Filter chip select | Gentle scale-up (1.0 → 1.05 → 1.0) + haptic tap | 150ms | AnimatedScale + HapticFeedback.lightImpact() |
| Bottom sheet drag | Smooth spring physics | 300ms | DraggableScrollableSheet with spring curve |
| Map marker appear | Scale from 0 + subtle bounce | 200ms | Built-in Flutter TweenAnimation |
| Open/Closed status change | Color crossfade green↔red | 500ms | AnimatedContainer |
| Distance counter | Animated number when location updates | 300ms | AnimatedSwitcher |
| Category section reveal | Staggered fade-in from left | 400ms total, 50ms stagger | StaggeredAnimation |

**Haptic feedback** on: chip selection, bottom sheet snap points, favorite toggle, pull-to-refresh release. Use `HapticFeedback.lightImpact()` — subtle but tactile.

### C. "Happening Now" Live Pulse

For events currently happening:
- Subtle pulsing dot (green or orange) next to event cards
- Pulsing ring animation on the map marker for live events
- "LIVE" badge on the event card

```dart
// Pulsing dot concept
AnimatedContainer(
  duration: Duration(seconds: 1),
  curve: Curves.easeInOut,
  width: isPulsed ? 10 : 8,
  height: isPulsed ? 10 : 8,
  decoration: BoxDecoration(
    color: Colors.orange,
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: isPulsed ? 8 : 4)],
  ),
)
```

### D. Smart Empty States

Instead of generic "No results" messages:
- **No outdoor places on rainy day**: "Rainy day? Check out indoor activities instead!" + one-tap to switch filter
- **No events this week**: "Quiet week! Here are some places to explore anytime." + show top-rated places
- **First launch**: animated walkthrough with Lottie illustrations (3 screens max)
- **Location denied**: friendly illustration + "We need your location to find places near you" + settings button

### E. Contextual Greeting

Time-aware greeting on the explore screen:
- Morning (5-12): "Good morning! Here's what's nearby"
- Afternoon (12-17): "Good afternoon! Looking for something fun?"
- Evening (17-21): "Good evening! Still time for an adventure"
- Include the user's city name: "Good morning, Larnaca!"

### F. Skeleton Loading with Brand Personality

Instead of generic gray shimmer, use:
- Atlas Green Light (`#E8F5EE`) as the shimmer base color
- Warm off-white (`#FFFBF5`) as the shimmer highlight
- This makes loading states feel branded rather than generic

---

## 10. Border Radius & Shape Trends

### 2025-2026: The Squircle Era

- Standard rounded corners (`border-radius`) are being replaced by **squircles** (superellipse curves) — the shape Apple uses for app icons
- Squircles feel more natural and less boxy than standard rounded rectangles
- Flutter supports this via `ContinuousRectangleBorder` for squircle-like shapes

### Recommended Border Radius System (Enhanced)

| Element | Current | Proposed | Rationale |
|---------|---------|----------|-----------|
| Cards | 12dp | 16dp | Slightly rounder = warmer, more 2026 |
| Buttons | 8dp | 12dp | Consistent with card radius |
| Chips/Tags | 20dp (pill) | 20dp (keep) | Pill shape is timeless |
| Bottom sheet | 16dp top | 20dp top | More pronounced, premium feel |
| Search bar | 12dp | Full pill (24dp) | Trend: search bars as pills |
| Image thumbnails | 8dp | 12dp | Match card radius |
| Floating nav bar | (new) | 16dp | Rounded floating bar |
| Map marker | 50% (circle) | 50% (keep) | Circles are correct for map pins |

---

## 11. Summary: Priority Recommendations for Little Atlas

### Quick Wins (Low Effort, High Impact)

1. **Warm the background** from `#FAFAFA` to `#FFFBF5` — instant family-friendly feel
2. **Add gradient overlays** on image cards for text readability
3. **Floating bottom navigation bar** with 12dp margins and 16dp radius
4. **Active tab indicator dot** above the selected navigation item
5. **Haptic feedback** on chip selection, favorites, bottom sheet snaps
6. **Skeleton shimmer** in brand colors (Atlas Green Light base)
7. **Contextual greeting** with time-of-day and city name
8. **Increase card border radius** from 12dp to 16dp

### Medium Effort, High Impact

9. **Lottie weather animations** in the weather banner (replace static icons)
10. **"Happening Now" pulse** on live event cards and map markers
11. **Date block pattern** on event cards (colored date square on left)
12. **Search bar as full pill** shape (border-radius 24dp)
13. **Staggered fade-in** animations for card lists
14. **Smart empty states** with contextual suggestions + illustrations
15. **Result count on filter button**: "Show 23 results"

### Larger Enhancements (Consider for v1.1+)

16. **Sectioned discovery feed** (if adding a home/discover tab beyond the map)
17. **Bento grid categories** for a browse section
18. **Weather-aware auto-reordering** of categories
19. **"Perfect day for..." prompt** based on current weather
20. **Favorites/saved places** tab (5th navigation item, local storage)
21. **Curated "lists"** (Eventbrite's "It-Lists" pattern) — e.g., "Best Rainy Day Activities in Limassol"

---

## Sources

- [Eventbrite App Redesign — Instrument](https://www.instrument.com/work/eventbrite-app)
- [Eventbrite Redesign — Fast Company](https://www.fastcompany.com/91289655/eventbrite-app-redesign-event-discovery)
- [Eventbrite 2025 Rebrand Analysis](https://www.blankboard.studio/originals/blog/eventbrite-rebrand-2025-strategy)
- [Fever App — Allison's Portfolio](https://www.heyalli.com/work/fever)
- [Airbnb Lava Icons 2025](https://medium.com/@waldobear002/airbnbs-new-lava-icon-format-a-technical-deep-dive-b2604626c7e0)
- [Airbnb App Redesign 2025](https://www.itsnicethat.com/articles/airbnb-app-redesign-140525)
- [9 Mobile App Design Trends 2026 — UXPilot](https://uxpilot.ai/blogs/mobile-app-design-trends)
- [12 Mobile App UI/UX Design Trends 2026](https://www.designstudiouiux.com/blog/mobile-app-ui-ux-design-trends/)
- [16 Key Mobile App UI/UX Trends 2026 — SPDLoad](https://spdload.com/blog/mobile-app-ui-ux-design-trends/)
- [Bottom Navigation Bar Complete 2025 Guide](https://blog.appmysite.com/bottom-navigation-bar-in-mobile-apps-heres-all-you-need-to-know/)
- [Mobile Navigation UX Best Practices 2026](https://www.designstudiouiux.com/blog/mobile-navigation-ux/)
- [Mobile Navigation: 6 Patterns for 2026](https://phone-simulator.com/blog/mobile-navigation-patterns-in-2026)
- [15 Filter UI Patterns That Work in 2025](https://bricxlabs.com/blogs/universal-search-and-filters-ui)
- [Mobile Filter UX Patterns — Pencil & Paper](https://www.pencilandpaper.io/articles/ux-pattern-analysis-mobile-filters)
- [10 Card UI Design Examples 2025](https://bricxlabs.com/blogs/card-ui-design-examples)
- [Card UI Best Practices — Mockplus](https://www.mockplus.com/blog/post/card-ui-design)
- [2026: Year of the Squircle](https://flyingw.press/article/2026-the-year-of-the-squircle/)
- [Border Radius Rules 2026](https://blog.92learns.com/border-radius-rules/)
- [Color Scheme Trends 2026 — Envato](https://elements.envato.com/learn/color-scheme-trends-in-mobile-app-design)
- [Kids Color Palette — Piktochart](https://piktochart.com/tips/kids-color-palette)
- [Map UI Design Best Practices — Eleken](https://www.eleken.co/blog-posts/map-ui-design)
- [Micro-Interactions 2025 Best Practices](https://www.stan.vision/journal/micro-interactions-2025-in-web-design)
- [5 Micro-Interaction Rules 2026](https://dev.to/devin-rosario/5-micro-interaction-design-rules-for-apps-in-2026-48nb)
- [How to Build Marketplace for Kids Activities — Apiko](https://apiko.com/blog/how-to-build-marketplace-for-kids-activities/)
- [Develop Childcare App Like Winnie](https://devtechnosys.com/insights/develop-a-childcare-app-like-winnie/)
- [Dribbble Event Discovery Designs](https://dribbble.com/tags/event-discovery)
- [Behance Event App Projects](https://www.behance.net/search/projects/event%20app?locale=en_US)
- [Hero Section Design Best Practices 2026](https://www.perfectafternoon.com/2025/hero-section-design/)
- [Bottom Tab Bar Best Practices — UX Planet](https://uxplanet.org/bottom-tab-bar-design-best-practices-ef3ee71de0fc)
