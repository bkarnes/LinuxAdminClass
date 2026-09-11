#!/bin/bash
# Verify: detection notes show duplicate-MAC evidence + a mitigation; stamped.

WORK="$HOME/kali-class-work/sec-wk11"
FILE="$WORK/detection-notes.txt"

if [ ! -s "$FILE" ]; then
    echo "$FILE is missing or empty — write your detection notes." >&2
    exit 1
fi

# Must mention the duplicate-MAC concept
if ! grep -qiE "(duplicate|two MAC|different MAC|flip|changed MAC)" "$FILE"; then
    echo "Notes should describe the duplicate-MAC evidence of ARP poisoning." >&2
    exit 1
fi

# Must mention at least one mitigation
if ! grep -qiE "(DAI|dynamic arp inspection|static arp|802\.1X|arpwatch)" "$FILE"; then
    echo "Notes should include a mitigation (DAI, static ARP, 802.1X, arpwatch...)." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk11 mitm-detect 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0