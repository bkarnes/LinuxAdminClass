#!/bin/bash
# Verify: htop, curl, jq installed AND the three proof files exist with
# version output in them.

check_tool() {
    local tool="$1" file="$2"
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "$tool is not installed (sudo apt install -y $tool)" >&2
        exit 1
    fi
    if [ ! -s "$HOME/$file" ]; then
        echo "~/$file is missing or empty — save '$tool --version' output into it." >&2
        exit 1
    fi
    if ! "$tool" --version >/dev/null 2>&1; then
        echo "$tool won't run --version — odd install?" >&2
        exit 1
    fi
}

check_tool htop toolkit-htop.txt
check_tool curl toolkit-curl.txt
check_tool jq toolkit-jq.txt

exit 0