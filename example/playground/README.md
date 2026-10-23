# Compose playground

Run from the repository root:

```sh
bazel run //example/playground:serve
```

Open http://localhost:8085. Override the target's default port at runtime:

```sh
bazel run //example/playground:serve -- -p 9000
```

Build the standalone HTML file:

```sh
bazel build //example/playground:preview
# bazel-bin/example/playground/preview.html
```

`kt_js_preview` takes `deps` containing `kt_js_library` targets and a `main_fun`
with the fully qualified name of a public `@Composable` function callable without
arguments. It generates the `ComposeViewport` entry point and embeds the linked
Kotlin/JS app, JavaScript dependencies, and Skiko WebAssembly runtime into one
HTML file. The file can be copied on its own; it needs no companion runtime files
or CDN. This uses the existing Kotlin/JS Compose Canvas toolchain with Wasm Skiko.

Both convenience rules can be loaded from `//kotlin:defs.bzl` (or
`@rules_kotlin_multiplatform//kotlin:defs.bzl` in a consuming module).
`simple_http(srcs = [...], port = 8085)` serves declared files on localhost and
accepts `-p PORT` or `--port PORT`. Files from its package retain package-relative
paths; other files retain repository-relative paths. A sole HTML input is also
served at `/`. The build tools and server require Python 3 on `PATH`.
