"""Kotlin Wasm rules: kt_wasm_library, kt_wasm_binary, kt_wasm_test."""

load("//kotlin/internal:compile.bzl", "kt_wasm_binary_impl", "kt_wasm_library_impl")
load("//kotlin/internal:providers.bzl", "KtWasmInfo")

kt_wasm_library = rule(
    implementation = kt_wasm_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
            doc = "Kotlin source files.",
        ),
        "deps": attr.label_list(
            doc = "Kotlin Wasm dependencies providing KtWasmInfo.",
        ),
        "module_name": attr.string(
            doc = "Kotlin Wasm module name (defaults to target name).",
        ),
        "compose_enabled": attr.bool(
            default = False,
            doc = "Whether to enable Compose Multiplatform compiler plugin.",
        ),
        "kotlinc_opts": attr.string_list(
            doc = "Extra kotlinc compiler options.",
        ),
    },
    toolchains = ["//kotlin:wasm_toolchain_type"],
    doc = "Compiles Kotlin source files into a Wasm klib.",
)

kt_wasm_binary = rule(
    implementation = kt_wasm_binary_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
            doc = "Kotlin source files.",
        ),
        "deps": attr.label_list(
            doc = "Kotlin Wasm dependencies.",
        ),
        "module_name": attr.string(
            doc = "Kotlin Wasm module name (defaults to target name).",
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
    toolchains = ["//kotlin:wasm_toolchain_type"],
    doc = "Links Kotlin Wasm library and sources into an executable WebAssembly application.",
)
