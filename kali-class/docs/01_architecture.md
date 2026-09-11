# 01 — Architecture

## Overview

`kali-class` is a NodeSchool-style interactive lab system that lives inside the
`LinuxAdminClass` repo. Students run real commands in their own Kali VM; a
Python CLI runner checks their work with Bash verifier scripts, offers
progressive hints, tracks progress locally, and produces a cryptographically
signed progress export for the instructor.

```
┌─────────────────────────────────────────────────────────────┐
│ Student's Kali VM                                            │
│                                                              │
│  ~/Projects/LinuxAdminClass/                                 │
│  ├── setup_vm.sh          (option 9 installs the runner)     │
│  ├── configs/             (shell snippets, rsyslog config)   │
│  └── kali-class/                                             │
│      ├── install.sh       → venv + editable pip install      │
│      ├── kali_class/      (Python package — the runner)      │
│      ├── workshops/       (14 × meta.yaml + exercises)       │
│      │   └── linux-wk01/exercises/                           │
│      │       ├── 01-pwd.yaml        (prompt + hints)         │
│      │       └── 01-pwd.verify.sh   (bash, exit 0 = pass)    │
│      ├── instructor/      (verify_export.py, gradebook.py)   │
│      └── targets/         (Black-Hat-Bash lab integration)   │
│                                                              │
│  ~/.kali-class/           (state, mode 700)                  │
│  ├── identity.json        (name, student ID, vm_uuid,        │
│  │                         sha256(class secret))             │
│  ├── progress.json        (per-exercise completion + hints)  │
│  └── venv/                (editable install of the runner)   │
│                                                              │
│  ~/kali-class-work/       (student artifacts + exports)      │
└─────────────────────────────────────────────────────────────┘
```

## Component responsibilities

| Component | Responsibility |
|-----------|---------------|
| `cli.py` | Argument parsing, verb/workshop dispatch, main menu |
| `runner.py` | The NodeSchool-style exercise loop (prompt → act → verify → hint) |
| `verifier.py` | Runs `*.verify.sh` with a timeout, reports pass/fail |
| `progress.py` | Reads/writes `progress.json` |
| `identity.py` | First-run registration, `whoami` JSON generation |
| `hints.py` (logic in runner) | Progressive hint reveal, usage counted |
| `anti_cheat.py` | Per-student deterministic tokens (HMAC) for artifact binding |
| `export.py` | Builds + signs the instructor export |
| `instructor/verify_export.py` | Instructor-side validation (signature, claims, roster) |

## Design decisions

### Python core + Bash verifiers (hybrid)
- Python gives a pleasant cross-shell UX (menus, colors, JSON state) and is
  pre-installed on Kali.
- Bash verifiers run with the student's real environment (`$HOME`, real
  filesystem) and can check anything a sysadmin would check: file existence,
  permissions, `systemctl` state, `crontab -l` output, docker containers.
- Verifiers are standalone scripts — an instructor can run them manually, and
  they double as executable documentation of "what done means".

### One workshop per week
14 directories under `workshops/`, each self-contained (meta.yaml +
exercises/). Adding a week = adding a directory. No central registry to
update; `list_workshops()` discovers them by scanning.

### Editable install
`pip install -e .` inside a venv at `~/.kali-class/venv` means `git pull`
immediately updates labs for students. The trade-off (venv must persist) is
documented in the student README and manual.

### State format
`progress.json` is deliberately simple and human-readable:

```json
{
  "workshops": {
    "linux-wk01": {
      "completed": ["01", "02"],
      "hints_used": {"02": 1}
    }
  },
  "last_updated": "2026-09-07T19:21:05+00:00"
}
```

## Data flow (one exercise attempt)

```
student runs real commands in terminal
        │
        ▼
runner: 'v' → verifier.run(workshop, exercise)
        │         │
        │         ├─ subprocess bash 01-pwd.verify.sh (timeout)
        │         ├─ exit 0 → progress.mark_complete() → save()
        │         │            + on_success message
        │         └─ exit ≠0 → failure message + offer hint
        ▼
'h' → hints[used++] printed (usage recorded)
        ▼
'export' → per-exercise HMAC claims + document signature
        ▼
instructor: verify_export.py (signature → claims → roster vm_uuid)
```

## Where Phase 1 fits the course

Phase 1 delivers the complete vertical slice: install → register → do an
exercise → export → instructor verify. Weeks 2–14 reuse this exact machinery;
only `workshops/<id>/` content differs.