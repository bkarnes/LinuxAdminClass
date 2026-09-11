# 06 — BHB Lab Integration (student-facing quick start)

> The technical map and week-by-week targeting live in
> `targets/blackhat-bash/README.md`. This doc is the deploy/ops reference.

## One command deploys everything

```bash
kali-class setup-bhb
```

Behind the scenes (`targets/blackhat-bash/deploy.sh`):

1. Clones `dolevf/Black-Hat-Bash` → `~/Projects/Black-Hat-Bash` (once)
2. Ensures the Docker daemon runs (`service docker start`)
3. `sudo make deploy` in `lab/` (8 containers on 2 networks)
4. Builds + runs `kali-class-privesc` (week 10 target, SSH :2222)
5. Runs `seed-flags.sh` (capstone flags — idempotent)
6. Health-checks: reports `N/8 lab machines running`

Re-run any time — every step is idempotent. After `bhb_stoplab` or a VM
reboot, just re-run the command.

## The targets at a glance

| Host | IP | Role | Used in |
|------|----|------|---------|
| p-web-01 | 172.16.10.10 | web | wk08, wk11, wk12, wk14 |
| p-ftp-01 | 172.16.10.11 | vsftpd (old) | wk08, wk09, wk11, wk12 |
| p-web-02 | 172.16.10.12 | web app | wk08 (gobuster/SQLi), wk14 flag |
| p-jumpbox-01 | 172.16.10.13 | SSH pivot | wk09, wk14 pivot |
| kali-class-privesc | localhost:2222 | privesc lab | wk10 |
| c-backup-01 | 10.1.0.13 | backup srv | wk14 exfil flag |
| c-redis-01 | 10.1.0.14 | redis | wk14 pivot path |
| c-db-01 / c-db-02 | 10.1.0.15/16 | databases | wk14 pivot flag |

Known service credentials (intentionally weak, for the labs):
`p-jumpbox-01` SSH `root:toor`; `p-ftp-01` `ftpuser:ftp123` and `anonymous`;
privesc box `intern:intern123`.

## The stamp system (weeks 8–12 evidence)

Each exercise ends with a stamp step:

```bash
kali-class stamp sec-wk08 nmap-sweep      # after saving the artifact
kali-class check-stamp sec-wk08 nmap-sweep  # what verifiers call
```

Stamps live in `~/.kali-class-work/sec-wkNN/.lab-stamps.json` and record
student ID + label + timestamp. Verifiers fail without the matching stamp,
which keeps artifacts tied to the registered student/VM.

## Flag seeding (weeks 10 & 14)

`seed-flags.sh` reads `flags/flag-manifest.yaml` and plants 5 flags:

| Flag | Container | Path | Unlock skill |
|------|-----------|------|--------------|
| FLAG_RECON | p-web-01 | /var/www/html/robots.txt | week 8 recon |
| FLAG_PRIVESC | kali-class-privesc | /root/flag.txt | week 10 |
| FLAG_FOOTHOLD | p-ftp-01 | /root/flag.txt | week 12 vsftpd |
| FLAG_PIVOT | c-db-01 | /root/flag.txt | week 14 pivot |
| FLAG_EXFIL | c-backup-01 | /opt/crown-jewels/FLAG.txt | week 14 exfil |

Re-runs skip already-planted flags. Containers that are down are skipped
with a warning; re-run after the lab is fully up.

**Warning for students:** `bhb_stoplab` / `make teardown` / `make clean`
destroy containers and flags. Don't tear down until the capstone is graded;
if you did, `kali-class setup-bhb` restores + re-seeds.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `make deploy` hangs | Docker daemon not fully up — wait/retry |
| Containers start then exit | `docker logs <container>` for details; rebuild with `make rebuild` |
| Port 2222 refused | privesc box didn't start — re-run setup-bhb, check `docker ps` |
| Flags not seeded | containers down when seeding ran; re-run `kali-class setup-bhb` |
| RAM pressure | close host apps; the full lab wants ~4GB free |

## Resource notes

The lab is entirely inside the student's VM — no campus network is ever
touched. All attacks stay on the VM's internal Docker networks, keeping the
course legal and self-contained.