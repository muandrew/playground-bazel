"""Kotlin JS rules and a single-file Compose application preview."""

load("//kotlin/internal:compile.bzl", "kt_js_binary_impl", "kt_js_library_impl", "kt_js_test_impl")
load("//kotlin/internal:preview.bzl", "kt_js_preview_entry", "kt_js_preview_html")
load("//kotlin/internal:providers.bzl", "KtJsInfo")

kt_js_library = rule(
    implementation = kt_js_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
            doc = "Kotlin source files.",
        ),
        "deps": attr.label_list(
            doc = "Kotlin JS dependencies providing KtJsInfo.",
        ),
        "module_name": attr.string(
            doc = "Kotlin JS module name (defaults to target name).",
        ),
        "compose_enabled": attr.bool(
            default = False,
            doc = "Whether to enable Compose Multiplatform compiler plugin.",
        ),
        "compose_runtime_klibs": attr.label_list(
            allow_files = True,
            doc = "Compose runtime klibs overriding the JS toolchain defaults.",
        ),
        "kotlinc_opts": attr.string_list(
            doc = "Extra kotlinc compiler options.",
        ),
    },
    toolchains = ["//kotlin:js_toolchain_type"],
    doc = "Compiles Kotlin source files into a JS klib.",
)

kt_js_binary = rule(
    implementation = kt_js_binary_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
            doc = "Kotlin source files.",
        ),
        "deps": attr.label_list(
            doc = "Kotlin JS dependencies.",
        ),
        "module_name": attr.string(
            doc = "Kotlin JS module name (defaults to target name).",
        ),
        "main": attr.string(
            default = "call",
            values = ["call", "noCall"],
            doc = "Whether to invoke main() on startup.",
        ),
        "target": attr.string(
            default = "es2015",
            values = ["es5", "es2015"],
            doc = "Target ECMA version.",
        ),
        "compose_enabled": attr.bool(
            default = False,
            doc = "Whether to enable Compose Multiplatform compiler plugin.",
        ),
        "compose_runtime_klibs": attr.label_list(
            allow_files = True,
            doc = "Compose runtime klibs overriding the JS toolchain defaults.",
        ),
        "compose_runtime_assets": attr.label_list(
            allow_files = True,
            doc = "Compose runtime assets overriding the JS toolchain defaults.",
        ),
        "kotlinc_opts": attr.string_list(
            doc = "Extra kotlinc compiler options.",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Runtime data dependencies.",
        ),
    },
    toolchains = ["//kotlin:js_toolchain_type"],
    doc = "Links Kotlin JS library and sources into an executable JavaScript application.",
)

kt_js_test = rule(
    implementation = kt_js_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
        ),
        "deps": attr.label_list(),
        "module_name": attr.string(),
        "main": attr.string(
            default = "call",
            values = ["call", "noCall"],
        ),
        "target": attr.string(
            default = "es2015",
            values = ["es5", "es2015"],
        ),
        "compose_enabled": attr.bool(
            default = False,
        ),
        "compose_runtime_klibs": attr.label_list(
            allow_files = True,
        ),
        "compose_runtime_assets": attr.label_list(
            allow_files = True,
        ),
        "kotlinc_opts": attr.string_list(),
        "data": attr.label_list(
            allow_files = True,
        ),
    },
    toolchains = ["//kotlin:js_toolchain_type"],
    doc = "Runs Kotlin JS tests using Node.js.",
)

def kt_js_preview(
        name,
        main_fun,
        deps = [],
        srcs = [],
        title = "",
        compose_runtime_klibs = [],
        compose_runtime_assets = [],
        kotlinc_opts = [],
        **kwargs):
    """Package a Compose Kotlin/JS app and its Skiko Wasm runtime into one HTML.

    Args:
        name: Target name; produces <name>.html.
        main_fun: Fully qualified @Composable function callable without arguments.
        deps: kt_js_library targets containing the app and its dependencies.
        srcs: Optional additional Kotlin sources.
        title: HTML page title, defaulting to name.
        compose_runtime_klibs: Overrides for the JS toolchain's Compose KLIBs.
        compose_runtime_assets: Overrides for the JS toolchain's runtime assets.
        kotlinc_opts: Additional Kotlin compiler options.
        **kwargs: Common attributes such as visibility, tags, and testonly.
    """
    internal = {
        "visibility": ["//visibility:private"],
        "tags": kwargs.get("tags", []) + ["manual"],
        "testonly": kwargs.get("testonly", False),
    }
    kt_js_preview_entry(
        name = name + "_entry",
        main_fun = main_fun,
        **internal
    )
    kt_js_binary(
        name = name + "_app",
        srcs = srcs + [":" + name + "_entry"],
        deps = deps,
        compose_enabled = True,
        compose_runtime_klibs = compose_runtime_klibs,
        compose_runtime_assets = compose_runtime_assets,
        kotlinc_opts = kotlinc_opts,
        **internal
    )
    kt_js_preview_html(
        name = name,
        app = ":" + name + "_app",
        title = title,
        **kwargs
    )
