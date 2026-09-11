#!/bin/bash
# Verify: service list + ssh status captured.

if [ ! -s "$HOME/services-list.txt" ]; then
    echo "~/services-list.txt is missing or empty (systemctl list-units --type=service > ~/services-list.txt)." >&2
    exit 1
fi

if ! grep -qE "\.service" "$HOME/services-list.txt"; then
    echo "The list doesn't look like systemd unit output." >&2
    exit 1
fi

if [ ! -s "$HOME/ssh-status.txt" ]; then
    echo "~/ssh-status.txt is missing or empty (systemctl status ssh > ~/ssh-status.txt 2>&1)." >&2
    exit 1
fi

if ! grep -qiE "ssh|loaded|active" "$HOME/ssh-status.txt"; then
    echo "~/ssh-status.txt doesn't look like systemctl status output." >&2
    exit 1
fi

exit 0