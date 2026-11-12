#!/usr/bin/env python3
"""PreToolUse hook for Edit|Write|MultiEdit|NotebookEdit.

Blocks a file change until, in this session (read from the transcript), Claude has
  1. Read every CLAUDE.md that applies to the target file (target dir up to the git root), and
  2. Read a coding-style reference: another file with the same extension in the project, or a
     style config file (eslint, prettier, ruff, editorconfig, ...).

Exit 2 blocks the tool call and shows stderr to Claude. Anything unexpected exits 0 (fail open),
so a bug in this hook can never brick editing.
"""
import json
import os
import subprocess
import sys

CODE_EXTS = {
    ".py", ".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs", ".go", ".java", ".kt", ".rs", ".rb",
    ".php", ".cs", ".c", ".cc", ".cpp", ".h", ".hpp", ".swift", ".vue", ".svelte", ".css",
    ".scss", ".sh", ".sql", ".dart", ".scala",
}
STYLE_FILES = {
    ".editorconfig", "pyproject.toml", "setup.cfg", "tox.ini", "ruff.toml", ".ruff.toml",
    "tsconfig.json", "biome.json", "rustfmt.toml", ".rustfmt.toml", ".clang-format",
    ".rubocop.yml", ".golangci.yml", ".golangci.yaml", ".prettierrc", ".prettierrc.json",
    ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.yaml", ".prettierrc.yml",
    "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs", ".eslintrc",
    ".eslintrc.json", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.yml", ".eslintrc.yaml",
    "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs", "eslint.config.ts",
    ".stylelintrc", ".stylelintrc.json", "checkstyle.xml",
}


def allow():
    sys.exit(0)


def block(lines):
    sys.stderr.write("\n".join(lines) + "\n")
    sys.exit(2)


def real(path):
    return os.path.realpath(os.path.expanduser(path))


def read_paths(transcript_path):
    """Absolute paths of every file Claude has read with the Read tool in this session."""
    out = set()
    with open(transcript_path, encoding="utf-8", errors="ignore") as fh:
        for line in fh:
            if '"Read"' not in line:
                continue
            try:
                entry = json.loads(line)
            except ValueError:
                continue
            msg = entry.get("message") or {}
            content = msg.get("content")
            if not isinstance(content, list):
                continue
            for block_ in content:
                if (
                    isinstance(block_, dict)
                    and block_.get("type") == "tool_use"
                    and block_.get("name") == "Read"
                ):
                    fp = (block_.get("input") or {}).get("file_path")
                    if fp:
                        out.add(real(fp))
    return out


def main():
    data = json.load(sys.stdin)
    tool_input = data.get("tool_input") or {}
    target = tool_input.get("file_path") or tool_input.get("notebook_path")
    transcript = data.get("transcript_path")
    if not target or not transcript or not os.path.exists(transcript):
        allow()

    cwd = data.get("cwd") or os.getcwd()
    target = real(target if os.path.isabs(target) else os.path.join(cwd, target))
    home = real("~")

    # Walk up to the nearest existing directory to ask git for the project root.
    d = os.path.dirname(target)
    while d and not os.path.isdir(d):
        d = os.path.dirname(d)
    try:
        root = subprocess.run(
            ["git", "-C", d, "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        allow()
    if not root:  # not inside a git project: not our business
        allow()
    root = real(root)

    rel = os.path.relpath(target, root)
    if rel.startswith("..") or rel.split(os.sep)[0] in (".git", ".claude"):
        allow()
    if target.startswith(os.path.join(home, ".claude") + os.sep):
        allow()
    if os.path.basename(target) == "CLAUDE.md":
        allow()

    reads = read_paths(transcript)
    problems = []

    # 1. CLAUDE.md files that apply to the target (target dir up to the project root).
    required = []
    cur = os.path.dirname(target)
    while True:
        for cand in (os.path.join(cur, "CLAUDE.md"), os.path.join(cur, ".claude", "CLAUDE.md")):
            if os.path.isfile(cand):
                required.append(real(cand))
        if cur == root or len(cur) <= len(root):
            break
        cur = os.path.dirname(cur)
    missing_md = [p for p in required if p not in reads]
    if missing_md:
        problems.append(
            "Read these CLAUDE.md files with the Read tool before changing files "
            "(project rules, scope and what NOT to do):\n  - " + "\n  - ".join(missing_md)
        )

    # 2. A coding-style reference.
    ext = os.path.splitext(target)[1].lower()
    if ext in CODE_EXTS:
        in_root = [p for p in reads if p.startswith(root + os.sep) and p != target]
        has_same_ext = any(os.path.splitext(p)[1].lower() == ext for p in in_root)
        has_style_cfg = any(os.path.basename(p) in STYLE_FILES for p in in_root)
        if not (has_same_ext or has_style_cfg):
            problems.append(
                f"Read the project's coding style before writing {ext} code: read at least one "
                f"existing {ext} file next to or similar to {os.path.relpath(target, root)} "
                "(naming, structure, imports, error handling, tests) and/or the style config "
                "(.editorconfig, eslint/prettier/ruff/golangci config)."
            )

    if problems:
        block(
            ["BLOCKED: context not loaded yet for " + os.path.relpath(target, root) + "."]
            + problems
            + [
                "Then retry the change. Keep it minimal: only what the requirements need, "
                "following the patterns you just read, with no extra abstractions, config, "
                "dependencies or out-of-scope edits."
            ]
        )
    allow()


if __name__ == "__main__":
    try:
        main()
    except SystemExit:
        raise
    except Exception:
        sys.exit(0)  # fail open
