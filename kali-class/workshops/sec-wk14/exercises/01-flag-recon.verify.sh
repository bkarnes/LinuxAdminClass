#!/bin/bash
# Verify: FLAG_RECON claimed: correct value + stamp.

WORK="$HOME/kali-class-work/sec-wk14"
FILE="$WORK/flag-1.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — save the flag line there." >&2
    exit 1
fi

if ! grep -q "FLAG{r3c0n_1s_n0t_0pt10n4l}" "$FILE"; then
    echo "flag-1.txt doesn't contain FLAG_RECON — enumerate p-web-01's robots.txt." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk14 flag-recon 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0