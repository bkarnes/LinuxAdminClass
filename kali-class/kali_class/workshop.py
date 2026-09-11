"""Workshop and exercise model + YAML loading.

Exercises live at workshops/<workshop-id>/exercises/NN-<slug>.yaml with a
sibling NN-<slug>.verify.sh script. meta.yaml describes the workshop.
"""

from dataclasses import dataclass, field
from pathlib import Path

import yaml

from . import paths


@dataclass
class Exercise:
    id: str
    title: str
    prompt: str
    hints: list[str] = field(default_factory=list)
    verify_script: Path | None = None
    on_success: str = ""
    verify_timeout: int = 30

    def verify_path(self, workshop_dir: Path) -> Path | None:
        if self.verify_script:
            return workshop_dir / "exercises" / self.verify_script
        return None


@dataclass
class Workshop:
    id: str
    title: str
    summary: str
    week: int
    phase: str
    deps: list[str] = field(default_factory=list)
    exercises: list[Exercise] = field(default_factory=list)

    @property
    def dir(self) -> Path:
        return paths.workshops_root() / self.id

    def by_id(self, exercise_id: str) -> Exercise | None:
        for ex in self.exercises:
            if ex.id == exercise_id:
                return ex
        return None


def list_workshops() -> list[Workshop]:
    root = paths.workshops_root()
    found: list[Workshop] = []
    if not root.is_dir():
        return found
    for child in sorted(root.iterdir()):
        if child.is_dir() and (child / "meta.yaml").exists():
            found.append(load_workshop(child.name))
    found.sort(key=lambda w: w.week)
    return found


def load_workshop(workshop_id: str) -> Workshop:
    directory = paths.workshops_root() / workshop_id
    meta_path = directory / "meta.yaml"
    if not meta_path.exists():
        raise FileNotFoundError(f"Unknown workshop '{workshop_id}' (no meta.yaml)")

    meta = yaml.safe_load(meta_path.read_text()) or {}
    exercises = _load_exercises(directory)

    return Workshop(
        id=workshop_id,
        title=meta.get("title", workshop_id),
        summary=meta.get("summary", ""),
        week=int(meta.get("week", 0)),
        phase=meta.get("phase", "unknown"),
        deps=list(meta.get("deps", [])),
        exercises=exercises,
    )


def _load_exercises(directory: Path) -> list[Exercise]:
    ex_dir = directory / "exercises"
    if not ex_dir.is_dir():
        return []
    exercises: list[Exercise] = []
    for yaml_path in sorted(ex_dir.glob("*.yaml")):
        data = yaml.safe_load(yaml_path.read_text()) or {}
        verify = data.get("verify", {})
        exercises.append(
            Exercise(
                id=str(data.get("id", yaml_path.stem)),
                title=data.get("title", yaml_path.stem),
                prompt=data.get("prompt", "").strip(),
                hints=list(data.get("hints", [])),
                verify_script=verify.get("script"),
                verify_timeout=int(verify.get("timeout", 30)),
                on_success=data.get("on_success", ""),
            )
        )
    exercises.sort(key=lambda e: e.id)
    return exercises