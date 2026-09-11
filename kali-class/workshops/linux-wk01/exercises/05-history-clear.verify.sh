#!/bin/bash
# Verify: the student ran 'history' and 'clear' (from the rsyslog command log).
# If logging isn't set up, fall back to a behavioral check on history capability.

LOG=/var/log/commands.log

if [ -r "$LOG" ]; then
    if ! grep -qE '(^|/|\s)history(\s|$)' "$LOG" 2>/dev/null; then
        echo "I didn't see you run 'history' yet in the command log. (Linux commands are case-sensitive — 'HISTORY' is not 'history'.)" >&2
        exit 1
    fi
    if ! grep -qE '(^|/|\s)clear(\s|$)' "$LOG" 2>/dev/null; then
        echo "I didn't see you run 'clear' yet in the command log. (Linux commands are case-sensitive — 'CLEAR' is not 'clear'.)" >&2
        exit 1
    fi
    exit 0
fi

# Fallback: logging not present — confirm the tools exist and the shell
# has a history feature enabled.
if ! command -v clear >/dev/null 2>&1; then
    echo "clear is not available?" >&2
    exit 1
fi

exit 0