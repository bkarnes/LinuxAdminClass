# 14 — Instructor Operations

> **Runbook:** day-to-day procedures live in
> `instructor/INSTRUCTOR_GUIDE.md` (registration, grading rounds,
> troubleshooting, semester checklist). This doc is the systems-level
> operations reference for running the lab platform itself.

---

## The instructor's toolkit

| Tool | When | What |
|------|------|------|
| `verify_export.py` | any single submission | verify + optional CSV, live human-readable output |
| `gradebook.py` | batch/semester scale | walk a whole submissions dir → one CSV |
| `INSTRUCTOR_GUIDE.md` | every grading round | the step-by-step runbook |
| `shared-secret.env` | never commit | the class secret (first line) |

## gradebook.py

```bash
# Whole-class gradebook from a directory of exports:
python3 kali-class/instructor/gradebook.py \
    --secret-file kali-class/instructor/shared-secret.env \
    --roster ~/grading/roster \
    --csv ~/grading/gradebooks/gradebook-full.csv \
    ~/grading/submissions/*/*.txt

# Single-week CSV (week 3 example):
python3 kali-class/instructor/gradebook.py \
    --secret-file kali-class/instructor/shared-secret.env \
    --week linux-wk03 \
    --csv ~/grading/gradebooks/week03.csv \
    ~/grading/submissions-week03/*.txt
```

Output columns: `student_id, name, file, status, exercises_completed,
exercises_total, hints_used_total, problems` — plus
`<workshop>_done/_total` when `--week` is given.

Exit code 0 only when every export verified — safe for scripted pipelines.

## Semester operations calendar

| When | Action |
|------|--------|
| Pre-semester | secret → `shared-secret.env` (gitignored); push repo; LMS Assignment 0; smoke test |
| Night 1 | announce secret; students register; roster JSONs → `~/grading/roster/` |
| Weekly | collect exports → `gradebook.py` → LMS transfer → resolve SUSPECTs |
| Week 7/8 (optional) | midterm practical from wk01–07 verifiers on fresh VMs |
| Week 8 | `kali-class setup-bhb` works on lab image before class |
| Week 14 | flags seeded; capstone graded; **no teardown until graded** |
| Post-semester | archive `~/grading/`; retire the secret |

## VM management (student VMs)

- Students keep their VM all semester — progress, identity, and artifacts
  live there. The runner survives reboots.
- VM rebuild → new machine-id → re-roster via "Assignment 0b" (guide §5.1).
- If the Docker disk fills mid-semester (BHB images): `docker system prune`
  is safe *between* weeks, never during 13–14.

## Backup & recovery

| What | Where | Backup guidance |
|------|-------|-----------------|
| Roster + gradebooks + exports | `~/grading/` | copy weekly (small files) |
| Student VM state | their VMs | students own this; snapshots before week 14 recommended |
| Class secret | your `shared-secret.env` + your head | two safe copies; never in the repo |

## Semester-end shutdown

1. Students run a final `kali-class export` for the archive.
2. Archive `~/grading/` (grade appeals live here for a year).
3. Choose a **fresh secret** next semester — never reuse.
4. Optional: bump the workshop version in `pyproject.toml` if you tuned
   exercises; students' `git pull` picks up changes.

## Where the deeper docs live

| Topic | Doc |
|-------|-----|
| Grading model + rubric weights | `docs/09`, `docs/12` |
| Anti-cheat internals | `docs/10` |
| Weekly outlines | `docs/04` (A), `docs/05` (B) |
| BHB ops | `docs/06` + `targets/blackhat-bash/README.md` |
| Incidents ops | `docs/07` + `kali-class/incidents/README.md` |