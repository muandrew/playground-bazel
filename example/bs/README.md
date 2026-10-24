# Compose Multiplatform bottom-sheet workspace

This directory is a standalone Bazel workspace. Run every command from this
directory, not from the repository root.

It demonstrates consuming this repository's Kotlin Multiplatform rules as an
external dependency: [`MODULE.bazel`](MODULE.bazel) fetches the SHA-verified
archive for commit `e2834f3`. The workspace does not use a local
path override or any dependency repository from its parent checkout.

The sample pins Bazel 9.0.0, Compose Multiplatform 1.12.0 (Material 3
1.12.0-alpha03, Skiko 0.150.1), and Kotlin 2.4.21. The JavaScript runtime
uses `kotlinx-coroutines` 1.10.2 because Compose 1.12's original 1.9.0 KLIB
is not link-compatible with Kotlin 2.4's standard library.

Use Bazelisk and Java 17 or later. Python 3 serves the browser build. The web
target compiles Kotlin/JS and renders Compose UI to an HTML canvas via Skiko's
WebAssembly runtime; no Gradle or npm install is required.

```sh
cd example/bs
bazel build //:web //:zip //:desktop
bazel run //:desktop
```

Build the Android APK (with the Android SDK configured for Bazel):

```sh
bazel build //:android
```

The debug APK is `bazel-bin/android/android_app.apk`. It supports Android API
24 and later and compiles the shared source against Android Compose AARs rather
than desktop Compose jars.

Serve the browser app at `http://localhost:8086`:

```sh
bazel run //:serve
```

Pass another port with `bazel run //:serve -- 8090`. The server binds to
loopback and cleans its temporary staging directory on exit.

`bazel build //:zip` creates `bazel-bin/web/zip.zip`, ready to extract into a
static host's document root. The browser example keeps its hand-authored
`web/index.html`; both `//:serve` and `//:zip` consume that page together with
the `kt_js_binary` output files.

The fetched prior revision predates the custom rule's test metadata, so the
state test is built with `bazel build //:test`; its executable can be invoked
from `bazel-bin/shared/sheet_state_test` when Node.js is available.

In the browser, exercise the **Hidden**, **Peek**, **Compact**, and **Full**
anchors; drag between detents, dismiss with the scrim, and resize the viewport.
See [the sheet specification](shared/SPEC.md) for the interaction details.
