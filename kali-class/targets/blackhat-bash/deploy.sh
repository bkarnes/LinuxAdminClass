#!/usr/bin/env bash
# Black-Hat-Bash lab deployer — wraps the upstream repo's make deploy.
# Idempotent: safe to re-run. Called by `kali-class setup-bhb`.
set -uo pipefail

BHB_DIR="$HOME/Projects/Black-Hat-Bash"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m"

log()  { echo -e "${GREEN}[bhb]${NC} $*"; }
warn() { echo -e "${YELLOW}[bhb]${NC} $*"; }
fail() { echo -e "${RED}[bhb]${NC} $*"; }

# ---------------------------------------------------------------- clone ----
if [ ! -d "$BHB_DIR" ]; then
    log "Cloning Black-Hat-Bash into ~/Projects/Black-Hat-Bash"
    ( cd "$HOME/Projects" && git clone https://github.com/dolevf/Black-Hat-Bash.git ) || {
        fail "Could not clone Black-Hat-Bash. Check internet connectivity."
        exit 1
    }
else
    log "Black-Hat-Bash repo already present at $BHB_DIR"
fi

# --------------------------------------------------------------- docker ----
if ! command -v docker >/dev/null 2>&1; then
    fail "Docker is not installed. Run setup_vm.sh option 3 first."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    warn "Docker daemon not reachable — starting service..."
    sudo service docker start
    sleep 3
    if ! docker info >/dev/null 2>&1; then
        fail "Docker still not reachable. Reboot and try again."
        exit 1
    fi
fi

# ---------------------------------------------------------------- deploy ---
cd "$BHB_DIR/lab" || { fail "lab directory missing"; exit 1; }

log "Deploying the lab (make deploy) — this builds 8 containers, be patient..."
if ! sudo make deploy; then
    warn "make deploy reported errors; trying docker compose directly..."
    sudo docker compose up --detach || {
        fail "Lab deployment failed."
        exit 1
    }
fi

# ------------------------------------------------------------ privesc box ---
# Dedicated Week 10 target (misconfigured Ubuntu container)
PRIVESC_DIR="$HOME/Projects/LinuxAdminClass/kali-class/targets/blackhat-bash/privesc-box"
if sudo docker ps --format '{{.Names}}' | grep -q "^kali-class-privesc$"; then
    log "privesc box already running"
else
    if [ -d "$PRIVESC_DIR" ]; then
        log "Building the kali-class-privesc target (week 10)..."
        sudo docker build -t kali-class-privesc:latest "$PRIVESC_DIR" >/dev/null 2>&1 || {
            warn "privesc image build failed — week 10 will be unavailable"
        }
        sudo docker rm -f kali-class-privesc >/dev/null 2>&1
        sudo docker run -d --name kali-class-privesc \
            -p 2222:22 kali-class-privesc:latest >/dev/null 2>&1 || \
            warn "could not start kali-class-privesc"
    fi
fi

# ------------------------------------------------------------ seed flags ---
if [ -f "$HOME/Projects/LinuxAdminClass/kali-class/targets/blackhat-bash/seed-flags.sh" ]; then
    log "Seeding capstone flags (idempotent)..."
    bash "$HOME/Projects/LinuxAdminClass/kali-class/targets/blackhat-bash/seed-flags.sh" || {
        warn "Flag seeding had issues (capstone week only) — lab is still usable."
    }
fi

# --------------------------------------------------------------- verify ----
log "Checking the 8 lab machines..."
expected=(p-web-01 p-ftp-01 p-web-02 p-jumpbox-01 c-backup-01 c-redis-01 c-db-01 c-db-02)
up=0
for h in "${expected[@]}"; do
    if sudo docker ps --format '{{.Names}}' | grep -q "^$h$"; then
        up=$((up+1))
    else
        warn "container not up: $h"
    fi
done
log "$up/8 lab machines running."

if [ "$up" -lt 6 ]; then
    warn "Fewer than 6 machines are up — re-run: kali-class setup-bhb"
    exit 1
fi

log "Lab ready. Public targets: 172.16.10.10-13   Private: 10.1.0.11-16"
exit 0