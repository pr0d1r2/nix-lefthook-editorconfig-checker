# shellcheck shell=bash
# Lefthook-compatible editorconfig-checker wrapper.
# Usage: lefthook-editorconfig-checker file1 [file2 ...]
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

files=()
for f in "$@"; do
    [ -f "$f" ] || continue
    files+=("$f")
done

if [ ${#files[@]} -eq 0 ]; then
    exit 0
fi

exec editorconfig-checker "${files[@]}"
