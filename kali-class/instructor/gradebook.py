#!/usr/bin/env python3
"""Batch gradebook builder for kali-class submissions.

Walks a directory of exported progress files, verifies each (signature,
per-student claims, optional roster vm_uuid cross-check), and writes one
CSV covering the whole class. For a single-file run with live output, use
verify_export.py — this is the batch/semester-scale tool.

Usage:
    python3 gradebook.py --secret-file shared-secret.env \
        --roster roster/ --csv gradebook.csv submissions/

    # single week column extraction (e.g. week 3):
    python3 gradebook.py --secret-file ... --week linux-wk03 \
        --roster roster/ --csv week03.csv submissions-week03/*.txt
"""

import argparse
import csv
import sys
from pathlib import Path

# reuse the verified primitives from verify_export.py
sys.path.insert(0, str(__import__("pathlib").Path(__file__).resolve().parent))
from verify_export import (  # noqa: E402
    hmac_key_from_secret,
    load_roster,
    parse_export,
    verify_file,
)


def build_rows(files, key, class_id, roster):
    rows = []
    for f in files:
        data = parse_export(f)
        header = data["header"]
        student_id = header.get("student_id", "?")
        name = header.get("name", "?")

        ok, problems = verify_file(f, key, class_id, roster)

        total_done = sum(p["done"] for p in data["progress"].values())
        total_ex = sum(p["total"] for p in data["progress"].values())
        hints = sum(p["hints"] for p in data["progress"].values())

        rows.append(
            {
                "student_id": student_id,
                "name": name,
                "file": f.name,
                "status": "OK" if ok else "SUSPECT",
                "exercises_completed": total_done,
                "exercises_total": total_ex,
                "hints_used_total": hints,
                "problems": "; ".join(problems),
            }
        )
    return rows


def main() -> int:
    ap = argparse.ArgumentParser(description="Build a gradebook CSV from kali-class exports")
    ap.add_argument("files", nargs="+", type=Path, help="Exported progress .txt files (glob or dir)")
    ap.add_argument("--secret", help="Class secret (inline; prefer --secret-file)")
    ap.add_argument("--secret-file", type=Path, help="File whose first line is the class secret")
    ap.add_argument("--roster", type=Path, help="Directory of whoami-*.json submissions")
    ap.add_argument("--csv", type=Path, required=True, help="Output gradebook CSV path")
    ap.add_argument("--week", help="Only report one workshop's line, e.g. linux-wk03")
    args = ap.parse_args()

    secret = args.secret
    if args.secret_file:
        secret = args.secret_file.read_text().strip().splitlines()[0]
    if not secret:
        ap.error("Provide --secret or --secret-file")

    key = hmac_key_from_secret(secret)
    roster = load_roster(args.roster) if args.roster else None

    rows = build_rows(args.files, key, "LinuxAdminClass-2027", roster)

    if args.week:
        # add a per-week completion column derived from the export
        for row, f in zip(rows, args.files):
            data = parse_export(f)
            wk = data["progress"].get(args.week)
            row[f"{args.week}_done"] = wk["done"] if wk else 0
            row[f"{args.week}_total"] = wk["total"] if wk else 0

    import csv as _csv

    fieldnames = list(rows[0].keys()) if rows else []
    with args.csv.open("w", newline="") as fh:
        writer = _csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    ok_count = sum(1 for r in rows if r["status"] == "OK")
    print(f"{ok_count}/{len(rows)} exports OK — gradebook: {args.csv}")
    for r in rows:
        if r["status"] != "OK":
            print(f"  !! {r['student_id']} {r['name']}: {r['problems']}")
    return 0 if ok_count == len(rows) else 1


if __name__ == "__main__":
    sys.exit(main())