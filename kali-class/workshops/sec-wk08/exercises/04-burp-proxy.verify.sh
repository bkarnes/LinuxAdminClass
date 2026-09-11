#!/bin/bash
# Verify: proxied response captured (proves the Burp path works end-to-end).

WORK="$HOME/kali-class-work/sec-wk08"
FILE="$WORK/burp-intercept.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty." >&2
    echo "Try: curl -x http://127.0.0.1:8080 http://172.16.10.10 -o $FILE" >&2
    exit 1
fi

# It should be an HTTP response body (HTML) from the web server
if ! grep -qiE "(<html|<!DOCTYPE|<body|HTTP/)" "$FILE"; then
    echo "The file doesn't look like an HTTP response body." >&2
    exit 1
fi

# If Burp is not running, curl would fail entirely — but a direct (unproxied)
# curl produces the same file. Check Burp's listener is actually up:
if ! ss -tln 2>/dev/null | grep -q ":8080"; then
    echo "Nothing is listening on 127.0.0.1:8080 — start Burp Suite (burpsuite) first." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk08 burp 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0