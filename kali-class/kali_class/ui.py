import os
import re

RESET = "\033[0m"
GREEN = "\033[1;32m"
RED = "\033[1;31m"
BLUE = "\033[1;34m"
YELLOW = "\033[1;33m"
CYAN = "\033[1;36m"

_NO_COLOR = bool(os.environ.get("NO_COLOR"))


def _c(color: str, text: str) -> str:
    if _NO_COLOR or not _supports_color():
        return text
    return f"{color}{text}{RESET}"


def _supports_color() -> bool:
    return hasattr(sys_stdout(), "isatty") and sys_stdout().isatty()


def sys_stdout():
    import sys

    return sys.stdout


def success(text: str) -> str:
    return _c(GREEN, text)


def failure(text: str) -> str:
    return _c(RED, text)


def info(text: str) -> str:
    return _c(BLUE, text)


def warn(text: str) -> str:
    return _c(YELLOW, text)


def accent(text: str) -> str:
    return _c(CYAN, text)


def checkmark() -> str:
    return success("✓")


def circle() -> str:
    return warn("○")


BANNER = r"""
 _  __       _  _    _____  _
| |/ /      | |(_)  / ____|| |
| ' /  __ _ | | _  | |     | |  __ _  ___  ___
|  <  / _` || || | | |     | | / _` |/ __|/ __|
| . \| (_| || || | | |____ | || (_| |\__ \\__ \
|_|\_\\__,_||_||_|  \_____||_| \__,_||___/|___/
"""


def print_banner(class_id: str) -> None:
    print(accent(BANNER))
    print(info(f" {class_id} — Interactive Labs"))
    print()


def safe_input(prompt: str) -> str:
    """input() that treats EOF (Ctrl+D) as 'q' so no traceback ever hits the student."""
    try:
        return input(prompt)
    except EOFError:
        return "q"


def slugify(text: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return slug