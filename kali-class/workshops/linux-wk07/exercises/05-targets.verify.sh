#!/bin/bash
# Verify: target.txt records the real default + runlevel equivalence;
# targets-list.txt lists systemd targets.

WORK="$HOME/kali-class-work/linux-wk07"
FILE="$WORK/target.txt"
LIST="$WORK/targets-list.txt"

actual_default=$(systemctl get-default 2>/dev/null)
if [ -z "$actual_default" ]; then
    echo "Could not read the system default target — is systemd running?" >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty (systemctl get-default)." >&2
    exit 1
fi

first=$(head -n1 "$FILE" | tr -d '[:space:]')
if [ "$first" != "$actual_default" ]; then
    echo "target.txt first line ('$first') should be the real default: $actual_default" >&2
    exit 1
fi

# Runlevel equivalence line
if ! grep -qE "^equivalent: runlevel [0-9]" "$FILE"; then
    echo "target.txt needs a final line like: equivalent: runlevel 5" >&2
    exit 1
fi

# The equivalence must be correct
rl=$(grep -oE "runlevel [0-9]" "$FILE" | tail -1 | grep -oE "[0-9]")
case "$actual_default" in
    multi-user.target)  want=3 ;;
    graphical.target)   want=5 ;;
    *) want=0 ;;
esac
if [ "$want" -ne 0 ] && [ "$rl" != "$want" ]; then
    echo "Runlevel equivalence wrong: $actual_default maps to runlevel $want." >&2
    exit 1
fi

if [ ! -s "$LIST" ]; then
    echo "$LIST is missing or empty (systemctl list-units --type=target)." >&2
    exit 1
fi

if ! grep -qE "\.target" "$LIST"; then
    echo "targets-list.txt doesn't look like target unit output." >&2
    exit 1
fi

exit 0