# 00 — Course Overview

**Course:** Linux Systems Fundamentals & Cyber Security with Linux
**Length:** 14 weeks (7 weeks fundamentals + 7 weeks security)
**Environment:** Kali Linux VMs (VirtualBox), everything self-contained
**Lab system:** `kali-class` — NodeSchool-style interactive workshops running
inside each student's VM
**Primary labs:** this repo's 14 workshops. TryHackMe rooms = optional bonus.

---

## The arc

```
Weeks 1–7: LINUX FUNDAMENTALS          Weeks 8–14: CYBER SECURITY
(learn the system you'll defend)       (attack and defend real targets)

wk01 CLI & filesystem   ──┐             wk08 Recon & Web App  ─┐
wk02 Files & directories  │             wk09 Password attacks │
wk03 Users & permissions  ├ BHB-ready    wk10 Privesc          │  BHB lab
wk04 Bash scripting I     │ + midterm    wk11 Network / MITM   ├  + incident
wk05 Package management   │ practical    wk12 Metasploit       │  containers
wk06 Processes            │              wk13 Blue team / IR  │
wk07 Services & boot    ──┘             wk14 Capstone pentest ─┘
```

Midterm practical option: at end of week 7 or 8, select verifiers from
weeks 1–7 and run them against a fresh VM — the same scripts double as
exam tasks.

---

## Weekly workshop map

| Wk | Workshop | Topic | 5 exercises |
|----|----------|-------|-------------|
| 1 | `linux-wk01` | Intro & command line | pwd · mkdir/touch · man+redirect · FHS hunt · history |
| 2 | `linux-wk02` | Files & directories | nested tree · cp/mv · head/tail · globbing · find scavenger (token) |
| 3 | `linux-wk03` | Users & permissions | passwd extract · decode perms · chmod 640 · sudo drill · shared dir |
| 4 | `linux-wk04` | Bash scripting I | hello script · read/if · diskcheck · countdown · backup script (token) |
| 5 | `linux-wk05` | Package management | sources · toolkit install · purge lifecycle · apt show · hold/unhold |
| 6 | `linux-wk06` | Processes & resources | ps snapshot · kill runaway (planted) · nice/renice · df/du/free · job control |
| 7 | `linux-wk07` | Services & boot | service board · restart ssh · enable ssh · journalctl · targets/runlevels |
| 8 | `sec-wk08` | Recon & web app | nmap sweep · fingerprint · gobuster · Burp proxy · SQLi bypass |
| 9 | `sec-wk09` | Password attacks | hashid · john MD5 · hashcat SHA-512 · hydra SSH · hydra FTP |
| 10 | `sec-wk10` | Privilege escalation | low-priv shell · SUID enum · 3 escalation vectors (nano/find/passwd) |
| 11 | `sec-wk11` | Network attacks / MITM | FTP sniff · arpspoof · Wireshark filters · ettercap · MITM detection |
| 12 | `sec-wk12` | Metasploit basics | orientation · vsftpd exploit · postex · msfvenom · pivot analysis |
| 13 | `sec-wk13` | Blue team / IR | 4 incident containers · template write-up |
| 14 | `sec-wk14` | Capstone | 5 CTF flags (RECON/FOOTHOLD/PRIVESC/PIVOT/EXFIL) + pentest report |

---

## How the labs work (one paragraph for the syllabus)

Students run real commands in their own Kali VM. Each week's workshop presents
5 exercises; the student does the task in their own terminal and presses
**v** to verify — Bash verifier scripts check actual system state and give
instant green ✓ / red ✗ feedback with progressive hints on demand. Progress
is saved locally; weekly exports are cryptographically bound to the
student's identity and VM (anti-cheat), and graded with
`instructor/verify_export.py`.

---

## Key course infrastructure

| Component | Location | Purpose |
|-----------|----------|---------|
| Lab runner | `kali-class/kali_class/` | CLI, workshop loop, stamps, exports |
| 14 workshops | `kali-class/workshops/` | meta.yaml + exercises per week |
| Target lab | `kali-class/targets/blackhat-bash/` | BHB deploy, flags, privesc box |
| Incident images | `kali-class/incidents/` | 4 IR containers |
| Instructor tooling | `kali-class/instructor/` | verify_export.py, gradebook.py, guide |
| Build docs | `kali-class/docs/` | this directory |

Related docs: architecture (`01`), runner design (`02`), install (`03`),
Phase A/B outlines (`04`, `05`), BHB integration (`05`/`06`), incidents
(`07`), bash mini-course (`08`), grading model (`09`), anti-cheat (`10`),
outcomes (`11`), rubrics (`12`), student manual (`13`), instructor ops
(`14`).

---

## Assessment summary

- **Weekly:** signed export (`kali-class export`) → instructor verifies →
  gradebook CSV. Weighting per `docs/12` (exercises 70% / hints 10% /
  conduct 20% for weeks 1–7; artifacts + write-ups weighted up in 8–13).
- **Capstone:** 5 flags (50%) + pentest report (40%) + methodology (10%).
- **Integrity:** 3-layer tamper-evidence + VM binding (docs/10) +
  rsyslog command history correlation.

## Original outline preserved

This overview replaces and supersedes the original
`14-week_course_outline.md`. Everything from that file was either absorbed
here (course title, 14-week arc, per-week topics), moved to
`docs/04_phase_a_outlines_wk01-07.md` (expanded per-week teaching notes,
demo ideas, pacing guide), or into the workshops themselves (the expanded
Week 4/10/12 content became the exercise YAMLs of wk04 and the
mini-course doc `08_bash_mini_course.md`).

## Prerequisites & first night

See the top-level README (Kali VM download, VirtualBox setup) and
`docs/03_install_and_distribution.md` for the night-1 flow:
`setup_vm.sh` options 1 → 2 → 3 → 9, then `kali-class` registration,
then `kali-class whoami` → LMS "Assignment 0".