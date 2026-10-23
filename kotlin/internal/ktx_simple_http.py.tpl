#!/usr/bin/env python3
"""Serve the files declared by a ktx_simple_http Bazel target."""

import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os
from pathlib import Path
import sys
import tempfile


CONFIG = @@CONFIG@@


def runfile(logical_path):
    for root in (os.environ.get("RUNFILES_DIR"), os.environ.get("TEST_SRCDIR"), sys.argv[0] + ".runfiles"):
        if root:
            candidate = Path(root) / logical_path
            if candidate.exists():
                return candidate.resolve()
    manifest = Path(os.environ.get("RUNFILES_MANIFEST_FILE", sys.argv[0] + ".runfiles_manifest"))
    if manifest.is_file():
        with manifest.open(encoding="utf-8") as entries:
            for entry in entries:
                escaped = entry.startswith(" ")
                key, separator, value = entry.lstrip(" ").rstrip("\n").partition(" ")
                if escaped:
                    for before, after in (("\\s", " "), ("\\n", "\n"), ("\\b", "\\")):
                        key, value = key.replace(before, after), value.replace(before, after)
                if key == logical_path:
                    return Path(value if separator else key).resolve(strict=True)
    raise FileNotFoundError("Missing runfile: " + logical_path + ". Start this target with bazel run.")


def port_number(value):
    try:
        port = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError("port must be an integer")
    if not 1 <= port <= 65535:
        raise argparse.ArgumentTypeError("port must be between 1 and 65535")
    return port


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-p", "--port", type=port_number, default=CONFIG["port"], help="HTTP port (default: %(default)s)")
    args = parser.parse_args()
    # Assemble a site outside the workspace and the Bazel output tree. Only
    # declared files are mounted, and the temporary directory is removed on exit.
    with tempfile.TemporaryDirectory(prefix="bazel-simple-http-") as site:
        for relative, logical in CONFIG["files"]:
            destination = Path(site) / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.symlink_to(runfile(logical))
        if len(CONFIG["files"]) == 1:
            relative = CONFIG["files"][0][0]
            if relative.endswith(".html") and relative != "index.html":
                (Path(site) / "index.html").symlink_to(Path(site) / relative)
        handler = partial(SimpleHTTPRequestHandler, directory=site)
        with ThreadingHTTPServer(("127.0.0.1", args.port), handler) as server:
            print("Serving at http://localhost:%s (Ctrl+C to stop)" % args.port, flush=True)
            try:
                server.serve_forever()
            except KeyboardInterrupt:
                pass


if __name__ == "__main__":
    main()
