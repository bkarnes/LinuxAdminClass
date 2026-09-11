#!/bin/bash
# Verify: ~/scripts/greet.sh reads a name and greets with it.

SCRIPT="$HOME/scripts/greet.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "~/scripts/greet.sh doesn't exist yet." >&2
    exit 1
fi

# The script must read stdin (a read-based prompt). Run with test input.
out=$(printf 'TestyMcTestface\n' | bash "$SCRIPT" 2>/dev/null | tail -1)

case "$out" in
    *"Hello, TestyMcTestface!"*)
        exit 0
        ;;
    *)
        echo "Script output didn't greet the test name. Got: '$out'" >&2
        echo "Expected something like: Hello, TestyMcTestface!" >&2
        exit 1
        ;;
esac