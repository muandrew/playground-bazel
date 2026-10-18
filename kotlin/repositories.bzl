"""Repository rules for downloading Compose Multiplatform JS/Wasm KLIB artifacts."""

_COMPOSE_JS_KLIBS = [
    ("androidx-annotation-js-1.9.1.klib", "https://dl.google.com/dl/android/maven2/androidx/annotation/annotation-js/1.9.1/annotation-js-1.9.1.klib", "bce021c6476db59d6b82bcb305dafaa8cd6da48a791e7ffb95bd886ae2bfc65f"),
    ("animation-core-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/animation/animation-core-js/1.12.0-alpha02/animation-core-js-1.12.0-alpha02.klib", "d7b157226f8e1da6b9e4013e4a502b31bb4049300d96cac1451dc3dbf8ae8f61"),
    ("animation-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/animation/animation-js/1.12.0-alpha02/animation-js-1.12.0-alpha02.klib", "e1ad86535d86a374e2cce054acf1194b4c9373d2f871d125db1a014bbce75786"),
    ("annotation-js-1.10.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/annotation-internal/annotation-js/1.10.0/annotation-js-1.10.0.klib", "772c19a5e4de38adc073b917464de7696d3eacf69eaf6537524432f3a793c5b1"),
    ("atomicfu-js-0.28.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/atomicfu-js/0.28.0/atomicfu-js-0.28.0.klib", "279294bfc9736de6f3c6c0092b3d977ba51ffa5a1e6037a45bb6eb47539410a2"),
    ("collection-js-1.10.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/collection-internal/collection-js/1.10.0/collection-js-1.10.0.klib", "6fc35c9c4cb507a52ecc41b30b59740de22a30b8b6c37fbba5e0580bf0b44354"),
    ("foundation-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/foundation/foundation-js/1.12.0-alpha02/foundation-js-1.12.0-alpha02.klib", "f7d761d226684a3306a895a543ac58c72f0281a8a4d0483b9b0f165ea5c24a19"),
    ("foundation-layout-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/foundation/foundation-layout-js/1.12.0-alpha02/foundation-layout-js-1.12.0-alpha02.klib", "7555fdf683a8ce23bcfe3601425795dd615f36d7942312e9b6e98daa38e8e7f1"),
    ("kotlin-dom-api-compat-2.2.20.klib", "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-dom-api-compat/2.2.20/kotlin-dom-api-compat-2.2.20.klib", "1f77671efa85bcf148181f3e74815293f713cb270d78c03c93c3be535eabb439"),
    ("kotlinx-browser-js-0.5.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-browser-js/0.5.0/kotlinx-browser-js-0.5.0.klib", "e794f4e1b4d40507c3d9e01ef411151bd537b9981b00d34f57483f04890646bd"),
    ("kotlinx-coroutines-core-js-1.9.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-coroutines-core-js/1.9.0/kotlinx-coroutines-core-js-1.9.0.klib", "af0f3d72a1706c326ad328908e2f2e87ad49b0d2c49fa4bba706019e6c26a26a"),
    ("kotlinx-datetime-js-0.7.1.klib", "https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-datetime-js/0.7.1/kotlinx-datetime-js-0.7.1.klib", "2c577450040e72437bde31d027745c068cd33745d217495893fb0d84342ad46b"),
    ("lifecycle-common-js-2.9.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-common-js/2.9.6/lifecycle-common-js-2.9.6.klib", "2dce6cff869f0494fd900deda999b3979277a62e1148548729c287bc422515a6"),
    ("lifecycle-runtime-compose-js-2.9.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-compose-js/2.9.6/lifecycle-runtime-compose-js-2.9.6.klib", "8c2909947b81441739b10534bb8c84d837b5a040103ed87fe6a8bef03e27cd0e"),
    ("lifecycle-runtime-js-2.9.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-runtime-js/2.9.6/lifecycle-runtime-js-2.9.6.klib", "cd1dabf5a515293bd6168d21e34055adafa0590bec9d8f4a891080eeb163fc8f"),
    ("lifecycle-viewmodel-js-2.9.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-js/2.9.6/lifecycle-viewmodel-js-2.9.6.klib", "6fcb9fa47b271ef276f453b00ad0af8566ff980a3a47f107b16083c80d211ff1"),
    ("lifecycle-viewmodel-savedstate-js-2.9.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/lifecycle/lifecycle-viewmodel-savedstate-js/2.9.6/lifecycle-viewmodel-savedstate-js-2.9.6.klib", "e4432377ee0059d87cb5809dc2b3d008d332e8f0146a18c00e9fd06356d8df45"),
    ("material-ripple-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/material/material-ripple-js/1.12.0-alpha02/material-ripple-js-1.12.0-alpha02.klib", "bc645bb53ccb8c9ae25cd73454616621ac00becb559445af35490f78038a1e63"),
    ("material3-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/material3/material3-js/1.12.0-alpha02/material3-js-1.12.0-alpha02.klib", "4b73f36368b4ac87d0afb806e132a6b18f06f06d7166c4ea64f798fe489d0588"),
    ("navigationevent-compose-js-1.1.0.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/navigationevent/navigationevent-compose-js/1.1.0/navigationevent-compose-js-1.1.0.klib", "1015ef6cc1282811dbb0b1ba4800779d5f5fe1e66d7e33f7d3d5c2e3f6e45bd7"),
    ("runtime-annotation-js-1.12.0-alpha03.klib", "https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-annotation-js/1.12.0-alpha03/runtime-annotation-js-1.12.0-alpha03.klib", "f7c67d91d6180671be25c9872562a061b8a2aa86f2d53ccf613e2727a91bb3ef"),
    ("runtime-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/runtime/runtime-js/1.12.0-alpha02/runtime-js-1.12.0-alpha02.klib", "ccd8de39db948cdddeeee94826ed6e56791d3b310184607aa92950ecca1de26b"),
    ("runtime-js-1.12.0-alpha03.klib", "https://dl.google.com/dl/android/maven2/androidx/compose/runtime/runtime-js/1.12.0-alpha03/runtime-js-1.12.0-alpha03.klib", "e98f75d88e74832054628170ae1dfe9dfedfe327e56c865774ce4c8beaf30c61"),
    ("runtime-saveable-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/runtime/runtime-saveable-js/1.12.0-alpha02/runtime-saveable-js-1.12.0-alpha02.klib", "a4c577dd9f1ae46db15544f51e3820a6561ef1b0c87d7d03419ea17d8c0c3a5e"),
    ("savedstate-compose-js-1.3.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/savedstate/savedstate-compose-js/1.3.6/savedstate-compose-js-1.3.6.klib", "8f0181b5cde7fc60ea33124f490d54568936bc306a5b034332bff811baf6066d"),
    ("savedstate-js-1.3.6.klib", "https://repo1.maven.org/maven2/org/jetbrains/androidx/savedstate/savedstate-js/1.3.6/savedstate-js-1.3.6.klib", "02dab63f67b626919b1af4e44cc40716d46b993df4bd8607c33936391e6a5a0a"),
    ("skiko-js-0.148.2.klib", "https://repo1.maven.org/maven2/org/jetbrains/skiko/skiko-js/0.148.2/skiko-js-0.148.2.klib", "4b876ca338d9c0753107be69aa1863a5200785343f93ccfb64fa28195bcbffad"),
    ("ui-backhandler-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-backhandler-js/1.12.0-alpha02/ui-backhandler-js-1.12.0-alpha02.klib", "8e7a034acbde8a9e0b3ee3aba2f82da85d93137551b133f4f0e310c14ed25a34"),
    ("ui-geometry-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-geometry-js/1.12.0-alpha02/ui-geometry-js-1.12.0-alpha02.klib", "9370845cb7c87e271285862580e43833f5de004413bf26f19735d72292ec9f06"),
    ("ui-graphics-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-graphics-js/1.12.0-alpha02/ui-graphics-js-1.12.0-alpha02.klib", "9846006b1f3e4b12c831009778a1ca1539e3ec5eb5641e706d0f50d7e9fa45d2"),
    ("ui-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-js/1.12.0-alpha02/ui-js-1.12.0-alpha02.klib", "02d13ceb1965671786d50ce9d003a26bcdc51f44818bfb6126dd1556124c24f0"),
    ("ui-text-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-text-js/1.12.0-alpha02/ui-text-js-1.12.0-alpha02.klib", "8d5755a6903efab067a76e4746fd3731fac088bc5c025e17177b3676112941df"),
    ("ui-unit-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-unit-js/1.12.0-alpha02/ui-unit-js-1.12.0-alpha02.klib", "fcde974cb211c58297275f9ad48cb3999dd4df263c43fb0af9299be13444f6ca"),
    ("ui-util-js-1.12.0-alpha02.klib", "https://repo1.maven.org/maven2/org/jetbrains/compose/ui/ui-util-js/1.12.0-alpha02/ui-util-js-1.12.0-alpha02.klib", "9e1c014a692c29a650b69a8b4c4ae0381b95ae07d88970a2dfe87f498ab52665"),
]

def _compose_ui_js_impl(repository_ctx):
    for out_name, url, sha256 in _COMPOSE_JS_KLIBS:
        repository_ctx.download(
            url = url,
            output = out_name,
            sha256 = sha256,
        )

    repository_ctx.download_and_extract(
        url = "https://repo1.maven.org/maven2/org/jetbrains/skiko/skiko-js-wasm-runtime/0.148.2/skiko-js-wasm-runtime-0.148.2.jar",
        sha256 = "1d3e143f7491d2c56bee53b4375a521b414f7747abdaf0158cd3355f599862c2",
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
