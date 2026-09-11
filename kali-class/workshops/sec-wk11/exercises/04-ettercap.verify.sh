#!/bin/bash
# Verify: ettercap console output captured; stamped.

WORK="$HOME/kali-class-work/sec-wk11"
FILE="$WORK/ettercap.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — save ettercap's console output." >&2
    exit 1
fi

if ! grep -qiE "(ettercap|MITM|hosts)" "$FILE"; then
    echo "The file doesn't look like ettercap output." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk11 ettercap 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0