#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-8086}"
if ! [[ "$PORT" =~ ^[0-9]{1,5}$ ]] || (( 10#$PORT < 1 || 10#$PORT > 65535 )); then
    echo "Usage: bazel run //web:serve -- [port: 1-65535]" >&2
    exit 1
fi
PORT="$((10#$PORT))"

rlocation() {
    local relative="$1" candidate
    for candidate in \
        "${RUNFILES_DIR:-}/$relative" \
        "${TEST_SRCDIR:-}/$relative" \
        "${0}.runfiles/$relative"; do
        if [ -e "$candidate" ]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
    local manifest="${RUNFILES_MANIFEST_FILE:-${0}.runfiles_manifest}"
    if [ -f "$manifest" ]; then
        candidate="$(awk -v key="$relative" '$1 == key {sub(/^[^ ]+ /, ""); print; exit}' "$manifest")"
        if [ -n "$candidate" ] && [ -e "$candidate" ]; then
            printf '%s\n' "$candidate"
            return
        fi
    fi
    echo "Missing runfile: $relative. Run this server with bazel run //web:serve." >&2
    return 1
}

INDEX="$(rlocation _main/example/bs/web/index.html)"
APP="$(rlocation _main/example/bs/web/web_app_files/bs_app.mjs)"
ASSETS="$(dirname "$APP")"
for asset in skiko.mjs skiko.wasm js-reexport-symbols.mjs; do
    if [ ! -f "$ASSETS/$asset" ]; then
        echo "Missing Compose runtime asset: $ASSETS/$asset" >&2
        exit 1
    fi
done

# Assemble a complete site outside of the source tree and Bazel output tree.
SITE="$(mktemp -d "${TMPDIR:-/tmp}/compose-bs-web.XXXXXXXX")"
SERVER_PID=""
cleanup() {
    if [ -n "$SERVER_PID" ]; then
        kill "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi
    rm -rf "$SITE"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
cp -RL "$ASSETS/." "$SITE/"
cp "$INDEX" "$SITE/index.html"

echo "Bottom Sheet Demo: http://localhost:$PORT"
echo "Press Ctrl+C to stop."
python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$SITE" &
SERVER_PID=$!
wait "$SERVER_PID"
