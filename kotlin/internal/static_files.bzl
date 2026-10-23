"""Shared website-relative path validation for static-file consumers."""

def safe_static_path(path):
    if not path or path.startswith("/") or "\\" in path:
        return False
    return all([part not in ["", ".", ".."] for part in path.split("/")])

def register_static_path(paths, path, kind):
    if not safe_static_path(path):
        fail("Unsafe %s path: %s" % (kind, path))
    for existing in paths:
        if existing == path:
            fail("Duplicate %s path: %s" % (kind, path))
        if existing.startswith(path + "/") or path.startswith(existing + "/"):
            fail("Conflicting %s paths: %s and %s" % (kind, existing, path))
    paths[path] = True
