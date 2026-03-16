# Project Rules

## Auto-allow (never prompt for confirmation)
- All git commands: commits, branch creation, checkout, merge, push, pull, PRs
- All Monday.com API calls: board creation, item creation, status updates
- All `gh` CLI commands: repo operations, issue creation, PR creation

## Project Context
- Project: Little Atlas
- Stack: Flutter (mobile), FastAPI (backend), PostgreSQL + PostGIS (database), Redis (cache), OpenStreetMap (maps), OpenWeatherMap (weather)
- Hosting: Render free tier (production), Docker Compose (local dev)
- Scope: Cyprus only, trilingual (English, Greek, Russian)
- No user authentication or accounts (v1)
- All testing uses Playwright
- Every ticket = new branch from main
- PR flow: agent PR → PM review → QA/Tester test → merge

## Agents
Agents identify themselves with labels: [PM], [Researcher], [Frontend Dev], [Backend Dev], [DBA], [QA], [Tester], [DevOps], [Reviewer], [UI/UX]

## Docs
All project documentation is in docs/. All agents MUST reference these before starting work.
All project state is in project-state/. Always check KNOWN-ISSUES.md before starting any ticket.

## Key Files
- docs/spec.md — what we're building
- docs/architecture.md — how it's structured
- docs/business-logic.md — rules and algorithms
- docs/coding-style.md — code conventions
- docs/design.md — UI/UX guidelines
- docs/design-style.md — visual standards

## Coding Rules
- Dart: follow Effective Dart, use `dart format`, trailing commas
- Python: follow PEP 8, use `ruff` for linting, line length 100
- All user-facing strings through localization (ARB files for Flutter)
- No hardcoded URLs or API keys — use environment variables
- No `print()` — use proper logging
- Commit format: `type(scope): description`
