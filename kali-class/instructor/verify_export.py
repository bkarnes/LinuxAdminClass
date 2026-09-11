#!/usr/bin/env python3
"""Verify a student's exported progress file (and optional whoami JSON).

Usage:
    python3 verify_export.py --secret <class-secret> <export-file.txt>
    python3 verify_export.py --secret-file shared-secret.env <export-file.txt> [...]
    python3 verify_export.py --secret-file shared-secret.env --roster roster.csv submissions/

The class secret is NEVER stored in this repo. Keep it in shared-secret.env
(gitignored) or pass it inline with --secret.
"""

import argparse
import csv
import hashlib
import hmac
import json
import re
import sys
from pathlib import Path

# Field order must match kali_class/export.py build_export()
CLAIM_RE = re.compile(r"^\s{2}([a-z0-9-]+):([0-9a-zA-Z._-]+):\s*([0-9a-f]{64})\s*$")
PROGRESS_RE = re.compile(r"^\s{2}([a-z0-9-]+):\s*(\d+)/(\d+)\s*\(hints used: (\d+)\)\s*$")
HEADER_RE = re.compile(r"^Student:\s*(.+?)\s*\((.+?)\)\s*$")
VM_RE = re.compile(r"^VM UUID:\s*(\S+)\s*$")


def hmac_key_from_secret(secret: str) -> bytes:
    # Must match the student side: identity.secret_hash = sha256(secret).hexdigest(),
    # and the runner uses secret_hash (the hex string) as the HMAC key.
    return hashlib.sha256(secret.encode()).hexdigest().encode()


def exercise_token(key: bytes, class_id: str, student_id: str, workshop_id: str, exercise_id: str) -> str:
    msg = f"{class_id}|{student_id}|{workshop_id}|{exercise_id}|"
    return hmac.new(key, msg.encode(), hashlib.sha256).hexdigest()


def parse_export(path: Path):
    text = path.read_text()
    lines = text.splitlines()

    header = {}
    progress = {}
    claims = {}
    body_lines = []
    signature = None

    for line in lines:
        m = HEADER_RE.match(line)
        if m:
            header["name"], header["student_id"] = m.groups()
            continue
        if line.startswith("Class:"):
            header["class_id"] = line.split(":", 1)[1].strip()
            continue
        m = VM_RE.match(line)
        if m:
            header["vm_uuid"] = m.group(1)
            continue
        m = PROGRESS_RE.match(line)
        if m:
            wid, done, total, hints = m.groups()
            progress[wid] = {"done": int(done), "total": int(total), "hints": int(hints)}
            continue
        m = CLAIM_RE.match(line)
        if m:
            wid, eid, claim = m.groups()
            claims[f"{wid}:{eid}"] = claim
            continue
        if line.startswith("Signature:"):
            signature = line.split(":", 1)[1].strip()
            continue

    # The signed body is everything up to and including the last claim line
    sig_idx = next((i for i, l in enumerate(lines) if l.startswith("Signature:")), len(lines))
    body = "\n".join(lines[:sig_idx])

    return {"header": header, "progress": progress, "claims": claims, "body": body, "signature": signature}


def verify_file(path: Path, key: bytes, class_id: str, roster: dict | None) -> tuple[bool, list[str]]:
    problems: list[str] = []
    data = parse_export(path)

    if not data["signature"]:
        return False, ["No signature found — file is incomplete or tampered."]

    # 1. Whole-document signature
    expected_sig = hmac.new(key, data["body"].encode(), hashlib.sha256).hexdigest()
    if not hmac.compare_digest(expected_sig, data["signature"]):
        problems.append("Document signature MISMATCH — content was modified or secret is wrong.")
        return False, problems

    student_id = data["header"].get("student_id", "")
    name = data["header"].get("name", "?")

    # 2. Per-exercise claims (these bind to the student_id)
    bad_claims = 0
    for claim_key, claim_val in data["claims"].items():
        wid, eid = claim_key.split(":", 1)
        expected = exercise_token(key, class_id, student_id, wid, eid)
        if not hmac.compare_digest(expected, claim_val):
            bad_claims += 1
    if bad_claims:
        problems.append(f"{bad_claims} per-exercise claim(s) do not match this student_id — possible copied file.")

    # 3. Roster cross-check (vm_uuid)
    if roster is not None:
        expected_vm = roster.get(student_id)
        actual_vm = data["header"].get("vm_uuid", "")
        if expected_vm and expected_vm != actual_vm:
            problems.append(
                f"vm_uuid MISMATCH: roster says {expected_vm[:16]}..., file says {actual_vm[:16]}... — progress may have been copied from another VM."
            )
        if student_id not in roster:
            problems.append(f"student_id '{student_id}' not found in roster.")

    status = "OK" if not problems else "SUSPECT"
    print(f"\n{path.name}: {name} ({student_id}) -> {status}")
    for wid, p in sorted(data["progress"].items()):
        print(f"    {wid}: {p['done']}/{p['total']} (hints: {p['hints']})")
    for p in problems:
        print(f"    !! {p}")

    return not problems, problems


def load_roster(roster_dir: Path) -> dict:
    """Load whoami-*.json files from a directory of LMS submissions."""
    roster = {}
    for f in roster_dir.glob("whoami-*.json"):
        try:
            data = json.loads(f.read_text())
            ident = data["identity"]
            roster[ident["student_id"]] = ident.get("vm_uuid", "")
        except (json.JSONDecodeError, KeyError):
            print(f"warn: could not parse {f.name}", file=sys.stderr)
    return roster


def main() -> int:
    ap = argparse.ArgumentParser(description="Verify kali-class student exports")
    ap.add_argument("files", nargs="+", type=Path, help="Exported progress .txt file(s)")
    ap.add_argument("--secret", help="The class secret (inline)")
    ap.add_argument("--secret-file", type=Path, help="File containing the class secret (first line)")
    ap.add_argument("--roster", type=Path, help="Directory of whoami-*.json LMS submissions")
    ap.add_argument("--csv", type=Path, help="Also write a gradebook CSV here")
    args = ap.parse_args()

    secret = args.secret
    if args.secret_file:
        secret = args.secret_file.read_text().strip().splitlines()[0]
    if not secret:
        ap.error("Provide --secret or --secret-file")

    key = hmac_key_from_secret(secret)
    roster = load_roster(args.roster) if args.roster else None

    all_ok = True
    gradebook_rows = []

    for f in args.files:
        ok, problems = verify_file(f, key, "LinuxAdminClass-2027", roster)
        all_ok = all_ok and ok
        data = parse_export(f)
        student_id = data["header"].get("student_id", "?")
        name = data["header"].get("name", "?")
        total_done = sum(p["done"] for p in data["progress"].values())
        total_ex = sum(p["total"] for p in data["progress"].values())
        gradebook_rows.append(
            {
                "student_id": student_id,
                "name": name,
                "file": f.name,
                "status": "OK" if ok else "SUSPECT",
                "exercises_completed": total_done,
                "exercises_total": total_ex,
                "problems": "; ".join(problems),
            }
        )

    if args.csv:
        with args.csv.open("w", newline="") as fh:
            writer = csv.DictWriter(fh, fieldnames=list(gradebook_rows[0].keys()))
            writer.writeheader()
            writer.writerows(gradebook_rows)
        print(f"\nGradebook CSV written to {args.csv}")

    print()
    print("All exports verified OK." if all_ok else "One or more exports need review.")
    return 0 if all_ok else 1


if __name__ == "__main__":
    sys.exit(main())