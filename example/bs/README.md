# Compose Multiplatform bottom-sheet workspace

This directory is a standalone Bazel workspace. Run every command from this
directory, not from the repository root.

It demonstrates consuming this repository's Kotlin Multiplatform rules as an
external dependency: [`MODULE.bazel`](MODULE.bazel) fetches the SHA-verified
archive for commit `62c77794e99abbe66ba8e0619529c308d1b3e485`, the revision
immediately before this example was added. The workspace does not use a local
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
bazel build //:web //:desktop
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

The fetched prior revision predates the custom rule's test metadata, so the
state test is built with `bazel build //:test`; its executable can be invoked
from `bazel-bin/shared/sheet_state_test` when Node.js is available.

In the browser, exercise the **Hidden**, **Peek**, **Compact**, and **Full**
anchors; drag between detents, dismiss with the scrim, and resize the viewport.
See [the sheet specification](shared/SPEC.md) for the interaction details.
