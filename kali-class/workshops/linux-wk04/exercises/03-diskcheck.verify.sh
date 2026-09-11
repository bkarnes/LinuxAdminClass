#!/bin/bash
# Verify: ~/scripts/diskcheck.sh reports usage + OK and exits 0 when all's well.

SCRIPT="$HOME/scripts/diskcheck.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "~/scripts/diskcheck.sh doesn't exist yet." >&2
    exit 1
fi

out=$(bash "$SCRIPT" 2>/dev/null)
rc=$?

if [ $rc -ne 0 ]; then
    echo "Script exited $rc on a healthy system — it should exit 0 here." >&2
    exit 1
fi

if ! echo "$out" | grep -qE "Usage is [0-9]+%, status: OK"; then
    echo "Output doesn't match 'Usage is <N>%, status: OK'. Got: '$out'" >&2
    exit 1
fi

# Sanity: the reported number should be a plausible disk usage (0-100)
n=$(echo "$out" | grep -oE "[0-9]+")
if [ -z "$n" ] || [ "$n" -gt 100 ]; then
    echo "The usage number looks wrong ($n)." >&2
    exit 1
fi

exit 0