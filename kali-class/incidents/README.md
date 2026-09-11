# Incident Response Containers

Four self-contained Docker images for the Week 13 incident-response labs
(sec-wk13). Students launch each container, investigate with terminal
tools, fix the planted state where instructed, and document findings.

These are the original incident snapshots from the course build
(`Build_Docs_Linux_Terminal_Class` Part I), ported here so everything ships
in one repo. Safe: no real malware, deterministic, resettable.

## Deploy

```bash
kali-class setup-incidents
```

That builds all 4 images and prints the exact `docker run` command for the
week's exercise. The sec-wk13 exercises drive the launches; nothing runs
in the background between exercises.

| Container | Image | Scenario | Skills |
|-----------|-------|----------|--------|
| linux-ir-authfail | `linux-ir-authfail:1.0` | SSH brute-force in the logs | grep, wc, log triage |
| linux-ir-filetamper | `linux-ir-filetamper:1.0` | tampered file, wrong perms | stat, chmod, chown |
| linux-ir-malwarelite | `linux-ir-malwarelite:1.0` | CPU-burning hidden script | ps, top, kill |
| linux-ir-timeline | `linux-ir-timeline:1.0` | multi-event reconstruction | timestamps, ordering |

## Notes

- Rebuild any time: `setup-incidents` re-runs cleanly (docker build is
  cached).
- Containers are disposable — `docker rm -f <name>` removes state; re-run
  restores the incident exactly.
- Findings files for each exercise go to
  `~/kali-class-work/sec-wk13/` (stamped per-exercise).