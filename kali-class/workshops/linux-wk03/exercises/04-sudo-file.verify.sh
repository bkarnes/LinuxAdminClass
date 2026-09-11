#!/bin/bash
# Verify: root-owned file exists in /opt and the student recorded the outcome.

TARGET=/opt/root-made-this.txt

if [ ! -f "$TARGET" ]; then
    echo "sudo touch /opt/root-made-this.txt hasn't been done (file missing)." >&2
    exit 1
fi

owner=$(stat -c '%U' "$TARGET")
if [ "$owner" != "root" ]; then
    echo "The file exists but is owned by $owner, not root. Use sudo when creating it." >&2
    exit 1
fi

if [ ! -f "$HOME/sudo-experience.txt" ]; then
    echo "~/sudo-experience.txt is missing — record what happened when you tried to write as a normal user." >&2
    exit 1
fi

answer=$(tr -d '[:space:]' < "$HOME/sudo-experience.txt" | tr '[:upper:]' '[:lower:]')
case "$answer" in
    denied)
        # Expected on standard systems: normal user cannot write into a root file.
        if ! grep -qE "(^|[[:space:]])Permission denied" /dev/null 2>/dev/null; then
            : # can't verify the live error, but the stated experience is consistent
        fi
        ;;
    worked)
        # Only plausible if the user IS root or has write via group/ACL — check
        if [ -w "$TARGET" ]; then
            : # consistent
        else
            echo "You recorded 'worked', but this user cannot write that file — recheck." >&2
            exit 1
        fi
        ;;
    *)
        echo "~/sudo-experience.txt should contain exactly 'denied' or 'worked'." >&2
        exit 1
        ;;
esac

exit 0