#!/bin/bash
# Verify: FTP capture + sniffed credentials documented; stamped.

WORK="$HOME/kali-class-work/sec-wk11"
PCAP="$WORK/ftp-capture.pcap"
CREDS="$WORK/sniffed-creds.txt"

if [ ! -s "$CREDS" ]; then
    echo "$CREDS is missing or empty — save the USER/PASS lines from the capture." >&2
    exit 1
fi

if ! grep -qE "USER" "$CREDS"; then
    echo "The creds file doesn't include a USER line from the FTP session." >&2
    exit 1
fi

# The pcap or creds must reference the FTP exchange
if [ -f "$PCAP" ]; then
    if command -v tcpdump >/dev/null 2>&1 && ! tcpdump -A -r "$PCAP" 2>/dev/null | grep -qE "USER"; then
        echo "The pcap exists but has no FTP USER traffic — log in to FTP while capturing." >&2
        exit 1
    fi
fi

STAMP=$(kali-class check-stamp sec-wk11 ftp-sniff 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0