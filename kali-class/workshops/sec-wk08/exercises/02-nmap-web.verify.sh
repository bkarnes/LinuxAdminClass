#!/bin/bash
# Verify: web scan file exists, mentions the host + an open web port, stamped.

WORK="$HOME/kali-class-work/sec-wk08"
FILE="$WORK/nmap-web-01.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty (nmap -sV -p 80,443 -oN $FILE 172.16.10.10)." >&2
    exit 1
fi

if ! grep -q "172.16.10.10" "$FILE"; then
    echo "The scan doesn't reference p-web-01 (172.16.10.10)." >&2
    exit 1
fi

if ! grep -qE "^(80|443)/tcp[[:space:]]+open" "$FILE"; then
    echo "No open web ports found in the scan output — is the lab up?" >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk08 nmap-web 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0