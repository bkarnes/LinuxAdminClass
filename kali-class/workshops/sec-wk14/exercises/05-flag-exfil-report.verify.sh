#!/bin/bash
# Verify: FLAG_EXFIL + capstone report (all template sections); both stamped.

WORK="$HOME/kali-class-work/sec-wk14"
FLAG="$WORK/flag-5.txt"
REPORT="$WORK/capstone-report.md"

if [ ! -s "$FLAG" ]; then
    echo "$FLAG is missing or empty — read the crown jewels on c-backup-01." >&2
    exit 1
fi

if ! grep -q "FLAG{cr0wn_j3w3ls_3xf1ltr4t3d}" "$FLAG"; then
    echo "flag-5.txt doesn't contain FLAG_EXFIL — cat /opt/crown-jewels/FLAG.txt on c-backup-01." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk14 flag-exfil 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

if [ ! -s "$REPORT" ]; then
    echo "$REPORT is missing or empty — write the pentest report (Machine_Template.md)." >&2
    exit 1
fi

# Template sections (capstone-modified)
missing=0
for section in "NMAP" "Kill Chain" "Flags Captured" "Take Away"; do
    if ! grep -qiE "$section" "$REPORT"; then
        echo "Report is missing the section: $section" >&2
        missing=1
    fi
done
[ $missing -eq 1 ] && exit 1

# All five flags named in the report
for f in FLAG_RECON FLAG_FOOTHOLD FLAG_PRIVESC FLAG_PIVOT FLAG_EXFIL; do
    if ! grep -q "$f" "$REPORT"; then
        echo "Report's Flags Captured section should list $f" >&2
        missing=1
    fi
done
[ $missing -eq 1 ] && exit 1

STAMP=$(kali-class check-stamp sec-wk14 capstone-report 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0