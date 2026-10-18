"""Bzlmod module extension for Kotlin Multiplatform rules."""

def _kmp_extension_impl(module_ctx):
    # Provides future expansion for custom toolchain downloads and repository generation
    pass

kmp_extension = module_extension(
    implementation = _kmp_extension_impl,
)
