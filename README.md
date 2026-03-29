# FootballPulse

FootballPulse is an iPhone-only SwiftUI app scaffold for following football teams and tournaments through a local FastAPI backend. It is designed to be AI-friendly, modular, and safe to evolve toward production features like richer stats, TV coverage, and server-backed push notifications.

## What is included

- SwiftUI iPhone app scaffold generated with XcodeGen
- Search for teams or competitions
- Favorite a team or tournament locally
- Dashboard that pins favorite match schedules to the home screen
- Fixture detail screen prepared for stats, lineups, and broadcast metadata
- Local reminder scheduling for matches
- Automatic fallback to mock data when no backend URL is configured
- Project-local Cursor memory and a reusable git workflow skill

## Project structure

- `project.yml`: XcodeGen source of truth for the Xcode project
- `FootballPulse/Sources/App`: app bootstrap and dependency wiring
- `FootballPulse/Sources/Core`: models, networking, persistence, notifications
- `FootballPulse/Sources/Features`: SwiftUI feature areas and view models
- `backend/`: FastAPI scraping backend with FBref-first fixture ingestion and SQLite cache
- `Tests/FootballPulseTests`: focused unit tests for persistence settings
- `.cursor/memory/project-memory.md`: lightweight project memory for agentic work
- `.cursor/skills/git-workflow`: reusable repo-local git skill

## Setup

1. Generate the Xcode project:
   `xcodegen generate`
2. Start the backend:
   `cd backend && python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements-dev.txt && uvicorn app.main:app --reload`
3. Create a local secrets file from the example:
   `cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig`
4. If needed, override `BACKEND_BASE_URL` in `Config/Secrets.xcconfig`
5. Open `FootballPulse.xcodeproj` in Xcode and run the `FootballPulse` scheme on an iPhone simulator or device

If `Config/Secrets.xcconfig` is missing or invalid, the app runs in mock mode so the UI still builds and demos correctly.

## Backend setup

The repo now includes a backend service in `backend/` for scraping fixtures directly, starting with FBref as the main provider.

1. `cd backend`
2. `python3 -m venv .venv`
3. `source .venv/bin/activate`
4. `pip install -r requirements-dev.txt`
5. `uvicorn app.main:app --reload`

The first backend version exposes:

- `GET /health`
- `GET /api/v1/sources`
- `GET /api/v1/fixtures/{source_slug}`

## Production notes

- For simulator use, `http://127.0.0.1:8000` works as the default backend URL. For a physical iPhone, point `BACKEND_BASE_URL` at your Mac's local network IP instead.
- The current backend only exposes seeded sources, so search is limited to the catalog you define there.
- The notification layer is structured so v1 can use local reminders, while future remote push can be added behind a server.
- App icons, privacy text, bundle identifier, screenshots, and App Store metadata still need your final brand values.
