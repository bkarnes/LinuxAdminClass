#!/bin/bash
# Verify: ~/fhs-answers.txt contains the three expected FHS paths (order agnostic).

FILE="$HOME/fhs-answers.txt"

if [ ! -f "$FILE" ]; then
    echo "~/fhs-answers.txt doesn't exist yet. Put your three paths in it, one per line." >&2
    exit 1
fi

check() {
    local needle="$1" label="$2"
    if ! grep -qxE "$needle" "$FILE"; then
        echo "Missing (or not on its own line): $label -> expected exactly '$needle'" >&2
        return 1
    fi
}

ok=0
check "/etc"      "configuration directory"  && ok=$((ok+1))
check "/var/log"  "log directory"            && ok=$((ok+1))
check "/tmp"      "temporary directory"      && ok=$((ok+1))

if [ "$ok" -ne 3 ]; then
    exit 1
fi

exit 0