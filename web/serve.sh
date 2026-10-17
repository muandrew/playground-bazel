#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"
# Resolve web root directory containing index.html and playground_bazel.js
if [ -n "${RUNFILES_DIR:-}" ] && [ -d "${RUNFILES_DIR}/_main/web" ]; then
    DIR="${RUNFILES_DIR}/_main/web"
elif [ -n "${RUNFILES_DIR:-}" ] && [ -d "${RUNFILES_DIR}/playground_bazel/web" ]; then
    DIR="${RUNFILES_DIR}/playground_bazel/web"
elif [ -d "${0}.runfiles/_main/web" ]; then
    DIR="${0}.runfiles/_main/web"
elif [ -d "${0}.runfiles/playground_bazel/web" ]; then
    DIR="${0}.runfiles/playground_bazel/web"
elif [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ] && [ -d "${BUILD_WORKSPACE_DIRECTORY}/web" ]; then
    DIR="${BUILD_WORKSPACE_DIRECTORY}/web"
elif [ -f "$(dirname "$0")/index.html" ]; then
    DIR="$(dirname "$0")"
elif [ -d "web" ]; then
    DIR="web"
else
    DIR="."
fi

if [ ! -f "${DIR}/index.html" ]; then
    echo "Error: index.html not found in ${DIR}" >&2
    exit 1
fi

# Check if port is in use and find next free port if default was busy
if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Notice: Port ${PORT} is in use."
    for p in {8081..8099}; do
        if ! lsof -Pi :"$p" -sTCP:LISTEN -t >/dev/null 2>&1; then
            PORT="$p"
            break
        fi
    done
fi

echo "=========================================================="
echo " Serving Compose Multiplatform Web Bottom Sheet Demo"
echo " Document Root: ${DIR}"
echo " Target URL:    http://localhost:${PORT}"
echo " (Press Ctrl+C to stop the server)"
echo "=========================================================="

python3 -m http.server "${PORT}" --directory "${DIR}"
