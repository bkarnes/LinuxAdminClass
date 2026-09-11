import hashlib
import hmac
import json

from . import CLASS_ID, paths


def _key() -> bytes:
    identity_path = paths.identity_file()
    if not identity_path.exists():
        raise RuntimeError("Not registered yet — run 'kali-class' once first.")
    identity = json.loads(identity_path.read_text())
    return identity["secret_hash"].encode()


def exercise_token(student_id: str, workshop_id: str, exercise_id: str, artifact: str = "") -> str:
    """Deterministic per-student, per-exercise token.

    The instructor can recompute this for any (student_id, workshop, exercise),
    but it differs between students, so one student's proof cannot be reused
    by another.
    """
    msg = f"{CLASS_ID}|{student_id}|{workshop_id}|{exercise_id}|{artifact}"
    return hmac.new(_key(), msg.encode(), hashlib.sha256).hexdigest()


def seeded_content(student_id: str, workshop_id: str, exercise_id: str) -> str:
    """Human-readable token planted in per-student artifact files."""
    return exercise_token(student_id, workshop_id, exercise_id, "seed")[:32]


def verify_claim(student_id: str, workshop_id: str, exercise_id: str, artifact: str, claim: str) -> bool:
    expected = exercise_token(student_id, workshop_id, exercise_id, artifact)
    return hmac.compare_digest(expected, claim)


def ensure_seed_files(workshop_id: str, student_id: str, filenames: dict[str, str]) -> None:
    """Create per-student seed files used by verifiers (idempotent).

    filenames maps relative filename -> describing label used to derive content.
    """
    target = paths.workshop_work_dir(workshop_id) / "seeded"
    target.mkdir(parents=True, exist_ok=True)
    marker = target / ".kali-class-seeded"
    if marker.exists() and marker.read_text().strip() == student_id:
        return
    for filename, label in filenames.items():
        content = _seed_content(filename, label, student_id, workshop_id)
        (target / filename).write_text(content)
    marker.write_text(student_id + "\n")


def _seed_content(filename: str, label: str, student_id: str, workshop_id: str) -> str:
    if filename.endswith("-hashes.txt"):
        # Password-attack labs: plaintext file 'hashes:password' pairs unique
        # to the student (crackable with a small wordlist).
        passwords = ["letmein123", "football2026", "P@ssw0rd!", "changeme7"]
        lines = []
        for i, pw in enumerate(passwords, 1):
            token = exercise_token(student_id, workshop_id, f"{label}-{i}", "hash")
            lines.append(f"{token[:32]}:{pw}")
        return "\n".join(lines) + "\n"
    return f"seed-label={label}\nseed-value={seeded_content(student_id, workshop_id, label)}\n"