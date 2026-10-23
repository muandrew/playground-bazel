"""Generic deterministic ZIP rule for targets providing website files."""

load("//kotlin/internal:providers.bzl", "StaticFilesInfo")
load("//kotlin/internal:static_files.bzl", "register_static_path")

def _ktx_zip_impl(ctx):
    paths = {}
    entries = []
    for dep in ctx.attr.deps:
        if StaticFilesInfo not in dep:
            fail("deps target %s does not provide StaticFilesInfo" % dep.label)
        for entry in dep[StaticFilesInfo].entries:
            path = entry.path
            register_static_path(paths, path, "ZIP")
            entries.append({"path": path, "file": entry.file.path})
    if not entries:
        fail("deps must contain at least one target providing StaticFilesInfo", attr = "deps")

    manifest = ctx.actions.declare_file(ctx.label.name + ".files.json")
    ctx.actions.write(manifest, json.encode(entries))
    archive = ctx.actions.declare_file(ctx.label.name + ".zip")
    args = ctx.actions.args()
    args.add("--manifest", manifest)
    args.add("--output", archive)
    inputs = [entry.file for dep in ctx.attr.deps for entry in dep[StaticFilesInfo].entries]
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
        "deps": attr.label_list(mandatory = True, providers = [StaticFilesInfo]),
        "_zipper": attr.label(default = Label("//kotlin/internal:zipper"), executable = True, cfg = "exec"),
    },
    doc = "Create a deterministic ZIP containing website files at their website-relative paths.",
)
