#!/bin/bash
# Verify: ~/perm-quiz.txt has the real permission string of /etc/passwd on
# line 1 and correct read/write interpretation on lines 2 and 3.

FILE="$HOME/perm-quiz.txt"

if [ ! -f "$FILE" ]; then
    echo "~/perm-quiz.txt is missing." >&2
    exit 1
fi

actual=$(stat -c '%A' /etc/passwd)

line1=$(sed -n '1p' "$FILE" | tr -d '[:space:]')
if [ "$line1" != "$actual" ]; then
    echo "Line 1 should be the permission string of /etc/passwd (expected $actual, got '$line1')." >&2
    exit 1
fi

# What owner can do: does line 1 grant owner write? Then answer must mention write.
owner_write=no
case "$actual" in
    -??w*|??w*) owner_write=yes ;;
esac

line2=$(sed -n '2p' "$FILE" | tr '[:upper:]' '[:lower:]')
if [ "$owner_write" = yes ]; then
    if ! echo "$line2" | grep -q "read-write\|read and write\|rw"; then
        echo "Line 2: the owner can read-write, but your answer says otherwise." >&2
        exit 1
    fi
else
    if ! echo "$line2" | grep -q "read"; then
        echo "Line 2: at minimum the owner can read; your answer seems wrong." >&2
        exit 1
    fi
fi

line3=$(sed -n '3p' "$FILE" | tr '[:upper:]' '[:lower:]')
if ! echo "$line3" | grep -q "read"; then
    echo "Line 3: group members can at least read; your answer seems wrong." >&2
    exit 1
fi
if echo "$line3" | grep -q "read-write\|full control"; then
    echo "Line 3: group does NOT get write on $actual — check again." >&2
    exit 1
fi

exit 0