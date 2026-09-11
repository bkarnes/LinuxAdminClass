# 07 — Existing Docker Incidents (Week 13 Labs)

The four incident-response containers ported from the original course build
(`Build_Docs_Linux_Terminal_Class` Part I), now maintained at
`kali-class/incidents/`. Deployed with `kali-class setup-incidents`.

## Images

### linux-ir-authfail:1.0 — Brute Force Login Attempts
| | |
|--|--|
| Scenario | Repeated failed SSH logins |
| Preloaded | `/var/log/auth.log` with a brute-force pattern from 10.10.10.5 |
| Student objectives | Identify suspicious IP · count attempts · name the account |
| Skills | `grep`, `wc -l`, log interpretation |

Verifier (`sec-wk13/01`): findings file contains the IP, the attempt count,
and the target username; stamp required.

### linux-ir-filetamper:1.0 — Unauthorized File Changes
| | |
|--|--|
| Preloaded | `/srv/grades/final.csv`: appended `MODIFIED` line, mode 777, owner nobody |
| Student objectives | Identify, restore permissions + ownership + content |
| Skills | `ls -l`, `stat`, `chmod`, `chown`, `sed` |

Verifier (`sec-wk13/02`): **checks live container state** — mode back to
600, owner root:root, MODIFIED line gone, plus the findings file.

### linux-ir-malwarelite:1.0 — Malicious Script Running
| | |
|--|--|
| Preloaded | `/usr/local/bin/bad.sh` (beacon loop), `/etc/cron.d/badjob` persistence, `/tmp/.hidden/` artifacts |
| Student objectives | Find process, stop it, inspect, explain |
| Skills | `ps`, `top`, `kill`/`pkill`, `cat`, hidden dirs |

Verifier (`sec-wk13/03`): `bad.sh` not running inside the container;
findings name the path + cron persistence.

### linux-ir-timeline:1.0 — Timeline Reconstruction
| | |
|--|--|
| Preloaded | `/incident/` files with staged mtimes + hidden `.payload.sh`, `/var/log/applog` |
| Student objectives | Build a timeline, identify root cause |
| Skills | `stat`, `ls -la`, chronological reasoning |

Verifier (`sec-wk13/04`): timeline file with ascending incident-window
times, hidden-payload event included.

### Capstone of the week (`sec-wk13/05`)
A full incident write-up in the course template format (Issue Summary →
Evidence → Commands Used → Actions Taken → Outcome) for one incident of
the student's choice.

## Ops notes

- **Idempotent rebuild:** `setup-incidents` re-runs cleanly (Docker build
  cache). Containers are disposable; `docker rm -f <name>` + re-run
  restores the incident exactly — this is the reset mechanism.
- **No real malware:** `bad.sh` is a sleep loop + fake beacon. Safe for a
  classroom.
- **Evidence flow:** each exercise stamps its findings with
  `kali-class stamp sec-wk13 <label>` so the artifacts bind to the
  student's identity like every other workshop.

## Original mapping preserved

| CLO | Incident | Verifier |
|-----|----------|----------|
| Analyze system logs | IR 1 & 4 | authfail-findings, timeline |
| Manage permissions securely | IR 2 | live container stat |
| Identify malicious persistence | IR 3 | ps + findings |
| Document incidents clearly | all | write-up template check |