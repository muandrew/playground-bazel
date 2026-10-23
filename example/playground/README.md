# Compose playground

Run the local preview from the repository root:

```sh
bazel run //example/playground:serve
```

Open http://localhost:8085. Override the target's default port at runtime:

```sh
bazel run //example/playground:serve -- -p 9000
```

Build a static website directory or a ZIP archive suitable for extracting into a
static server's document root:

```sh
bazel build //example/playground:preview
bazel build //example/playground:zip
# bazel-bin/example/playground/preview_files/index.html
# bazel-bin/example/playground/zip.zip
```

`ktx_js_preview_binary` takes `deps` containing `kt_js_library` targets and a
`main_fun` with the fully qualified name of a public `@Composable` function
callable without arguments. It emits `index.html`, the linked Kotlin module, and
the JavaScript and WebAssembly runtime files needed by the browser. Keep the
relative paths intact when copying the output files. The `StaticFilesInfo`
provider (exported from `//kotlin:defs.bzl`) carries that website layout to
generic file consumers.

`ktx_js_preview_binary` replaces the older single-HTML `ktx_js_preview` API;
load the new macro name when migrating an existing target.

Both generic consumers are loaded from `//kotlin:defs.bzl` (or
`@rules_kotlin_multiplatform//kotlin:defs.bzl` in a consuming module):

* `ktx_simple_http(name = "serve", deps = [":preview"])` serves website files
  on localhost; pass `-p PORT` or `--port PORT` to change the default port.
  Existing `srcs = [...]` use remains supported.
* `ktx_zip(name = "zip", deps = [":preview"])` creates a deterministic ZIP
  rooted at `index.html`, with no Bazel workspace paths in the archive.

The build tools and local server require Python 3 on `PATH`.
