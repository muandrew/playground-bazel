"""Kotlin Native rules: kt_native_library, kt_native_binary, kt_native_test."""

load("//kotlin/internal:compile.bzl", "kt_native_binary_impl", "kt_native_library_impl")
load("//kotlin/internal:providers.bzl", "KtNativeInfo")

kt_native_library = rule(
    implementation = kt_native_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
            doc = "Kotlin source files.",
        ),
        "deps": attr.label_list(
            doc = "Kotlin Native dependencies.",
        ),
        "module_name": attr.string(
            doc = "Module name.",
        ),
        "kotlinc_opts": attr.string_list(),
    },
    doc = "Compiles Kotlin source files into a Native klib.",
)

kt_native_binary = rule(
    implementation = kt_native_binary_impl,
    executable = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
        ),
        "deps": attr.label_list(),
        "module_name": attr.string(),
        "kotlinc_opts": attr.string_list(),
    },
    doc = "Links Kotlin Native sources into an executable binary.",
)

kt_native_test = rule(
    implementation = kt_native_binary_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".kt"],
        ),
        "deps": attr.label_list(),
        "module_name": attr.string(),
    },
    doc = "Runs Kotlin Native tests.",
)
