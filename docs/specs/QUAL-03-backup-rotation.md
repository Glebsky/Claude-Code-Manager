# QUAL-03 — Backup File Rotation

> **Status:** Proposed  
> **Priority:** SHOULD  
> **Requirement:** NFR-R03

---

## Problem Statement

`_next_settings_backup_path()` accumulates `.bak`, `.bak2`, `.bak3`, ... files indefinitely. After many app restarts on a machine with repeated setting saves, the AppData directory fills with stale backups.

---

## Solution

Module `app/backup.py` manages rotation with a configurable cap:

```python
# app/backup.py
import pathlib
import logging

logger = logging.getLogger(__name__)
MAX_BACKUPS: int = 5


def rotate_backups(target: pathlib.Path) -> None:
    """
    Before overwriting `target`, create a timestamped backup.
    If more than MAX_BACKUPS backups exist, delete the oldest.

    Naming: settings.json.bak1  (oldest) ... settings.json.bak5 (newest)
    Strategy: shift-rotate (bak4->bak5, bak3->bak4, ..., current->bak1)
    """
    if not target.exists():
        return

    parent = target.parent
    stem   = target.name

    # Collect existing backups sorted oldest-first
    baks = sorted(
        parent.glob(f"{stem}.bak*"),
        key=lambda p: p.stat().st_mtime
    )

    # Drop oldest if at cap
    while len(baks) >= MAX_BACKUPS:
        oldest = baks.pop(0)
        try:
            oldest.unlink()
            logger.debug("Deleted old backup: %s", oldest)
        except OSError as e:
            logger.warning("Could not delete backup %s: %s", oldest, e)

    # Rotate: current file becomes bak1 (or next available number)
    idx = len(baks) + 1
    dest = parent / f"{stem}.bak{idx}"
    try:
        target.rename(dest)
        logger.debug("Backup created: %s", dest)
    except OSError as e:
        logger.warning("Could not create backup %s: %s", dest, e)
```

### Integration with settings

```python
# app/settings.py
from app.backup import rotate_backups

def _write_to_disk(s: dict) -> None:
    rotate_backups(SETTINGS_PATH)       # keep old version as .bakN
    tmp = SETTINGS_PATH.with_suffix(".tmp")
    tmp.write_text(json.dumps(s, indent=2, ensure_ascii=False), encoding="utf-8")
    tmp.replace(SETTINGS_PATH)         # atomic rename
```

### Same rotation for `.claude.json` backups in Fix Claude

Reuse `rotate_backups(claude_json_path)` before overwriting `~/.claude.json`.

---

## Acceptance Criteria

- [ ] After 10 consecutive saves: `glob("settings.json.bak*")` returns exactly 5 files
- [ ] Oldest bak is deleted when cap reached
- [ ] `test_backup.py::test_rotation_cap` passes
- [ ] `test_backup.py::test_no_error_on_missing_target` passes
- [ ] Backups are human-readable JSON (not binary)
