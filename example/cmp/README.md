# Compose counter example workspace

This directory is a standalone Bazel workspace. It pins Bazel 8.4.2,
Kotlin 2.3.21, Compose Multiplatform 1.9.3, Material 3 1.9.0, and Skiko
0.9.22.2.

The workspace fetches the Kotlin Multiplatform rules from this repository at
commit `e2834f3`, using a SHA-verified GitHub
archive. It resolves its own module and Maven dependency locks. Run commands
from this directory with Bazelisk, Java 17 or later, and Python 3 available.

```sh
bazel build //:web //:zip //:desktop //:android
bazel run //:desktop
bazel run //:serve
```

The Android SDK must be configured for the Android target. The browser app is
served at `http://localhost:8085`; see [the web example guide](web/README.md)
for browser behavior and the Kotlin/JS state test command.
