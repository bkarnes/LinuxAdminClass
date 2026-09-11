#!/bin/bash
# Verify: q1/q2/q3 exist in reports/ AND copies exist in reports/2026/.

for n in 1 2 3; do
    if [ ! -f "$HOME/company/reports/q$n.txt" ]; then
        echo "~/company/reports/q$n.txt is missing." >&2
        exit 1
    fi
    if [ ! -f "$HOME/company/reports/2026/q$n.txt" ]; then
        echo "~/company/reports/2026/q$n.txt is missing — the copies didn't happen." >&2
        exit 1
    fi
    if ! cmp -s "$HOME/company/reports/q$n.txt" "$HOME/company/reports/2026/q$n.txt"; then
        echo "reports/2026/q$n.txt differs from the original q$n.txt." >&2
        exit 1
    fi
done

exit 0