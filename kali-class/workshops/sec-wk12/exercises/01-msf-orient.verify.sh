#!/bin/bash
# Verify: msf orientation documented (version + vsftpd search); stamped.

WORK="$HOME/kali-class-work/sec-wk12"
FILE="$WORK/msf-orientation.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — paste your msfconsole session output." >&2
    exit 1
fi

if ! grep -qiE "Framework: [0-9]" "$FILE"; then
    echo "Missing the 'Framework: x.y.z' version line from msfconsole." >&2
    exit 1
fi

if ! grep -q "vsftpd_234_backdoor" "$FILE"; then
    echo "The search results should include exploit/unix/ftp/vsftpd_234_backdoor." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk12 msf-orient 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0