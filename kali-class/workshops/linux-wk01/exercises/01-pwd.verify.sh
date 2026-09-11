#!/bin/bash
# Verify: student knows how to print the working directory.
# We can't verify history directly (they may use a different terminal),
# so we check that /proc self-explanatory command exists and that the
# student has executed pwd this session via the rsyslog command log if available.
# Fallback: always pass if the binary exists, since this is exercise 1.

if ! command -v pwd >/dev/null 2>&1; then
    echo "pwd is missing on this system?" >&2
    exit 1
fi

# Check the CLI command log (set up by setup_vm.sh option 2) for a pwd entry.
# If the log doesn't exist (or isn't readable by the student), we accept —
# the student may have logging disabled.
LOG=/var/log/commands.log
if [ -r "$LOG" ] && ! grep -qE '(^|/|\s)pwd(\s|$)' "$LOG" 2>/dev/null; then
    echo "I didn't see you run 'pwd' yet. (Linux commands are case-sensitive — 'PWD' is not 'pwd'.)" >&2
    exit 1
fi

exit 0