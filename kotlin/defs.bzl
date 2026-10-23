"""Public definitions for rules_kotlin_multiplatform."""

load("//kotlin:http.bzl", _simple_http = "simple_http")
load("//kotlin:js.bzl", _kt_js_binary = "kt_js_binary", _kt_js_library = "kt_js_library", _kt_js_preview = "kt_js_preview", _kt_js_test = "kt_js_test")
load("//kotlin:native.bzl", _kt_native_binary = "kt_native_binary", _kt_native_library = "kt_native_library", _kt_native_test = "kt_native_test")
load("//kotlin:toolchain.bzl", _kt_js_toolchain = "kt_js_toolchain", _kt_native_toolchain = "kt_native_toolchain", _kt_wasm_toolchain = "kt_wasm_toolchain")
load("//kotlin:wasm.bzl", _kt_wasm_binary = "kt_wasm_binary", _kt_wasm_library = "kt_wasm_library")
load("//kotlin/internal:providers.bzl", _KtJsInfo = "KtJsInfo", _KtNativeInfo = "KtNativeInfo", _KtWasmInfo = "KtWasmInfo")

kt_js_library = _kt_js_library
kt_js_binary = _kt_js_binary
kt_js_test = _kt_js_test
kt_js_preview = _kt_js_preview
simple_http = _simple_http

kt_wasm_library = _kt_wasm_library
kt_wasm_binary = _kt_wasm_binary

kt_native_library = _kt_native_library
kt_native_binary = _kt_native_binary
kt_native_test = _kt_native_test

kt_js_toolchain = _kt_js_toolchain
kt_wasm_toolchain = _kt_wasm_toolchain
kt_native_toolchain = _kt_native_toolchain

KtJsInfo = _KtJsInfo
KtWasmInfo = _KtWasmInfo
KtNativeInfo = _KtNativeInfo
