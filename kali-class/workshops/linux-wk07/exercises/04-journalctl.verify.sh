#!/bin/bash
# Verify: two journal extracts exist and look like journalctl output.

if [ ! -s "$HOME/journal-recent.txt" ]; then
    echo "~/journal-recent.txt is missing or empty (journalctl -n 20 --no-pager > ~/journal-recent.txt)." >&2
    exit 1
fi

if ! grep -qE "^[A-Z][a-z]{2} [0-9]{2} " "$HOME/journal-recent.txt"; then
    echo "~/journal-recent.txt doesn't look like journalctl output (missing date stamps)." >&2
    exit 1
fi

if [ ! -f "$HOME/journal-ssh.txt" ]; then
    echo "~/journal-ssh.txt is missing (journalctl -u ssh -n 20 --no-pager)." >&2
    exit 1
fi

# Unit-scoped extract: ssh-related lines, OR the legitimate "-- No entries --"
# response for a unit with no journal records yet. Both are correct evidence
# the student ran the query.
if [ -s "$HOME/journal-ssh.txt" ] \
   && ! grep -qiE "ssh|No entries" "$HOME/journal-ssh.txt"; then
    echo "~/journal-ssh.txt has content but nothing ssh-related — scope with -u ssh." >&2
    exit 1
fi

exit 0