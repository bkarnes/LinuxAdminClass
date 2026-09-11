# 13 — Student Lab Manual

How to run your labs, week by week, without breaking your VM.

---

## 1. The one-time setup (already done on night 1)

You ran `setup_vm.sh` and installed the labs (option 9). You registered with
`kali-class` (name, student ID, class secret). Your registration lives at
`~/.kali-class/identity.json` — private, mode 600.

**If anything went wrong with registration** (typo in your name, wrong
secret): `kali-class re-register`. Your progress is kept.

**Assignment 0:** `kali-class whoami` wrote `whoami-<your-ID>.json` — you
uploaded it to the LMS. Done? You're registered.

## 2. The weekly ritual

```bash
kali-class                    # see the menu and your progress
kali-class linux-wk02         # start this week's workshop (or sec-wk08 etc.)
```

Inside a workshop:

| Key | Does |
|-----|------|
| **v** | verify the current exercise |
| **h** | next hint (they're fine to use — they're counted, not penalized harshly) |
| **s** | skip (come back later) |
| **l** | list all exercises |
| **q** | leave |

You do the real work in **your own terminal**, then switch back and press
**v**. Green ✓ = done; the runner advances automatically.

Finished all 5? 🎉 — run `kali-class export` and upload the dated file to
the LMS. That's your weekly submission.

## 3. Where things live on YOUR vm

| Path | What |
|------|------|
| `~/.kali-class/` | runner state (identity, progress) — **don't delete** |
| `~/.kali-class/venv/` | the runner itself — **definitely don't delete** |
| `~/kali-class-work/<workshop>/` | your artifacts: answers, scripts, captures |
| `~/kali-class-work/*-progress-*.txt` | your exports (upload the latest) |

If you ever break the runner: `cd ~/Projects/LinuxAdminClass/kali-class &&
./install.sh` rebuilds it.

**Updating labs:** `cd ~/Projects/LinuxAdminClass && git pull` — new
exercises appear instantly (editable install). No reinstall needed.

## 4. Rules of the road

1. **Do the work in your own VM.** Your exports are cryptographically bound
   to your student ID and your VM. A copied export fails verification — and
   the hints make cheating pointless anyway.
2. **Hints are not weakness.** They're counted but the penalty is tiny. A
   used hint beats a copied answer every time.
3. **Don't delete your `~/kali-class-work/`** — artifacts may be graded.
4. **Document as you go.** Screenshots and notes now save you pain later
   (especially weeks 8–14).
5. **Reboot breaks nothing.** Progress and identity survive reboots; the
   Week 6 runaway process re-plants if it died.

## 5. Week-by-week survival notes

### Weeks 1–7 (fundamentals)
- **wk02 ex03:** if `/var/log/syslog` is missing, generate `~/biglog.txt`
  first (`seq 1 1000 > ~/biglog.txt`) and use that.
- **wk03 ex04–05, wk07 ex02–03:** need `sudo` — your password is asked, that's
  normal.
- **wk04 ex05:** the runner plants seed files FOR you — don't recreate them
  by hand; just archive the directory as-is.
- **wk06 ex02:** the runaway process is real but harmless. Find it, kill it,
  document it. If it's already gone (another session killed it), just
  document PID + signal from your `runaway.pid` file.
- **wk05 ex03:** `apt purge` then `autoremove` — leave nothing behind.
- **wk07 ex05:** your default target is probably `graphical.target`
  (runlevel 5). Read what `systemctl get-default` says — don't guess.

### Weeks 8–14 (cybersec, Black-Hat-Bash lab)
- First: `kali-class setup-bhb` (before Week 8). It deploys the 8-machine
  Docker lab inside your VM.
- Targets live on `172.16.10.10–13` (public) and `10.1.0.11–16` (private —
  reachable via pivot from week 11+).
- **Don't run `make teardown` or `make clean` mid-week** — your flags die
  with the containers. If you do: `kali-class setup-bhb` re-seeds them
  (idempotent).
- Week 13 uses the incident-response Docker images from
  `~/Projects/LinuxAdminClass/kali-class/incidents/`.
- Week 14: capture 5 flags, keep the report template
  (`Machine_Template.md` at the repo root) open from day one — fill it as
  you go, not at the end.

## 6. When things go wrong

| Problem | Fix |
|---------|-----|
| `kali-class: command not found` | `source ~/.bashrc` or re-run `./install.sh` |
| Verifier says "Seed file missing" | `kali-class <workshop>` once — the runner plants seeds on entry |
| Verifier keeps failing | press **h** — hints walk you through |
| Wrong name on exports | `kali-class re-register` (progress kept), re-upload whoami JSON |
| Deleted `~/.kali-class/` by accident | re-run `install.sh`, then `kali-class re-register` |
| VM rebuilt (new machine-id) | `kali-class whoami`, upload as "Assignment 0b" — tell your instructor |

## 7. Cheating — why the runner makes it pointless

Your export file carries:

- a signature over every line (edits break it),
- per-exercise proofs keyed to YOUR student ID (copies carry the wrong proofs),
- your VM's unique ID, checked against what you registered on night 1.

Copy a friend's file and the instructor's verifier flags it in one run.
Hints are free. Doing the work is faster. That's the design.

## 8. TryHackMe (optional bonus)

The weekly workshops are your primary labs. Your instructor may list
TryHackMe rooms as optional enrichment — do them for extra practice, not
instead of the weekly export.

---

*Questions? Start with `kali-class <workshop>` and press h. The lab wants
you to succeed.*