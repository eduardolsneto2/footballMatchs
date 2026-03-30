# Project Memory

## Product

- App name: FootballPulse
- Platform: iPhone only
- UI stack: SwiftUI
- Data provider: local FastAPI backend with FBref-first ingestion
- Core v1 value: favorite a team or competition and pin upcoming matches on the home screen

## Assistant behavior

- After any change that **does not** hot-reload (edits to `backend/.env`, new/changed `requirements*.txt` and `pip install`, or other startup-only config), **tell the user to restart the backend** (Ctrl+C, then `cd backend && ./run.sh`). Normal edits to `backend/app/*.py` reload automatically with `--reload`; still mention restart if unsure.

## Architecture defaults

- Use `project.yml` and XcodeGen as the source of truth for project structure.
- Keep feature code under `FootballPulse/Sources/Features` and shared services under `FootballPulse/Sources/Core`.
- Keep backend code under `backend/` as part of the monorepo.
- Do not commit `Config/Secrets.xcconfig`.
- Do not commit `backend/.venv` or local SQLite database files.
- If no backend URL is configured, the app should stay demoable with mock data.
- Local reminders are acceptable in v1. True remote push requires a backend.
- Backend sources are no longer limited to code-defined seeds; arbitrary team or competition sources can be registered through `POST /api/v1/sources`.

## Shipping constraints

- **Root tabs:** The app uses a custom bottom bar in `RootTabView` (`ZStack` + `safeAreaInset`) instead of SwiftUI `TabView`, because on iOS 26 the system tab chrome can inset content in a rounded card with black margins. `UIDesignRequiresCompatibility` remains in Info.plist / `project.yml` for other system UI.
- The current scaffold is production-minded, but the final App Store release still needs branding assets, privacy disclosures, and a real bundle identifier.
- Fully automatic lookup for arbitrary FBref teams and competitions will require either a maintained source catalog or a browser-based worker, because FBref search is protected by Cloudflare.

## Near-term roadmap

- Expand the backend beyond fixtures into richer stats, broader source discovery, and notification-ready endpoints.
- Add an app flow for registering custom team and competition sources without leaving the iPhone client.
- Add a backend service for remote push notifications and background sync.
