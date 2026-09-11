import argparse
import sys

from . import CLASS_ID, __version__, paths, ui
from . import export as export_mod
from . import identity as identity_mod
from . import stamps as stamps_mod
from .progress import Progress
from .runner import start as run_workshop
from .workshop import list_workshops, load_workshop


def main() -> int:
    VERBS = ("whoami", "progress", "export", "re-register", "setup-bhb", "setup-incidents", "stamp", "check-stamp")
    parser = argparse.ArgumentParser(
        prog="kali-class",
        description=f"{CLASS_ID} — NodeSchool-style interactive labs",
    )
    parser.add_argument("--version", action="version", version=f"%(prog)s {__version__}")
    parser.add_argument("workshop", nargs="?", help="Workshop id, e.g. linux-wk01")
    parser.add_argument("stampargs", nargs="*", help=argparse.SUPPRESS)
    parser.add_argument("--list", action="store_true", help="List all workshops and exit")

    args, extra = parser.parse_known_args()

    # Allow both `kali-class linux-wk01` and `kali-class whoami` forms:
    # verbs are detected manually so they can't collide with workshop ids.
    if args.workshop in VERBS:
        command = args.workshop
        args.workshop = None
    elif extra and extra[0] in VERBS:
        command = extra[0]
        extra = extra[1:]
    else:
        command = None
    setattr(args, "command", command)

    paths.ensure_dirs()

    if args.command == "re-register":
        identity = identity_mod.re_register()
        print(ui.success(" Re-registered successfully."))
        _print_identity(identity)
        return 0

    identity = identity_mod.ensure_registered()

    if args.command == "whoami":
        return cmd_whoami(identity)

    if args.list:
        _print_all_workshops(Progress.load())
        return 0

    if args.command == "progress":
        _print_all_workshops(Progress.load())
        return 0

    if args.command == "export":
        out = export_mod.export_file(identity)
        print(ui.success(f" Export written to: {out}"))
        print(ui.info(" Submit this file to your instructor."))
        return 0

    if args.command == "stamp":
        # kali-class stamp <workshop> <label>
        sargs = args.stampargs or extra
        if not sargs:
            print(ui.failure(" Usage: kali-class stamp <workshop> <label>"))
            return 1
        wid = sargs[0]
        label = sargs[1] if len(sargs) > 1 else "artifact"
        entry = stamps_mod.stamp(wid, label)
        print(ui.success(f" Stamped: {wid} / {label} as {entry['student_id']}"))
        return 0

    if args.command == "check-stamp":
        sargs = args.stampargs or extra
        if not sargs or len(sargs) < 2:
            print(ui.failure(" Usage: kali-class check-stamp <workshop> <label>"))
            return 1
        ok, msg = stamps_mod.check_stamp(sargs[0], sargs[1])
        if ok:
            print(msg)
            return 0
        print(ui.failure(f" {msg}"))
        return 1

    if args.command == "setup-bhb":
        return cmd_setup_bhb(identity)

    if args.command == "setup-incidents":
        return cmd_setup_incidents(identity)

    if args.workshop:
        try:
            workshop = load_workshop(args.workshop)
        except FileNotFoundError as exc:
            print(ui.failure(f" {exc}"))
            return 1
        run_workshop(workshop, Progress.load(), identity)
        return 0

    return main_menu(identity)


def main_menu(identity) -> int:
    ui.print_banner(CLASS_ID)
    print(f" Welcome back, {identity.name.split()[0]}. Here's where you stand:")
    progress = Progress.load()
    _print_all_workshops(progress, quiet_banner=True)

    print(ui.info("\n   Pick a workshop by number, or (q)uit:"))
    choice = input("   > ").strip().lower()
    if choice in ("q", "quit", ""):
        print(" Have a nice day.")
        return 0

    workshops = list_workshops()
    try:
        idx = int(choice) - 1
        workshop = workshops[idx]
    except (ValueError, IndexError):
        print(ui.failure(" Unrecognized choice."))
        return 1

    run_workshop(workshop, progress, identity)
    return 0


def cmd_setup_bhb(identity) -> int:
    """Deploy the Black-Hat-Bash target lab (wraps targets/blackhat-bash/deploy.sh)."""
    import subprocess

    deploy = paths.workshops_root().parent / "targets" / "blackhat-bash" / "deploy.sh"
    if not deploy.exists():
        print(ui.failure(f" deploy script not found at {deploy}"))
        return 1
    print(ui.info(" Deploying the Black-Hat-Bash target lab (8 docker machines)..."))
    proc = subprocess.run(["bash", str(deploy)])
    if proc.returncode != 0:
        print(ui.failure(" BHB deploy reported problems — read the output above."))
        return proc.returncode
    print(ui.success(" BHB lab is up. Targets:"))
    print("   public  172.16.10.10-13  (p-web-01, p-ftp-01, p-web-02, p-jumpbox-01)")
    print("   private 10.1.0.11-16     (c-backup-01, c-redis-01, c-db-01, c-db-02)")
    print(ui.info(" Start exercises with: kali-class sec-wk08"))
    return 0


def cmd_setup_incidents(identity) -> int:
    """Build the 4 incident-response containers for sec-wk13."""
    import subprocess

    inc_dir = paths.workshops_root().parent / "incidents"
    if not inc_dir.is_dir():
        print(ui.failure(f" incidents directory not found: {inc_dir}"))
        return 1
    if not paths.instructor_dir().exists():
        pass  # not needed here

    images = {
        "authfail": "linux-ir-authfail:1.0",
        "filetamper": "linux-ir-filetamper:1.0",
        "malwarelite": "linux-ir-malwarelite:1.0",
        "timeline": "linux-ir-timeline:1.0",
    }

    for name, image in images.items():
        dockerfile = inc_dir / name / "Dockerfile"
        if not dockerfile.exists():
            print(ui.failure(f" missing {dockerfile}"))
            return 1
        print(ui.info(f" Building {image} ..."))
        proc = subprocess.run(
            ["docker", "build", "-t", image, str(dockerfile.parent)],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            print(ui.failure(f" build failed for {image}:"))
            print(proc.stderr[-500:] or proc.stdout[-500:])
            return 1
        print(ui.success(f" built {image}"))

    print()
    print(ui.success(" All 4 incident images built. Launch commands:"))
    print("   docker run -d --name linux-ir-authfail   linux-ir-authfail:1.0")
    print("   docker run -d --name linux-ir-filetamper linux-ir-filetamper:1.0")
    print("   docker run -d --name linux-ir-malwarelite linux-ir-malwarelite:1.0")
    print("   docker run -d --name linux-ir-timeline   linux-ir-timeline:1.0")
    print(ui.info(" The sec-wk13 exercises walk you through each one."))
    return 0


def cmd_whoami(identity) -> int:
    _print_identity(identity)
    out = identity_mod.whoami_json(identity)
    print(ui.success(f"\n Registration file written to: {out}"))
    print(ui.info(" Upload this file to the LMS as 'Assignment 0: Registration'."))
    return 0


def _print_identity(identity) -> None:
    print()
    print(f" Name:       {identity.name}")
    print(f" Student ID: {identity.student_id}")
    print(f" Class:      {identity.class_id}")
    print(f" VM UUID:    {identity.vm_uuid}")
    print(f" First run:  {identity.first_run}")


def _print_all_workshops(progress: Progress, quiet_banner: bool = False) -> None:
    workshops = list_workshops()
    if not quiet_banner:
        ui.print_banner(CLASS_ID)
    if not workshops:
        print(ui.warn(" No workshops are installed."))
        return
    print()
    for i, w in enumerate(workshops, start=1):
        done = len(progress.completed(w.id))
        total = len(w.exercises)
        if total and done == total:
            status = ui.success(f"✓ complete")
        else:
            status = f"{done}/{total}"
        print(f" {i:2}) {w.id:<12} {w.title:<28} {status}")
    print()


if __name__ == "__main__":
    sys.exit(main())