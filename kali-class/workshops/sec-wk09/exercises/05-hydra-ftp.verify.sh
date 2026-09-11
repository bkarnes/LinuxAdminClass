#!/bin/bash
# Verify: hydra FTP run documented against p-ftp-01; stamped.

WORK="$HOME/kali-class-work/sec-wk09"
FILE="$WORK/hydra-ftp.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "hydra -l ftpuser -P <passwords> 172.16.10.11 -t 4 ftp -o $FILE" >&2
    exit 1
fi

if ! grep -qE "(172\.16\.10\.11|ftp)" "$FILE"; then
    echo "Output doesn't reference the FTP target — run against 172.16.10.11." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk09 hydra-ftp 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

if grep -qE "login:" "$FILE" && grep -qiE "password" "$FILE"; then
    exit 0
fi

if grep -qE "(Hydra|hydra)" "$FILE"; then
    echo "Hydra ran but no hit — include 'ftp123' (and try anonymous) in the attack." >&2
    exit 1
fi

echo "Saved output doesn't look like hydra output." >&2
exit 1