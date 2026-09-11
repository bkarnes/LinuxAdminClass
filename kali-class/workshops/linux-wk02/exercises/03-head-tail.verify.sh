#!/bin/bash
# Verify: ~/head-out.txt has exactly 5 lines and ~/tail-out.txt has exactly 5
# lines, both sourced from a consistent file (syslog if present, else ~/biglog.txt).

# Which source did the student use? Pick whichever exists (syslog preferred).
SRC=""
for candidate in /var/log/syslog "$HOME/biglog.txt"; do
    if [ -f "$candidate" ]; then
        SRC="$candidate"
        break
    fi
done

if [ -z "$SRC" ]; then
    echo "Neither /var/log/syslog nor ~/biglog.txt exists — no source to check against." >&2
    exit 1
fi

if [ ! -f "$HOME/head-out.txt" ]; then
    echo "~/head-out.txt is missing. Remember to redirect head's output." >&2
    exit 1
fi
if [ ! -f "$HOME/tail-out.txt" ]; then
    echo "~/tail-out.txt is missing. Remember to redirect tail's output." >&2
    exit 1
fi

head_lines=$(wc -l < "$HOME/head-out.txt")
tail_lines=$(wc -l < "$HOME/tail-out.txt")

if [ "$head_lines" -ne 5 ]; then
    echo "~/head-out.txt should contain exactly 5 lines (found $head_lines)." >&2
    exit 1
fi
if [ "$tail_lines" -ne 5 ]; then
    echo "~/tail-out.txt should contain exactly 5 lines (found $tail_lines)." >&2
    exit 1
fi

# First line of head must match first line of the source
if [ -n "$(head -n 1 "$SRC")" ]; then
    src_first=$(head -n 1 "$SRC")
    out_first=$(head -n 1 "$HOME/head-out.txt")
    if [ "$src_first" != "$out_first" ]; then
        echo "head-out.txt doesn't start with the same line as $SRC." >&2
        exit 1
    fi
fi

# Last line of tail must match last line of the source
src_last=$(tail -n 1 "$SRC")
out_last=$(tail -n 1 "$HOME/tail-out.txt")
if [ "$src_last" != "$out_last" ]; then
    echo "tail-out.txt doesn't end with the same line as $SRC." >&2
    exit 1
fi

exit 0