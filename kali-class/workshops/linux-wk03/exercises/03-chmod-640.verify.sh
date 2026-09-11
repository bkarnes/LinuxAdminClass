#!/bin/bash
# Verify: ~/secret-plan.txt has mode 640 (allowing for umask quirks: exactly
# what the student set must stick) and the answer file records it.

TARGET="$HOME/secret-plan.txt"

if [ ! -f "$TARGET" ]; then
    echo "~/secret-plan.txt doesn't exist yet." >&2
    exit 1
fi

actual=$(stat -c '%a' "$TARGET")
if [ "$actual" != "640" ]; then
    echo "Permissions are $actual, expected 640 (owner rw, group r, others none)." >&2
    exit 1
fi

if [ ! -f "$HOME/mode-answer.txt" ]; then
    echo "~/mode-answer.txt is missing — record the permission string." >&2
    exit 1
fi

# stat -c '%A' output includes the file-type char as the first position
# (e.g. "-rw-r-----" for a regular file). Accept with or without it.
if ! grep -qE "^-?rw-r-----" "$HOME/mode-answer.txt"; then
    echo "~/mode-answer.txt should contain the symbolic string (rw-r-----)." >&2
    exit 1
fi

exit 0