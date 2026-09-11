#!/bin/bash
# Verify: ~/users-list.txt contains real usernames from /etc/passwd, root included.

FILE="$HOME/users-list.txt"

if [ ! -f "$FILE" ]; then
    echo "~/users-list.txt is missing. Extract usernames from /etc/passwd." >&2
    exit 1
fi

if ! grep -qx "root" "$FILE"; then
    echo "The list doesn't include 'root' — not a complete username extraction." >&2
    exit 1
fi

if ! grep -qx "$USER" "$FILE"; then
    echo "The list doesn't include YOUR username ($USER)." >&2
    exit 1
fi

# No colons: they should have extracted field 1 only
if grep -q ":" "$FILE"; then
    echo "The file still contains colons — that's the whole /etc/passwd, not just usernames." >&2
    exit 1
fi

# Cross-check: count of lines should equal number of accounts
if [ "$(wc -l < "$FILE")" -ne "$(wc -l < /etc/passwd)" ]; then
    echo "Line count doesn't match /etc/passwd — did you filter instead of extract?" >&2
    exit 1
fi

exit 0