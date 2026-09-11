#!/bin/bash
# Verify: SUID list captured incl. the planted nanohelp binary; stamped.

WORK="$HOME/kali-class-work/sec-wk10"
FILE="$WORK/suid-list.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "Run from the intern shell: find / -perm -4000 -type f 2>/dev/null" >&2
    exit 1
fi

if ! grep -q "/usr/local/bin/nanohelp" "$FILE"; then
    echo "The list doesn't include the planted SUID binary (/usr/local/bin/nanohelp) — scan the whole filesystem." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk10 suid-scan 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0