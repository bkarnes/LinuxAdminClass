# 04 — Phase A Outlines (Weeks 1–7)

Per-week teaching outlines mapped to the workshops. Each week = one workshop
directory with 5 exercises. In-class time: lecture/demo (~40%) + lab (~60%).

---

## Week 1 — Introduction to Linux and the Command Line (`linux-wk01`)

**Learning objectives:** navigate the filesystem, read the manual, know the
FHS, use shell history.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Where in the world are you? | `pwd`, working directory | command log (or fallback) |
| 2 | Take a look around | `mkdir`, `touch` | filesystem state |
| 3 | RTFM — the man pages | `man`, `ls -l`, redirection | file content pattern |
| 4 | FHS scavenger hunt | `/etc`, `/var/log`, `/tmp` | exact answers file |
| 5 | Learn from your history | `history`, `clear` | command log |

Demo ideas: the FHS tour (`ls /`), `man -k` keyword search, history
shortcuts (`!!`, Ctrl+R).

---

## Week 2 — Working with Files and Directories (`linux-wk02`)

**Learning objectives:** create/copy/move/delete, sample large files,
glob across many files, locate anything with `find`.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Build a filing cabinet | `mkdir -p`, nested trees | exact tree check |
| 2 | Copy, move, rename | `cp`, `mv` (+ intact original) | cmp against original |
| 3 | Peek at a big file | `head -n`, `tail -n`, redirect | line counts + content match vs source |
| 4 | Wildcards | `*`, brace expansion, batch copy | 3-file glob result |
| 5 | find scavenger hunt | `find -name`, per-student seed | **token check (anti-cheat)** |

Exercise 3 accepts either `/var/log/syslog` or a generated `~/biglog.txt`
so the lab works even on a fresh VM.

---

## Week 3 — Users, Groups, and Permissions (`linux-wk03`)

**Learning objectives:** read the user database, decode permission strings,
apply octal modes, use sudo deliberately, build a shared workspace.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Who are you? Who's here? | `whoami`, `id`, `groups`, `cut` on `/etc/passwd` | list matches passwd |
| 2 | Read a permission string | type/owner/group/others positions | answers vs `stat %A` |
| 3 | chmod by the numbers | octal math, `chmod 640` | mode + symbolic answer |
| 4 | sudo vs su | least privilege, root-owned file | file + owner + outcome record |
| 5 | Shared directory (capstone) | `groupadd`, `chown root:group`, `770` | getent + stat |

**Instructor note:** exercises 4–5 need students to have sudo. Everyone just
did setup_vm.sh option 1, so every student user is in the sudo group.

---

## Week 4 — Bash Scripting I (`linux-wk04`)

**Learning objectives:** shebang → executable → run lifecycle; variables,
`read`, conditionals, loops, argument handling; a real backup script.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Hello, script | shebang, `chmod +x`, execution | runs + prints exact line (+ log) |
| 2 | Variables and input | `read -p`, interpolation | verifier feeds test input |
| 3 | Decisions | `if`, `df` parsing, exit codes | output pattern + rc 0 |
| 4 | Loops | `$1` arg check, `for ((...))` | usage-case rc 1 + countdown exact |
| 5 | Backup script (capstone) | `tar -czf`, `date +%Y%m%d`, `mkdir -p` | **token check inside the tarball (anti-cheat)** |

The capstone is the anti-cheat showcase: the runner plants
`~/kali-class-work/linux-wk04/seeded/` with the student's personal token;
the verifier extracts the tarball and compares tokens. A friend's archive
fails.

This week implements the **Bash mini-course modules 1–4** (see `docs/08`).

---

## Week 5 — Package Management (`linux-wk05`)

**Learning objectives:** repositories, install/update/remove lifecycle,
inspecting before installing, holding packages.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Know your sources | `apt` sources, `/etc/os-release` | URIs + ID/CODENAME lines |
| 2 | Admin toolkit | `apt update/install`, htop+curl+jq | tools on PATH + proof files |
| 3 | Remove cleanly | `apt purge`, `autoremove`, `dpkg -l` states | sl uninstalled + record |
| 4 | Inspect before install | `apt show`, Depends line | package + depends lines |
| 5 | Hold/unhold (capstone) | `apt-mark hold/showhold/unhold` | hold recorded + released |

**Instructor note:** all five work offline except the installs; do installs
in class where the network is guaranteed.

---

## Week 6 — Processes and Resource Monitoring (`linux-wk06`)

**Learning objectives:** full process snapshots, killing, priorities,
resource gauges, shell job control.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Snapshot of everything | `ps aux`, header + completeness | file pattern + line count |
| 2 | Runaway process drill | `ps | grep`, `kill`, kill -9 | process dead (via runner-planted PID) + report |
| 3 | Priority adjustments | `nice`, `renice`, `ps -o ni` | NI column + OLD/NEW record |
| 4 | Resource inventory | `df -h`, `du -sh`, `free -h` | 3 reports with format checks |
| 5 | Job control (capstone) | `&`, `jobs`, `kill %1` | before/after jobs pair |

**The runaway drill:** starting the workshop plants a harmless
`kali-class-runaway` process (sleep loop) whose PID is stamped in
`~/kali-class-work/linux-wk06/runaway.pid`. The verifier fails while it
runs and passes when the student kills it and documents PID + signal.
Idempotent: re-entering the workshop re-plants only if it's dead.

---

## Week 7 — System Services and the Boot Process (`linux-wk07`)

**Learning objectives:** systemd units, status/start/stop/restart, enabling
at boot, journalctl, default targets and runlevel equivalence.

| # | Exercise | Concepts | Verified by |
|---|----------|----------|-------------|
| 1 | Read the service board | `systemctl list-units`, `status ssh` | 2 capture files |
| 2 | Start, stop, restart | `systemctl restart`, `is-active` | live is-active + Active line |
| 3 | Enable at boot | `systemctl enable`, `is-enabled` | live is-enabled + record |
| 4 | Ask the journal | `journalctl -n`, `journalctl -u ssh` | 2 extracts (empty unit OK) |
| 5 | Targets (capstone) | `get-default`, targets list, runlevel map | real default + correct equivalence |

**Instructor note:** weeks 5–7 complete the pre-midterm arc; a midterm
practical can reuse these verifiers as exam tasks.

---

## Pacing guide (14 weeks)

| Week | Workshop | Lab type |
|------|----------|----------|
| 1 | linux-wk01 | in-class |
| 2 | linux-wk02 | in-class |
| 3 | linux-wk03 | in-class (sudo) |
| 4 | linux-wk04 | in-class + homework polish |
| 5 | linux-wk05 | in-class (network) |
| 6 | linux-wk06 | in-class |
| 7 | linux-wk07 | in-class (sudo) → **midterm practical available** |