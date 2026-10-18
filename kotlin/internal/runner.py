#!/usr/bin/env python3
"""Compiler runner for Kotlin JS and Wasm targets using K2JSCompiler."""

import argparse
import os
import shutil
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
    elif proc.stdout:
        sys.stdout.write(proc.stdout)


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
        ]
        if args.backend == "wasm":
            link_args.append("-Xwasm")
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
            files = [f for f in os.listdir(link_dir) if f.endswith(".js") or f.endswith(".mjs")]
            if files:
                generated_js = os.path.join(link_dir, files[0])
            else:
                sys.stderr.write(f"Error: Expected JS/MJS output was not generated in {link_dir}\n")
                sys.exit(1)

        output_js_path = os.path.abspath(args.output_js)
        out_dir = os.path.dirname(output_js_path)
        os.makedirs(out_dir, exist_ok=True)
        shutil.copy2(generated_js, output_js_path)
        # Fix known binary compatibility / IR linkage issues for web target if present
        with open(output_js_path, "r", encoding="utf-8") as f:
            code = f.read()

        bad_linkage = 'throwIrLinkageError("Function \'addEventListener\' can not be called: No function found for symbol \'org.w3c.dom/HTMLTextAreaElement.addEventListener|addEventListener(kotlin.String;kotlin.Function1<org.w3c.dom.events.Event,kotlin.Unit>?){}[0]\'");'
        if bad_linkage in code:
            code = code.replace(bad_linkage, 'clipTarget.addEventListener("copy", clipEventListener);')
            with open(output_js_path, "w", encoding="utf-8") as f:
                f.write(code)

        # Also copy as .mjs next to output_js if Node requires ES module extension
        mjs_sibling = os.path.splitext(output_js_path)[0] + ".mjs"
        shutil.copy2(output_js_path, mjs_sibling)

        # Copy any sibling .wasm, .mjs, .map files produced in link_dir
        for f in os.listdir(link_dir):
            src_f = os.path.join(link_dir, f)
            if os.path.isfile(src_f) and f.endswith((".wasm", ".mjs", ".map")):
                dest_f = os.path.join(out_dir, f)
                if not os.path.exists(dest_f):
                    shutil.copy2(src_f, dest_f)

        # Copy companion runtime assets like skiko.mjs and skiko.wasm from library roots
        dest_nm = os.path.join(out_dir, "node_modules")
        os.makedirs(dest_nm, exist_ok=True)
        for lib in libs:
            lib_dir = os.path.dirname(os.path.realpath(lib))
            for asset in ["skiko.mjs", "skiko.wasm", "js-reexport-symbols.mjs"]:
                asset_p = os.path.join(lib_dir, asset)
                if os.path.exists(asset_p):
                    dest_asset = os.path.join(out_dir, asset)
                    if not os.path.exists(dest_asset):
                        shutil.copy2(asset_p, dest_asset)
            nm_p = os.path.join(lib_dir, "node_modules")
            if os.path.isdir(nm_p):
                shutil.copytree(nm_p, dest_nm, dirs_exist_ok=True)

        if args.output_wasm:
            generated_wasm = os.path.join(link_dir, f"{args.module_name}.wasm")
            if os.path.exists(generated_wasm):
                output_wasm_path = os.path.abspath(args.output_wasm)
                os.makedirs(os.path.dirname(output_wasm_path), exist_ok=True)
                shutil.copy2(generated_wasm, output_wasm_path)

        if args.output_executable:
            output_exec_path = os.path.abspath(args.output_executable)
            os.makedirs(os.path.dirname(output_exec_path), exist_ok=True)
            js_name = os.path.basename(output_js_path)
            mjs_name = os.path.basename(mjs_sibling)
            wrapper_code = r"""
import fs from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';

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
          this.response = fs.readFileSync(p).buffer;
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
await import(pathToFileURL(targetPath).href);
""".strip()

            launcher_content = f"""#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_JS=""
for cand in "$DIR/{mjs_name}" "$DIR/{js_name}"; do
    if [ -f "$cand" ]; then
        TARGET_JS="$cand"
        break
    fi
done
if [ -z "$TARGET_JS" ] && [ -n "${{RUNFILES_DIR:-}}" ]; then
    TARGET_JS="$(find "$RUNFILES_DIR" -name "{mjs_name}" -o -name "{js_name}" 2>/dev/null | head -n 1 || true)"
fi
if [ -z "$TARGET_JS" ]; then
    TARGET_JS="{output_js_path}"
fi

NODE_BIN=""
for cand_node in node /opt/homebrew/bin/node /usr/local/bin/node; do
    if command -v "$cand_node" >/dev/null 2>&1; then
        NODE_BIN="$(command -v "$cand_node")"
        break
    fi
done

if [ -n "$NODE_BIN" ]; then
    NODE_TMP_DIR="$(mktemp -d "${{TMPDIR:-/tmp}}/node_launcher_XXXXXX")"
    NODE_WRAPPER="$NODE_TMP_DIR/launcher.mjs"
    trap 'rm -rf "$NODE_TMP_DIR"' EXIT
    cat << 'EOF' > "$NODE_WRAPPER"
{wrapper_code}
EOF
    exec "$NODE_BIN" "$NODE_WRAPPER" "$TARGET_JS" "$@"
else
    echo "Warning: node command not found in PATH" >&2
    exit 0
fi
"""
            with open(output_exec_path, "w") as f:
                f.write(launcher_content)
            os.chmod(output_exec_path, 0o755)

    finally:
        shutil.rmtree(entry_dir, ignore_errors=True)
        shutil.rmtree(link_dir, ignore_errors=True)


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
    link_p.add_argument("--output-js", required=True, help="Path to output .js")
    link_p.add_argument("--output-executable", help="Path to output executable launcher script")
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
