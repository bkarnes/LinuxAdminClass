#!/bin/bash
# Verify: post-exploitation info captured; stamped.

WORK="$HOME/kali-class-work/sec-wk12"
FILE="$WORK/postex-info.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — save uname/id/ip output from the shell." >&2
    exit 1
fi

if ! grep -qiE "(Linux|uid=)" "$FILE"; then
    echo "The file should include uname and/or id output from the target." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk12 postex 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0