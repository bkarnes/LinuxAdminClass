#!/bin/bash
# Verify: proof of root via the /etc/passwd vector; stamped.

WORK="$HOME/kali-class-work/sec-wk10"
FILE="$WORK/privesc-passwd.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — capture whoami after su kc." >&2
    exit 1
fi

if ! grep -qx "root" "$FILE"; then
    echo "The file should contain 'root' — prove the passwd-user escalation." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk10 privesc-passwd 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0