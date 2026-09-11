#!/bin/bash
# Verify: ~/apt-sources.txt contains repo URIs and the distro identity lines.

FILE="$HOME/apt-sources.txt"

if [ ! -f "$FILE" ]; then
    echo "~/apt-sources.txt doesn't exist yet." >&2
    exit 1
fi

# At least one deb URI line
if ! grep -qE "(^deb |https?://|uris)" "$FILE"; then
    echo "No repository URIs in the file — list your apt sources into it." >&2
    exit 1
fi

# Distro identity lines
if ! grep -qE "^ID=" "$FILE"; then
    echo "Missing the 'ID=' line from /etc/os-release." >&2
    exit 1
fi
if ! grep -qE "^VERSION_CODENAME=" "$FILE"; then
    echo "Missing the 'VERSION_CODENAME=' line from /etc/os-release." >&2
    exit 1
fi

exit 0