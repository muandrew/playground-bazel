"""Toolchain definitions for Kotlin Multiplatform (JS, Wasm, Native)."""

def _kt_js_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        compiler_jar = ctx.file.compiler_jar,
        stdlib_klib = ctx.file.stdlib_klib,
        test_klib = ctx.file.test_klib,
        compose_plugin_jar = ctx.file.compose_plugin_jar,
        compose_runtime_klibs = ctx.files.compose_runtime_klibs,
        target_version = ctx.attr.target_version,
        runner = ctx.executable._runner,
    )
    return [toolchain_info]

kt_js_toolchain = rule(
    implementation = _kt_js_toolchain_impl,
    attrs = {
        "compiler_jar": attr.label(
            mandatory = True,
            allow_single_file = [".jar"],
            doc = "The Kotlin compiler JAR (kotlinc/lib/kotlin-compiler.jar).",
        ),
        "stdlib_klib": attr.label(
            mandatory = True,
            allow_single_file = [".klib"],
            doc = "The Kotlin JS stdlib klib (kotlinc/lib/kotlin-stdlib-js.klib).",
        ),
        "test_klib": attr.label(
            mandatory = False,
            allow_single_file = [".klib"],
            doc = "The Kotlin JS test klib (kotlinc/lib/kotlin-test-js.klib).",
        ),
        "compose_plugin_jar": attr.label(
            mandatory = False,
            allow_single_file = [".jar"],
            doc = "Compose Multiplatform compiler plugin JAR.",
        ),
        "compose_runtime_klibs": attr.label_list(
            allow_files = True,
            doc = "Compose runtime klibs required when compose_enabled is True.",
        ),
        "target_version": attr.string(
            default = "2.3.21",
            doc = "Kotlin language and compiler version.",
        ),
        "_runner": attr.label(
            default = Label("//kotlin/internal:runner"),
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Toolchain configuration for Kotlin JS rules.",
)

def _kt_wasm_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        compiler_jar = ctx.file.compiler_jar,
        stdlib_klib = ctx.file.stdlib_klib,
        test_klib = ctx.file.test_klib,
        compose_plugin_jar = ctx.file.compose_plugin_jar,
        target_version = ctx.attr.target_version,
        runner = ctx.executable._runner,
    )
    return [toolchain_info]

kt_wasm_toolchain = rule(
    implementation = _kt_wasm_toolchain_impl,
    attrs = {
        "compiler_jar": attr.label(
            mandatory = True,
            allow_single_file = [".jar"],
        ),
        "stdlib_klib": attr.label(
            mandatory = False,
            allow_single_file = [".klib"],
        ),
        "test_klib": attr.label(
            mandatory = False,
            allow_single_file = [".klib"],
        ),
        "compose_plugin_jar": attr.label(
            mandatory = False,
            allow_single_file = [".jar"],
        ),
        "target_version": attr.string(
            default = "2.3.21",
        ),
        "_runner": attr.label(
            default = Label("//kotlin/internal:runner"),
            executable = True,
            cfg = "exec",
        ),
    },
    doc = "Toolchain configuration for Kotlin Wasm rules.",
)

def _kt_native_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        target_version = ctx.attr.target_version,
    )
    return [toolchain_info]

kt_native_toolchain = rule(
    implementation = _kt_native_toolchain_impl,
    attrs = {
        "target_version": attr.string(
            default = "2.3.21",
        ),
    },
    doc = "Toolchain configuration for Kotlin Native rules.",
)
