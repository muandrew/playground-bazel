#!/usr/bin/env bash
set -euo pipefail

APP_BIN=""
if [ -n "${RUNFILES_DIR:-}" ]; then
    APP_BIN="$(find "$RUNFILES_DIR" -type f -name "web_app" ! -name "*.js" 2>/dev/null | head -n 1 || true)"
fi
if [ -z "$APP_BIN" ] && [ -n "${TEST_SRCDIR:-}" ]; then
    APP_BIN="$(find "$TEST_SRCDIR" -type f -name "web_app" ! -name "*.js" 2>/dev/null | head -n 1 || true)"
fi
if [ -z "$APP_BIN" ]; then
    APP_BIN="example/cmp/web/web_app"
fi

if [ ! -x "$APP_BIN" ]; then
    echo "Error: web_app executable not found or not executable at: $APP_BIN" >&2
    exit 1
fi

exec "$APP_BIN" "$@"
