#!/bin/bash
# Verify: ssh is enabled for boot AND the is-enabled output was recorded.

FILE="$HOME/kali-class-work/linux-wk07/ssh-enabled.txt"

state=$(systemctl is-enabled ssh 2>/dev/null || echo not-found)
if [ "$state" != "enabled" ]; then
    echo "ssh is '$state' — enable it: sudo systemctl enable ssh" >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty (systemctl is-enabled ssh > $FILE)." >&2
    exit 1
fi

if ! grep -q "^enabled" "$FILE"; then
    echo "$FILE should contain the word: enabled" >&2
    exit 1
fi

exit 0