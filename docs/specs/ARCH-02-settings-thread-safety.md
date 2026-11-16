# ARCH-02 — Thread-Safe Settings Access

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** NFR-R01

---

## Problem Statement

Background threads (model catalog fetch, update check, CLI runner) may read and write the global settings dict concurrently with the main UI thread. Without synchronisation, this can cause:
- Torn reads (partial JSON written to disk)
- Lost updates (two threads overwrite each other)
- Crashes from dict changing size during iteration

---

## Solution

Protect all access to the settings dict with a single `threading.RLock`.

RLock (re-entrant lock) is used instead of Lock because `save_settings` may call `migrate_settings` which calls `load_settings` from the same thread.

```python
# app/settings.py
import threading, json, pathlib, logging
from app.constants import SETTINGS_PATH
from app.backup import rotate_backups

logger = logging.getLogger(__name__)
_lock = threading.RLock()
_cache: dict | None = None   # in-memory cache

def load_settings() -> dict:
    global _cache
    with _lock:
        if _cache is not None:
            return _cache
        _cache = _read_from_disk()
        _cache = _migrate(_cache)
        return _cache

def save_settings(s: dict) -> None:
    with _lock:
        global _cache
        _cache = s
        _write_to_disk(s)

def get_setting(key: str, default=None):
    with _lock:
        return load_settings().get(key, default)

def set_setting(key: str, value) -> None:
    with _lock:
        s = load_settings()
        s[key] = value
        save_settings(s)

def _read_from_disk() -> dict:
    if not SETTINGS_PATH.exists():
        return {}
    try:
        return json.loads(SETTINGS_PATH.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        logger.warning("Settings file unreadable (%s), using empty dict", e)
        rotate_backups(SETTINGS_PATH)  # keep corrupt file as bak
        return {}

def _write_to_disk(s: dict) -> None:
    SETTINGS_PATH.parent.mkdir(parents=True, exist_ok=True)
    rotate_backups(SETTINGS_PATH)
    tmp = SETTINGS_PATH.with_suffix(".tmp")
    tmp.write_text(json.dumps(s, indent=2, ensure_ascii=False), encoding="utf-8")
    tmp.replace(SETTINGS_PATH)   # atomic on Windows NTFS
```

### Atomic write

Write to `.tmp` first, then `replace()` — this ensures no other process reads a half-written file.

---

## Rules

- ALL access to settings MUST go through `get_setting` / `set_setting` / `load_settings` / `save_settings`
- NO direct dict access to `_cache` from outside `settings.py`
- Background threads MUST NOT hold `_lock` for more than 200 ms (no blocking I/O inside lock except the controlled `_write_to_disk`)

---

## Acceptance Criteria

- [ ] `test_settings.py::test_concurrent_write` passes (10 threads writing simultaneously, no corruption)
- [ ] `test_settings.py::test_atomic_write` verifies `.tmp` -> replace pattern
- [ ] `grep -rn "_cache\[" app/` returns 0 results outside `settings.py`
- [ ] NFR-P02: settings save completes < 200 ms
