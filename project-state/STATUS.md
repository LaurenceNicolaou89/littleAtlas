# Little Atlas — Project Status

## Current Phase
Phase 7 — UI Redesign v2 + Deployment Configs COMPLETE

## Progress
- Phase 1 (Intake): Complete
- Phase 2 (Documentation): Complete — all 6 docs approved
- Phase 3 (Setup): Complete — repo, Docker, tickets, CLAUDE.md
- Phase 4 (Implementation): Complete — all 38/38 tickets done
- Phase 5 (Code Review): Complete — 30 findings fixed
- Phase 6 (Testing & Deployment): Complete — 32/32 tests passing
- UI Redesign v1: Complete — 10/10 tasks done
- UI Redesign v2: Complete — 15/15 tasks done
- Oracle Cloud Deployment: Complete — 3/3 tasks done

## UI Redesign v2 Summary
- Soft Modern palette (Atlas Violet #6C5CE7, Rose Pink, Aqua Teal) replacing Atlas Green
- Design system: design_tokens.dart + app_theme.dart with all constants
- 17 new shared widgets (FloatingNavBar, WeatherHeroCard, PlaceCardHorizontal/FullWidth, EventCardHorizontal/Redesign, InfoPill, GradientButton, SectionHeader, DateBlock, LiveBadge, BrandedSkeleton, FilterChipRemovable, LanguageTile, SettingsCard)
- 10 old widgets deleted (-1,848 lines)
- Floating 5-tab navigation bar (12dp margin, 20dp radius, violet dot indicator)
- Photo-forward cards with gradient overlays
- Weather hero card with Lottie animations
- Date block event cards with animated LIVE pulse badges
- Playful Cards settings screen (no iOS-style grouped lists)
- Contextual time-of-day greeting on Discover screen
- Slide-up page transitions (250ms easeInOut)
- Haptic feedback on chips, nav, bottom sheet, pull-to-refresh
- Branded violet skeleton loading
- Accessibility: Semantics on all images
- 32/32 Playwright API tests passing
- Zero flutter analyze errors

## Oracle Cloud Deployment Summary
- Caddyfile for automatic HTTPS via Let's Encrypt
- docker-compose.oracle.yml with Caddy, API, PostGIS, Redis (no exposed DB ports)
- Full deployment guide at docs/deployment-oracle.md
- Target: Oracle Cloud Always Free ARM VM (4 OCPUs, 24GB RAM, $0/mo)

## Next Up
- Sign up for Oracle Cloud and deploy
- Add real cinema/theatre data sources
- Replace Lottie placeholder animations with real weather animations from LottieFiles
- User feedback iteration
