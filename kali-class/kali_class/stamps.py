"""Shared lab stamp helpers.

Cybersec exercises produce artifacts (scans, captures, hashes) that must be
tied to a specific student + workshop. Each lab writes a stamp file into the
artifact folder via `kali-class stamp <workshop> <label>`, and verifiers
check `kali-class check-stamp` for their label.
"""

import json
from pathlib import Path

from . import paths


def _stamps_path(workshop_id: str) -> Path:
    return paths.workshop_work_dir(workshop_id) / ".lab-stamps.json"


def _identity_data() -> dict:
    path = paths.identity_file()
    if not path.exists():
        return {"student_id": "unknown", "name": "unknown"}
    try:
        return json.loads(path.read_text())
    except json.JSONDecodeError:
        return {"student_id": "unknown", "name": "unknown"}


def stamp(workshop_id: str, label: str) -> dict:
    """Record a lab stamp tied to the registered student."""
    data = _identity_data()
    entry = {
        "student_id": data.get("student_id", "unknown"),
        "name": data.get("name", "unknown"),
        "workshop": workshop_id,
        "label": label,
    }
    p = _stamps_path(workshop_id)
    stamps = {}
    if p.exists():
        try:
            stamps = json.loads(p.read_text())
        except json.JSONDecodeError:
            stamps = {}
    stamps[label] = entry
    p.write_text(json.dumps(stamps, indent=2) + "\n")
    return entry


def check_stamp(workshop_id: str, label: str) -> tuple[bool, str]:
    p = _stamps_path(workshop_id)
    if not p.exists():
        return False, "no stamps file"
    try:
        stamps = json.loads(p.read_text())
    except json.JSONDecodeError:
        return False, "stamps file corrupt"
    if label not in stamps:
        return False, f"stamp '{label}' not found — run: kali-class stamp {workshop_id} {label}"
    return True, f"{stamps[label]['student_id']}"


def all_stamps(workshop_id: str) -> dict:
    p = _stamps_path(workshop_id)
    if not p.exists():
        return {}
    try:
        return json.loads(p.read_text())
    except json.JSONDecodeError:
        return {}