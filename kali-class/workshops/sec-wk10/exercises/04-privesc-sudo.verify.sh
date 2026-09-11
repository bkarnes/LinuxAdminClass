#!/bin/bash
# Verify: proof of root via the sudo-find path; stamped.

WORK="$HOME/kali-class-work/sec-wk10"
FILE="$WORK/privesc-sudo.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — capture whoami output from the sudo find shell." >&2
    exit 1
fi

if ! grep -qx "root" "$FILE"; then
    echo "The file should contain 'root' — prove the sudo escalation worked." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk10 privesc-sudo 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0