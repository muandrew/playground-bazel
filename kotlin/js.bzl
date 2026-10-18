"""Kotlin JS rules: kt_js_library, kt_js_binary, kt_js_test."""

load("//kotlin/internal:compile.bzl", "kt_js_binary_impl", "kt_js_library_impl", "kt_js_test_impl")
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
        "kotlinc_opts": attr.string_list(),
        "data": attr.label_list(
            allow_files = True,
        ),
    },
    toolchains = ["//kotlin:js_toolchain_type"],
    doc = "Runs Kotlin JS tests using Node.js.",
)
