# 09 — Hints, Progress & Grading

> **Runbook:** for step-by-step registration and grading procedures, see
> `instructor/INSTRUCTOR_GUIDE.md` — this document explains the model; the
> guide is the day-to-day runbook.

## Hints

- Each exercise lists ordered hints in its YAML, from gentle nudge to
  near-spoiler.
- One hint per `h` press; the count is stored per exercise.
- Hint counts are included in the export — instructors can distinguish
  "used hints and learned" from "no hints, suspiciously clean".
- Running out of hints prints a clear "you've seen them all" message.

Example (Week 1, Exercise 3):

```
Hint 1/3: Read the manual with: man ls. Look for 'use a long listing format'.
Hint 2/3: The long-format flag is -l (lowercase L, not a one).
Hint 3/3: Capture output with redirection: ls -l /etc > ~/etc-listing.txt
```

## Progress model

| File | Contents |
|------|----------|
| `~/.kali-class/progress.json` | `{workshops: {id: {completed: [ex-id], hints_used: {ex-id: n}}}}` |
| `~/kali-class-work/<wid>/` | Artifacts (answers, scripts, captures, flags) |
| `~/kali-class-work/<student_id>-progress-YYYYMMDD.txt` | Signed export |
| `~/kali-class-work/whoami-<student_id>.json` | LMS registration file |

## Export format

```
Student: Jane Doe (901234567)
Class: LinuxAdminClass-2027
VM UUID: e3b3277c...
Exported: 2026-09-07T19:21:11+00:00

Workshop progress:
  linux-wk01: 5/5 (hints used: 1)

Per-exercise claims:
  linux-wk01:01: <64-hex HMAC>
  linux-wk01:02: <64-hex HMAC>
  ...

Signature: <64-hex HMAC over the entire body>
```

Three cryptographic layers (details in `docs/10_anti_cheat_design.md`):

1. **Document signature** — any edit to any line invalidates it.
2. **Per-exercise claims** — bound to the student's ID; a copied file has the
   wrong claims for the copier's ID.
3. **vm_uuid** — cross-checked against the roster built from Assignment 0
   `whoami` uploads.

## Grading workflow (instructor)

```bash
# one-time: collect Assignment 0 JSONs into roster/
python3 instructor/verify_export.py \
    --secret-file instructor/shared-secret.env \
    --roster roster/ \
    --csv gradebook.csv \
    submissions/*.txt
```

Output per student: completion per workshop, hint totals, OK/SUSPECT flag,
and specific problems (bad signature, foreign claims, vm mismatch).

`--csv` writes a spreadsheet-ready gradebook:

```csv
student_id,name,file,status,exercises_completed,exercises_total,problems
901234567,Jane Doe,901234567-progress-20260907.txt,OK,5,5,
```

### Suggested rubric weighting (Phase 2 refines per week)

| Component | Weight | Source |
|-----------|--------|--------|
| Exercises completed | 70% | export progress lines |
| Hint economy | 10% | hint counts (informational, instructor judgment) |
| Write-ups / reports | 20% | LMS (incident write-ups, capstone report) |

## What students submit

| Assignment | File | Where it comes from |
|-----------|------|--------------------|
| Assignment 0: Registration | `whoami-<id>.json` | `kali-class whoami` |
| Weekly lab grade | `<id>-progress-YYYYMMDD.txt` | `kali-class export` |
| Incident write-ups (wk13) | findings .txt files | `~/kali-class-work/sec-wk13/` |
| Capstone (wk14) | report + export | manual + `kali-class export` |

## Integrity escalation path

If an export is SUSPECT:

1. Ask the student to run `kali-class whoami` live in class — does the VM
   UUID match the roster?
2. Ask them to run `kali-class export` fresh in front of you.
3. Optionally compare `/var/log/commands.log` (set up by `setup_vm.sh`
   option 2) with the claimed timeline — a fabricated export has no matching
   command history.

The system is tamper-*evident*, not tamper-*impossible* — the goal is to make
cheating harder than doing the work, which these labs make genuinely fast.