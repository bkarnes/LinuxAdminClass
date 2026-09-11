#!/bin/bash
# Verify: student cracked THEIR seeded SHA-512 hashes; stamped.

WORK="$HOME/kali-class-work/sec-wk09"
SEEDS="$WORK/seeded/sha512-hashes.txt"
OUT="$WORK/sha512-cracked.txt"

if [ ! -f "$SEEDS" ]; then
    echo "Seed file missing — run kali-class sec-wk09 once to plant your hashes." >&2
    exit 1
fi

if [ ! -s "$OUT" ]; then
    echo "$OUT is missing or empty." >&2
    exit 1
fi

expected_passwords="letmein123 football2026 P@ssw0rd! changeme7"

found=0
for pw in $expected_passwords; do
    if grep -qF "$pw" "$OUT"; then
        found=$((found+1))
    fi
done

if [ "$found" -lt 3 ]; then
    echo "Only $found/4 of YOUR passwords in the results — crack with rockyou." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk09 hashcat-sha512 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0