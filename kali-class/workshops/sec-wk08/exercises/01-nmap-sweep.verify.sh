#!/bin/bash
# Verify: nmap sweep file exists, looks like real nmap -sn output, and the
# student stamped it.

WORK="$HOME/kali-class-work/sec-wk08"
FILE="$WORK/nmap-sweep.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty (nmap -sn 172.16.10.0/24 > $FILE)." >&2
    exit 1
fi

if ! grep -q "Starting Nmap" "$FILE"; then
    echo "That doesn't look like nmap output — capture the real scan output." >&2
    exit 1
fi

up_count=$(grep -cE "Nmap scan report for 172\.16\.10\.(10|11|12|13)$" "$FILE")
if [ "$up_count" -lt 4 ]; then
    echo "Only $up_count of the 4 public targets found. Is the lab running? (kali-class setup-bhb)" >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk08 nmap-sweep 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0