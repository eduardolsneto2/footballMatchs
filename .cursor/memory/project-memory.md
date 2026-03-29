# Project Memory

## Product

- App name: FootballPulse
- Platform: iPhone only
- UI stack: SwiftUI
- Data provider: API-Football
- Core v1 value: favorite a team or competition and pin upcoming matches on the home screen

## Architecture defaults

- Use `project.yml` and XcodeGen as the source of truth for project structure.
- Keep feature code under `FootballPulse/Sources/Features` and shared services under `FootballPulse/Sources/Core`.
- Keep backend code under `backend/` as part of the monorepo.
- Do not commit `Config/Secrets.xcconfig`.
- Do not commit `backend/.venv` or local SQLite database files.
- If no API key is configured, the app should stay demoable with mock data.
- Local reminders are acceptable in v1. True remote push requires a backend.

## Shipping constraints

- The current scaffold is production-minded, but the final App Store release still needs branding assets, privacy disclosures, and a real bundle identifier.
- Long-term, API-Football calls should move behind a backend to avoid exposing the third-party key in the client.

## Near-term roadmap

- Expand the new backend beyond fixtures into richer stats, team search, and notification-ready endpoints.
- Improve the iPhone app to consume backend fixtures instead of relying on third-party client-side APIs.
- Add a backend service for remote push notifications and background sync.
