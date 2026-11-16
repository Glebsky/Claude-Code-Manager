# QUAL-02 — Eliminate URL Migration Duplication

> **Status:** Proposed  
> **Priority:** SHOULD  
> **Requirement:** NFR-M01

---

## Problem Statement

The logic "ensure the default Base URL is present in the provider's URL list" is duplicated across three functions:

- `load_settings()` — adds defaults after reading from disk
- `migrate_settings()` — adds defaults during schema migration
- `save_settings()` — adds defaults before writing to disk

This means default URL logic can diverge silently and must be maintained in three places.

---

## Solution

Extract a single helper, called only from `migrate_settings()`:

```python
# app/settings.py
from app.constants import DEFAULT_URLS_BY_PROVIDER

def _ensure_default_urls(s: dict) -> dict:
    """
    Guarantee that each provider's default Base URL
    is present as the first entry in its URL list.
    Called once during migration; not in load or save.
    """
    for provider, default_url in DEFAULT_URLS_BY_PROVIDER.items():
        key = f"{provider}_base_urls"
        urls: list = s.setdefault(key, [])
        if default_url not in urls:
            urls.insert(0, default_url)
    return s


def _migrate(s: dict) -> dict:
    s = _migrate_v1_to_v2(s)      # schema changes
    s = _ensure_default_urls(s)   # single call here
    s = migrate_plaintext_keys(s) # SEC-02 migration
    return s
```

### `app/constants.py`

```python
DEFAULT_URLS_BY_PROVIDER: dict[str, str] = {
    "freemodel":  "https://cc.freemodel.dev",
    "openai":     "https://api.freemodel.dev",
    "custom":     "",           # no default for custom
}
```

---

## Acceptance Criteria

- [ ] `grep -n "_ensure_default_urls\|insert.*default" app/settings.py` returns exactly 1 call site
- [ ] Default URL logic absent from `_read_from_disk()` and `_write_to_disk()`
- [ ] `test_settings.py::test_default_urls_added_once` passes
- [ ] `test_settings.py::test_default_urls_not_duplicated` passes (calling migrate twice doesn't duplicate)
