import subprocess
from pathlib import Path

from . import ui
from .workshop import Exercise, Workshop


class VerifyResult:
    def __init__(self, ok: bool, message: str = ""):
        self.ok = ok
        self.message = message


def run(workshop: Workshop, exercise: Exercise) -> VerifyResult:
    script_path = exercise.verify_path(workshop.dir)
    if script_path is None or not Path(script_path).exists():
        return VerifyResult(False, "No verifier script found for this exercise.")

    try:
        proc = subprocess.run(
            ["bash", str(script_path)],
            capture_output=True,
            text=True,
            timeout=exercise.verify_timeout,
        )
    except subprocess.TimeoutExpired:
        return VerifyResult(False, "The verifier timed out. Is a command hanging?")

    if proc.returncode == 0:
        return VerifyResult(True, proc.stdout.strip())

    detail = proc.stderr.strip() or proc.stdout.strip()
    if detail:
        return VerifyResult(False, f"Verifier says: {detail}")
    return VerifyResult(False, "Not quite — try again, or ask for a hint.")


def report(result: VerifyResult) -> None:
    if result.ok:
        print(ui.success(" ✓ Correct! Nice work."))
        if result.message:
            print(f"   {result.message}")
    else:
        print(ui.failure(" ✗ Not yet."))
        if result.message:
            print(f"   {result.message}")
        print(ui.info("   Run 'hint' if you're stuck, then try again and run 'verify'."))