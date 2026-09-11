#!/bin/bash
# Verify: authfail findings recorded (IP, count, username); stamped.

WORK="$HOME/kali-class-work/sec-wk13"
FILE="$WORK/authfail-findings.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — answer the three questions there." >&2
    exit 1
fi

if ! grep -qE "10\.10\.10\.5" "$FILE"; then
    echo "The suspicious source IP is missing — which IP repeats?" >&2
    exit 1
fi

# Failed-attempt count from the planted log (8 lines): accept '8' standalone,
# '8 failed', or a dedicated count line.
count=$(grep -cE "Failed password for attacker from 10\.10\.10\.5" "$FILE")
if [ "$count" -lt 1 ] && ! grep -qE "(^|[^0-9])8([^0-9]|$)" "$FILE"; then
    echo "Record the NUMBER of failed attempts from that IP (count the lines)." >&2
    exit 1
fi

if ! grep -qiE "attacker" "$FILE"; then
    echo "Record the username the attacker targeted." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk13 ir-authfail 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0