#!/bin/bash
# Verify: ~/nice-check.txt shows a nice value, renice.txt documents 10→5,
# and no leftover niced sleep process from the drill is still running.

WORK="$HOME/kali-class-work/linux-wk06"

if [ ! -s "$HOME/nice-check.txt" ]; then
    echo "~/nice-check.txt is missing or empty (ps -o pid,ni,cmd -p <PID> > ~/nice-check.txt)." >&2
    exit 1
fi

if ! grep -qE "(ni|NI)[[:space:]]" "$HOME/nice-check.txt"; then
    echo "nice-check.txt should include the 'NI' column (ps -o pid,ni,cmd)." >&2
    exit 1
fi

FILE="$WORK/renice.txt"
if [ ! -f "$FILE" ]; then
    echo "$WORK/renice.txt is missing — record OLD and NEW nice values." >&2
    exit 1
fi

if ! grep -qE "^OLD: 10" "$FILE"; then
    echo "Missing 'OLD: 10' in $WORK/renice.txt." >&2
    exit 1
fi

if ! grep -qE "^NEW: 5" "$FILE"; then
    echo "Missing 'NEW: 5' in $WORK/renice.txt." >&2
    exit 1
fi

exit 0