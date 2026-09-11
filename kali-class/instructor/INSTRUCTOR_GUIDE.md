# Instructor Guide — kali-class Labs

Day-to-day runbook for registering students and grading lab submissions in
the LinuxAdminClass course. Design rationale lives in
`kali-class/docs/10_anti_cheat_design.md`; the grading model in
`kali-class/docs/09_hints_progress_grading.md`.

---

## 0. Quick Reference Card

```bash
# ── REGISTRATION (night 1, once) ─────────────────────────────────────────
# Students upload whoami-<id>.json to the LMS (Assignment 0).
# You download them and build the roster:
mkdir -p ~/grading/roster
cp ~/Downloads/whoami-*.json ~/grading/roster/        # the student_id → vm_uuid map

# ── GRADING (every submission round) ──────────────────────────────────────
python3 kali-class/instructor/verify_export.py \
    --secret-file kali-class/instructor/shared-secret.env \
    --roster ~/grading/roster \
    --csv ~/grading/gradebook-week03.csv \
    ~/grading/submissions-week03/*.txt

# ── INTEGRITY REVIEW (only when a submission is SUSPECT) ─────────────────
# 1. Ask the student to run `kali-class whoami` live — VM UUID matches roster?
# 2. Have them run `kali-class export` fresh in front of you.
# 3. Optionally compare their /var/log/commands.log with the claimed work.
```

Workshop → submission mapping: week N's lab is graded from the
`<workshop-id>: N/5` line in each student's export (see §3.4).

---

## 1. Before Night 1

- [ ] **Choose the class secret.** One memorable phrase (no dictionary words
      you'd regret, no personal info). It lives only in your head until
      announced.
- [ ] **Store it locally:** create `kali-class/instructor/shared-secret.env`
      from the provided `.example`, with the secret on the **first line**.
      The `*.env` pattern is gitignored — **never commit it, never email it,
      never post it to the LMS.**
- [ ] **Push the updated repo to GitHub** before the first class night so
      students clone the complete package.
- [ ] **Create LMS assignment "Assignment 0: Registration"** — a file-upload
      dropbox for `whoami-<student_id>.json`.
- [ ] **Prepare your local grading workspace:**
      ```bash
      mkdir -p ~/grading/roster ~/grading/gradebooks
      # submissions get their own folder per round:
      mkdir -p ~/grading/submissions-week01
      ```
- [ ] **Smoke-test the tooling** with the E2E flow (register a fake student
      in a scratch VM or throwaway account, export, verify, then delete the
      scratch state).

---

## 2. Registering Students (Night 1)

### What you announce (verbally only)
1. The **class secret** — say it twice, write it on the board, erase it after
   the first exercise. Students type it once during `kali-class` first-run
   registration; it is stored only as a SHA-256 hash on their VM.
2. That registration files are **due tonight** as Assignment 0.

### What students run (validated flow)
```
./setup_vm.sh                 # the existing menu
   option 1 → add their user (reboots)
   option 2 → CLI logging (also creates /var/log/commands.log)
   option 3 → Docker
   option 9 → Install kali-class labs
kali-class                    # first run → name, student ID, secret (3 prompts)
kali-class whoami             # prints identity + writes whoami-<id>.json
                              # → upload JSON to LMS (Assignment 0)
```

### What you do
1. Download the `whoami-*.json` submissions from the LMS.
2. Copy them all into `~/grading/roster/`.
3. That's the roster built. Every future grading round uses
   `--roster ~/grading/roster` to cross-check each export's `VM UUID`
   against the VM the student registered from.

> The roster is the single source of truth for VM binding. Guard it; back it
> up with your gradebook.

### Edge cases
| Situation | Fix |
|-----------|-----|
| Student typo'd their name | They run `kali-class re-register` (progress is kept, identity re-derived) and re-upload the JSON |
| Student registered before you announced the secret (guessed wrong) | Same: `re-register` with the real secret, re-upload |
| Student has no JSON yet at grading time | They aren't in the roster; exports will flag "not in roster" — treat as late registration, not cheating |

---

## 3. Running Grading Each Time

### 3.1 Collect the week's exports
Students run `kali-class export` and upload the dated file:

```
<student_id>-progress-YYYYMMDD.txt      e.g. 901234567-progress-20260907.txt
```

Download them from the LMS into the round's folder:

```bash
mkdir -p ~/grading/submissions-week03
# copy the downloaded files there
```

### 3.2 Run the verifier

```bash
python3 kali-class/instructor/verify_export.py \
    --secret-file kali-class/instructor/shared-secret.env \
    --roster ~/grading/roster \
    --csv ~/grading/gradebooks/gradebook-week03.csv \
    ~/grading/submissions-week03/*.txt
```

(`--secret 'thephrase'` works inline if you prefer, but the secret then sits
in shell history — `--secret-file` is the habit to build.)

### 3.3 Read the output

Real sample output (from the Phase 1 end-to-end test):

```
999888777-progress-20260907.txt: Bob Student (999888777) -> OK
    linux-wk01: 5/5 (hints: 1)

All exports verified OK.
```

- Per-student status: `OK` or `SUSPECT` (with reasons listed underneath).
- Per-workshop line: `done/total (hints: n)` — hints are informational, not
  a penalty.

With `--csv`, you also get a spreadsheet-ready gradebook:

```csv
student_id,name,file,status,exercises_completed,exercises_total,problems
999888777,Bob Student,999888777-progress-20260907.txt,OK,5,5,
```

### 3.4 Grading week N specifically

Exports are **cumulative** — each file contains every completed workshop to
date. To grade week N, read that week's line from the progress block:

```
Workshop progress:
  linux-wk01: 5/5 (hints used: 1)
  linux-wk02: 5/5 (hints used: 0)
  linux-wk03: 3/5 (hints used: 2)     ← week 3 grade basis: 3/5
```

Quick extraction across a whole folder (week 1 example — the anchored
pattern matches the progress line, not the per-exercise claims):

```bash
grep -HE "^\s+linux-wk01:\s+[0-9]/5" ~/grading/submissions-week01/*.txt
```

Weighting suggestion (see `docs/09`): exercises 70%, hint economy 10%
(instructor judgment), write-ups/reports 20%.

### 3.5 Multiple submissions
Files are date-stamped. If a student uploaded twice, grade the **latest
date**; earlier files are natural progress snapshots. A drop in completion
between dates is worth a glance, not an accusation (workshop `reset` exists).

### 3.6 When a submission is SUSPECT

Run the three-step review, in order:

1. **Live whoami.** Ask the student to run `kali-class whoami` in class.
   The printed `VM UUID` must match the roster entry for their student ID.
2. **Fresh export.** Have them run `kali-class export` in front of you and
   re-verify the new file on the spot.
3. **Command history.** If still unresolved, ask for
   `/var/log/commands.log` (created by `setup_vm.sh` option 2). Fabricated
   progress has no matching command history behind it.

> **Caveat:** a rebuilt VM gets a new machine-id, which legitimately changes
> the VM UUID (see §5.1). vm_uuid mismatch alone is not proof of cheating —
> it's a prompt to run steps 1–3. Assume good faith first.

---

## 4. What to Grade per Phase

| Weeks | Evidence | Method |
|-------|----------|--------|
| 1–7 (Linux fundamentals) | Signed export file | `verify_export.py` only |
| 8–13 (cybersec) | Export **plus** artifacts in `~/kali-class-work/sec-wkNN/` (nmap XML, captures, findings .txt) | Tool + optional spot-checks during lab |
| 14 (capstone) | Export **plus** 5 CTF flags claimed **plus** pentest report | Tool + manual review of the report (built on `Machine_Template.md`) |

Flag-based capstone grading (Phase 4): each flag claim is an HMAC bound to
the student's ID; the verifier confirms claims the same way as exercises —
you do nothing extra beyond the standard run.

---

## 5. Roster & Secret Maintenance

### 5.1 Student rebuilt their VM
The machine-id changes, so exports stop matching the roster:

1. Have the student run `kali-class whoami` and upload the fresh JSON as
   **"Assignment 0b: Re-registration"** (LMS).
2. Replace that student's file in `~/grading/roster/`.
3. Re-run the verifier — the mismatch disappears.

This is expected maintenance, not an integrity event.

### 5.2 Student drops the class
Delete their `whoami-*.json` from the roster. (Exports from a dropped
student will then flag "not in roster" — correct behavior.)

### 5.3 Class secret compromised
1. Choose a new secret; update `shared-secret.env`.
2. At the next class, announce it and have everyone run
   `kali-class re-register` (one minute; progress files are preserved,
   identity is re-derived).
3. Collect fresh `whoami` JSONs into the roster again.

---

## 6. Troubleshooting

| Verifier says | Meaning | Likely cause | Action |
|---------------|---------|--------------|--------|
| `No signature found` | File truncated or hand-built | Upload/export mistake | Ask student to re-run `kali-class export` |
| `Document signature MISMATCH` | Content was modified after signing | Tampering *or* student edited the file (e.g. added a header) | Fresh export in class (§3.6 step 2) |
| `…claim(s) do not match this student_id` | Claims were generated by a different student | File copied from a friend | Integrity conversation |
| `vm_uuid MISMATCH` | Export came from a different VM than registration | **Usually:** VM rebuilt (new machine-id) | §5.1 re-roster; if unexplained, §3.6 |
| `student_id '…' not found in roster` | No Assignment 0 on file | Late registration or dropped student | Late: collect whoami JSON; drop: remove export from round |

Tool exits 0 when everything verified, 1 when anything needs review — safe
for scripted pipelines.

---

## 7. Semester Checklist

### Pre-semester
- [ ] Secret chosen, stored in `instructor/shared-secret.env` (gitignored)
- [ ] Repo pushed to GitHub with all 14 workshops
- [ ] LMS: Assignment 0 (Registration) created
- [ ] `~/grading/` workspace created; roster empty and ready
- [ ] Scratch-VM smoke test passed (register → export → verify)

### Night 1
- [ ] Announce secret verbally; board-erase
- [ ] Students: setup_vm.sh 1 → 2 → 3 → 9
- [ ] Students: `kali-class` (register) → `whoami` → upload JSON
- [ ] You: JSONs → `~/grading/roster/`

### Weekly rhythm (repeat ×14)
- [ ] Announce/assign the week's workshop
- [ ] Students run `kali-class linux-wkNN` / `sec-wkNN` (weeks 8+ need the
      BHB lab running: `kali-class setup-bhb`)
- [ ] Students run `kali-class export` and upload the dated file
- [ ] You: verify with `--secret-file --roster --csv`
- [ ] Transfer week-N line into LMS gradebook
- [ ] Resolve any SUSPECT via §3.6

### Capstone (week 14)
- [ ] BHB lab deployed with flags seeded (`seed-flags.sh` is idempotent)
- [ ] Remind students: **do not** `make teardown`/`clean` until graded
- [ ] Grade: export (5 flags claimed) + written report
- [ ] Spot-check one machine live if desired

### Post-semester
- [ ] Archive `~/grading/` (roster + submissions + gradebooks) for grade
      appeals
- [ ] Note the class secret for retirement — don't reuse it next semester;
      choose a fresh one
- [ ] File improvement notes for next cohort (exercise tuning, hint wording)

---

*Tooling reference: `kali-class/instructor/verify_export.py` (Phase 5 may add
`gradebook.py` for multi-file automation; the `--csv` flow above is the
supported mechanism today).*