#!/bin/bash
# Verify: copy happened, then move+rename; original untouched in docs/.

if [ ! -f "$HOME/practice/company/docs/notes.txt" ]; then
    echo "~/practice/company/docs/notes.txt is gone — you should still have the original!" >&2
    exit 1
fi

if [ -e "$HOME/practice/company/docs/notes-backup.txt" ]; then
    echo "notes-backup.txt should no longer be in ~/practice/company/docs (you were to move it)." >&2
    exit 1
fi

if [ ! -f "$HOME/practice/company/reports/2026-notes.txt" ]; then
    echo "~/practice/company/reports/2026-notes.txt doesn't exist yet." >&2
    exit 1
fi

# The copy should be an exact duplicate of the original (empty at this stage,
# but same size either way)
if ! cmp -s "$HOME/practice/company/docs/notes.txt" "$HOME/practice/company/reports/2026-notes.txt"; then
    echo "2026-notes.txt exists but doesn't match notes.txt. Did you copy rather than recreate?" >&2
    exit 1
fi

exit 0