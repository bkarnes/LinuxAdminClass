# 12 — Assessment Rubrics

## Weekly lab grading (all 14 weeks)

Every workshop has exactly 5 exercises; each export line
`<workshop>: N/5` is the raw score basis.

### Base weekly rubric (weeks 1–7)

| Component | Weight | Source | Notes |
|-----------|--------|--------|-------|
| Exercises completed | 70% | export `N/5` line | each exercise = 14% |
| Hint economy | 10% | hints-used counts | see guidance below |
| In-lab conduct | 20% | instructor observation | participation, help-seeking, cleanup |

**Hint economy guidance (informational, not punitive):**
- 0–1 hints across the week: full 10%
- 2–4 hints: 8%
- 5+ hints: 6% (they finished — hints are legitimate learning aids)
- Never deduct below 6% for hint use alone. The number exists to surface
  pattern anomalies (e.g. 0 hints everywhere + perfect scores), not to
  punish help-seeking.

### Cybersec weekly rubric (weeks 8–13)

| Component | Weight | Source |
|-----------|--------|--------|
| Exercises completed | 50% | export |
| Attack artifacts | 30% | `~/kali-class-work/sec-wkNN/` spot-check |
| Notes / write-up | 20% | findings file quality |

Artifacts are spot-checked in lab (nmap XML present and plausible, capture
files real, etc.) — the export proves completion, artifacts prove work.

### Capstone rubric (week 14)

| Component | Weight | Source |
|-----------|--------|--------|
| Flags captured (5 × 10%) | 50% | export flag claims (HMAC-verified) |
| Pentest report | 40% | report built on `Machine_Template.md` |
| Methodology notes | 10% | report's kill-chain narrative section |

**Capstone report rubric (40 points possible):**
| Aspect | Points | What good looks like |
|--------|--------|---------------------|
| Recon narrative | 8 | scan methodology, findings per machine |
| Exploitation narrative | 8 | foothold + privesc path, commands justified |
| Lateral movement | 8 | pivot path 172.16.10.x → 10.1.0.x explained |
| Findings & exfil | 8 | crown-jewels located, impact stated |
| Remediation advice | 8 | specific fixes, prioritized |

## Grading scale mapping (suggested)

| Export line | LMS score |
|-------------|-----------|
| 5/5 | 100% |
| 4/5 | 85% |
| 3/5 | 70% |
| 2/5 | 55% |
| 1/5 | 40% |
| 0/5 | 0% (or late penalty per syllabus) |

Adjust to your institutional scale; the exporter reports `N/5` and hint
counts only.

## Late / makeup policy hooks

- Exports are dated (`-YYYYMMDD`); grade the latest, apply your late policy.
- `kali-class reset <workshop>` lets a student redo a week cleanly —
  use it for makeups rather than partial credit debates.
- SUSPECT exports: run the 3-step review (`INSTRUCTOR_GUIDE.md` §3.6)
  before penalizing.

## Integrity penalty guidance

| Finding | Suggested action |
|---------|------------------|
| vm_uuid mismatch, explained (VM rebuild) | re-roster, grade normally |
| Claims mismatch student_id | zero for that submission + academic-integrity process |
| Signature mismatch with no explanation | redo live in class; grade on fresh export |

Penalty philosophy: the labs are short and hints are free — the honest path
is faster than cheating. Grade leniently on process, strictly on forgery.