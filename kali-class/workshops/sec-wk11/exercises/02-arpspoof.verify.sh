#!/bin/bash
# Verify: arpspoof output captured; stamped.

WORK="$HOME/kali-class-work/sec-wk11"
FILE="$WORK/arpspoof.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "sudo arpspoof -i <iface> -t 172.16.10.11 172.16.10.10 | tee $FILE" >&2
    exit 1
fi

# arpspoof prints repeated lines like: "…mac 172.16.10.10 is-at <mac>"
if ! grep -qiE "is-at" "$FILE"; then
    echo "The output doesn't look like arpspoof replies (no 'is-at' lines)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk11 arpspoof 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0