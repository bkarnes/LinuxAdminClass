import json
import os
from datetime import datetime, timezone
from pathlib import Path

from . import paths


DEFAULT_DATA = {"workshops": {}, "last_updated": ""}


class Progress:
    def __init__(self, data: dict | None = None):
        self.data = data or json.loads(json.dumps(DEFAULT_DATA))

    def workshop(self, workshop_id: str) -> dict:
        return self.data["workshops"].setdefault(workshop_id, {"completed": [], "hints_used": {}})

    def mark_complete(self, workshop_id: str, exercise_id: str) -> bool:
        ws = self.workshop(workshop_id)
        if exercise_id in ws["completed"]:
            return False
        ws["completed"].append(exercise_id)
        self.touch()
        return True

    def is_complete(self, workshop_id: str, exercise_id: str) -> bool:
        return exercise_id in self.workshop(workshop_id)["completed"]

    def record_hint(self, workshop_id: str, exercise_id: str) -> int:
        ws = self.workshop(workshop_id)
        count = ws["hints_used"].get(exercise_id, 0) + 1
        ws["hints_used"][exercise_id] = count
        self.touch()
        return count

    def hints_used(self, workshop_id: str, exercise_id: str) -> int:
        return self.workshop(workshop_id)["hints_used"].get(exercise_id, 0)

    def completed(self, workshop_id: str) -> list[str]:
        return self.workshop(workshop_id)["completed"]

    def reset_workshop(self, workshop_id: str) -> None:
        self.data["workshops"][workshop_id] = {"completed": [], "hints_used": {}}
        self.touch()

    def all_completed(self) -> dict[str, list[str]]:
        return {wid: ws["completed"] for wid, ws in self.data["workshops"].items()}

    def touch(self) -> None:
        self.data["last_updated"] = datetime.now(timezone.utc).isoformat()

    def save(self) -> None:
        paths.ensure_dirs()
        path = paths.progress_file()
        path.write_text(json.dumps(self.data, indent=2) + "\n")
        os.chmod(path, 0o600)

    @staticmethod
    def load() -> "Progress":
        path = paths.progress_file()
        if not path.exists():
            return Progress()
        try:
            data = json.loads(path.read_text())
            if "workshops" not in data:
                data = json.loads(json.dumps(DEFAULT_DATA))
            return Progress(data)
        except json.JSONDecodeError:
            return Progress()