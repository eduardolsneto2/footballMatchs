# Backend

This backend is a FastAPI service for scraping and serving football fixtures, starting with FBref as the main source.

## Why it lives here

The iPhone app and scraping service are kept in the same repository as a monorepo:

- `FootballPulse/`: iPhone app
- `backend/`: scraping API, cache, and future notification-oriented backend

## Initial goals

- Expose a small API for searchable sources and fixtures
- Scrape FBref competition schedules
- Support team fixtures by filtering competition schedules when a direct team page is not reliable
- Cache normalized fixtures in SQLite with a structure that can move to Postgres later

## Local setup

1. Create a virtual environment:
   `python3 -m venv .venv`
2. Activate it:
   `source .venv/bin/activate`
3. Install dependencies:
   `pip install -r requirements-dev.txt`
4. Run the API:
   `uvicorn app.main:app --reload`
5. Run tests:
   `pytest`

## Current API

- `GET /health`
- `GET /api/v1/sources`
- `GET /api/v1/fixtures/{source_slug}`

## Notes

- The service currently uses seeded source definitions for a few teams and competitions.
- FBref coverage varies by league and team. For clubs like `CRB`, the backend is prepared to scrape competition schedules and filter the relevant matches.
- This is intentionally the first backend cut: the data model is structured for later additions like richer stats, notifications, and more providers.

