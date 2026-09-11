#!/bin/bash
# Verify: hash-type identifications recorded + stamped.

WORK="$HOME/kali-class-work/sec-wk09"
FILE="$WORK/hash-types.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — record your identifications (2 lines)." >&2
    exit 1
fi

if ! grep -qiE "md5-hashes\.txt:.*md5" "$FILE"; then
    echo "Missing/incorrect line for md5-hashes.txt (should say MD5)." >&2
    exit 1
fi

if ! grep -qiE "sha512-hashes\.txt:.*(sha.?512|SHA-512)" "$FILE"; then
    echo "Missing/incorrect line for sha512-hashes.txt (should say SHA-512)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk09 hashid 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0