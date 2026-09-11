#!/bin/bash
# Verify: Wireshark notes reference both filters; stamped.

WORK="$HOME/kali-class-work/sec-wk11"
FILE="$WORK/wireshark-notes.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — note the filters you used in Wireshark." >&2
    exit 1
fi

if ! grep -qE "ftp" "$FILE"; then
    echo "Notes should mention the 'ftp' filter." >&2
    exit 1
fi

if ! grep -qE "PASS" "$FILE"; then
    echo "Notes should mention the ftp.request.command == \"PASS\" filter." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk11 wireshark 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0