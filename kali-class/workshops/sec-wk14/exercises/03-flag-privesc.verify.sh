#!/bin/bash
# Verify: FLAG_PRIVESC claimed; stamped.

WORK="$HOME/kali-class-work/sec-wk14"
FILE="$WORK/flag-3.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    exit 1
fi

if ! grep -q "FLAG{pr1v3sc_v14_m1sc0nf1g}" "$FILE"; then
    echo "flag-3.txt doesn't contain FLAG_PRIVESC — escalate on the privesc box first." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk14 flag-privesc 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0