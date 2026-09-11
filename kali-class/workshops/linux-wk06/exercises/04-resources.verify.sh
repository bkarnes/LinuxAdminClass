#!/bin/bash
# Verify: the three resource reports exist and contain plausible output.

check() {
    local file="$1" desc="$2" pattern="$3"
    if [ ! -s "$HOME/$file" ]; then
        echo "~/$file is missing or empty ($desc)." >&2
        exit 1
    fi
    if ! grep -qE "$pattern" "$HOME/$file"; then
        echo "~/$file doesn't look like $desc output." >&2
        exit 1
    fi
}

check "resource-df.txt"  "df -h"    "Filesystem|Mounted"
check "resource-du.txt"  "du -sh"   "[0-9.]+[KMG]?[[:space:]]"
check "resource-free.txt" "free -h" "Mem:"

exit 0