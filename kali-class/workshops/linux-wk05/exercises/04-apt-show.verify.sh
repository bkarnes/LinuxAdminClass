#!/bin/bash
# Verify: ~/tree-info.txt contains apt's package details incl. a Depends line.

FILE="$HOME/tree-info.txt"

if [ ! -s "$FILE" ]; then
    echo "~/tree-info.txt is missing or empty (apt show tree > ~/tree-info.txt)." >&2
    exit 1
fi

if ! grep -qiE "^Package: tree" "$FILE"; then
    echo "The file doesn't contain apt's 'Package: tree' record." >&2
    exit 1
fi

if ! grep -qE "^Depends:" "$FILE"; then
    echo "Missing a 'Depends:' line — append the dependencies (apt show tree | grep ^Depends)." >&2
    exit 1
fi

exit 0