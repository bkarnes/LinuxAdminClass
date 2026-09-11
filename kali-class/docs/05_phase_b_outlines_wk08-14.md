# 05 — Phase B Outlines (Weeks 8–14)

Per-week outlines for the cybersec phase. Every workshop runs against the
Black-Hat-Bash Docker lab (deployed with `kali-class setup-bhb`) plus, for
week 10, the dedicated `kali-class-privesc` container.

Every exercise that produces evidence requires a **lab stamp**:
`kali-class stamp <workshop> <label>` — verifiers call
`kali-class check-stamp` and fail without it. This ties each artifact to the
student's registered identity (per-VM).

---

## Week 8 — Recon, Enumeration & Web App Security (`sec-wk08`)

**Objectives:** host discovery, service fingerprinting, directory
enumeration, proxy interception, SQL injection fundamentals.

| # | Exercise | Tool | Evidence | Stamp label |
|---|----------|------|----------|-------------|
| 1 | Sweep the network | `nmap -sn` | nmap-sweep.txt | `nmap-sweep` |
| 2 | Fingerprint the web server | `nmap -sV` | nmap-web-01.txt | `nmap-web` |
| 3 | Directory enumeration | gobuster/dirb | gobuster-web02.txt | `gobuster` |
| 4 | Burp proxy basics | Burp + curl | burp-intercept.txt | `burp` |
| 5 | SQL injection (capstone) | curl + payload | sqli-login.txt | `sqli` |

**Demo ideas:** compare `-sn` vs `-sV` output; show the SQLi payload
anatomy (`' OR '1'='1' -- `) on the whiteboard first.

**Targets:** 172.16.10.0/24 discovery; p-web-01 (.10) fingerprint; p-web-02
(.12) gobuster + SQLi.

---

## Week 9 — Password Attacks (`sec-wk09`)

**Objectives:** hash identification, offline cracking (john + hashcat),
online brute force (hydra) against two services.

| # | Exercise | Tool | Evidence | Stamp label |
|---|----------|------|----------|-------------|
| 1 | Know your hashes | hashid | hash-types.txt | `hashid` |
| 2 | Crack MD5 with john | john | md5-cracked.txt | `john-md5` |
| 3 | Crack SHA-512 with hashcat | hashcat | sha512-cracked.txt | `hashcat-sha512` |
| 4 | Brute-force SSH (jumpbox) | hydra | hydra-ssh.txt | `hydra-ssh` |
| 5 | Brute-force FTP (capstone) | hydra | hydra-ftp.txt | `hydra-ftp` |

**Per-student hashes:** the runner plants `md5-hashes.txt` /
`sha512-hashes.txt` in `~/kali-class-work/sec-wk09/seeded/` at workshop
start — each file's hash tokens are derived from the student's ID + class
secret. The planted plaintexts (4 common passwords) are the same class-wide
so cracking succeeds with rockyou; the *hash values* are unique per student,
which the export's HMAC claims then bind to the individual student.

**Crackable with rockyou:** `letmein123`, `football2026`, `P@ssw0rd!`,
`changeme7`. Verifiers require ≥3 of the student's own 4 to appear.

**Lab credentials:** p-jumpbox-01 SSH accepts `root:toor`; p-ftp-01 accepts
`ftpuser:ftp123` (and `anonymous`). Include `toor`/`ftp123` in the password
lists students build.

---

## Week 10 — Privilege Escalation (`sec-wk10`)

**Objectives:** foothold, SUID enumeration, GTFOBins escalation (nano,
find), writable /etc/passwd.

Target: the dedicated **`kali-class-privesc`** container (Ubuntu 22.04,
SSH on localhost:2222, user `intern:intern123`) — deliberately
misconfigured in three independent ways (see
`targets/blackhat-bash/privesc-box/Dockerfile`). A readable
`/opt/notes/admin-todo.txt` hints at the misconfigurations.

| # | Exercise | Vector | Evidence |
|---|----------|--------|----------|
| 1 | Get your low-priv shell | SSH foothold | initial-shell.txt (intern) |
| 2 | Find the SUID misconfig | `find -perm -4000` | suid-list.txt (nanohelp) |
| 3 | SUID nano escalation | GTFOBins nano | privesc-suid.txt (root) |
| 4 | Passwordless sudo find | GTFOBins sudoers | privesc-sudo.txt (root) |
| 5 | Writable /etc/passwd (capstone) | append UID-0 user | privesc-passwd.txt (root) |

**Defensive tie-in:** close the lesson mapping each vector to its fix
(unset SUID, proper sudoers, `chown root:root /etc/passwd 644`).

---

## Week 11 — Network Attacks and MITM (`sec-wk11`)

**Objectives:** plaintext protocol sniffing, ARP poisoning, Wireshark
analysis, automated MITM, and detection (defender flip).

| # | Exercise | Tool | Evidence | Stamp label |
|---|----------|------|----------|-------------|
| 1 | Sniff FTP credentials | tcpdump | sniffed-creds.txt (+pcap) | `ftp-sniff` |
| 2 | ARP spoof the lab | arpspoof | arpspoof.txt | `arpspoof` |
| 3 | Wireshark filter drills | Wireshark | wireshark-notes.txt | `wireshark` |
| 4 | ettercap MITM | ettercap | ettercap.txt | `ettercap` |
| 5 | Detect the MITM (capstone) | arpwatch/ip neigh | detection-notes.txt | `mitm-detect` |

**Safety valve:** exercises 2/4 must run against the lab's Docker networks
only (never the campus LAN) — the lab is self-contained inside the student's
VM, which is why everything stays legal.

---

## Week 12 — Metasploit Basics (`sec-wk12`)

**Objectives:** msfconsole workflow, a real exploit, post-exploitation
basics, payload generation, pivot analysis.

| # | Exercise | Focus | Evidence | Stamp label |
|---|----------|-------|----------|-------------|
| 1 | msfconsole orientation | version + search | msf-orientation.txt | `msf-orient` |
| 2 | vsftpd backdoor exploit | exploit/multi | msf-vsftpd.txt | `msf-exploit` |
| 3 | Post-exploitation | uname/id/ip in shell | postex-info.txt | `postex` |
| 4 | msfvenom payload | linux/x64 reverse shell | payload.elf + log | `msfvenom` |
| 5 | Pivot analysis (capstone) | route/pivot reasoning | pivot-notes.txt | `pivot` |

**Target:** `exploit/unix/ftp/vsftpd_234_backdoor` against 172.16.10.11.
The private net (10.1.0.0/24) is deliberately unreachable — week 14's
capstone walks the real pivot via p-jumpbox-01.

---

## Weeks 13–14 (Phase 4 — see docs/07 + flag manifest)

- Week 13: the 4 incident containers (`incidents/`), IR write-ups.
- Week 14: 5-flag capstone across the kill chain + report
  (`Machine_Template.md`).

## Phase-B rubric adjustments

Per `docs/12`: cybersec weeks weigh export 50% / artifacts 30% /
write-up 20%. The stamps file (`~/.kali-class-work/sec-wkNN/.lab-stamps.json`)
is the artifact roster the instructor can audit live in lab.

## Kali VM test checklist (instructor, before night 1 of week 8)

- [ ] `kali-class setup-bhb` → 8 containers + privesc box up
- [ ] `ssh -p 2222 intern@127.0.0.1` works (intern:intern123)
- [ ] nmap/gobuster/hydra/john/hashcat/msfconsole present (full Kali metapackage)
- [ ] `kali-class stamp sec-wk08 test && kali-class check-stamp sec-wk08 test`
- [ ] `seed-flags.sh` reports planted=5 (or already-present on re-run)
- [ ] One full pass of sec-wk08 exercises against the live lab