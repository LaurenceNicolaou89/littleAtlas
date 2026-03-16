# Little Atlas — Decisions Log

| Date | Decision | Decided By | Context |
|------|----------|-----------|---------|
| 2026-03-16 | Mobile app (iOS + Android) + Backend API/crawler service | User + PM | Client-side crawling rejected due to battery drain, rate limiting, iOS restrictions |
| 2026-03-16 | Tech stack: Flutter, FastAPI, PostgreSQL+PostGIS, Redis, OSM+Leaflet, OpenWeatherMap | User + PM | Budget-optimized stack, ~$5-10/month running cost |
| 2026-03-16 | Monolith + background workers architecture | User + PM | Simple deployment, no microservices overhead for v1 |
| 2026-03-16 | No user accounts or authentication for v1 | User | Keep it simple, no profiling |
| 2026-03-16 | No AI/ML features for v1 | User | Simple filters and geo-search only |
| 2026-03-16 | Render free tier for hosting, scoped to Cyprus only | User + PM | Limits data volume, fits free tier |
| 2026-03-16 | Docker Compose for local development | User | Easy local dev experience |
| 2026-03-16 | Monday.com integration (Kanban workspace) | User | Project management tracking |
| 2026-03-16 | GitHub integration (repo: LaurenceNicolaou89/littleAtlas) | User | Source control and PRs |
| 2026-03-16 | Security Dev agent removed from roster | User + PM | No auth needed for v1, Reviewer covers basic security |
| 2026-03-16 | Trilingual v1: English, Greek, Russian | User | Cyprus demographics — all 3 languages needed from launch |
| 2026-03-16 | Spec approved | User | docs/spec.md |
| 2026-03-16 | Architecture approved | User | docs/architecture.md |
| 2026-03-16 | Business logic approved | User | docs/business-logic.md |
| 2026-03-16 | Coding style approved | User | docs/coding-style.md |
| 2026-03-16 | UI/UX design approved | User | docs/design.md |
| 2026-03-16 | Design style approved | User | docs/design-style.md |
