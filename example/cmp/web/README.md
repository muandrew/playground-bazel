# Compose Multiplatform web example

This example renders the shared Material 3 counter button onto a canvas using
Compose Multiplatform 1.9.3 and Material 3 1.9.0 on Bazel 8 or 9. Kotlin/JS runs the
application; Skiko 0.9.22.2 supplies the WebAssembly graphics runtime. The Kotlin
compiler is 2.3.21. This example uses the Kotlin/JS canvas target.

Use Bazelisk to select Bazel 9, pinned in `.bazelversion`. To use Bazel 8.4.2,
prefix commands with `USE_BAZEL_VERSION=8.4.2`. Building and
serving require JDK 17 or later (`java`) and Python 3 on your PATH. Node.js is
also required for the state test below. No Gradle or npm install is needed.

Start the server:

```sh
bazel run //example/cmp/web:serve
```

Open `http://localhost:8085`. An optional explicit port can be supplied with
`bazel run //example/cmp/web:serve -- 8090`. The server binds to the loopback
interface and exits with an error if that port is already in use.

The page should show a dark canvas and a **Count: 0** button. Each click should
increment the button label and the status below it. Refreshing should reset the
count. The page displays loading and startup errors so a runtime failure is
visible. The server assembles the HTML, JavaScript modules, npm dependencies, and
Skiko assets in a temporary directory and removes it when stopped.

Run the shared state assertions under Node.js:

```sh
bazel test //example/cmp/web:counter_state_test --test_output=all
```

The original `//example/cmp/web:web_test` label is a suite containing that test.
These assertions exercise the shared counter state. To verify rendering and input,
also open the served page in a browser and perform the clicks described above.
The browser must support JavaScript, WebAssembly, and WebGL.

The previous dependency graph mixed Compose 1.12 alpha libraries with a 1.9 label
and omitted a required AndroidX collection runtime library. In a browser,
`Recomposer` failed to link `MutableScatterMap` before the UI could render. The
fixed graph pins Compose 1.9 releases and their runtime dependencies together.

Browser acceptance check: verify the Compose title and counter are visible,
click the rendered button twice to change **Count: 0 → Count: 1 → Count: 2**,
and confirm the browser console has no errors. A passing Node.js state test alone
does not establish that rendering or browser input works.
