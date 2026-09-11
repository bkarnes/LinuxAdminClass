#!/bin/bash
# Verify: ~/practice/first.txt exists as an empty file created by the student.

DIR="$HOME/practice"
FILE="$DIR/first.txt"

if [ ! -d "$DIR" ]; then
    echo "The directory ~/practice doesn't exist yet. Did you create it?" >&2
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "~/practice exists, but first.txt is missing inside it." >&2
    exit 1
fi

if [ -s "$FILE" ]; then
    echo "first.txt exists but is not empty. 'touch' should create it empty." >&2
    exit 1
fi

exit 0