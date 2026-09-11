#!/bin/bash
# Verify: FLAG_PIVOT claimed; stamped.

WORK="$HOME/kali-class-work/sec-wk14"
FILE="$WORK/flag-4.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    exit 1
fi

if ! grep -q "FLAG{p1v0t_thr0ugh_jumpb0x}" "$FILE"; then
    echo "flag-4.txt doesn't contain FLAG_PIVOT — pivot via the jumpbox to c-db-01." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk14 flag-pivot 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0