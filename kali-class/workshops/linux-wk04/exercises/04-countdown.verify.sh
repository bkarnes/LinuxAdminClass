#!/bin/bash
# Verify: ~/scripts/countdown.sh counts down from an argument, errors politely
# without one (exit 1).

SCRIPT="$HOME/scripts/countdown.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "~/scripts/countdown.sh doesn't exist yet." >&2
    exit 1
fi

# Case 1: no argument → usage message + exit 1
out=$(bash "$SCRIPT" 2>/dev/null)
rc=$?
if [ $rc -ne 1 ]; then
    echo "Running with no argument should exit 1 (got $rc)." >&2
    exit 1
fi
if ! echo "$out" | grep -qi "usage"; then
    echo "No-argument run should print a usage message. Got: '$out'" >&2
    exit 1
fi

# Case 2: argument 3 → three lines: 3, 2, 1
out=$(bash "$SCRIPT" 3 2>/dev/null)
rc=$?
if [ $rc -ne 0 ]; then
    echo "Running with '3' should exit 0 (got $rc)." >&2
    exit 1
fi

if [ "$out" != $'3\n2\n1' ]; then
    echo "Countdown from 3 should print exactly '3', '2', '1' on three lines. Got: '$out'" >&2
    exit 1
fi

exit 0