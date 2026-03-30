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

**One command** (from this `backend/` folder):

```bash
./run.sh
```

This creates `.venv` if needed, installs `requirements-dev.txt`, loads `.env` if you created one from `.env.example`, and starts the API at `http://127.0.0.1:8000`.

Manual steps (equivalent):

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
- `POST /api/v1/sources`
- `GET /api/v1/fixtures/{source_slug}` — when FBref returns HTTP errors or a Cloudflare challenge and the SQLite cache is empty, the API responds with **502** and a JSON `detail` string instead of **500**. If cached fixtures exist, the handler keeps serving them until a refresh succeeds.

## Registering any team or competition

The backend can now store sources in the database, so you are no longer limited to the hardcoded seeds. Once a source is registered, the iPhone app's existing Discover screen can find it through `GET /api/v1/sources`.

Example competition:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/sources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Premier League",
    "source_type": "competition",
    "urls": [
      "https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures"
    ]
  }'
```

Example team:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/sources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Arsenal",
    "source_type": "team",
    "urls": [
      "https://fbref.com/en/comps/9/schedule/Premier-League-Scores-and-Fixtures",
      "https://fbref.com/en/comps/8/schedule/Champions-League-Scores-and-Fixtures"
    ]
  }'
```

## Notes

- The service currently uses seeded source definitions for a few teams and competitions.
- FBref coverage varies by league and team. For clubs like `CRB`, the backend is prepared to scrape competition schedules and filter the relevant matches.
- Fully automatic lookup by arbitrary team or tournament name will need a broader provider catalog or a browser-based worker, because FBref search pages are protected by Cloudflare.
- This is intentionally the first backend cut: the data model is structured for later additions like richer stats, notifications, and more providers.

