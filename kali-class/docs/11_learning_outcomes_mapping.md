# 11 — Learning Outcomes Mapping

Course Learning Outcomes (CLOs) for the Linux Admin course, mapped to the
workshops that teach them and the mechanisms that prove them. Observable,
tool-agnostic, and defensible to a curriculum committee.

| CLO | Workshop(s) | Evidence | Verification mechanism |
|-----|-------------|----------|------------------------|
| Navigate the Linux filesystem | linux-wk01, wk02 | tree built, FHS answers | verifier exit codes |
| Manage files and directories | linux-wk02 | copies/moves/globs | cmp against originals |
| Interpret users, groups, permissions | linux-wk03 | permission decode, modes applied | getent + stat |
| Administer users and groups | linux-wk03 | shared dir with projectx group | getent group + stat |
| Write and debug Bash scripts | linux-wk04 (+ wk02, wk06 usage) | scripts that pass behavioral checks | verifiers execute the student's script |
| Manage software packages | linux-wk05 | install/remove/hold cycle | dpkg + apt-mark live state |
| Monitor and control processes | linux-wk06 | snapshot, kill, renice | live process state + artifacts |
| Manage system services | linux-wk07 | restart, enable, journal | systemctl live state + captures |
| Understand the boot process | linux-wk07 | default target + runlevel map | systemctl + correct equivalence |
| Perform recon and enumeration | sec-wk08 | nmap XML artifacts | verifier (Phase 3) |
| Assess web application security | sec-wk08 | dirb/Burp findings | verifier (Phase 3) |
| Conduct password attacks | sec-wk09 | cracked-hash file | verifier (Phase 3) |
| Escalate privileges | sec-wk10 | privesc evidence | verifier (Phase 3) |
| Capture and analyze network traffic | sec-wk11 | pcap artifacts | verifier (Phase 3) |
| Operate Metasploit | sec-wk12 | session evidence | verifier (Phase 3) |
| Perform incident response triage | sec-wk13 | findings files + restored state | verifier + write-up (Phase 4) |
| Execute a full pentest kill chain | sec-wk14 | 5 flags + report | flag HMACs + report rubric (Phase 4) |
| Document technical work clearly | wk13, wk14 + all reports | write-ups per template | rubric-based manual review |
| Apply academic integrity in practice | all weeks | signed exports, bound to student+VM | verify_export.py 3-layer checks |

## Alignment with the original course goals

The original outline's promise — "students move from users to power users,
grounded in admin fundamentals before offense" — is preserved:

- Weeks 1–7: each CLO verified by **observable system state**, not self-report.
- Weeks 8–14: each CLO verified by **attack artifacts bound to the student's
  identity** (anti-cheat tokens + signed exports).
- Documentation CLO runs through every phase (write-ups, capstone report,
  incident findings).

## Assessment coverage matrix

| CLO | Formative (labs) | Summative |
|-----|------------------|-----------|
| Filesystem / files | wk01–02 verifiers | midterm practical |
| Permissions / users | wk03 verifiers | midterm practical |
| Scripting | wk04 verifiers | midterm practical + capstone tooling |
| Packages / services / boot | wk05–07 verifiers | midterm practical |
| Cybersec skills | wk08–13 verifiers | capstone flags |
| IR + documentation | wk13 write-ups | capstone report |

The midterm practical (instructor's option, end of week 7 or 8) can be built
by selecting verifiers from weeks 1–7 and running them against a fresh VM —
the same scripts double as exam tasks.