#!/bin/bash
# Verify: the ~/practice/company tree exists exactly as specified.

need_dir() {
    if [ ! -d "$1" ]; then
        echo "Missing directory: $1" >&2
        exit 1
    fi
}

need_dir "$HOME/practice/company"
need_dir "$HOME/practice/company/docs"
need_dir "$HOME/practice/company/photos"
need_dir "$HOME/practice/company/reports"
need_dir "$HOME/practice/company/reports/2026"

if [ ! -f "$HOME/practice/company/docs/notes.txt" ]; then
    echo "~/practice/company/docs/notes.txt is missing." >&2
    exit 1
fi

exit 0