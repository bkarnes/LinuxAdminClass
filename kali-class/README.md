# kali-class — Interactive Labs

NodeSchool-style interactive labs for the LinuxAdminClass course. Everything
runs inside your own Kali VM: you do real commands in your real terminal,
and the lab runner checks your work, gives hints when you're stuck, and
keeps track of your progress.

## Quick start

```bash
# From the LinuxAdminClass repo (students already have this):
cd ~/Projects/LinuxAdminClass/kali-class
./install.sh

# Then register (first time only — name, student ID, class secret):
kali-class

# Check in and grab your LMS upload file:
kali-class whoami

# Start Week 1:
kali-class linux-wk01
```

## The 14 workshops

| Week | Workshop | Topic |
|------|----------|-------|
| 1 | `linux-wk01` | Intro to Linux & the command line |
| 2 | `linux-wk02` | Working with files and directories |
| 3 | `linux-wk03` | Users, groups, and permissions |
| 4 | `linux-wk04` | Bash scripting I |
| 5 | `linux-wk05` | Package management |
| 6 | `linux-wk06` | Processes and resource monitoring |
| 7 | `linux-wk07` | Services and the boot process |
| 8 | `sec-wk08` | Recon, enumeration & web app security |
| 9 | `sec-wk09` | Password attacks |
| 10 | `sec-wk10` | Privilege escalation |
| 11 | `sec-wk11` | Network attacks / MITM |
| 12 | `sec-wk12` | Metasploit basics |
| 13 | `sec-wk13` | Blue team / incident response |
| 14 | `sec-wk14` | Capstone pentest (report + CTF flags) |

Weeks 8–12, 14 use the Black Hat Bash Docker lab as targets — run
`kali-class setup-bhb` before starting (Week 8 onward). Week 13 uses the
incident containers — run `kali-class setup-incidents`.

## How a lab works

1. `kali-class <workshop>` shows you an exercise.
2. You do the task in your **own terminal** (the runner never sandboxes you).
3. Back in the runner, press **v** to verify. Green checkmark = done.
4. Stuck? Press **h** for a hint (hints are tracked, it's fine to use them).
5. Finish all 5 exercises → 🎉 and move to the next week.

## Commands

| Command | What it does |
|---------|-------------|
| `kali-class` | Main menu + progress overview |
| `kali-class <workshop-id>` | Run a specific week's exercises |
| `kali-class whoami` | Print registration + write `whoami-<id>.json` for the LMS |
| `kali-class progress` | Show completion across all 14 workshops |
| `kali-class export` | Write a signed progress file for your instructor |
| `kali-class re-register` | Fix a name/ID typo (keeps your progress) |
| `kali-class setup-bhb` | Deploy the Black-Hat-Bash target lab (weeks 8–14) |
| `kali-class setup-incidents` | Build the 4 incident containers (week 13) |
| `kali-class stamp <workshop> <label>` | Record evidence for a cybersec exercise |
| `kverify` / `khint` / `kprogress` / `kexport` / `kwhoami` | Shortcut aliases |

## Where your data lives

- `~/.kali-class/identity.json` — your registration (name, student ID, VM UUID,
  hashed class secret). Mode 600, private to you.
- `~/.kali-class/progress.json` — which exercises you've completed and hints used.
- `~/kali-class-work/` — artifacts the labs have you create (answers, captures,
  flags, exports). Your instructor may ask you to submit files from here.

## Important

**Do not delete `~/.kali-class/venv`.** That's the lab runner itself. The
runner is installed in "editable" mode, which means updating the class repo
with `git pull` instantly updates your labs — but only as long as the venv
exists. If you ever delete it, re-run `./install.sh` from this directory.

## Anti-cheating (why it matters)

Your exported progress file is cryptographically bound to:

- your student ID,
- your VM's unique machine ID,
- and the class secret (hashed, never stored in plain text).

Copying a friend's export file will fail verification because the per-exercise
proofs are tied to *their* student ID and *their* VM. Do your own work — the
hints exist precisely so you never need to.