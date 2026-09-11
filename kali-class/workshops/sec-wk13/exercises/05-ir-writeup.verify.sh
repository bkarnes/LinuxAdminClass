#!/bin/bash
# Verify: a structured incident write-up exists with all template sections.

WORK="$HOME/kali-class-work/sec-wk13"
FILE="$WORK/incident-writeup.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — write the incident write-up." >&2
    exit 1
fi

# All five required template sections
missing=0
for section in "Issue Summary" "Evidence" "Commands Used" "Actions Taken" "Outcome"; do
    if ! grep -qiE "$section" "$FILE"; then
        echo "Write-up is missing the section: $section" >&2
        missing=1
    fi
done
[ $missing -eq 1 ] && exit 1

# Substance: at least 10 non-empty lines
if [ "$(grep -cE '\S' "$FILE")" -lt 10 ]; then
    echo "Write-up is too thin (fewer than 10 content lines) — fill the template." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk13 ir-writeup 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0