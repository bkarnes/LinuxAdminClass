#!/bin/bash
# Verify: ~/practice/head-out.txt has exactly 5 lines and
# ~/practice/tail-out.txt has exactly 5 lines, both sourced from a
# consistent file (~/practice/biglog.txt primary; a READABLE system log
# as fallback).

# Which source did the student use? Pick whichever is READABLE (not merely
# present — rsyslog creates logs as 0640 root:adm, unreadable by students).
SRC=""
for candidate in "$HOME/practice/biglog.txt" /var/log/syslog; do
    if [ -r "$candidate" ]; then
        SRC="$candidate"
        break
    fi
done

if [ -z "$SRC" ]; then
    echo "No readable source file found. Create the practice file first:" >&2
    echo "  seq 1 1000 > ~/practice/biglog.txt" >&2
    exit 1
fi

if [ ! -f "$HOME/practice/head-out.txt" ]; then
    echo "~/practice/head-out.txt is missing. Remember to redirect head's output." >&2
    exit 1
fi
if [ ! -f "$HOME/practice/tail-out.txt" ]; then
    echo "~/practice/tail-out.txt is missing. Remember to redirect tail's output." >&2
    exit 1
fi

head_lines=$(wc -l < "$HOME/practice/head-out.txt")
tail_lines=$(wc -l < "$HOME/practice/tail-out.txt")

if [ "$head_lines" -ne 5 ]; then
    echo "~/practice/head-out.txt should contain exactly 5 lines (found $head_lines)." >&2
    exit 1
fi
if [ "$tail_lines" -ne 5 ]; then
    echo "~/practice/tail-out.txt should contain exactly 5 lines (found $tail_lines)." >&2
    exit 1
fi

# First line of head must match first line of the source
if [ -n "$(head -n 1 "$SRC")" ]; then
    src_first=$(head -n 1 "$SRC")
    out_first=$(head -n 1 "$HOME/practice/head-out.txt")
    if [ "$src_first" != "$out_first" ]; then
        echo "head-out.txt doesn't start with the same line as $SRC." >&2
        exit 1
    fi
fi

# Last line of tail must match last line of the source
src_last=$(tail -n 1 "$SRC")
out_last=$(tail -n 1 "$HOME/practice/tail-out.txt")
if [ "$src_last" != "$out_last" ]; then
    echo "tail-out.txt doesn't end with the same line as $SRC." >&2
    exit 1
fi

exit 0