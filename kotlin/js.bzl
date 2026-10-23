"""Kotlin JS rules and static-file Compose application previews."""

load("//kotlin/internal:compile.bzl", "kt_js_binary_impl", "kt_js_library_impl", "kt_js_test_impl")
load("//kotlin/internal:preview.bzl", "ktx_js_preview_entry", _preview_binary_rule = "preview_binary_rule")
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

def ktx_js_preview_binary(
        name,
        main_fun,
        deps = [],
        srcs = [],
        title = "",
        compose_runtime_klibs = [],
        compose_runtime_assets = [],
        kotlinc_opts = [],
        **kwargs):
    """Build a Compose Kotlin/JS app as a set of website files.

    Args:
        name: Target name; provides index.html and runtime files through StaticFilesInfo.
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
    ktx_js_preview_entry(
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
        module_name = name,
        **internal
    )
    _preview_binary_rule(
        name = name,
        app = ":" + name + "_app",
        module_name = name,
        title = title,
        **kwargs
    )
