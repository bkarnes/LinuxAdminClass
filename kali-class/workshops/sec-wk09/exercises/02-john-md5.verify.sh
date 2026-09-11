#!/bin/bash
# Verify: the student cracked THEIR seeded MD5 hashes — plaintexts must
# match this student's planted values. Stamped.

WORK="$HOME/kali-class-work/sec-wk09"
SEEDS="$WORK/seeded/md5-hashes.txt"
OUT="$WORK/md5-cracked.txt"

if [ ! -f "$SEEDS" ]; then
    echo "Seed file missing — run kali-class sec-wk09 once to plant your hashes." >&2
    exit 1
fi

if [ ! -s "$OUT" ]; then
    echo "$OUT is missing or empty (john --show --format=Raw-MD5 <hashfile> > $OUT)." >&2
    exit 1
fi

# The cracked passwords for THIS student (deterministic)
expected_passwords="letmein123 football2026 P@ssw0rd! changeme7"

found=0
for pw in $expected_passwords; do
    if grep -qF "$pw" "$OUT"; then
        found=$((found+1))
    fi
done

if [ "$found" -lt 3 ]; then
    echo "Only $found/4 of YOUR passwords appear in the results — crack with rockyou." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk09 john-md5 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0