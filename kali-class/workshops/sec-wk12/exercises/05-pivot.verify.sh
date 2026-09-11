#!/bin/bash
# Verify: pivot analysis recorded; stamped.

WORK="$HOME/kali-class-work/sec-wk12"
FILE="$WORK/pivot-notes.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — write your pivot analysis." >&2
    exit 1
fi

if ! grep -qiE "10\.1\.0" "$FILE"; then
    echo "Notes should reference the private net (10.1.0.0/24)." >&2
    exit 1
fi

if ! grep -qiE "(jumpbox|route|pivot)" "$FILE"; then
    echo "Notes should explain the pivot concept (jumpbox/route)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk12 pivot 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0