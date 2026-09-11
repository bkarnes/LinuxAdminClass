import json
import sys
from pathlib import Path

from . import CLASS_ID as CLASS_BANNER_CLASS_ID
from . import anti_cheat, paths, ui, verifier
from .progress import Progress
from .workshop import Exercise, Workshop


def start(workshop: Workshop, progress: Progress, identity=None) -> None:
    exercises = workshop.exercises
    if not exercises:
        print(ui.warn(f"Workshop {workshop.id} has no exercises yet."))
        return

    ui.print_banner(CLASS_BANNER_CLASS_ID)

    if identity:
        anti_cheat.ensure_seed_files(
            workshop.id, identity.student_id, _seed_specs(workshop, identity)
        )

    _ensure_runaway(workshop.id)

    while True:
        current = _next_exercise(workshop, progress)
        if current is None:
            print(ui.success(f"\n 🎉 You have completed every exercise in {workshop.id}!"))
            _print_menu(workshop, progress, show_hint=True)
            cmd = _prompt_command()
            if cmd in ("r", "reset"):
                _reset(workshop, progress)
                continue
            break

        print()
        print(ui.accent(f" {workshop.id} › {current.id} — {current.title}"))
        print()
        for line in current.prompt.splitlines():
            print(f"   {line}")
        print()
        print(ui.info("   Type your commands in your own terminal, then come back here."))
        print(ui.info("   (v)erify   (h)int   (s)kip   (l)ist   (q)uit"))

        cmd = ui.safe_input("\n   > ").strip().lower()
        if cmd in ("v", "verify"):
            result = verifier.run(workshop, current)
            verifier.report(result)
            if result.ok:
                progress.mark_complete(workshop.id, current.id)
                progress.save()
                if current.on_success:
                    print(ui.success(f" {current.on_success}"))
        elif cmd in ("h", "hint"):
            used = progress.hints_used(workshop.id, current.id)
            if used >= len(current.hints):
                print(ui.warn(" No more hints for this exercise — you have seen them all."))
            else:
                progress.record_hint(workshop.id, current.id)
                progress.save()
                print(ui.info(f" Hint {used + 1}/{len(current.hints)}: {current.hints[used]}"))
        elif cmd in ("s", "skip"):
            print(ui.warn(f" Skipped {current.id}. You can come back to it anytime."))
            progress.workshop(workshop.id)["completed"].append(current.id)
            progress.save()
        elif cmd in ("l", "list"):
            _print_menu(workshop, progress)
        elif cmd in ("q", "quit", ""):
            break
        else:
            print(ui.failure(" Unrecognized choice. Use v/h/s/l/q."))


def _next_exercise(workshop: Workshop, progress: Progress) -> Exercise | None:
    done = set(progress.completed(workshop.id))
    for ex in workshop.exercises:
        if ex.id not in done:
            return ex
    return None


def _print_menu(workshop: Workshop, progress: Progress, show_hint: bool = False) -> None:
    done = set(progress.completed(workshop.id))
    print()
    print(ui.accent(f" {workshop.id} — {workshop.title} ({len(done)}/{len(workshop.exercises)} done)"))
    if workshop.summary:
        print(f"   {workshop.summary}")
    print()
    for ex in workshop.exercises:
        marker = ui.checkmark() if ex.id in done else ui.circle()
        print(f"   {marker} {ex.id}  {ex.title}")


def _reset(workshop: Workshop, progress: Progress) -> None:
    answer = ui.safe_input(ui.warn(f" Reset ALL progress for {workshop.id}? (y/N) ")).strip().lower()
    if answer == "y":
        progress.reset_workshop(workshop.id)
        progress.save()
        print(ui.info(f" Progress for {workshop.id} has been cleared."))


def _prompt_command() -> str:
    print(ui.info("\n   (r)eset progress   (Enter/q) back to main menu"))
    return ui.safe_input("   > ").strip().lower()


def _seed_specs(workshop: Workshop, identity) -> dict[str, str]:
    """Declare which per-student seed files each workshop needs."""
    specs = {
        "linux-wk04": {"backup_source.txt": "backup-source"},
        "linux-wk02": {"scavenger.txt": "scavenger"},
        "sec-wk09": {
            "md5-hashes.txt": "md5-hashes",
            "sha512-hashes.txt": "sha512-hashes",
        },
    }
    return specs.get(workshop.id, {})


def _ensure_runaway(workshop_id: str) -> None:
    """Plant the Week 6 'runaway process' drill target (idempotent).

    A harmless sleep-loop marked with a recognizable name; the student's
    exercise is to find and kill it.
    """
    if workshop_id != "linux-wk06":
        return
    import subprocess

    stamp = paths.workshop_work_dir("linux-wk06") / "runaway.pid"
    if stamp.exists():
        pid = stamp.read_text().strip()
        try:
            int(pid)
            with open(f"/proc/{pid}/comm") as fh:
                if fh.read().strip().startswith("kali-class-ru"):
                    return  # still running
        except (OSError, ValueError):
            pass  # stale; re-plant

    script = paths.work_dir() / ".runaway.sh"
    script.write_text(
        "#!/bin/bash\n"
        "exec -a kali-class-runaway sleep 86400\n"
    )
    proc = subprocess.Popen(
        ["bash", str(script)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    # The child re-execs as 'sleep' under a renamed argv; track the actual
    # sleep child so the verifier can check it's gone.
    stamp.write_text(f"{proc.pid}\n")


def load_state_safe(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except (OSError, json.JSONDecodeError):
        return {}