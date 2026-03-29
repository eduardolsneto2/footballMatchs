# FootballPulse Agent Guide

## Current stack

- iPhone-only SwiftUI app
- XcodeGen project generation from `project.yml`
- Local persistence via `UserDefaults` stores for v1 favorites and reminder preferences
- API provider abstraction with live and mock implementations
- Backend monorepo service in `backend/` using FastAPI and FBref-first scraping

## Working agreements

- Keep secrets out of git. Use `Config/Secrets.xcconfig` locally.
- Keep backend virtualenvs and SQLite files out of git.
- Maintain a clean path toward moving API traffic behind a backend.
- Preserve mock mode so UI work stays unblocked without external credentials.
- Record major product or architecture changes in `.cursor/memory/project-memory.md`.
