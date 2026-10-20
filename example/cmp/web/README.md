# Compose Multiplatform web example

This example renders the shared Material 3 counter button onto a canvas using
Compose Multiplatform 1.9.3 and Material 3 1.9.0. Kotlin/JS runs the
application; Skiko 0.9.22.2 supplies the WebAssembly graphics runtime. The Kotlin
compiler is 2.3.21. This example uses the Kotlin/JS canvas target and is a
standalone Bazel workspace rooted at `example/cmp`.

The workspace pins Bazel 8.4.2. It fetches the Kotlin Multiplatform rules from
this repository at commit `62c77794e99abbe66ba8e0619529c308d1b3e485` using a
SHA-verified archive, then resolves Kotlin 2.3.21 and its own Compose 1.9.x
dependency graph. Run commands from `example/cmp`. Building and serving require
JDK 17 or later and Python 3. Node.js is also required for the state test. No
Gradle or npm install is needed.

Start the server:

```sh
bazel run //:serve
```

Open `http://localhost:8085`. An optional explicit port can be supplied with
`bazel run //:serve -- 8090`. The server binds to the loopback
interface and exits with an error if that port is already in use.

The page should show a dark canvas and a **Count: 0** button. Each click should
increment the button label and the status below it. Refreshing should reset the
count. The page displays loading and startup errors so a runtime failure is
visible. The server assembles the HTML, JavaScript modules, npm dependencies, and
Skiko assets in a temporary directory and removes it when stopped.

Run the shared state assertions under Node.js:

```sh
bazel test //web:counter_state_test --test_output=all
```

The `//web:web_test` label is a suite containing that test.
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
