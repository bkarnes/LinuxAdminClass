#!/bin/bash
# Verify: FLAG_FOOTHOLD claimed; stamped.

WORK="$HOME/kali-class-work/sec-wk14"
FILE="$WORK/flag-2.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    exit 1
fi

if ! grep -q "FLAG{ftpd_b4ckd00r_f00th0ld}" "$FILE"; then
    echo "flag-2.txt doesn't contain FLAG_FOOTHOLD — cat /root/flag.txt on p-ftp-01." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk14 flag-foothold 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0