import hashlib
import hmac
import json
from datetime import datetime, timezone

from . import CLASS_ID, paths
from .workshop import list_workshops


def build_export(identity) -> tuple[str, dict]:
    """Build the signed export body and return (body_text, parsed_claims)."""
    progress = _load_progress()
    workshops = {w.id: w for w in list_workshops()}

    lines = []
    claims = {}

    lines.append(f"Student: {identity.name} ({identity.student_id})")
    lines.append(f"Class: {identity.class_id or CLASS_ID}")
    lines.append(f"VM UUID: {identity.vm_uuid}")
    lines.append(f"Exported: {datetime.now(timezone.utc).isoformat()}")
    lines.append("")

    lines.append("Workshop progress:")
    for wid, ws in sorted(progress.get("workshops", {}).items()):
        total = len(workshops[wid].exercises) if wid in workshops else 0
        done = len(ws.get("completed", []))
        hints = ws.get("hints_used", {})
        hint_total = sum(hints.values())
        lines.append(f"  {wid}: {done}/{total} (hints used: {hint_total})")
    lines.append("")

    lines.append("Per-exercise claims:")
    from .anti_cheat import exercise_token

    for wid, ws in sorted(progress.get("workshops", {}).items()):
        for exercise_id in sorted(ws.get("completed", [])):
            claim = exercise_token(identity.student_id, wid, exercise_id)
            claims[f"{wid}:{exercise_id}"] = claim
            lines.append(f"  {wid}:{exercise_id}: {claim}")

    body = "\n".join(lines)
    return body, claims


def sign(identity, body: str) -> str:
    return hmac.new(identity.hmac_key, body.encode(), hashlib.sha256).hexdigest()


def export_file(identity) -> str:
    body, _ = build_export(identity)
    signature = sign(identity, body)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d")
    out_path = paths.work_dir() / f"{identity.student_id}-progress-{stamp}.txt"
    out_path.write_text(body + f"\nSignature: {signature}\n")
    return str(out_path)


def _load_progress() -> dict:
    path = paths.progress_file()
    if not path.exists():
        return {"workshops": {}}
    try:
        data = json.loads(path.read_text())
        if "workshops" not in data:
            data = {"workshops": {}}
        return data
    except json.JSONDecodeError:
        return {"workshops": {}}


def sha256_of(text: str) -> str:
    return hashlib.sha256(text.encode()).hexdigest()