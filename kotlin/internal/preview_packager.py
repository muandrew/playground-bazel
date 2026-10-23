#!/usr/bin/env python3
"""Embed Kotlin/JS modules and Compose's Skiko Wasm runtime in one HTML file."""

import argparse
import base64
import html
import json
from pathlib import Path
import re


MODULE_PREFIX = "kt-js-preview/"
WASM_URL = re.compile(r"new URL\(\s*(['\"])skiko\.wasm\1\s*,\s*import\.meta\.url\s*\)")
JODA_MODULE = "node_modules/@js-joda/core/dist/js-joda.esm.js"


def package(manifest, title):
    files = manifest["files"]
    required = {manifest["entry"], "skiko.mjs", "js-reexport-symbols.mjs", "skiko.wasm", JODA_MODULE}
    missing = required - files.keys()
    if missing:
        raise ValueError("Missing Compose preview runtime assets: " + ", ".join(sorted(missing)))

    modules = {}
    module_paths = sorted(name for name in files if "/" not in name and name.endswith(".mjs"))
    module_paths.append(JODA_MODULE)
    for name in module_paths:
        source = Path(files[name]).read_text(encoding="utf-8")
        # Blob modules have no directory against which to resolve relative imports.
        # Give each sibling module a bare name resolved by the embedded import map.
        for sibling in module_paths:
            for quote in ("'", '"'):
                source = source.replace(quote + "./" + sibling + quote, json.dumps(MODULE_PREFIX + sibling))
        if name == "skiko.mjs":
            source, replacements = WASM_URL.subn("new URL(__KT_JS_PREVIEW_WASM_URL__)", source)
            if replacements != 1:
                raise ValueError("Unsupported Skiko runtime: expected one skiko.wasm URL relative to import.meta.url")
        modules[MODULE_PREFIX + name] = base64.b64encode(source.encode("utf-8")).decode("ascii")

    payload = json.dumps({
        "entry": MODULE_PREFIX + manifest["entry"],
        "modules": modules,
        "wasm": base64.b64encode(Path(files["skiko.wasm"]).read_bytes()).decode("ascii"),
    }, separators=(",", ":"))
    # All source text is base64, so app strings such as </script> cannot end the
    # containing script. Escape paths too, since target names enter the payload.
    payload = payload.replace("<", "\\u003c")
    return """<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="icon" href="data:,">
  <title>__TITLE__</title>
  <style>
    html, body, #root { margin: 0; width: 100%; height: 100%; overflow: hidden; }
    #loading { position: fixed; top: 16px; left: 16px; right: 16px;
               font: 14px system-ui, sans-serif; white-space: pre-wrap; }
    #loading[hidden] { display: none; }
  </style>
</head>
<body>
  <div id="root" data-compose-state="loading"></div>
  <div id="loading" role="status">Loading Compose…</div>
  <noscript>This preview requires JavaScript and WebAssembly.</noscript>
  <script>
    const payload = __PAYLOAD__;
    const loading = document.getElementById("loading");
    function showError(error) {
      console.error(error);
      document.getElementById("root").dataset.composeState = "error";
      loading.hidden = false;
      loading.setAttribute("role", "alert");
      loading.textContent = "Unable to start Compose.\\n" +
          (error?.stack || error?.message || String(error));
    }
    window.addEventListener("error", event => showError(event.error || event.message));
    window.addEventListener("unhandledrejection", event => showError(event.reason));
    function decode(encoded) {
      return Uint8Array.from(atob(encoded), char => char.charCodeAt(0));
    }
    try {
      const wasmUrl = URL.createObjectURL(new Blob([decode(payload.wasm)], {type: "application/wasm"}));
      const imports = {};
      for (const [name, encoded] of Object.entries(payload.modules)) {
        const source = new TextDecoder().decode(decode(encoded))
            .replaceAll("__KT_JS_PREVIEW_WASM_URL__", JSON.stringify(wasmUrl));
        imports[name] = URL.createObjectURL(new Blob([source], {type: "text/javascript"}));
      }
      imports["@js-joda/core"] = imports["kt-js-preview/node_modules/@js-joda/core/dist/js-joda.esm.js"];
      const map = document.createElement("script");
      map.type = "importmap";
      map.textContent = JSON.stringify({imports});
      document.head.appendChild(map);
      import(imports[payload.entry]).catch(showError);
    } catch (error) {
      showError(error);
    }
  </script>
</body>
</html>
""".replace("__TITLE__", html.escape(title)).replace("__PAYLOAD__", payload)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--title", required=True)
    args = parser.parse_args()
    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    Path(args.output).write_text(package(manifest, args.title), encoding="utf-8")


if __name__ == "__main__":
    main()
