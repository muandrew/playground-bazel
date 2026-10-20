"""Starlark implementation of Kotlin Multiplatform rules (JS, Wasm, Native)."""

load(":providers.bzl", "KtJsInfo", "KtNativeInfo", "KtWasmInfo")

def _kt_compile_klib_action(
        ctx,
        toolchain,
        srcs,
        deps,
        module_name,
        output_klib,
        backend = "js",
        compose_enabled = False,
        kotlinc_opts = []):
    direct_klibs = []
    transitive_depsets = []

    for dep in deps:
        if backend == "wasm" and KtWasmInfo in dep:
            direct_klibs.append(dep[KtWasmInfo].klib)
            transitive_depsets.append(dep[KtWasmInfo].transitive_klibs)
        elif KtJsInfo in dep:
            direct_klibs.append(dep[KtJsInfo].klib)
            transitive_depsets.append(dep[KtJsInfo].transitive_klibs)

    args = ctx.actions.args()
    args.use_param_file("@%s", use_always = False)
    args.add("compile-klib")
    args.add("--output", output_klib.path)
    args.add("--module-name", module_name)
    args.add("--compiler-jar", toolchain.compiler_jar.path)
    args.add("--backend", backend)

    extra_klibs = []
    plugin_inputs = []
    if compose_enabled:
        if toolchain.compose_plugin_jar:
            args.add("--compose-plugin", toolchain.compose_plugin_jar.path)
            plugin_inputs.append(toolchain.compose_plugin_jar)
        if hasattr(toolchain, "compose_runtime_klibs") and toolchain.compose_runtime_klibs:
            extra_klibs.extend(toolchain.compose_runtime_klibs)

    # Toolchain stdlib klib + compose runtime klibs
    stdlib = toolchain.stdlib_klib
    all_klibs = depset(
        direct = direct_klibs + ([stdlib] if stdlib else []) + extra_klibs,
        transitive = transitive_depsets,
    )

    for klib in all_klibs.to_list():
        args.add("--libraries", klib.path)

    for opt in kotlinc_opts:
        args.add("--kotlinc-opts=" + opt)

    if srcs:
        args.add("--srcs")
        for src in srcs:
            args.add(src.path)

    inputs = depset(
        direct = srcs + [toolchain.compiler_jar] + plugin_inputs,
        transitive = [all_klibs],
    )

    ctx.actions.run(
        mnemonic = "KotlincCompileKlib",
        progress_message = "Compiling Kotlin %s klib: %s" % (backend.upper(), module_name),
        executable = toolchain.runner,
        arguments = [args],
        inputs = inputs,
        outputs = [output_klib],
    )

    return all_klibs, direct_klibs

def kt_js_library_impl(ctx):
    toolchain = ctx.toolchains["//kotlin:js_toolchain_type"]
    module_name = ctx.attr.module_name or ctx.label.name
    output_klib = ctx.actions.declare_file(ctx.label.name + ".klib")

    all_klibs, direct_klibs = _kt_compile_klib_action(
        ctx = ctx,
        toolchain = toolchain,
        srcs = ctx.files.srcs,
        deps = ctx.attr.deps,
        module_name = module_name,
        output_klib = output_klib,
        backend = "js",
        compose_enabled = ctx.attr.compose_enabled,
        kotlinc_opts = ctx.attr.kotlinc_opts,
    )

    return [
        DefaultInfo(files = depset([output_klib])),
        KtJsInfo(
            klib = output_klib,
            transitive_klibs = all_klibs,
            direct_klibs = direct_klibs,
            module_name = module_name,
        ),
    ]

def kt_js_binary_impl(ctx):
    toolchain = ctx.toolchains["//kotlin:js_toolchain_type"]
    module_name = ctx.attr.module_name or ctx.label.name
    output_js = ctx.actions.declare_file(ctx.label.name + "_files/" + module_name + ".mjs")
    output_executable = ctx.actions.declare_file(ctx.label.name)

    direct_klibs = []
    transitive_depsets = []

    for dep in ctx.attr.deps:
        if KtJsInfo in dep:
            direct_klibs.append(dep[KtJsInfo].klib)
            transitive_depsets.append(dep[KtJsInfo].transitive_klibs)

    args = ctx.actions.args()
    args.use_param_file("@%s", use_always = False)
    args.add("link-binary")
    args.add("--output-js", output_js.path)
    args.add("--output-executable", output_executable.path)
    args.add("--runfile-js", ctx.workspace_name + "/" + output_js.short_path)
    args.add("--module-name", module_name)
    args.add("--compiler-jar", toolchain.compiler_jar.path)
    args.add("--backend", "js")
    args.add("--main", ctx.attr.main)
    args.add("--target", ctx.attr.target)

    extra_klibs = []
    extra_assets = []
    plugin_inputs = []
    if ctx.attr.compose_enabled:
        if toolchain.compose_plugin_jar:
            args.add("--compose-plugin", toolchain.compose_plugin_jar.path)
            plugin_inputs.append(toolchain.compose_plugin_jar)
        if hasattr(toolchain, "compose_runtime_klibs") and toolchain.compose_runtime_klibs:
            extra_klibs.extend(toolchain.compose_runtime_klibs)
        if hasattr(toolchain, "compose_runtime_assets") and toolchain.compose_runtime_assets:
            extra_assets.extend(toolchain.compose_runtime_assets)

    stdlib = toolchain.stdlib_klib
    all_klibs = depset(
        direct = direct_klibs + ([stdlib] if stdlib else []) + extra_klibs,
        transitive = transitive_depsets,
    )

    for klib in all_klibs.to_list():
        args.add("--libraries", klib.path)

    for opt in ctx.attr.kotlinc_opts:
        args.add("--kotlinc-opts=" + opt)

    if ctx.files.srcs:
        args.add("--srcs")
        for src in ctx.files.srcs:
            args.add(src.path)

    inputs = depset(
        direct = ctx.files.srcs + [toolchain.compiler_jar] + plugin_inputs,
        transitive = [all_klibs],
    )

    outputs = [output_js, output_executable]
    # Each runtime file is a declared output with an explicit source input. Keep
    # npm package paths intact so generated bare imports resolve in Node and can
    # be mapped by the browser's import map.
    asset_paths = {}
    for asset in extra_assets:
        marker = "node_modules/"
        marker_index = asset.short_path.find(marker)
        relative_path = asset.short_path[marker_index:] if marker_index >= 0 else asset.basename
        if relative_path in asset_paths:
            fail("Duplicate Kotlin JS runtime asset: " + relative_path)
        asset_paths[relative_path] = True
        output_asset = ctx.actions.declare_file(ctx.label.name + "_files/" + relative_path)
        ctx.actions.symlink(output = output_asset, target_file = asset)
        outputs.append(output_asset)

    ctx.actions.run(
        mnemonic = "KotlincLinkJs",
        progress_message = "Linking Kotlin JS binary: %s" % module_name,
        executable = toolchain.runner,
        arguments = [args],
        inputs = inputs,
        outputs = [output_js, output_executable],
    )

    runfiles = ctx.runfiles(files = outputs + ctx.files.data)
    return [
        DefaultInfo(
            executable = output_executable,
            files = depset(outputs),
            runfiles = runfiles,
        ),
        KtJsInfo(
            klib = None,
            transitive_klibs = all_klibs,
            direct_klibs = direct_klibs,
            module_name = module_name,
        ),
    ]

def kt_js_test_impl(ctx):
    # Tests are binaries that run and verify output
    binary_res = kt_js_binary_impl(ctx)
    return binary_res

def kt_wasm_library_impl(ctx):
    toolchain = ctx.toolchains["//kotlin:wasm_toolchain_type"]
    module_name = ctx.attr.module_name or ctx.label.name
    output_klib = ctx.actions.declare_file(ctx.label.name + ".klib")

    all_klibs, direct_klibs = _kt_compile_klib_action(
        ctx = ctx,
        toolchain = toolchain,
        srcs = ctx.files.srcs,
        deps = ctx.attr.deps,
        module_name = module_name,
        output_klib = output_klib,
        backend = "wasm",
        compose_enabled = ctx.attr.compose_enabled,
        kotlinc_opts = ctx.attr.kotlinc_opts,
    )

    return [
        DefaultInfo(files = depset([output_klib])),
        KtWasmInfo(
            klib = output_klib,
            transitive_klibs = all_klibs,
            direct_klibs = direct_klibs,
            module_name = module_name,
        ),
    ]

def kt_wasm_binary_impl(ctx):
    toolchain = ctx.toolchains["//kotlin:wasm_toolchain_type"]
    module_name = ctx.attr.module_name or ctx.label.name
    output_js = ctx.actions.declare_file(ctx.label.name + ".js")
    output_wasm = ctx.actions.declare_file(ctx.label.name + ".wasm")
    output_executable = ctx.actions.declare_file(ctx.label.name)

    direct_klibs = []
    transitive_depsets = []

    for dep in ctx.attr.deps:
        if KtWasmInfo in dep:
            direct_klibs.append(dep[KtWasmInfo].klib)
            transitive_depsets.append(dep[KtWasmInfo].transitive_klibs)

    stdlib = toolchain.stdlib_klib
    all_klibs = depset(
        direct = direct_klibs + ([stdlib] if stdlib else []),
        transitive = transitive_depsets,
    )

    args = ctx.actions.args()
    args.use_param_file("@%s", use_always = False)
    args.add("link-binary")
    args.add("--output-js", output_js.path)
    args.add("--output-wasm", output_wasm.path)
    args.add("--output-executable", output_executable.path)
    args.add("--module-name", module_name)
    args.add("--compiler-jar", toolchain.compiler_jar.path)
    args.add("--backend", "wasm")
    args.add("--main", ctx.attr.main)
    args.add("--target", ctx.attr.target)

    for klib in all_klibs.to_list():
        args.add("--libraries", klib.path)

    plugin_inputs = []
    if ctx.attr.compose_enabled and toolchain.compose_plugin_jar:
        args.add("--compose-plugin", toolchain.compose_plugin_jar.path)
        plugin_inputs.append(toolchain.compose_plugin_jar)

    for opt in ctx.attr.kotlinc_opts:
        args.add("--kotlinc-opts=" + opt)

    if ctx.files.srcs:
        args.add("--srcs")
        for src in ctx.files.srcs:
            args.add(src.path)

    inputs = depset(
        direct = ctx.files.srcs + [toolchain.compiler_jar] + plugin_inputs,
        transitive = [all_klibs],
    )

    ctx.actions.run(
        mnemonic = "KotlincLinkWasm",
        progress_message = "Linking Kotlin Wasm binary: %s" % module_name,
        executable = toolchain.runner,
        arguments = [args],
        inputs = inputs,
        outputs = [output_js, output_wasm, output_executable],
    )

    runfiles = ctx.runfiles(files = [output_js, output_wasm] + ctx.files.data)
    return [
        DefaultInfo(
            executable = output_executable,
            files = depset([output_js, output_wasm, output_executable]),
            runfiles = runfiles,
        ),
        KtWasmInfo(
            klib = None,
            transitive_klibs = all_klibs,
            direct_klibs = direct_klibs,
            module_name = module_name,
        ),
    ]

def kt_native_library_impl(ctx):
    # Starlark rule stub for future kt_native_library expansion
    module_name = ctx.attr.module_name or ctx.label.name
    output_klib = ctx.actions.declare_file(ctx.label.name + ".klib")
    ctx.actions.write(
        output = output_klib,
        content = "KLIB stub for %s" % module_name,
    )
    return [
        DefaultInfo(files = depset([output_klib])),
        KtNativeInfo(
            klib = output_klib,
            transitive_klibs = depset([output_klib]),
            direct_klibs = [output_klib],
            module_name = module_name,
        ),
    ]

def kt_native_binary_impl(ctx):
    module_name = ctx.attr.module_name or ctx.label.name
    output_bin = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(
        output = output_bin,
        content = "#!/bin/sh\necho 'Native binary stub for %s'\n" % module_name,
        is_executable = True,
    )
    return [
        DefaultInfo(executable = output_bin),
    ]
