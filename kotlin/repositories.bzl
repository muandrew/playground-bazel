"""Repository rules for downloading Compose Multiplatform JS/Wasm KLIB artifacts."""

# Resolved from the published jsRuntimeElements variants for Compose 1.9.3
# and Material3 1.9.0. Compose runtime/collection and JetBrains AndroidX KLIBs
# forward to the AndroidX implementations below; both identities are required.
# Keep a single version per KLIB unique_name, including transitive dependencies.
_COMPOSE_JS_KLIBS = [
    ("androidx-annotation-js-1.9.1.klib", "https://dl.google.com/dl/android/maven2/androidx/annotation/annotation-js/1.9.1/annotation-js-1.9.1.klib", "bce021c6476db59d6b82bcb305dafaa8cd6da48a791e7ffb95bd886ae2bfc65f"),
    ("androidx-collection-js-1.5.0.klib", "https://dl.google.com/dl/android/maven2/androidx/collection/collection-js/1.5.0/collection-js-1.5.0.klib", "e73d13acd986d435a87ecff6777f5d004279c03373fcc7dc8ee400ccbd4e7108"),
    ("androidx-runtime-js-1.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-js/1.9.4/runtime-js-1.9.4.klib", "578bfbf883823a0eef42fdae040c0f26fc585df76c1e194f64423a68a6edd5a9"),
    ("androidx-runtime-annotation-js-1.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-annotation-js/1.9.4/runtime-annotation-js-1.9.4.klib", "ad86380ca8ccdc9c0a5f3c213be32a167c2a9cffb74251ea1a194ded7046d4e4"),
    ("androidx-runtime-saveable-js-1.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-saveable-js/1.9.4/runtime-saveable-js-1.9.4.klib", "628ba36371c71215f295313a9dbf6e50b8a8b87ff58c3c83ccff3a9e4abe9051"),
    ("androidx-lifecycle-common-js-2.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-common-js/2.9.4/lifecycle-common-js-2.9.4.klib", "e9c5cdf3debc1f45d67ba8bd38e9bafee7f33d17d3fc51f69891610b97041914"),
    ("androidx-lifecycle-runtime-js-2.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-runtime-js/2.9.4/lifecycle-runtime-js-2.9.4.klib", "a9923ee62bdeb90a87ba1256a458c777d50f37616bf4ebe2f0bda7cc0f553c69"),
    ("androidx-lifecycle-runtime-compose-js-2.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-runtime-compose-js/2.9.4/lifecycle-runtime-compose-js-2.9.4.klib", "bc983add07aebcf5bc1788efbe8bb992929691ec896c090de674ac96a4485ae3"),
    ("androidx-lifecycle-viewmodel-js-2.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-viewmodel-js/2.9.4/lifecycle-viewmodel-js-2.9.4.klib", "d53d3e9a5acb0752f7a8fd6e659ad5d5fe682f07c4cc6e2f337fc08f725ef165"),
    ("androidx-lifecycle-viewmodel-savedstate-js-2.9.4.klib", "https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-viewmodel-savedstate-js/2.9.4/lifecycle-viewmodel-savedstate-js-2.9.4.klib", "a81f0d2901b3c9028b5fc0836b42df69ca81eb6e6ae90499fbc31ae071a330f6"),
    ("androidx-savedstate-js-1.3.3.klib", "https://dl.google.com/dl/android/maven2/androidx/savedstate/savedstate-js/1.3.3/savedstate-js-1.3.3.klib", "6dd5a6c0012f69e10efad4126ac6c4280022d6c408846f1c7118db00bb99eb8e"),
    ("androidx-savedstate-compose-js-1.3.3.klib", "https://dl.google.com/dl/android/maven2/androidx/savedstate/savedstate-compose-js/1.3.3/savedstate-compose-js-1.3.3.klib", "078a8bbf4fff49e579f24e05e3f2c23794fa7d4d8baab9c9484644b9e8a2ff26"),
    ("androidx-lifecycle-common-js-2.9.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-common-js/2.9.6/lifecycle-common-js-2.9.6.klib", "2dce6cff869f0494fd900deda999b3979277a62e1148548729c287bc422515a6"),
    ("androidx-lifecycle-runtime-js-2.9.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-js/2.9.6/lifecycle-runtime-js-2.9.6.klib", "cd1dabf5a515293bd6168d21e34055adafa0590bec9d8f4a891080eeb163fc8f"),
    ("androidx-lifecycle-runtime-compose-js-2.9.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-compose-js/2.9.6/lifecycle-runtime-compose-js-2.9.6.klib", "8c2909947b81441739b10534bb8c84d837b5a040103ed87fe6a8bef03e27cd0e"),
    ("androidx-lifecycle-viewmodel-js-2.9.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-js/2.9.6/lifecycle-viewmodel-js-2.9.6.klib", "6fcb9fa47b271ef276f453b00ad0af8566ff980a3a47f107b16083c80d211ff1"),
    ("androidx-lifecycle-viewmodel-savedstate-js-2.9.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-savedstate-js/2.9.6/lifecycle-viewmodel-savedstate-js-2.9.6.klib", "e4432377ee0059d87cb5809dc2b3d008d332e8f0146a18c00e9fd06356d8df45"),
    ("androidx-savedstate-js-1.3.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/savedstate/savedstate-js/1.3.6/savedstate-js-1.3.6.klib", "02dab63f67b626919b1af4e44cc40716d46b993df4bd8607c33936391e6a5a0a"),
    ("androidx-savedstate-compose-js-1.3.6.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/androidx/savedstate/savedstate-compose-js/1.3.6/savedstate-compose-js-1.3.6.klib", "8f0181b5cde7fc60ea33124f490d54568936bc306a5b034332bff811baf6066d"),
    ("animation-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/animation/animation-js/1.9.3/animation-js-1.9.3.klib", "0a0a97526635de4b39d041b5c55495af5b41874c9ffbe1d5ebd2c8463c726788"),
    ("animation-core-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/animation/animation-core-js/1.9.3/animation-core-js-1.9.3.klib", "4ff645a0035d0d2c32d2c2c40dcbb4dd1728dd6f7371e994533902024596fd39"),
    ("annotation-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/annotation-internal/annotation-js/1.9.3/annotation-js-1.9.3.klib", "72b28610f992e98be38dcc80d25bea296f8a715924a2d69ef4dc6d3dd63e7668"),
    ("collection-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/collection-internal/collection-js/1.9.3/collection-js-1.9.3.klib", "b8c3040e472dce846d774cfc7e29b42ed6c2c86a978f1be90d069682f909eec4"),
    ("foundation-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/foundation/foundation-js/1.9.3/foundation-js-1.9.3.klib", "81b958d7057448b43cb388b88ab7a3b86b05e9f156738833731646fdb3793c89"),
    ("foundation-layout-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/foundation/foundation-layout-js/1.9.3/foundation-layout-js-1.9.3.klib", "dffb97eb6a8ca03632b9319c320117075eeb6c6ddd6a34609e31bdeedf0e8ac1"),
    ("material-ripple-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/material/material-ripple-js/1.9.3/material-ripple-js-1.9.3.klib", "4552f03cffd15d927288ecc98648efd12e2e2262402f126c352148e1962ff52f"),
    ("material3-js-1.9.0.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/material3/material3-js/1.9.0/material3-js-1.9.0.klib", "505ed85ee8ef577b99643bc918214eb9ff47a27df2df5020e682bd1e63d0adb7"),
    ("runtime-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/runtime/runtime-js/1.9.3/runtime-js-1.9.3.klib", "dc98a4bacd2c4e21073db8760285a2376fa8a1f2153ce629ef57edaeccefdcd1"),
    ("runtime-saveable-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/runtime/runtime-saveable-js/1.9.3/runtime-saveable-js-1.9.3.klib", "5f62934db14e93ddb622f6d07ab2bd918da12847cd10b2197903b5999b4a32f9"),
    ("ui-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-js/1.9.3/ui-js-1.9.3.klib", "494767f51221c53d28e5151f215a10c4b09018547055bf4ec1247a05c19768c8"),
    ("ui-backhandler-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-backhandler-js/1.9.3/ui-backhandler-js-1.9.3.klib", "1895b02c457111e3e94ae7a1c153167e39adff197117bcc886c41ed06f32a3b8"),
    ("ui-geometry-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-geometry-js/1.9.3/ui-geometry-js-1.9.3.klib", "9874981795f9a4b76ea3d5753c237d118077f164abde5730077beb4f2333fbaf"),
    ("ui-graphics-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-graphics-js/1.9.3/ui-graphics-js-1.9.3.klib", "436943c2010c8e465e0e224296e0724e7306eec39f80bc8d3d40924025fdcf20"),
    ("ui-text-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-text-js/1.9.3/ui-text-js-1.9.3.klib", "5da6fb1220e6f517376fda71a4d6e6d023e53fc87c0731a55d4f2ea3314a9c83"),
    ("ui-unit-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-unit-js/1.9.3/ui-unit-js-1.9.3.klib", "678ef855ae8f2bf2225d1a588ede2fb89779502683f3e868f13769ec04cbc492"),
    ("ui-util-js-1.9.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-util-js/1.9.3/ui-util-js-1.9.3.klib", "16aab3f690c157a834ef7a3cfbcdc24ed2caa1d1f30f03f07790bed779a9e95d"),
    ("kotlin-dom-api-compat-2.1.21.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-dom-api-compat/2.1.21/kotlin-dom-api-compat-2.1.21.klib", "12346796ff1c7b541b987d31d64d2ca3527b4bc2130daea67146805f44810b09"),
    ("kotlinx-atomicfu-runtime-2.1.21.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlinx-atomicfu-runtime/2.1.21/kotlinx-atomicfu-runtime-2.1.21.klib", "f872d15663d5bb460fe569c9b81e2411d797425ab1cc9814fb239267f6ce6d36"),
    ("atomicfu-js-0.27.0.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/atomicfu-js/0.27.0/atomicfu-js-0.27.0.klib", "21f2ee31b98438bb990f749cd03b4ec66d73823758cd56db36b169edde08c805"),
    ("kotlinx-coroutines-core-js-1.8.1.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-js/1.8.1/kotlinx-coroutines-core-js-1.8.1.klib", "ca57db0daf2d89fa3d42380c5e7820173559e234e16fc298d6962aff14316c0c"),
    ("kotlinx-datetime-js-0.7.1.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-datetime-js/0.7.1/kotlinx-datetime-js-0.7.1.klib", "2c577450040e72437bde31d027745c068cd33745d217495893fb0d84342ad46b"),
    ("kotlinx-serialization-core-js-1.7.3.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-core-js/1.7.3/kotlinx-serialization-core-js-1.7.3.klib", "79fc0b140561bc7a50c0b3979ab4aacac0e8731ffec806b6af24f8d54cdc6347"),
    ("skiko-js-0.9.22.2.klib", "https://repo.maven.apache.org/maven2/org/jetbrains/skiko/skiko-js/0.9.22.2/skiko-js-0.9.22.2.klib", "c6a5ab6bcc29664e13ee301096e8c269b0788937d2d5e63b671048f1dc98a397"),
]

def _compose_ui_js_impl(repository_ctx):
    for out_name, url, sha256 in _COMPOSE_JS_KLIBS:
        repository_ctx.download(
            url = url,
            output = out_name,
            sha256 = sha256,
        )

    repository_ctx.download_and_extract(
        url = "https://repo.maven.apache.org/maven2/org/jetbrains/skiko/skiko-js-wasm-runtime/0.9.22.2/skiko-js-wasm-runtime-0.9.22.2.jar",
        sha256 = "e5b9fb6ec64427d95698bd7acb0d7abe889c3c07fe5d82d1e0098450b084be7d",
    )

    # kotlinx-datetime 0.7.1 declares @js-joda/core 3.2.0 in its JS source set.
    repository_ctx.download_and_extract(
        url = "https://registry.npmjs.org/@js-joda/core/-/core-3.2.0.tgz",
        output = "node_modules/@js-joda/core",
        sha256 = "853990e161b83efc5c38b26e6ad5d88d380803aff8dbed1aedcefda2360f31be",
        stripPrefix = "package",
    )

    repository_ctx.file(
        "BUILD.bazel",
        """package(default_visibility = ["//visibility:public"])

filegroup(
    name = "klibs",
    srcs = glob(["*.klib"]),
)

filegroup(
    name = "skiko_wasm",
    srcs = ["skiko.wasm"],
)

filegroup(
    name = "skiko_mjs",
    srcs = ["skiko.mjs"],
)

filegroup(
    name = "skiko_reexport",
    srcs = ["js-reexport-symbols.mjs"],
)

filegroup(
    name = "node_modules",
    srcs = glob(["node_modules/**"]),
)
""",
    )

compose_ui_js = repository_rule(
    implementation = _compose_ui_js_impl,
    doc = "Downloads Compose Multiplatform JS Canvas/Skiko KLIBs and WebAssembly runtime.",
)


# Resolved from the published JS runtime variants for Compose 1.12.0 and
# Material3 1.12.0-alpha03. Keep each artifact pinned by SHA-256. The JS graph
# uses kotlinx-browser's DOM declarations without a second DOM-compat KLIB;
# the example supplies the legacy EventListener factory required by Compose.
_COMPOSE_BS_JS_KLIBS = [
    ('androidx-annotation-js-1.9.1.klib', 'https://dl.google.com/dl/android/maven2/androidx/annotation/annotation-js/1.9.1/annotation-js-1.9.1.klib', 'bce021c6476db59d6b82bcb305dafaa8cd6da48a791e7ffb95bd886ae2bfc65f'),
    ('androidx-collection-js-1.5.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/collection/collection-js/1.5.0/collection-js-1.5.0.klib', 'e73d13acd986d435a87ecff6777f5d004279c03373fcc7dc8ee400ccbd4e7108'),
    ('androidx-runtime-js-1.12.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-js/1.12.0/runtime-js-1.12.0.klib', 'ee339f2748271af945efa60b6cbe19ef59f6c30cc0b4456a64b8ac3c03aec7ab'),
    ('androidx-runtime-annotation-js-1.12.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-annotation-js/1.12.0/runtime-annotation-js-1.12.0.klib', 'a1f25da7f277f440f70545afce08c712d1c32bccda73bd45bb401915e6953ca1'),
    ('androidx-runtime-retain-js-1.12.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-retain-js/1.12.0/runtime-retain-js-1.12.0.klib', 'a4ac877053d6d9c544de4120e75fc94209e7bd5d5c93ab40e6350e1ba6f50cb6'),
    ('androidx-runtime-saveable-js-1.12.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-saveable-js/1.12.0/runtime-saveable-js-1.12.0.klib', 'e6b19e318090dc3e2ad082524743b94cd289514310fb223a78d9e664cfe06a98'),
    ('androidx-graphics-shapes-js-1.1.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/graphics/graphics-shapes-js/1.1.0/graphics-shapes-js-1.1.0.klib', 'a936cb2a83d5d256b4495bf01fea936a4f194e3117a6c7b816ecec643fc773a8'),
    ('androidx-lifecycle-common-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-common-js/2.11.0/lifecycle-common-js-2.11.0.klib', '26d609cf18d5716ff18aa22289a3aa0f1a4b882a85fbcc913bd760cf6b106aa6'),
    ('androidx-lifecycle-runtime-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-runtime-js/2.11.0/lifecycle-runtime-js-2.11.0.klib', 'a6794025526743ae688d887a511b3d5155cb57a610f47830581e8efd599d1099'),
    ('androidx-lifecycle-runtime-compose-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-runtime-compose-js/2.11.0/lifecycle-runtime-compose-js-2.11.0.klib', 'ca2c00d166e25496b6ec11cedf9a782c488d086939f22b81f244f97750669eba'),
    ('androidx-lifecycle-viewmodel-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-viewmodel-js/2.11.0/lifecycle-viewmodel-js-2.11.0.klib', '2dc987e6e353e02eedfc0c1190498a43fb9e3f09b85b57da9e97ab60e80093f4'),
    ('androidx-lifecycle-viewmodel-compose-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-viewmodel-compose-js/2.11.0/lifecycle-viewmodel-compose-js-2.11.0.klib', '06c91001eeb4a25aed22dca20458b9a5ae41965e27c7ca97e239ac70b18454a0'),
    ('androidx-lifecycle-viewmodel-savedstate-js-2.11.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/lifecycle/lifecycle-viewmodel-savedstate-js/2.11.0/lifecycle-viewmodel-savedstate-js-2.11.0.klib', '182b19c14e1e7ef9eade9d0c6a4bc4277c26b0effe95d5fee8274f3e96e98403'),
    ('androidx-navigationevent-js-1.1.1.klib', 'https://dl.google.com/dl/android/maven2/androidx/navigationevent/navigationevent-js/1.1.1/navigationevent-js-1.1.1.klib', 'd0a0f853867359c9fadc8cd4d7c76b1cb5c65439299d2871d61761ddd5be69a9'),
    ('androidx-navigationevent-compose-js-1.1.1.klib', 'https://dl.google.com/dl/android/maven2/androidx/navigationevent/navigationevent-compose-js/1.1.1/navigationevent-compose-js-1.1.1.klib', 'e5a8a274fd4bbdb07cb3038649fecd1c9daf70e3ddf18b9b500b02002b4220ca'),
    ('androidx-savedstate-js-1.4.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/savedstate/savedstate-js/1.4.0/savedstate-js-1.4.0.klib', 'e32b3fa6fb1691fb482cf7549bab731a722fc6b2d58b35f6607732c8c61af944'),
    ('androidx-savedstate-compose-js-1.4.0.klib', 'https://dl.google.com/dl/android/maven2/androidx/savedstate/savedstate-compose-js/1.4.0/savedstate-compose-js-1.4.0.klib', 'd4c2620ec10df2a434cff0a2361cc2c4137356242bf7de23efd8a919b023a8fb'),
    ('lifecycle-common-js-2.9.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-common-js/2.9.6/lifecycle-common-js-2.9.6.klib', '2dce6cff869f0494fd900deda999b3979277a62e1148548729c287bc422515a6'),
    ('lifecycle-runtime-js-2.9.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-js/2.9.6/lifecycle-runtime-js-2.9.6.klib', 'cd1dabf5a515293bd6168d21e34055adafa0590bec9d8f4a891080eeb163fc8f'),
    ('lifecycle-runtime-compose-js-2.9.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-compose-js/2.9.6/lifecycle-runtime-compose-js-2.9.6.klib', '8c2909947b81441739b10534bb8c84d837b5a040103ed87fe6a8bef03e27cd0e'),
    ('lifecycle-viewmodel-js-2.9.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-js/2.9.6/lifecycle-viewmodel-js-2.9.6.klib', '6fcb9fa47b271ef276f453b00ad0af8566ff980a3a47f107b16083c80d211ff1'),
    ('lifecycle-viewmodel-savedstate-js-2.9.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-savedstate-js/2.9.6/lifecycle-viewmodel-savedstate-js-2.9.6.klib', 'e4432377ee0059d87cb5809dc2b3d008d332e8f0146a18c00e9fd06356d8df45'),
    ('navigationevent-compose-js-1.1.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/navigationevent/navigationevent-compose-js/1.1.0/navigationevent-compose-js-1.1.0.klib', '1015ef6cc1282811dbb0b1ba4800779d5f5fe1e66d7e33f7d3d5c2e3f6e45bd7'),
    ('savedstate-js-1.3.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/savedstate/savedstate-js/1.3.6/savedstate-js-1.3.6.klib', '02dab63f67b626919b1af4e44cc40716d46b993df4bd8607c33936391e6a5a0a'),
    ('savedstate-compose-js-1.3.6.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/androidx/savedstate/savedstate-compose-js/1.3.6/savedstate-compose-js-1.3.6.klib', '8f0181b5cde7fc60ea33124f490d54568936bc306a5b034332bff811baf6066d'),
    ('animation-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/animation/animation-js/1.12.0/animation-js-1.12.0.klib', '57562922e00350b79931bff55b2c80c4716f25e5eacf55eb4a987a1fb9d1f455'),
    ('animation-core-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/animation/animation-core-js/1.12.0/animation-core-js-1.12.0.klib', '2fe3aa4b2dac038131c92819a10fbb8897ec0f88c1e6b1f262f7e516cbeedcb3'),
    ('annotation-js-1.10.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/annotation-internal/annotation-js/1.10.0/annotation-js-1.10.0.klib', '772c19a5e4de38adc073b917464de7696d3eacf69eaf6537524432f3a793c5b1'),
    ('collection-js-1.10.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/collection-internal/collection-js/1.10.0/collection-js-1.10.0.klib', '6fc35c9c4cb507a52ecc41b30b59740de22a30b8b6c37fbba5e0580bf0b44354'),
    ('foundation-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/foundation/foundation-js/1.12.0/foundation-js-1.12.0.klib', '96c50ee931c7400e0b7e219ae57c00ec677318d1965483447480fc8698fca591'),
    ('foundation-layout-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/foundation/foundation-layout-js/1.12.0/foundation-layout-js-1.12.0.klib', '4eff67fc06c01cc0ecd11d5f4423864bd545c1be82abce3333b09d0c32bac5e3'),
    ('material-ripple-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/material/material-ripple-js/1.12.0/material-ripple-js-1.12.0.klib', 'fb3c4f9a8c03812bd1e59e71642c72562a6d50f771dea4359eae9fbc7b5f0a43'),
    ('material3-js-1.12.0-alpha03.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/material3/material3-js/1.12.0-alpha03/material3-js-1.12.0-alpha03.klib', '802e9719444475d1282d7ee138fea8dd4be03231bf682d9e428689e49c686970'),
    ('runtime-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/runtime/runtime-js/1.12.0/runtime-js-1.12.0.klib', 'b128f71d6c5c16627da04b3302fc73b9367f279270d2f385ab6915c8d2f7f6a5'),
    ('runtime-saveable-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/runtime/runtime-saveable-js/1.12.0/runtime-saveable-js-1.12.0.klib', '4c28335ac314c82ff5dfb6f18c5879716f9c2e1b78bde69c6e49416632fccfc3'),
    ('ui-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-js/1.12.0/ui-js-1.12.0.klib', 'b8f060383858e5a233b4b4a15cd942e61c13ccc420b150ab13a0cf91e2172017'),
    ('ui-backhandler-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-backhandler-js/1.12.0/ui-backhandler-js-1.12.0.klib', '41f1b591f2b0196b5626be08656a234cb33d0424b2c640c82bb899e6bdc8591d'),
    ('ui-geometry-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-geometry-js/1.12.0/ui-geometry-js-1.12.0.klib', '435986f077dc2bdce753a11243e215e6fd3e4cd7ce2fc220cc3b97817da342a6'),
    ('ui-graphics-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-graphics-js/1.12.0/ui-graphics-js-1.12.0.klib', 'c21abc46e2509756cb21468ffd2354693ba4134a429ee1a7f69315d1b48da5e7'),
    ('ui-text-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-text-js/1.12.0/ui-text-js-1.12.0.klib', '34da6ae30db9974587fd959d8ccab117924380d33e46923a19f8c171cdd540d9'),
    ('ui-unit-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-unit-js/1.12.0/ui-unit-js-1.12.0.klib', '245083f4ac8ee024d77f9c6388b78aaacbf5621a575d8a5ef8552552fb1b17b1'),
    ('ui-util-js-1.12.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/compose/ui/ui-util-js/1.12.0/ui-util-js-1.12.0.klib', '05fa56adfd3229a044eb346ad67f164e1c262a6fbbb76812fdd9bab55f15a716'),
    # kotlinx-browser carries the DOM declarations expected by the Compose 1.12 JS binaries.
    ('kotlinx-browser-js-0.5.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-browser-js/0.5.0/kotlinx-browser-js-0.5.0.klib', 'e794f4e1b4d40507c3d9e01ef411151bd537b9981b00d34f57483f04890646bd'),
    ('atomicfu-js-0.28.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/atomicfu-js/0.28.0/atomicfu-js-0.28.0.klib', '279294bfc9736de6f3c6c0092b3d977ba51ffa5a1e6037a45bb6eb47539410a2'),
    ('kotlinx-coroutines-core-js-1.9.0.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-js/1.9.0/kotlinx-coroutines-core-js-1.9.0.klib', 'af0f3d72a1706c326ad328908e2f2e87ad49b0d2c49fa4bba706019e6c26a26a'),
    ('kotlinx-datetime-js-0.7.1.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-datetime-js/0.7.1/kotlinx-datetime-js-0.7.1.klib', '2c577450040e72437bde31d027745c068cd33745d217495893fb0d84342ad46b'),
    ('kotlinx-serialization-core-js-1.7.3.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlinx/kotlinx-serialization-core-js/1.7.3/kotlinx-serialization-core-js-1.7.3.klib', '79fc0b140561bc7a50c0b3979ab4aacac0e8731ffec806b6af24f8d54cdc6347'),
    ('skiko-js-0.150.1.klib', 'https://repo.maven.apache.org/maven2/org/jetbrains/skiko/skiko-js/0.150.1/skiko-js-0.150.1.klib', '59b9155eb0788482405cd1e859d385ee742d65814a0ce3c67177b68c83a37c34'),
]

def _compose_bs_js_impl(repository_ctx):
    for out_name, url, sha256 in _COMPOSE_BS_JS_KLIBS:
        repository_ctx.download(
            url = url,
            output = out_name,
            sha256 = sha256,
        )

    repository_ctx.download_and_extract(
        url = "https://repo.maven.apache.org/maven2/org/jetbrains/skiko/skiko-js-wasm-runtime/0.150.1/skiko-js-wasm-runtime-0.150.1.jar",
        output = "skiko_runtime",
        sha256 = "aff08515ebd22863e9bb0b776068dfd2c7f7a384ed5e7e480b2ded349b653a0c",
    )

    repository_ctx.download_and_extract(
        url = "https://registry.npmjs.org/@js-joda/core/-/core-3.2.0.tgz",
        output = "node_modules/@js-joda/core",
        sha256 = "853990e161b83efc5c38b26e6ad5d88d380803aff8dbed1aedcefda2360f31be",
        stripPrefix = "package",
    )

    repository_ctx.file(
        "BUILD.bazel",
        """package(default_visibility = ["//visibility:public"])

filegroup(name = "klibs", srcs = glob(["*.klib"]))
filegroup(name = "skiko_wasm", srcs = ["skiko_runtime/skiko.wasm"])
filegroup(name = "skiko_mjs", srcs = ["skiko_runtime/skiko.mjs"])
filegroup(name = "skiko_reexport", srcs = ["skiko_runtime/js-reexport-symbols.mjs"])
filegroup(name = "node_modules", srcs = glob(["node_modules/**"]))
""",
    )

compose_bs_js = repository_rule(
    implementation = _compose_bs_js_impl,
    doc = "Downloads pinned Compose Multiplatform 1.12 JS KLIBs and Skiko runtime assets.",
)
