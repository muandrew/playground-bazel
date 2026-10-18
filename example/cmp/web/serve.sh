#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8085}"
DIR=""

# Locate the web assets directory (runfiles or bazel-bin)
for candidate in \
    "${RUNFILES_DIR:-}/_main/example/cmp/web" \
    "${RUNFILES_DIR:-}/example/cmp/web" \
    "${0}.runfiles/_main/example/cmp/web" \
    "${0}.runfiles/example/cmp/web"; do
    if [ -f "${candidate}/index.html" ] && [ -f "${candidate}/web_app.js" ]; then
        DIR="${candidate}"
        break
    fi
done

if [ -z "$DIR" ] && [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
    CAND="${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/example/cmp/web"
    if [ -f "${CAND}/web_app.js" ]; then
        DIR="${CAND}"
        if [ ! -f "${DIR}/index.html" ] && [ -f "${BUILD_WORKSPACE_DIRECTORY}/example/cmp/web/index.html" ]; then
            cp "${BUILD_WORKSPACE_DIRECTORY}/example/cmp/web/index.html" "${DIR}/index.html"
        fi
    fi
fi

if [ -z "$DIR" ]; then
    if [ -f "index.html" ]; then
        DIR="$(pwd)"
    elif [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ] && [ -f "${BUILD_WORKSPACE_DIRECTORY}/example/cmp/web/index.html" ]; then
        DIR="${BUILD_WORKSPACE_DIRECTORY}/example/cmp/web"
    else
        DIR="$(dirname "$0")"
    fi
fi


if [ ! -f "${DIR}/index.html" ]; then
    echo "Error: index.html not found in ${DIR}" >&2
    exit 1
fi

# Find free port if 8085 is in use
if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
    for p in {8086..8099}; do
        if ! lsof -Pi :"$p" -sTCP:LISTEN -t >/dev/null 2>&1; then
            PORT="$p"
            break
        fi
    done
fi

echo "=========================================================="
echo " Serving Compose Multiplatform Web Shared Button Demo"
echo " Document Root: ${DIR}"
echo " Target URL:    http://localhost:${PORT}"
echo " (Press Ctrl+C to stop the server)"
echo "=========================================================="

python3 -m http.server "${PORT}" --directory "${DIR}"
