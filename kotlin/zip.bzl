"""Generic deterministic ZIP rule for targets providing website files."""

load("//kotlin/internal:providers.bzl", "StaticFilesInfo")
load("//kotlin/internal:static_files.bzl", "register_static_path")

def _ktx_zip_impl(ctx):
    paths = {}
    entries = []
    prefix = ctx.label.package + "/" if ctx.label.package else ""
    for file in ctx.files.srcs:
        path = file.short_path
        if prefix and path.startswith(prefix):
            path = path[len(prefix):]
        elif path.startswith("../"):
            path = path[3:]
        register_static_path(paths, path, "ZIP")
        entries.append({"path": path, "file": file.path})
    for dep in ctx.attr.deps:
        if StaticFilesInfo not in dep:
            fail("deps target %s does not provide StaticFilesInfo" % dep.label)
        for entry in dep[StaticFilesInfo].entries:
            path = entry.path
            register_static_path(paths, path, "ZIP")
            entries.append({"path": path, "file": entry.file.path})
    if not entries:
        fail("srcs or deps must contain at least one file")

    manifest = ctx.actions.declare_file(ctx.label.name + ".files.json")
    ctx.actions.write(manifest, json.encode(entries))
    archive = ctx.actions.declare_file(ctx.label.name + ".zip")
    args = ctx.actions.args()
    args.add("--manifest", manifest)
    args.add("--output", archive)
    inputs = ctx.files.srcs + [entry.file for dep in ctx.attr.deps for entry in dep[StaticFilesInfo].entries]
    ctx.actions.run(
        executable = ctx.executable._zipper,
        arguments = [args],
        inputs = inputs + [manifest],
        outputs = [archive],
        mnemonic = "KtxZip",
        progress_message = "Creating website ZIP: %s" % ctx.label,
    )
    return [DefaultInfo(files = depset([archive]))]

ktx_zip = rule(
    implementation = _ktx_zip_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True, default = [], doc = "Files to include. Paths in this package are relative to the package; other paths are relative to their repository root."),
        "deps": attr.label_list(default = [], providers = [StaticFilesInfo]),
        "_zipper": attr.label(default = Label("//kotlin/internal:zipper"), executable = True, cfg = "exec"),
    },
    doc = "Create a deterministic ZIP containing website files at their website-relative paths.",
)
