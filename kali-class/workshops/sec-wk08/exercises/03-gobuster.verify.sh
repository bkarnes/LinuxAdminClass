#!/bin/bash
# Verify: gobuster (or dirb) output exists and shows enumerated paths; stamped.

WORK="$HOME/kali-class-work/sec-wk08"
FILE="$WORK/gobuster-web02.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty. Run gobuster dir -u http://172.16.10.12 -w /usr/share/wordlists/dirb/common.txt -o $FILE" >&2
    exit 1
fi

# gobuster format: "Status: 200, Size: ..., Path: /xxx" or dirb: "+ /xxx/"
if ! grep -qE "(Path: /|Status: [0-9]+|^\+[[:space:]]*/)" "$FILE"; then
    echo "The file doesn't look like gobuster/dirb output — save the tool's own output." >&2
    exit 1
fi

# At least one discovered path
if ! grep -qE "(Path: /|^\+ ?/|Found: /)" "$FILE"; then
    echo "No paths enumerated. Wrong wordlist or wrong URL?" >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk08 gobuster 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0