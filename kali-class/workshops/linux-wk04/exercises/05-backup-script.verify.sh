#!/bin/bash
# Verify: ~/scripts/backup.sh exists, is executable, and has produced a
# today-dated tarball containing THIS student's seeded files (token-checked).

SCRIPT="$HOME/scripts/backup.sh"
SEED_ROOT="$HOME/kali-class-work/linux-wk04/seeded"
BACKUPS="$HOME/backups"
TODAY=$(date +%Y%m%d)
ARCHIVE="$BACKUPS/backup-$TODAY.tar.gz"

if [ ! -d "$SEED_ROOT" ]; then
    echo "Seed directory missing — start the workshop with 'kali-class linux-wk04' to plant it." >&2
    exit 1
fi

# Seed marker must match this student (planted by the runner)
MARKER="$SEED_ROOT/.kali-class-seeded"
if [ ! -f "$MARKER" ]; then
    echo "Seed marker missing — re-run kali-class to plant your seed files." >&2
    exit 1
fi

if [ ! -x "$SCRIPT" ]; then
    echo "~/scripts/backup.sh doesn't exist or isn't executable." >&2
    exit 1
fi

# The script must actually create the archive — run it (idempotent, dated).
bash "$SCRIPT" >/dev/null 2>&1

if [ ! -f "$ARCHIVE" ]; then
    echo "Expected archive $ARCHIVE wasn't created. Did the script run successfully?" >&2
    exit 1
fi

# The tarball must contain the seeded directory
if ! tar -tzf "$ARCHIVE" 2>/dev/null | grep -q "seeded/"; then
    echo "The archive doesn't contain the seeded directory. Archive the whole seeded dir." >&2
    exit 1
fi

# Token check: extract and confirm the student's own token is inside
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
tar -xzf "$ARCHIVE" -C "$tmp" 2>/dev/null

token=$(grep -h -m1 -oP '^seed-value=\K.*' "$tmp"/seeded/backup_source.txt 2>/dev/null)
if [ -z "$token" ]; then
    echo "Archive doesn't contain backup_source.txt with a seed-value." >&2
    exit 1
fi

# Compare against what the runner planted for THIS user
planted=$(grep -m1 -oP '^seed-value=\K.*' "$SEED_ROOT/backup_source.txt" 2>/dev/null)
if [ "$token" != "$planted" ]; then
    echo "The archive's seed token doesn't match YOURS. Archive your own seeded directory!" >&2
    exit 1
fi

exit 0