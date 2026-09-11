#!/bin/bash
# Verify: chronological timeline incl. the hidden payload event; stamped.

WORK="$HOME/kali-class-work/sec-wk13"
FILE="$WORK/timeline.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — write the ordered event lines." >&2
    exit 1
fi

# Must mention the hidden payload (by name or as 'hidden')
if ! grep -qiE "(payload|hidden)" "$FILE"; then
    echo "Timeline should include the hidden .payload.sh event." >&2
    exit 1
fi

# Must include times from the incident window in ascending order
if ! grep -qE "03:1[012]" "$FILE"; then
    echo "Timeline lines should start with the incident-window times (03:10–03:12)." >&2
    exit 1
fi

# Ascending order check: extract times, sort, compare
extracted=$(grep -oE "03:1[0-9]:[0-9]{2}" "$FILE" | head -10)
sorted=$(echo "$extracted" | LC_ALL=C sort)
if [ "$extracted" != "$sorted" ]; then
    echo "The timeline isn't in chronological order — sort your events." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk13 ir-timeline 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0