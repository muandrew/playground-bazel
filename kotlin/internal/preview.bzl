"""Entrypoint generation and single-file packaging for Compose JS previews."""

load(":providers.bzl", "KtJsInfo")

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

kt_js_preview_entry = rule(
    implementation = _preview_entry_impl,
    attrs = {"main_fun": attr.string(mandatory = True)},
)

def _preview_html_impl(ctx):
    app = ctx.attr.app
    module = app[KtJsInfo].module_name + ".mjs"
    files = app[DefaultInfo].files.to_list()
    entries = [f for f in files if f.basename == module]
    if len(entries) != 1:
        fail("Expected one Kotlin JS entry module named " + module)
    prefix = entries[0].dirname + "/"
    assets = {f.path[len(prefix):]: f.path for f in files if f.path.startswith(prefix)}
    manifest = ctx.actions.declare_file(ctx.label.name + ".assets.json")
    ctx.actions.write(manifest, json.encode({"entry": module, "files": assets}))
    html = ctx.actions.declare_file(ctx.label.name + ".html")
    args = ctx.actions.args()
    args.add("--manifest", manifest)
    args.add("--output", html)
    args.add("--title", ctx.attr.title or ctx.label.name)
    ctx.actions.run(
        executable = ctx.executable._packager,
        arguments = [args],
        inputs = files + [manifest],
        outputs = [html],
        mnemonic = "KtJsPreviewHtml",
        progress_message = "Packaging single-file Compose preview: %s" % ctx.label,
    )
    return [DefaultInfo(files = depset([html]), runfiles = ctx.runfiles(files = [html]))]

kt_js_preview_html = rule(
    implementation = _preview_html_impl,
    attrs = {
        "app": attr.label(mandatory = True, providers = [KtJsInfo]),
        "title": attr.string(),
        "_packager": attr.label(
            default = Label("//kotlin/internal:preview_packager"),
            executable = True,
            cfg = "exec",
        ),
    },
)
