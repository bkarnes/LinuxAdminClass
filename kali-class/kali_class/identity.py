import hashlib
import hmac
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path

from . import CLASS_ID
from . import paths


class RegistrationCancelled(Exception):
    pass


class Identity:
    def __init__(self, data: dict):
        self.name = data["name"]
        self.student_id = str(data["student_id"])
        self.class_id = data.get("class_id", CLASS_ID)
        self.secret_hash = data["secret_hash"]
        self.vm_uuid = data.get("vm_uuid", "unknown-vm-uuid")
        self.first_run = data.get("first_run", "")

    @property
    def hmac_key(self) -> bytes:
        return self.secret_hash.encode()

    def to_dict(self) -> dict:
        return {
            "name": self.name,
            "student_id": self.student_id,
            "class_id": self.class_id,
            "secret_hash": self.secret_hash,
            "vm_uuid": self.vm_uuid,
            "first_run": self.first_run,
        }


def load() -> Identity | None:
    path = paths.identity_file()
    if not path.exists():
        return None
    try:
        return Identity(json.loads(path.read_text()))
    except (json.JSONDecodeError, KeyError):
        return None


def save(identity: Identity) -> None:
    paths.ensure_dirs()
    path = paths.identity_file()
    path.write_text(json.dumps(identity.to_dict(), indent=2) + "\n")
    os.chmod(path, 0o600)


def ensure_registered() -> Identity:
    """Return the registered Identity, or run the interactive first-run flow."""
    existing = load()
    if existing:
        return existing
    identity = register_interactive()
    save(identity)
    return identity


def register_interactive() -> Identity:
    print()
    print(" It looks like this is your first time here. Let's get you registered.")
    print()
    name = _prompt_required("   1/3  Enter your full name (as on the roster): ", "name")
    student_id = _prompt_required("   2/3  Enter your student ID: ", "student ID")
    secret = _prompt_secret()

    return Identity(
        {
            "name": name,
            "student_id": student_id,
            "class_id": CLASS_ID,
            "secret_hash": hashlib.sha256(secret.encode()).hexdigest(),
            "vm_uuid": paths.vm_uuid(),
            "first_run": datetime.now(timezone.utc).isoformat(),
        }
    )


def _prompt_required(label: str, what: str) -> str:
    while True:
        value = input(label).strip()
        if value:
            return value
        print(f"   {what} cannot be empty. Please try again.")


def _prompt_secret() -> str:
    import getpass

    while True:
        secret = getpass.getpass("   3/3  Enter the class secret announced tonight: ")
        if not secret:
            print("   The class secret cannot be empty. Please try again.")
            continue
        confirm = getpass.getpass("        Confirm the class secret: ")
        if secret == confirm:
            return secret
        print("   The two entries did not match. Please try again.")


def re_register() -> Identity:
    """Wipe existing identity and re-run registration (keeps progress)."""
    path = paths.identity_file()
    if path.exists():
        path.unlink()
    identity = register_interactive()
    save(identity)
    return identity


def whoami_json(identity: Identity) -> Path:
    """Write the LMS-uploadable registration file and return its path."""
    paths.ensure_dirs()
    body = identity.to_dict()
    body["registered_at"] = datetime.now(timezone.utc).isoformat()
    signature = hmac.new(
        identity.hmac_key,
        json.dumps(body, sort_keys=True).encode(),
        hashlib.sha256,
    ).hexdigest()
    out = {
        "identity": body,
        "signature": signature,
    }
    out_path = paths.work_dir() / f"whoami-{identity.student_id}.json"
    out_path.write_text(json.dumps(out, indent=2) + "\n")
    return out_path


def is_valid_student_id(value: str) -> bool:
    return bool(re.fullmatch(r"[A-Za-z0-9-]{3,20}", value))