# QUAL-01 — Exception Handling Standard

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** NFR-M02

---

## Problem Statement

The codebase uses bare `except:` clauses extensively:

```python
try:
    do_something()
except:
    pass
```

This silently swallows `KeyboardInterrupt`, `SystemExit`, `MemoryError`, and all other exceptions, making bugs invisible and debugging impossible.

---

## Standard

### Rule 1 — Never use bare `except:`

```python
# BAD
try:
    result = json.loads(text)
except:
    result = {}

# GOOD
try:
    result = json.loads(text)
except (json.JSONDecodeError, ValueError) as e:
    logger.warning("Failed to parse JSON: %s", e)
    result = {}
```

### Rule 2 — Use specific exception types when possible

Prefer the narrowest applicable exception type:

| Situation                  | Exception type(s) to catch          |
|----------------------------|-------------------------------------|
| JSON parsing               | `json.JSONDecodeError`              |
| File I/O                   | `OSError`                           |
| Network requests           | `urllib.error.URLError`, `socket.timeout` |
| Subprocess                 | `subprocess.SubprocessError`        |
| Registry access            | `OSError`, `PermissionError`        |
| General fallback (last resort) | `Exception`                     |

### Rule 3 — Log, don't silently swallow

```python
# ACCEPTABLE (with log)
try:
    do_optional_thing()
except Exception as e:
    logger.warning("optional thing failed (non-critical): %s", e)

# NEVER acceptable
try:
    do_thing()
except Exception:
    pass  # NO: silent swallow
```

### Rule 4 — Add app-wide logger

```python
# app/constants.py or app/__init__.py
import logging
from pathlib import Path

LOG_PATH = Path(os.environ.get("APPDATA", "~")) / "ClaudeManager" / "app.log"

logging.basicConfig(
    filename=LOG_PATH,
    level=logging.WARNING,
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    encoding="utf-8",
)
```

Each module gets its own logger:

```python
# app/settings.py
import logging
logger = logging.getLogger(__name__)  # "app.settings"
```

---

## Migration

1. Find all bare excepts: `grep -n "except:" claude_code_manager.pyw`
2. For each occurrence: determine what can actually be raised, replace with specific type
3. Add `logger.warning(...)` or `logger.debug(...)` as appropriate
4. If the except was guarding truly optional code, use `logger.debug`

---

## Acceptance Criteria

- [ ] `grep -rn "^\s*except:" app/` returns 0 results
- [ ] `grep -rn "except Exception:$" app/` returns 0 results (must have `as e:`)
- [ ] `app.log` file created on startup in APPDATA
- [ ] A forced JSON parse failure writes a WARNING line to app.log
