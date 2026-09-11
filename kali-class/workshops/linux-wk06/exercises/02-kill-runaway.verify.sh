#!/bin/bash
# Verify: the runaway process is dead and the kill was documented.

WORK="$HOME/kali-class-work/linux-wk06"
STAMP="$WORK/runaway.pid"

# The runaway must be gone
if [ -f "$STAMP" ]; then
    pid=$(cat "$STAMP" 2>/dev/null)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        # cmdline (not comm) — the process renames itself via exec -a
        if tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q "kali-class-runaway"; then
            echo "The runaway process (PID $pid) is STILL RUNNING. Find and kill it." >&2
            exit 1
        fi
    fi
fi

# Documentation
FILE="$WORK/killed.txt"
if [ ! -f "$FILE" ]; then
    echo "$FILE is missing — record the PID and signal you used." >&2
    exit 1
fi

if ! grep -qE "^PID: [0-9]+" "$FILE"; then
    echo "Missing a 'PID: <number>' line in $FILE." >&2
    exit 1
fi

if ! grep -qE "^SIGNAL: (TERM|KILL|term|kill|15|9)" "$FILE"; then
    echo "Missing a 'SIGNAL: TERM' or 'SIGNAL: KILL' line in $FILE." >&2
    exit 1
fi

exit 0