#!/bin/bash
# Verify: cowsay is installed, ~/held.txt recorded the hold, and the package
# is now unheld (the full hold→record→unhold cycle).

if ! command -v cowsay >/dev/null 2>&1; then
    echo "cowsay isn't installed (sudo apt install -y cowsay)." >&2
    exit 1
fi

if [ ! -s "$HOME/held.txt" ]; then
    echo "~/held.txt is missing or empty (apt-mark showhold > ~/held.txt while held)." >&2
    exit 1
fi

if ! grep -qx "cowsay" "$HOME/held.txt"; then
    echo "~/held.txt doesn't list cowsay — capture apt-mark showhold WHILE it is held." >&2
    exit 1
fi

# Final state: unheld
if apt-mark showhold 2>/dev/null | grep -qx "cowsay"; then
    echo "cowsay is still held — finish the cycle with: apt-mark unhold cowsay" >&2
    exit 1
fi

exit 0