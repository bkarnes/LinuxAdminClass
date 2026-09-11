#!/bin/bash
# Verify: ~/ps-all.txt looks like real full ps output.

FILE="$HOME/ps-all.txt"

if [ ! -s "$FILE" ]; then
    echo "~/ps-all.txt is missing or empty (ps aux > ~/ps-all.txt)." >&2
    exit 1
fi

# Header + at least 10 processes
if ! head -1 "$FILE" | grep -qiE "(^USER|^%CPU|PID)"; then
    echo "Missing a header line — capture with ps aux (header included)." >&2
    exit 1
fi

if [ "$(wc -l < "$FILE")" -lt 10 ]; then
    echo "Only $(( $(wc -l < "$FILE") - 1 )) processes captured — use the 'a' flag for ALL processes." >&2
    exit 1
fi

# Should include system daemons (kernel threads count too via ps aux)
if ! grep -qE "(root|kthreadd|systemd)" "$FILE"; then
    echo "Snapshot doesn't include system processes — use ps aux, not bare ps." >&2
    exit 1
fi

exit 0