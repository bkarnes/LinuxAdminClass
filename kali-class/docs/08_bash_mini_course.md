# 08 — Bash Mini-Course

The original course build included a 5-module Bash mini-course to run during
the fundamentals weeks. Phase 2 implements it directly as the `linux-wk04`
workshop plus two supporting weeks. Module → exercise mapping:

| Module | Topic | Where it lives now |
|--------|-------|--------------------|
| 1 | Bash basics & execution | wk04 ex01 (shebang, chmod +x, run) |
| 2 | Variables & input | wk04 ex02 (`read -p`, interpolation) |
| 3 | Conditionals | wk04 ex03 (`if`, `df` parsing, exit codes) |
| 4 | Loops | wk04 ex04 (argument check + `for` countdown) |
| 5 | Admin automation (capstone) | wk04 ex05 (backup script with error handling) |

Reinforcement across other workshops (bash is used, not taught):

- wk02 ex03 — redirection in anger (head/tail to files)
- wk03 ex01 — `cut` with custom delimiter on `/etc/passwd`
- wk06 ex03 — command substitution (`$(...)`) inside `ps -o`
- wk07 ex05 — capturing command output to files for evidence

## Assessment (from the original mini-course rubric, applied to wk04)

| Criteria | Points |
|----------|--------|
| Script correctness | 40 |
| Safety | 20 |
| Readability | 20 |
| Output clarity | 20 |

- **Correctness** = the verifier passes (it checks behavior, not source).
- **Safety** = usage message + exit 1 on bad input (ex04 enforces this);
  no `rm -rf` without checks; quoting variables.
- **Readability** = comments, consistent naming, indentation (manual review
  of the submitted `~/scripts/*.sh` if desired — students submit the export
  plus can be asked to show scripts live).
- **Output clarity** = the exact output formats the verifiers require.

## Teaching sequence for Week 4 lecture (75 min)

1. **10 min** — What a shell script is; shebang; `bash script.sh` vs
   `./script.sh`; PATH considerations.
2. **15 min** — Variables: assignment, quoting rules, `$1`-`$9`, `$?`, `$$`.
3. **15 min** — Conditionals: `if`, `test`/`[ ]`, file tests, exit codes.
4. **15 min** — Loops: `for`, `while`, C-style.
5. **10 min** — Debugging: `bash -x`, `set -euo pipefail`.
6. **10 min** — Capstone walkthrough: backup script requirements.

## Stretch goals for fast finishers

- Add `set -euo pipefail` to the backup script and explain what each flag does.
- Make the backup script refuse to overwrite an existing archive for the
  same day (test `[ -f "$ARCHIVE" ]`).
- Rewrite countdown.sh with a `while` loop and compare.