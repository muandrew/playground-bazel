"""A convenience executable for serving declared files over local HTTP."""

load("//kotlin/internal:providers.bzl", "StaticFilesInfo")
load("//kotlin/internal:static_files.bzl", "register_static_path")

def _runfile_path(ctx, file):
    if file.short_path.startswith("../"):
        return file.short_path[3:]
    return ctx.workspace_name + "/" + file.short_path

def _ktx_simple_http_impl(ctx):
    if ctx.attr.port < 1 or ctx.attr.port > 65535:
        fail("port must be between 1 and 65535", attr = "port")
    prefix = ctx.label.package + "/" if ctx.label.package else ""
    paths = {}
    files = []
    input_files = []
    for file in ctx.files.srcs:
        path = file.short_path
        if prefix and path.startswith(prefix):
            path = path[len(prefix):]
        elif path.startswith("../"):
            path = path[3:]
        register_static_path(paths, path, "HTTP")
        files.append([path, _runfile_path(ctx, file)])
        input_files.append(file)

    for dep in ctx.attr.deps:
        if StaticFilesInfo not in dep:
            fail("deps target %s does not provide StaticFilesInfo" % dep.label)
        for entry in dep[StaticFilesInfo].entries:
            register_static_path(paths, entry.path, "HTTP")
            files.append([entry.path, _runfile_path(ctx, entry.file)])
            input_files.append(entry.file)

    if not files:
        fail("srcs or deps must contain at least one file")

    launcher = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.expand_template(
        template = ctx.file._server,
        output = launcher,
        substitutions = {"@@CONFIG@@": json.encode({"port": ctx.attr.port, "files": files})},
        is_executable = True,
    )
    return [DefaultInfo(
        executable = launcher,
        runfiles = ctx.runfiles(files = input_files),
    )]

ktx_simple_http = rule(
    implementation = _ktx_simple_http_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            default = [],
            doc = "Files to serve. Paths in this package are relative to the package; other paths are relative to their repository root. A sole HTML file is also served at /.",
        ),
        "deps": attr.label_list(
            providers = [StaticFilesInfo],
            doc = "Targets providing a website file layout through StaticFilesInfo.",
        ),
        "port": attr.int(default = 8085, doc = "Default port, overridden at runtime by -p PORT or --port PORT."),
        "_server": attr.label(
            default = Label("//kotlin/internal:ktx_simple_http.py.tpl"),
            allow_single_file = True,
        ),
    },
    doc = "Serve srcs at http://localhost:8085 with bazel run. Requires Python 3.",
)
