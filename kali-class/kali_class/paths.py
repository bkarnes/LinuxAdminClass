import os
from pathlib import Path

from . import CLASS_ID, KALI_CLASS_DIR_NAME, WORK_DIR_NAME


def home() -> Path:
    return Path(os.environ.get("HOME", str(Path.home())))


def state_dir() -> Path:
    return home() / KALI_CLASS_DIR_NAME


def work_dir() -> Path:
    return home() / WORK_DIR_NAME


def identity_file() -> Path:
    return state_dir() / "identity.json"


def progress_file() -> Path:
    return state_dir() / "progress.json"


def repo_root() -> Path:
    """Locate the LinuxAdminClass repo root (contains setup_vm.sh)."""
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "setup_vm.sh").exists() and (parent / "configs").is_dir():
            return parent
    raise FileNotFoundError(
        "Could not locate the LinuxAdminClass repo root (expected setup_vm.sh + configs/)"
    )


def workshops_root() -> Path:
    return Path(__file__).resolve().parent.parent / "workshops"


def instructor_dir() -> Path:
    return Path(__file__).resolve().parent.parent / "instructor"


def ensure_dirs() -> None:
    state_dir().mkdir(mode=0o700, parents=True, exist_ok=True)
    work_dir().mkdir(mode=0o755, parents=True, exist_ok=True)


def workshop_work_dir(workshop_id: str) -> Path:
    d = work_dir() / workshop_id
    d.mkdir(parents=True, exist_ok=True)
    return d


def vm_uuid() -> str:
    """Stable per-VM identifier for anti-cheat binding."""
    for candidate in ("/etc/machine-id", "/var/lib/dbus/machine-id"):
        try:
            text = Path(candidate).read_text().strip()
            if text:
                return text
        except OSError:
            continue
    return "unknown-vm-uuid"