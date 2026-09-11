#!/bin/bash
# Verify: documented low-priv session; stamped.

WORK="$HOME/kali-class-work/sec-wk10"
FILE="$WORK/initial-shell.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "sshpass -p intern123 ssh -p 2222 intern@127.0.0.1 whoami > $FILE" >&2
    exit 1
fi

if ! grep -qx "intern" "$FILE"; then
    echo "The file should contain 'intern' (proof of the low-priv session)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk10 initial-shell 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0