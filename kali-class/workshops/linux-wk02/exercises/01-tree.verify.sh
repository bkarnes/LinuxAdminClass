#!/bin/bash
# Verify: the ~/company tree exists exactly as specified.

need_dir() {
    if [ ! -d "$1" ]; then
        echo "Missing directory: $1" >&2
        exit 1
    fi
}

need_dir "$HOME/company"
need_dir "$HOME/company/docs"
need_dir "$HOME/company/photos"
need_dir "$HOME/company/reports"
need_dir "$HOME/company/reports/2026"

if [ ! -f "$HOME/company/docs/notes.txt" ]; then
    echo "~/company/docs/notes.txt is missing." >&2
    exit 1
fi

exit 0