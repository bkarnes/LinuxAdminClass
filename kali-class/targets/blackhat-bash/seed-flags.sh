#!/usr/bin/env bash
# Seed capstone flags into the running BHB lab containers.
# Reads flags/flag-manifest.yaml; idempotent — existing flag files are left
# alone. Re-runnable any time (kali-class setup-bhb calls this automatically).
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$HERE/flags/flag-manifest.yaml"

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"
log()  { echo -e "${GREEN}[flags]${NC} $*"; }
warn() { echo -e "${YELLOW}[flags]${NC} $*"; }
fail() { echo -e "${RED}[flags]${NC} $*"; }

command -v docker >/dev/null 2>&1 || { fail "docker not found"; exit 1; }
[ -f "$MANIFEST" ] || { fail "manifest missing: $MANIFEST"; exit 1; }

# Simple manifest reader: walk flags: entries (name/value/container/path)
planted=0
skipped=0
missing=0

name="" value="" container="" path=""
flush() {
    if [ -n "$name" ] && [ -n "$value" ] && [ -n "$container" ] && [ -n "$path" ]; then
        if ! sudo docker ps --format '{{.Names}}' | grep -q "^$container$"; then
            warn "container not running, skipping: $container"
            missing=$((missing+1))
        elif sudo docker exec "$container" test -f "$path" 2>/dev/null; then
            log "already present: $container:$path"
            skipped=$((skipped+1))
        else
            sudo docker exec "$container" mkdir -p "$(dirname "$path")" 2>/dev/null
            if sudo docker exec "$container" sh -c "echo '$value' > '$path' && chmod 600 '$path' 2>/dev/null"; then
                log "planted: $container:$path"
                planted=$((planted+1))
            else
                fail "could not plant: $container:$path"
                missing=$((missing+1))
            fi
        fi
    fi
    name="" value="" container="" path=""
}

while IFS= read -r line; do
    case "$line" in
        *"-"*"name:"*) flush; name=$(echo "$line" | sed 's/.*name:\s*//') ;;
        *value:*)      value=$(echo "$line" | sed 's/.*value:\s*//; s/"//g') ;;
        *container:*)  container=$(echo "$line" | sed 's/.*container:\s*//') ;;
        *path:*)       path=$(echo "$line" | sed 's/.*path:\s*//') ;;
    esac
done < "$MANIFEST"
flush

log "done: planted=$planted already-present=$skipped unavailable=$missing"
[ "$missing" -gt 0 ] && warn "some flags unseeded — is the BHB lab fully up? (kali-class setup-bhb)"
exit 0