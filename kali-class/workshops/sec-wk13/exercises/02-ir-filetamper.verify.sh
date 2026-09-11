#!/bin/bash
# Verify: filetamper remediated INSIDE the container + findings documented.

C=linux-ir-filetamper
WORK="$HOME/kali-class-work/sec-wk13"
FILE="$WORK/filetamper-findings.txt"

# Is the container running?
if ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^$C$"; then
    echo "Container $C isn't running (docker run -d --name $C linux-ir-filetamper:1.0)." >&2
    exit 1
fi

# Remediation checks inside the container
mode=$(docker exec "$C" stat -c '%a' /srv/grades/final.csv 2>/dev/null)
if [ "$mode" != "600" ]; then
    echo "The file is mode $mode inside the container — restore to 600 (chmod 600)." >&2
    exit 1
fi

owner=$(docker exec "$C" stat -c '%U:%G' /srv/grades/final.csv 2>/dev/null)
if [ "$owner" != "root:root" ]; then
    echo "The file is owned by $owner inside the container — restore root:root." >&2
    exit 1
fi

if docker exec "$C" grep -q "MODIFIED" /srv/grades/final.csv 2>/dev/null; then
    echo "The tampered line (MODIFIED) is still in the file — remove it." >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "$WORK/filetamper-findings.txt is missing — save after-state evidence + a risk note." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk13 ir-filetamper 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0