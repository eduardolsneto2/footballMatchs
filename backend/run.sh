#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -d .venv ]]; then
  echo "Creating virtual environment in backend/.venv ..."
  python3 -m venv .venv
fi

echo "Installing dependencies (requirements-dev.txt) ..."
./.venv/bin/pip install -q -r requirements-dev.txt

if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

echo "Starting API at http://127.0.0.1:8000 (Ctrl+C to stop)"
exec ./.venv/bin/python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
