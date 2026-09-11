# 02 — Runner Design

## The exercise loop

```
┌──────────────────────────────────────────────┐
│  ┌── linux-wk01 ── Where in the world ────┐  │
│  │                                        │  │
│  │  The first thing any admin does...     │  │
│  │  Print the absolute path of the        │  │
│  │  directory you are currently in.       │  │
│  │                                        │  │
│  │  (v)erify (h)int (s)kip (l)ist (q)uit  │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

1. The runner picks the first incomplete exercise.
2. It prints the prompt (markdown-ish plain text, indented).
3. The student does the task **in their own terminal**.
4. Back in the runner:
   - `v` runs the verifier → green ✓ + success message, or red ✗ + guidance.
   - `h` reveals the next hint (one at a time; counted in progress.json).
   - `s` skips (recorded as complete, but the instructor sees hint counts and
     can spot pattern-skippers).
   - `l` lists all exercises with ✓/○ status.
   - `q` exits.
5. When all exercises are done: 🎉 + menu shows every exercise checked.

## Exercise YAML schema

```yaml
id: "01"                    # stable id; used in progress.json + claims
title: "Where in the world are you?"
prompt: |
  Plain-text prompt shown to the student. Indented 2 spaces by the runner.
hints:                      # ordered; revealed one per 'h' press
  - "Nudge without giving it away."
  - "Stronger nudge."
  - "Near-spoiler."
verify:
  script: "01-pwd.verify.sh"   # relative to the workshop's exercises/ dir
  timeout: 10                  # seconds; verifier is killed beyond this
on_success: "A congratulation or memorable summary line."
```

## Verifier contract

A `*.verify.sh` script must:

1. Be **idempotent** — running it twice changes nothing.
2. Be **side-effect free** — it checks state, never mutates it.
3. **Exit 0** on pass, non-zero on fail.
4. Write a helpful one-line message to **stderr** on failure (surfaced to the
   student by the runner).
5. Contain no secrets, no flags, no answers — verifiers ship in the repo.

### Failure-message style

```
✗ Not yet.
  Verifier says: ~/practice/first.txt is missing inside it.
  Run 'hint' if you're stuck, then try again and run 'verify'.
```

Every failure message says *what was checked* and *what was missing* — never
*how to do it* (that's the hints' job).

## Anti-cheat-aware verifiers

Exercises that produce an artifact (a file, an archive, a flag capture) can
bind it to the student using `kali_class/anti_cheat.py`:

- `ensure_seed_files()` plants per-student seed files at workshop start
  (idempotent, keyed by student_id).
- A verifier greps the student's artifact for the per-student token:
  `seeded_content(student_id, workshop, exercise)`.
- The export's per-exercise claim is `HMAC(secret_hash, class|student|workshop|exercise|artifact)`
  — recomputable by the instructor, unique per student.

Phase 1 ships this machinery; Phase 2 exercises begin using it in Week 4
(the backup-script lab) and all cybersec weeks.

## Progress & hints

- Completion is binary per exercise (`completed` array in progress.json).
- Hints used per exercise are counted and surfaced in exports so the
  instructor can tell "did the work with help" from "quietly perfect".
- `reset` per workshop wipes completion + hint counts (retry support).

## The main menu

`kali-class` with no arguments shows all 14 workshops with completion
fractions and a numbered picker. `--list` prints the same without entering
the menu (useful for scripting and screenshots).

The menu is the **home screen and loops**: finishing a workshop (or pressing
`q`/Enter inside one) returns to the menu with fresh progress; `Enter` at
the menu re-renders it; `q` exits. Direct invocation (`kali-class
linux-wk02`) also lands in the menu when the session ends, so the
completion screen's "back to main menu" promise holds everywhere.

## Error handling

- Unknown workshop id → friendly error listing valid ids.
- Missing verifier script → explicit "No verifier found" failure, never a
  silent pass.
- Verifier timeout (default 30s) → kill + friendly timeout message.
- Corrupt progress.json → treated as fresh state (self-healing).