"""Entrypoint generation and static-file layout for Compose JS previews."""

load(":providers.bzl", "KtJsInfo", "StaticFilesInfo")
load(":static_files.bzl", "register_static_path")

def _preview_entry_impl(ctx):
    parts = ctx.attr.main_fun.split(".")
    initial_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    identifier_chars = initial_chars + "0123456789"
    for part in parts:
        if not part or part[0] not in initial_chars or any([c not in identifier_chars for c in part.elems()]):
            fail("main_fun must be a fully qualified Kotlin function name", attr = "main_fun")
    if len(parts) < 2:
        fail("main_fun must include the package name", attr = "main_fun")

    entry = ctx.actions.declare_file(ctx.label.name + ".kt")
    ctx.actions.write(entry, """import androidx.compose.runtime.SideEffect
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.ComposeViewport
import kotlinx.browser.document
import %s as previewApp

@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    ComposeViewport(viewportContainerId = "root") {
        previewApp()
        SideEffect {
            document.getElementById("loading")?.setAttribute("hidden", "")
            document.getElementById("root")?.setAttribute("data-compose-state", "ready")
        }
    }
}
""" % ".".join(["`%s`" % part for part in parts]))
    return [DefaultInfo(files = depset([entry]))]

ktx_js_preview_entry = rule(
    implementation = _preview_entry_impl,
    attrs = {"main_fun": attr.string(mandatory = True)},
)

def _html_escape(value):
    return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;").replace("'", "&#x27;")

def _preview_binary_impl(ctx):
    prefix = ctx.label.name + "_files/"
    title = _html_escape(ctx.attr.title or ctx.label.name)
    html = ctx.actions.declare_file(prefix + "index.html")
    ctx.actions.write(html, """<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>%s</title>
  <link rel="icon" href="data:,">
  <style>
    html, body, #root { margin: 0; width: 100%%; height: 100%%; overflow: hidden; }
    #loading { position: fixed; top: 16px; left: 16px; right: 16px;
               font: 14px system-ui, sans-serif; white-space: pre-wrap; }
    #loading[hidden] { display: none; }
  </style>
  <script type="importmap">{"imports":{"@js-joda/core":"./node_modules/@js-joda/core/dist/js-joda.esm.js"}}</script>
</head>
<body>
  <div id="root" data-compose-state="loading"></div>
  <div id="loading" role="status">Loading Compose…</div>
  <noscript>This preview requires JavaScript and WebAssembly.</noscript>
  <script>
    function showError(error) {
      console.error(error);
      document.getElementById("root").dataset.composeState = "error";
      const loading = document.getElementById("loading");
      loading.hidden = false;
      loading.setAttribute("role", "alert");
      loading.textContent = "Unable to start Compose.\\n" +
          (error?.stack || error?.message || String(error));
    }
    window.addEventListener("error", event => showError(event.error || event.message));
    window.addEventListener("unhandledrejection", event => showError(event.reason));
  </script>
  <script type="module" src="./%s"></script>
</body>
</html>
""" % (title, ctx.attr.module_name + ".mjs"))

    app = ctx.attr.app
    module = app[KtJsInfo].module_name + ".mjs"
    files = app[DefaultInfo].files.to_list()
    module_files = [file for file in files if file.basename == module]
    if len(module_files) != 1:
        fail("Expected one Kotlin JS entry module named " + module)
    module_file = module_files[0]
    module_dir = module_file.dirname + "/"
    required = {
        module: True,
        "skiko.mjs": True,
        "js-reexport-symbols.mjs": True,
        "skiko.wasm": True,
        "node_modules/@js-joda/core/dist/js-joda.esm.js": True,
    }
    selected = {}
    for file in files:
        if file.path == module_file.path:
            relative = module
        elif file.path.startswith(module_dir):
            relative = file.path[len(module_dir):]
        else:
            continue
        if relative in required:
            if relative in selected:
                fail("Duplicate Compose preview runtime asset: " + relative)
            selected[relative] = file
    for path in required:
        if path not in selected:
            fail("Missing Compose preview runtime asset: " + path)

    entries = [struct(path = "index.html", file = html)]
    for relative in sorted(selected.keys()):
        output = ctx.actions.declare_file(prefix + relative)
        ctx.actions.symlink(output = output, target_file = selected[relative])
        entries.append(struct(path = relative, file = output))

    paths = {}
    for entry in entries:
        register_static_path(paths, entry.path, "preview")
    return [
        DefaultInfo(files = depset([entry.file for entry in entries])),
        StaticFilesInfo(entries = entries),
    ]

preview_binary_rule = rule(
    implementation = _preview_binary_impl,
    attrs = {
        "app": attr.label(mandatory = True, providers = [KtJsInfo]),
        "module_name": attr.string(mandatory = True),
        "title": attr.string(),
    },
)
