#!/bin/bash
# Verify: sl is NOT currently installed and ~/sl-removed.txt documents that.

FILE="$HOME/sl-removed.txt"

if command -v sl >/dev/null 2>&1; then
    echo "sl is still installed — remove it (sudo apt purge -y sl && sudo apt autoremove -y)." >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "~/sl-removed.txt is missing (dpkg -l sl > ~/sl-removed.txt)." >&2
    exit 1
fi

# dpkg -l on a removed package prints 'un' (uninstalled) or 'no packages found'
if ! grep -qE "(^un |no packages found)" "$FILE"; then
    echo "The dpkg output doesn't show sl as removed. Re-run dpkg -l sl." >&2
    exit 1
fi

exit 0