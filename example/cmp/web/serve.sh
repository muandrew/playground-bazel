#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8085}"
DIR=""

if [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
    DIR="${BUILD_WORKSPACE_DIRECTORY}/example/cmp/web"
elif [ -f "example/cmp/web/index.html" ]; then
    DIR="example/cmp/web"
elif [ -f "index.html" ]; then
    DIR="$(pwd)"
else
    DIR="$(dirname "$0")"
fi

# Copy compiled web_app.js and Skiko Canvas assets if present
if [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
    if [ -f "${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/example/cmp/web/web_app.js" ]; then
        cp "${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/example/cmp/web/web_app.js" "${DIR}/web_app.js"
    fi
    find "${BUILD_WORKSPACE_DIRECTORY}/bazel-bin" \( -name "skiko.wasm" -o -name "skiko.mjs" -o -name "js-reexport-symbols.mjs" \) 2>/dev/null | while read -r asset; do
        cp "$asset" "${DIR}/" 2>/dev/null || true
    done
    if [ -d "${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/example/cmp/web/node_modules" ]; then
        cp -R "${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/example/cmp/web/node_modules" "${DIR}/" 2>/dev/null || true
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
