#!/usr/bin/env python3
"""Compiler runner for Kotlin JS and Wasm targets using K2JSCompiler."""

import argparse
import os
import shutil
import shlex
import subprocess
import sys
import tempfile


def parse_libraries(libs_args):
    result = []
    if not libs_args:
        return result
    for arg in libs_args:
        for item in arg.split(os.pathsep):
            item = item.strip()
            if item:
                result.append(os.path.realpath(item))
    # Deduplicate while preserving order
    seen = set()
    dedup = []
    for item in result:
        if item not in seen:
            seen.add(item)
            dedup.append(item)
    return dedup


def run_kotlinc(compiler_jar, kotlinc_args):
    java_cmd = os.environ.get("JAVA", "java")
    cmd = [
        java_cmd,
        "-cp", compiler_jar,
        "org.jetbrains.kotlin.cli.js.K2JSCompiler",
    ] + kotlinc_args
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        if proc.stdout:
            sys.stdout.write(proc.stdout)
        if proc.stderr:
            sys.stderr.write(proc.stderr)
        sys.exit(proc.returncode)
    if proc.stdout:
        sys.stdout.write(proc.stdout)
    if proc.stderr:
        sys.stderr.write(proc.stderr)


def compile_klib(args):
    libs = parse_libraries(args.libraries)
    tmpdir = os.path.realpath(tempfile.mkdtemp(prefix="kt_klib_"))
    try:
        kotlinc_args = [
            "-Xir-produce-klib-file",
            "-ir-output-name", args.module_name,
            "-ir-output-dir", tmpdir,
        ]
        if args.backend == "wasm":
            kotlinc_args.append("-Xwasm")
        if args.compose_plugin:
            kotlinc_args.append(f"-Xplugin={os.path.realpath(args.compose_plugin)}")
        if libs:
            kotlinc_args.extend(["-libraries", os.pathsep.join(libs)])
        if args.kotlinc_opts:
            kotlinc_args.extend(args.kotlinc_opts)
        kotlinc_args.extend(args.srcs)

        run_kotlinc(os.path.realpath(args.compiler_jar), kotlinc_args)

        generated_klib = os.path.join(tmpdir, f"{args.module_name}.klib")
        if not os.path.exists(generated_klib):
            klibs = [f for f in os.listdir(tmpdir) if f.endswith(".klib")]
            if klibs:
                generated_klib = os.path.join(tmpdir, klibs[0])
            else:
                sys.stderr.write(f"Error: Expected klib output was not generated in {tmpdir}\n")
                sys.exit(1)

        output_path = os.path.realpath(args.output)
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        shutil.copy2(generated_klib, output_path)
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


def link_binary(args):
    libs = parse_libraries(args.libraries)
    entry_dir = os.path.realpath(tempfile.mkdtemp(prefix="kt_entry_"))
    link_dir = os.path.realpath(tempfile.mkdtemp(prefix="kt_link_"))
    try:
        main_klib = os.path.realpath(args.main_klib) if args.main_klib else None
        if args.srcs:
            # Step 1: Compile entrypoint sources into a klib
            entry_klib_args = [
                "-Xir-produce-klib-file",
                "-ir-output-name", f"{args.module_name}_entry",
                "-ir-output-dir", entry_dir,
            ]
            if args.backend == "wasm":
                entry_klib_args.append("-Xwasm")
            if args.compose_plugin:
                entry_klib_args.append(f"-Xplugin={os.path.realpath(args.compose_plugin)}")
            if libs:
                entry_klib_args.extend(["-libraries", os.pathsep.join(libs)])
            if args.kotlinc_opts:
                entry_klib_args.extend(args.kotlinc_opts)
            entry_klib_args.extend(args.srcs)

            run_kotlinc(os.path.realpath(args.compiler_jar), entry_klib_args)
            main_klib = os.path.join(entry_dir, f"{args.module_name}_entry.klib")

        # Step 2: Link klib(s) into executable JS / Wasm
        link_args = [
            "-Xir-produce-js",
            "-ir-output-name", args.module_name,
            "-ir-output-dir", link_dir,
            "-target", args.target,
            "-main", args.main,
            # Reject broken dependency graphs before emitting browser-time errors.
            "-Xpartial-linkage-loglevel=error",
        ]
        if args.backend == "wasm":
            link_args.append("-Xwasm")
        else:
            link_args.extend(["-module-kind", "es"])
        if main_klib:
            link_args.append(f"-Xinclude={main_klib}")
        if libs:
            link_args.extend(["-libraries", os.pathsep.join(libs)])
        if args.kotlinc_opts:
            link_args.extend(args.kotlinc_opts)

        run_kotlinc(os.path.realpath(args.compiler_jar), link_args)

        # Locate produced JS / MJS file
        generated_js = None
        for candidate in [f"{args.module_name}.js", f"{args.module_name}.mjs"]:
            p = os.path.join(link_dir, candidate)
            if os.path.exists(p):
                generated_js = p
                break
        if not generated_js:
            sys.stderr.write(f"Error: Expected {args.module_name}.js or .mjs was not generated in {link_dir}\n")
            sys.exit(1)

        output_js_path = os.path.abspath(args.output_js)
        out_dir = os.path.dirname(output_js_path)
        os.makedirs(out_dir, exist_ok=True)
        shutil.copy2(generated_js, output_js_path)
        launcher_js_path = output_js_path
        # Preserve the existing Wasm companion layout; the explicit JS output
        # and runtime handling above are independent of Wasm's generated glue.
        if args.backend == "wasm":
            launcher_js_path = os.path.splitext(output_js_path)[0] + ".mjs"
            shutil.copy2(output_js_path, launcher_js_path)
            for name in os.listdir(link_dir):
                source = os.path.join(link_dir, name)
                destination = os.path.join(out_dir, name)
                if os.path.isfile(source) and name.endswith((".wasm", ".mjs", ".map")):
                    if not os.path.exists(destination):
                        shutil.copy2(source, destination)
        if args.output_wasm:
            generated_wasm = os.path.join(link_dir, f"{args.module_name}.wasm")
            if os.path.exists(generated_wasm):
                output_wasm_path = os.path.abspath(args.output_wasm)
                os.makedirs(os.path.dirname(output_wasm_path), exist_ok=True)
                shutil.copy2(generated_wasm, output_wasm_path)

        if args.output_executable:
            output_exec_path = os.path.abspath(args.output_executable)
            os.makedirs(os.path.dirname(output_exec_path), exist_ok=True)
            relative_js = os.path.relpath(launcher_js_path, os.path.dirname(output_exec_path))
            launcher_content = node_launcher(relative_js, args.runfile_js)
            with open(output_exec_path, "w") as f:
                f.write(launcher_content)
            os.chmod(output_exec_path, 0o755)

    finally:
        shutil.rmtree(entry_dir, ignore_errors=True)
        shutil.rmtree(link_dir, ignore_errors=True)


def node_launcher(relative_js, runfile_js):
    """Resolve only this target's module, including manifest-only runfiles."""
    return r"""#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
RELATIVE_JS=__RELATIVE_JS__
RUNFILE_JS=__RUNFILE_JS__
TARGET_JS="$DIR/$RELATIVE_JS"
if [[ ! -f "$TARGET_JS" ]]; then
    TARGET_JS=""
    for runfiles_root in "${RUNFILES_DIR:-}" "${TEST_SRCDIR:-}" "$0.runfiles"; do
        if [[ -n "$runfiles_root" && -f "$runfiles_root/$RUNFILE_JS" ]]; then
            TARGET_JS="$runfiles_root/$RUNFILE_JS"
            break
        fi
    done
fi
if [[ ! -f "$TARGET_JS" ]]; then
    manifest="${RUNFILES_MANIFEST_FILE:-$0.runfiles_manifest}"
    if [[ -f "$manifest" && -n "$RUNFILE_JS" ]]; then
        while IFS= read -r line; do
            if [[ "$line" == "$RUNFILE_JS "* ]]; then
                TARGET_JS="${line#"$RUNFILE_JS "}"
                break
            fi
        done < "$manifest"
    fi
fi
if [[ ! -f "$TARGET_JS" ]]; then
    echo "Kotlin JS module not found in runfiles: $RUNFILE_JS" >&2
    exit 1
fi
NODE_BIN="${NODE_BINARY:-}"
if [[ -z "$NODE_BIN" ]]; then
    # Bazel may restrict PATH for tests, including on Homebrew installations.
    for candidate in node /opt/homebrew/bin/node /usr/local/bin/node; do
        if command -v "$candidate" >/dev/null 2>&1; then
            NODE_BIN="$(command -v "$candidate")"
            break
        fi
    done
fi
if [[ -z "$NODE_BIN" ]] || ! command -v "$NODE_BIN" >/dev/null 2>&1; then
    echo "Node.js is required to run this Kotlin JS target; install Node.js or set NODE_BINARY." >&2
    exit 127
fi
exec "$NODE_BIN" --input-type=module - "$TARGET_JS" "$@" <<'KOTLIN_NODE_WRAPPER'
import fs from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';

// Skiko's JS runtime also supports model tests under Node.
if (typeof globalThis.window === 'undefined') {
  globalThis.window = globalThis;
}
if (typeof globalThis.XMLHttpRequest === 'undefined') {
  globalThis.XMLHttpRequest = class {
    open(method, url) { this.url = url; }
    send() {
      setTimeout(() => {
        try {
          const p = this.url.startsWith('file://') ? fileURLToPath(this.url) : this.url;
          const bytes = fs.readFileSync(p);
          this.response = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
          this.status = 200;
          if (this.onload) this.onload();
        } catch (e) {
          if (this.onerror) this.onerror(e);
        }
      }, 0);
    }
  };
}
const targetPath = process.argv[2];
process.argv = [process.execPath, targetPath, ...process.argv.slice(3)];
await import(pathToFileURL(targetPath).href);
KOTLIN_NODE_WRAPPER
""".replace("__RELATIVE_JS__", shlex.quote(relative_js)).replace(
        "__RUNFILE_JS__", shlex.quote(runfile_js or "")
    )


def main():
    parser = argparse.ArgumentParser(
        description="Kotlin JS/Wasm Compiler Runner",
        fromfile_prefix_chars="@",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    compile_p = subparsers.add_parser("compile-klib")
    compile_p.add_argument("--output", required=True, help="Path to output .klib")
    compile_p.add_argument("--module-name", required=True, help="Module name")
    compile_p.add_argument("--compiler-jar", required=True, help="Path to kotlin-compiler.jar")
    compile_p.add_argument("--libraries", action="append", default=[], help="Dependency klibs")
    compile_p.add_argument("--compose-plugin", help="Path to compose-compiler-plugin.jar")
    compile_p.add_argument("--backend", default="js", choices=["js", "wasm"])
    compile_p.add_argument("--kotlinc-opts", action="append", default=[])
    compile_p.add_argument("--srcs", nargs="*", default=[])

    link_p = subparsers.add_parser("link-binary")
    link_p.add_argument("--output-js", required=True, help="Path to output JavaScript module")
    link_p.add_argument("--output-executable", help="Path to output executable launcher script")
    link_p.add_argument("--runfile-js", help="Logical runfiles path of the JavaScript module")
    link_p.add_argument("--output-wasm", help="Path to output .wasm (for wasm backend)")
    link_p.add_argument("--module-name", required=True, help="Module name")
    link_p.add_argument("--compiler-jar", required=True, help="Path to kotlin-compiler.jar")
    link_p.add_argument("--libraries", action="append", default=[], help="Dependency klibs")
    link_p.add_argument("--compose-plugin", help="Path to compose-compiler-plugin.jar")
    link_p.add_argument("--backend", default="js", choices=["js", "wasm"])
    link_p.add_argument("--main-klib", help="Pre-compiled main klib to link")
    link_p.add_argument("--main", default="call", choices=["call", "noCall"])
    link_p.add_argument("--target", default="es2015", choices=["es5", "es2015"])
    link_p.add_argument("--kotlinc-opts", action="append", default=[])
    link_p.add_argument("--srcs", nargs="*", default=[])

    args = parser.parse_args()
    if args.command == "compile-klib":
        compile_klib(args)
    elif args.command == "link-binary":
        link_binary(args)


if __name__ == "__main__":
    main()
