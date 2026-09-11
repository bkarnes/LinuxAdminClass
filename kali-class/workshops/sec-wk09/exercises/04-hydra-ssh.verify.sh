#!/bin/bash
# Verify: hydra run against the jumpbox documented; stamped. A valid 'login:'
# line is required (hydra prints 'login: ... password: ...' on a hit).
# The lab accepts root:toor on p-jumpbox-01.

WORK="$HOME/kali-class-work/sec-wk09"
FILE="$WORK/hydra-ssh.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "hydra -L <users> -P <passwords> 172.16.10.13 -t 4 ssh -o $FILE" >&2
    exit 1
fi

if ! grep -qE "(172\.16\.10\.13|ssh)" "$FILE"; then
    echo "The output doesn't reference the jumpbox SSH — run hydra against 172.16.10.13." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk09 hydra-ssh 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

# A hit line (host or login form) — if hydra found nothing, require evidence
# the run happened (hydra prints 'Hydra (http...' header with target info).
if grep -qE "login:.*" "$FILE" && grep -qiE "password" "$FILE"; then
    exit 0
fi

if grep -qE "(Hydra|hydra)" "$FILE"; then
    echo "Hydra ran but no credential hit recorded — include 'toor' in your password list." >&2
    exit 1
fi

echo "Output saved but doesn't look like hydra output." >&2
exit 1