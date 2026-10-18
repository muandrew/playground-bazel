"""Providers for Kotlin Multiplatform rules (JS, Wasm, Native)."""

KtJsInfo = provider(
    doc = "Information about a Kotlin JS library.",
    fields = {
        "klib": "The compiled .klib file for this library target.",
        "transitive_klibs": "Depset of all transitive .klib dependencies.",
        "direct_klibs": "List of direct .klib dependencies.",
        "module_name": "The Kotlin JS module name.",
    },
)

KtWasmInfo = provider(
    doc = "Information about a Kotlin Wasm library.",
    fields = {
        "klib": "The compiled .klib file for this library target.",
        "transitive_klibs": "Depset of all transitive .klib dependencies.",
        "direct_klibs": "List of direct .klib dependencies.",
        "module_name": "The Kotlin Wasm module name.",
    },
)

KtNativeInfo = provider(
    doc = "Information about a Kotlin Native library.",
    fields = {
        "klib": "The compiled .klib file for this library target.",
        "transitive_klibs": "Depset of all transitive .klib dependencies.",
        "direct_klibs": "List of direct .klib dependencies.",
        "module_name": "The Kotlin Native module name.",
    },
)
