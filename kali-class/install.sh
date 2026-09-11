#!/usr/bin/env bash
# kali-class installer
# Creates a venv, installs the runner in editable mode, symlinks launchers,
# and appends shell completion snippets (idempotently).
#
# Expected location: ~/Projects/LinuxAdminClass/kali-class/install.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KC_DIR="$REPO_ROOT/kali-class"
STATE_DIR="$HOME/.kali-class"
WORK_DIR="$HOME/kali-class-work"
BIN_DIR="$HOME/.local/bin"

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
NC="\033[0m"

log()  { echo -e "${GREEN}[kali-class]${NC} $*"; }
warn() { echo -e "${YELLOW}[kali-class]${NC} $*"; }

# ---------------------------------------------------------------- checks ---
if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 not found. Install it first." >&2
    exit 1
fi

PYV=$(python3 -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)'; then
    log "Python $PYV found (need >= 3.10)."
else
    echo "Python >= 3.10 is required (found $PYV)." >&2
    exit 1
fi

if ! python3 -c 'import venv' >/dev/null 2>&1; then
    echo "python3-venv is missing. Run: sudo apt install python3-venv" >&2
    exit 1
fi

# ----------------------------------------------------------------- dirs ----
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"
mkdir -p "$WORK_DIR"
mkdir -p "$BIN_DIR"

# ----------------------------------------------------------------- venv ----
VENV="$STATE_DIR/venv"
if [ ! -d "$VENV" ]; then
    log "Creating virtual environment at $VENV"
    python3 -m venv "$VENV"
fi

log "Installing kali-class in editable mode (pip install -e .)"
"$VENV/bin/pip" install --quiet --upgrade pip
"$VENV/bin/pip" install --quiet -e "$KC_DIR"

# ------------------------------------------------------------- symlinks ----
log "Symlinking launchers into $BIN_DIR"
ln -sf "$VENV/bin/kali-class" "$BIN_DIR/kali-class"

# Ensure ~/.local/bin is on PATH for common shells
for RC in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC" ] && ! grep -q '\$HOME/.local/bin' "$RC" 2>/dev/null; then
        printf '\n# Added by kali-class installer:\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$RC"
    fi
done

# ------------------------------------------------- shell completion bits ---
MARKER="# --- kali-class completion ---"
COMPLETION_BASH="$REPO_ROOT/configs/kali-class-completion.bashrc"
COMPLETION_ZSH="$REPO_ROOT/configs/kali-class-completion.zshrc"

append_if_missing() {
    local rc="$1" src="$2"
    if [ ! -f "$rc" ]; then
        touch "$rc"
    fi
    if ! grep -qF "$MARKER" "$rc" 2>/dev/null; then
        {
            echo ""
            cat "$src"
        } >> "$rc"
        log "Added completion snippet to $(basename "$rc")"
    fi
}

if [ -f "$COMPLETION_BASH" ]; then
    append_if_missing "$HOME/.bashrc" "$COMPLETION_BASH"
fi
if [ -f "$COMPLETION_ZSH" ]; then
    append_if_missing "$HOME/.zshrc" "$COMPLETION_ZSH"
fi

# ------------------------------------------------------------------ done ---
log "Install complete."
echo
log "Run 'kali-class' to register and begin.  (You'll be asked for your name,"
log "student ID, and the class secret announced tonight.)"
echo
warn "NOTE: do NOT delete $VENV — it is your lab runner. If you ever need to"
warn "reinstall, just re-run this script."