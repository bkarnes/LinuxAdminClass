#!/bin/bash
# Verify: ssh service is active now AND the Active line was recorded.

FILE="$HOME/kali-class-work/linux-wk07/ssh-active.txt"

state=$(systemctl is-active ssh 2>/dev/null || echo unavailable)
if [ "$state" != "active" ]; then
    echo "ssh service is '$state' — restart it (sudo systemctl restart ssh)." >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty (systemctl status ssh | grep Active)." >&2
    exit 1
fi

if ! grep -qE "Active: active" "$FILE"; then
    echo "$FILE should contain the 'Active: active (running)' line." >&2
    exit 1
fi

exit 0