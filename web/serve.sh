#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"
echo "Serving web target at http://localhost:${PORT}"
python3 -m http.server "${PORT}" --directory "$(dirname "$0")"
