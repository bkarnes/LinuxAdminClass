#!/bin/bash
# Verify: proof of root via the SUID path; stamped.
# Accepts direct 'root' output OR a whoami/id captured through the spawner.

WORK="$HOME/kali-class-work/sec-wk10"
FILE="$WORK/privesc-suid.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — capture proof that you ran whoami as root via nanohelp." >&2
    exit 1
fi

if ! grep -qx "root" "$FILE"; then
    echo "The file should contain 'root' (your whoami output inside the elevated shell)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk10 privesc-suid 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0