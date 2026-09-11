#!/bin/bash
# Verify: ~/scripts/hello.sh exists, is executable, prints the right line,
# and was actually run (checked via the rsyslog command log if available).

SCRIPT="$HOME/scripts/hello.sh"
LOG=/var/log/commands.log

if [ ! -f "$SCRIPT" ]; then
    echo "~/scripts/hello.sh doesn't exist yet." >&2
    exit 1
fi

if [ ! -x "$SCRIPT" ]; then
    echo "The script isn't executable — chmod +x ~/scripts/hello.sh" >&2
    exit 1
fi

if ! head -1 "$SCRIPT" | grep -q '^#!'; then
    echo "The script is missing its shebang line (#!/bin/bash)." >&2
    exit 1
fi

out=$("$SCRIPT" 2>/dev/null)
if [ "$out" != "Hello from my first script" ]; then
    echo "Running the script printed: '$out' — expected: Hello from my first script" >&2
    exit 1
fi

# Evidence of a manual run (not required if logging isn't set up or is
# unreadable by the student)
if [ -r "$LOG" ] && ! grep -q "hello.sh" "$LOG" 2>/dev/null; then
    echo "No sign the script was RUN yet (nothing in the command log). Run it! (Linux commands are case-sensitive — './HELLO.sh' is not './hello.sh'.)" >&2
    exit 1
fi

exit 0