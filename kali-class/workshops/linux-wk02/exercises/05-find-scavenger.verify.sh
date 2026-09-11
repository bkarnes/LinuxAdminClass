#!/bin/bash
# Verify: ~/practice/found-seed.txt contains THIS student's seed-value.
# The seed file is planted by the runner (anti_cheat.ensure_seed_files) at
# workshop start, keyed to the registered student — a friend's copy won't match.

SEED_FILE="$HOME/kali-class-work/linux-wk02/seeded/scavenger.txt"
FOUND="$HOME/practice/found-seed.txt"

if [ ! -f "$SEED_FILE" ]; then
    echo "Seed file missing — start this workshop with 'kali-class linux-wk02' so it can plant one." >&2
    exit 1
fi

expected=$(grep -oP '^seed-value=\K.*' "$SEED_FILE" | head -1)
if [ -z "$expected" ]; then
    echo "Seed file is corrupt (no seed-value line). Re-run kali-class to re-plant." >&2
    exit 1
fi

if [ ! -f "$HOME/practice/found-seed.txt" ]; then
    echo "~/practice/found-seed.txt doesn't exist yet. Find the seed file and copy it there." >&2
    exit 1
fi

if ! grep -qF "seed-value=$expected" "$HOME/practice/found-seed.txt"; then
    echo "found-seed.txt doesn't contain YOUR seed-value. Did you copy the right file?" >&2
    exit 1
fi

# Content integrity: the copy must carry the full seed content
if ! grep -qF "seed-label=scavenger" "$HOME/practice/found-seed.txt"; then
    echo "found-seed.txt is incomplete — copy the whole file, not a fragment." >&2
    exit 1
fi

exit 0