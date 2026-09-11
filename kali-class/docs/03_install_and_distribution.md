# 03 — Install & Distribution

## Student flow (first night)

Students already clone the repo to `~/Projects/LinuxAdminClass` (per the main
README). The lab system ships inside that same clone — no second download.

```
1. ./setup_vm.sh          # the existing menu
2. choose 9               # "Install kali-class labs"
3. kali-class             # first run → 3-prompt registration
4. kali-class whoami      # writes whoami-<id>.json → upload to LMS (Assignment 0)
5. kali-class linux-wk01  # start the first lab
```

## What `install.sh` does

| Step | Detail |
|------|--------|
| 1. Checks | Python ≥ 3.10, `venv` module available |
| 2. Dirs | `~/.kali-class/` (mode 700), `~/kali-class-work/` |
| 3. Venv | Creates `~/.kali-class/venv` if missing |
| 4. Install | `pip install -e kali-class/` (editable) |
| 5. Launcher | Symlinks `~/.local/bin/kali-class` |
| 6. PATH | Ensures `~/.local/bin` is on PATH in `.bashrc`/`.zshrc` |
| 7. Aliases | Appends `configs/kali-class-completion.{bashrc,zshrc}` (marker-guarded, idempotent) |
| 8. Reboot | **None** — venv-only, safe mid-session |

Every step is idempotent; re-running `install.sh` (or `setup_vm.sh` option 9)
is always safe.

## Why editable install

- `git pull` in the repo instantly updates lab content for students — no
  reinstall, no version skew between instructor repo and student VMs.
- Students can read the exercise YAMLs and even the verifiers — we consider
  that a feature (transparency), not a leak: answers live in *doing*, not in
  files.
- Caveat (documented in README + student manual): do not delete
  `~/.kali-class/venv`. If deleted, re-run `install.sh`.

## Updating mid-semester

Instructor pushes new exercises to GitHub:

```bash
# student side
cd ~/Projects/LinuxAdminClass && git pull
# done — the venv picks up the new workshops automatically
```

Version skew is detectable: `kali-class --version` prints the package
version; workshops record nothing version-specific in progress.json.

## Offline classroom fallback

If a lab room has no internet: clone the repo to a USB stick, copy to each
VM's `~/Projects/LinuxAdminClass`, and run option 9 as usual. Everything
except `git pull` works offline. (Verifiers and runner are local; BHB labs in
Phase 3 need Docker Hub, so plan those nights with connectivity.)

## Files added to the repo by Phase 1

```
kali-class/
├── README.md
├── install.sh
├── pyproject.toml
├── kali_class/            (9 modules)
├── workshops/linux-wk01/  (meta.yaml + 5 exercises + 5 verifiers)
├── instructor/
│   ├── verify_export.py
│   └── shared-secret.env.example
└── docs/01, 02, 03, 09, 10 (this set)

configs/kali-class-completion.bashrc
configs/kali-class-completion.zshrc
.gitignore                 (secrets + venvs + local state)
setup_vm.sh                (option 9 + install-kali-class function)
```

## Distribution checklist for the instructor (semester start)

- [ ] Push the updated repo to GitHub before night 1.
- [ ] Choose the class secret; keep it in `instructor/shared-secret.env`
      (gitignored). Never commit it.
- [ ] Night 1: students run setup_vm.sh options 1 → 2 → 3 → 9.
- [ ] Students run `kali-class whoami` and upload the JSON to the LMS
      (Assignment 0) — this builds your `student_id → vm_uuid` roster.
- [ ] Store the roster JSONs in one folder; `gradebook.py` uses them for
      vm_uuid cross-checks all semester. (Full runbook:
      `instructor/INSTRUCTOR_GUIDE.md`, which includes the semester
      checklist.)