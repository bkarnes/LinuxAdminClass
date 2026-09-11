#!/bin/bash
# Verify: ~/etc-listing.txt exists and looks like long-format ls output of /etc.

FILE="$HOME/etc-listing.txt"

if [ ! -f "$FILE" ]; then
    echo "~/etc-listing.txt doesn't exist yet. Remember to redirect the output." >&2
    exit 1
fi

# Long format lines start with a permission string like -rw-r--r--
if ! grep -qE '^[-dlbcps][rwxsStT-]{9}' "$FILE"; then
    echo "The file exists but doesn't look like 'ls -l' output. Did you use -l?" >&2
    exit 1
fi

# Should mention /etc content — passwd is always there
if ! grep -qE 'passwd|shadow|apt' "$FILE"; then
    echo "The output doesn't look like a listing of /etc. Did you run it on /etc?" >&2
    exit 1
fi

exit 0