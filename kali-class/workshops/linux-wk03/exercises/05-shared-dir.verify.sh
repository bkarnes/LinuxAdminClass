#!/bin/bash
# Verify: /srv/shared exists, group projectx exists, dir is root:projectx 770.

DIR=/srv/shared

if [ ! -d "$DIR" ]; then
    echo "$DIR doesn't exist. Create it with sudo." >&2
    exit 1
fi

if ! getent group projectx >/dev/null; then
    echo "Group 'projectx' doesn't exist yet (sudo groupadd projectx)." >&2
    exit 1
fi

owner=$(stat -c '%U' "$DIR")
group=$(stat -c '%G' "$DIR")
mode=$(stat -c '%a' "$DIR")

if [ "$owner" != "root" ] || [ "$group" != "projectx" ]; then
    echo "$DIR is $owner:$group, expected root:projectx (use sudo chown root:projectx)." >&2
    exit 1
fi

if [ "$mode" != "770" ]; then
    echo "Mode is $mode, expected 770 (sudo chmod 770 $DIR)." >&2
    exit 1
fi

if [ ! -f "$HOME/shared-check.txt" ]; then
    echo "~/shared-check.txt is missing (ls -ld $DIR > ~/shared-check.txt)." >&2
    exit 1
fi

if ! grep -qE "drwxrwx---" "$HOME/shared-check.txt"; then
    echo "~/shared-check.txt should show the drwxrwx--- mode string." >&2
    exit 1
fi

exit 0