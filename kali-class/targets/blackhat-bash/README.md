# Black-Hat-Bash Lab Integration

The cybersec workshops (weeks 8–14) attack the Black-Hat-Bash book's Docker
lab: 8 machines across two networks, deployed inside the student's own Kali
VM.

## Network map

```
Kali VM (attacker)
 │
 ├── docker network: 172.16.10.0/24  (public / "internet-facing")
 │    p-web-01      172.16.10.10   web server (nginx/apache)
 │    p-ftp-01      172.16.10.11   ftp (vsftpd)
 │    p-web-02      172.16.10.12   web (10.1.0.11 private side)  ← pivot target
 │    p-jumpbox-01  172.16.10.13   jumpbox (10.1.0.12 private side)
 │
 └── (private net, only via pivot) 10.1.0.0/24
      c-backup-01  10.1.0.13
      c-redis-01   10.1.0.14
      c-db-01      10.1.0.15
      c-db-02      10.1.0.16
```

## Deployment

Students run **`kali-class setup-bhb`** once before Week 8 (and again
whenever they've torn the lab down). The command:

1. Clones `dolevf/Black-Hat-Bash` to `~/Projects/Black-Hat-Bash` (if missing)
2. Ensures the Docker daemon is running
3. `sudo make deploy` in the `lab/` directory (8 containers)
4. Seeds capstone flags (`seed-flags.sh` — idempotent)
5. Verifies at least 6 of 8 containers are up

`deploy.sh` is the single wrapper; it never modifies upstream files.

## Aliases available to students (setup_vm.sh option 6 already adds these)

| Alias | Effect |
|-------|--------|
| `bhb_startlab` | `docker compose up --detach` |
| `bhb_stoplab` | `docker compose down --volumes` |
| `bhb_labs` | cd to the lab dir |

`bhb_stoplab` destroys containers (flags with them). The capstone warning:
don't tear down until graded — `kali-class setup-bhb` re-seeds.

## Which weeks hit which machines

| Week | Workshop | Primary targets |
|------|----------|-----------------|
| 8 | Recon & Web App | all of 172.16.10.0/24; p-web-01, p-web-02 |
| 9 | Password Attacks | offline hash files (per-student) + p-ftp-01, p-jumpbox-01 |
| 10 | Privilege Escalation | kali-class-privesc container (dedicated privesc box) |
| 11 | Network Attacks / MITM | p-ftp-01 ↔ p-web-01 traffic (ARP) |
| 12 | Metasploit | p-ftp-01 (vsftpd backdoor), p-web-01 |
| 13 | Blue Team / IR | local incident containers (see `incidents/`) |
| 14 | Capstone | full kill chain; flags on 5 machines |

## Notes & caveats

- The lab was tested upstream on Kali 2023.4; current Kali rolling works the
  same way (Docker + docker compose).
- Burp Suite (`burpsuite`) is preinstalled on Kali; `rustscan` is aliased to
  a Docker wrapper by setup_vm.sh option 6.
- The `10.1.0.0/24` network is not directly reachable from the Kali VM —
  that's intentional (pivoting exercises, weeks 11–12).
- Resource note for students: the full lab wants ~4GB RAM free. Close
  unnecessary apps on the host.

## Upstream acknowledgment

Black-Hat-Bash is by Dolev Farhi & Adel "0xkharon" Khalla — MIT-licensed
lab files. We deploy it unmodified and reference it as the target
infrastructure. Students should consider buying the book — the workshops
pair naturally with chapters 4–8.