# Compose Multiplatform bottom sheet example

This example runs the shared multi-anchor music-player sheet on Android, the
web, and JVM desktop. The web target compiles Kotlin/JS and renders Compose UI
to an HTML canvas through Skiko's WebAssembly runtime using ComposeViewport. It
uses Compose Multiplatform 1.12.0 with Bazel and the repository's custom
Kotlin/JS rules; it does not rely on a Gradle placeholder bundle.

The compiler is Kotlin 2.3.21, Material 3 is 1.12.0-alpha03, and Skiko is
0.150.1. Material 3 has its own release numbering. The existing `example/cmp`
keeps its Compose 1.9.3 dependencies in separate repositories.

Use Bazelisk and Java 17 or later. Python 3 serves the browser build. The JS
state test also needs Node.js. No Gradle or npm install is needed. The default
`.bazelversion` selects Bazel 9; Bazel 8.4.2 can be selected explicitly with
`USE_BAZEL_VERSION=8.4.2` before any command.

Build the web and desktop apps with the default Bazel version:

```sh
bazel build //example/bs:web //example/bs:desktop
```

Run the desktop app with `bazel run //example/bs:desktop`.

Build the Android APK (requires the Android SDK configured for Bazel):

```sh
bazel build //example/bs:android
```

The signed debug APK is `bazel-bin/example/bs/android/android_app.apk`.
It supports Android API 24 and later. The Android target compiles the shared
sources against Android AARs rather than desktop Compose jars.

Serve the browser app at `http://localhost:8086`:

```sh
bazel run //example/bs:serve
```

An optional port can be supplied, for example
`bazel run //example/bs:serve -- 8090`. The server binds to loopback, assembles
the HTML, JavaScript modules, npm dependencies, and Skiko assets in a temporary
directory, then removes that directory when stopped. Startup and runtime errors
are shown on the page.

Run the shared Kotlin/JS state tests:

```sh
bazel test //example/bs:web_test --test_output=all
```

To use Bazel 8.4.2 instead, prefix each command, for example:

```sh
USE_BAZEL_VERSION=8.4.2 bazel build //example/bs:web //example/bs:desktop
USE_BAZEL_VERSION=8.4.2 bazel build //example/bs:android
USE_BAZEL_VERSION=8.4.2 bazel run //example/bs:serve
USE_BAZEL_VERSION=8.4.2 bazel test //example/bs:web_test --test_output=all
```

In the browser, exercise the **Hidden**, **Peek**, **Compact**, and **Full**
anchors using the controls, drag the sheet between detents, tap the scrim to
dismiss it, and scroll the full track list while the sheet is expanded. Resize
the browser and confirm the sheet remains usable. The Node.js state test does
not verify canvas rendering, pointer input, nested scrolling, or resizing;
those require a browser check. A browser with JavaScript, WebAssembly, and
WebGL support is required.

Both Bazel versions use the same `kt_js_library`, `kt_js_binary`, and `kt_js_test`
rules. Their optional `compose_runtime_klibs` and `compose_runtime_assets`
attributes select this example's 1.12 graph instead of the default 1.9 graph.
Use the same runtime graph throughout a library's dependency chain.

Compose 1.12's JS libraries need the DOM declarations from `kotlinx-browser`.
Loading an additional `kotlin-dom-api-compat` KLIB introduces conflicting DOM
definitions. A small [JS-only adapter](shared/src/jsMain/kotlin/org/w3c/dom/events/EventListenerCompat.kt)
provides the legacy `EventListener(handler)` factory still referenced by
Foundation 1.12. Strict link checks and the state test cover this adapter.

See [the sheet specification](shared/SPEC.md) for detents, styling, scrolling,
and dismissal behavior inherited from `prototype/cmp`.

Verified on macOS arm64 with these versions:

| Bazel | Web build | Desktop build | Android APK | Sheet and counter state tests |
| --- | --- | --- | --- | --- |
| 8.4.2 | Pass | Pass | Pass | Pass |
| 9.0.0 | Pass | Pass | Pass | Pass |

The Bazel 9 browser build was also checked at 1280×720 and 420×800: all four
detents, scrim and drag dismissal, reopening, playback controls, scrolling to
the end of the full content, nested downward dragging, and viewport resizing
worked without browser console errors. APK assembly and its merged manifest
were checked; Android device/emulator interaction was not exercised.
