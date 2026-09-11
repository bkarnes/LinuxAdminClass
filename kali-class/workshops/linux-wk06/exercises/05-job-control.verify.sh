#!/bin/bash
# Verify: jobs-list.txt captured a running job; jobs-after.txt shows none.
# This drill is self-reported (jobs are per-terminal) but format-checked,
# and the before/after pair must be consistent.

BEFORE="$HOME/jobs-list.txt"
AFTER="$HOME/jobs-after.txt"

if [ ! -s "$BEFORE" ]; then
    echo "~/jobs-list.txt is missing or empty (start sleep 300 &, then: jobs > ~/jobs-list.txt)." >&2
    exit 1
fi

if ! grep -qE "sleep" "$BEFORE"; then
    echo "~/jobs-list.txt doesn't mention the sleep job." >&2
    exit 1
fi

if [ ! -f "$AFTER" ]; then
    echo "~/jobs-after.txt is missing (jobs > ~/jobs-after.txt after killing %1)." >&2
    exit 1
fi

# After the kill, the sleep job must be absent
if grep -qE "sleep" "$AFTER"; then
    echo "~/jobs-after.txt still shows the sleep job — did you kill %1?" >&2
    exit 1
fi

exit 0