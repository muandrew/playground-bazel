#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8080}"
# Resolve workspace directory
ROOT_DIR=""
if [ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]; then
    ROOT_DIR="${BUILD_WORKSPACE_DIRECTORY}"
elif [ -f "MODULE.bazel" ]; then
    ROOT_DIR="$(pwd)"
elif [ -f "$(dirname "$0")/../../../MODULE.bazel" ]; then
    ROOT_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
elif [ -f "$(dirname "$0")/../MODULE.bazel" ]; then
    ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

DIST_DIR=""
CMP_DIR="${ROOT_DIR}/prototype/cmp"
if [ -n "${ROOT_DIR}" ] && [ -d "${CMP_DIR}/web/build/dist/wasmJs/productionExecutable" ]; then
    DIST_DIR="${CMP_DIR}/web/build/dist/wasmJs/productionExecutable"
elif [ -n "${ROOT_DIR}" ] && [ -f "${CMP_DIR}/gradlew" ]; then
    echo "Building Kotlin/Wasm distribution via Gradle..."
    (cd "${CMP_DIR}" && ./gradlew :web:wasmJsBrowserDistribution)
    DIST_DIR="${CMP_DIR}/web/build/dist/wasmJs/productionExecutable"
fi

if [ -n "${DIST_DIR}" ] && [ -d "${DIST_DIR}" ]; then
    # Ensure index.html exists in distribution directory
    if [ -n "${ROOT_DIR}" ] && [ -f "${CMP_DIR}/web/index.html" ]; then
        cp "${CMP_DIR}/web/index.html" "${DIST_DIR}/index.html"
    fi
    DIR="${DIST_DIR}"
    MODE="Real Kotlin/Wasm (WebAssembly + Skiko Canvas)"
else
    # Fallback to runfiles or web directory
    if [ -n "${RUNFILES_DIR:-}" ] && [ -d "${RUNFILES_DIR}/_main/prototype/cmp/web" ]; then
        DIR="${RUNFILES_DIR}/_main/prototype/cmp/web"
    elif [ -d "${0}.runfiles/_main/prototype/cmp/web" ]; then
        DIR="${0}.runfiles/_main/prototype/cmp/web"
    elif [ -d "prototype/cmp/web" ]; then
        DIR="prototype/cmp/web"
    elif [ -d "web" ]; then
        DIR="web"
    else
        DIR="$(dirname "$0")"
    fi
    MODE="Static Web Assets"
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
echo " Runtime Mode:  ${MODE}"
echo " Document Root: ${DIR}"
echo " Target URL:    http://localhost:${PORT}"
echo " (Press Ctrl+C to stop the server)"
echo "=========================================================="

python3 -m http.server "${PORT}" --directory "${DIR}"
