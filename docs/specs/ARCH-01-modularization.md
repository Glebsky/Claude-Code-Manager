# ARCH-01 — Modularization of Monolithic Source File

> **Status:** Proposed  
> **Priority:** SHOULD  
> **Requirement:** NFR-M01  
> **ADR:** [ADR-002](../adr/ADR-002-module-split.md)

---

## Problem Statement

The entire application lives in one file: `claude_code_manager.pyw` (~2.6 MB, ~60 000 lines). This makes it:
- Impossible to unit test individual components
- Difficult to review changes in PRs (no meaningful diffs)
- Prone to global state bugs
- Slow to load in IDEs

---

## Target Module Structure

See [ARCHITECTURE.md](../ARCHITECTURE.md) Section 2.1 for the full module map.

## Refactoring Order

Each step must leave the app fully functional before moving to the next.

### Step 1 — Extract `constants.py`

**What moves:** `APP_VERSION`, `APP_NAME`, `APPDATA_DIR`, `DEFAULT_BASE_URLS`, `GITHUB_API_URL`, `DEFAULT_URLS_BY_PROVIDER`.

**Rule:** `constants.py` MUST have zero imports from the rest of the app.

**Verification:** `python -c "from app.constants import APP_VERSION; print(APP_VERSION)"` works.

### Step 2 — Extract `i18n.py`

**What moves:** `TRANSLATIONS_EN`, `TRANSLATIONS_UA`, `tr()`, `get_current_lang()`, `set_lang()`.

**Depends on:** `constants.py` only.

**Verification:** `python -c "from app.i18n import tr; print(tr('btn.get_models'))"` works.

### Step 3 — Extract `security.py`

**What moves:** SSL context factory functions, `new_key_id()`, `save_api_key()`, `load_api_key()`, `delete_api_key()`.

**Depends on:** `constants.py` only.

**Verification:** `python -c "from app.security import make_verified_ssl_context"` works.

### Step 4 — Extract `backup.py`

**What moves:** `_next_settings_backup_path()`, `_rotate_backups()`, backup-related helpers.

**Depends on:** `constants.py` only.

### Step 5 — Extract `settings.py`

**What moves:** `load_settings()`, `save_settings()`, `migrate_settings()`, `_ensure_default_urls()`, `_settings_lock`.

**Depends on:** `constants.py`, `security.py` (for key migration), `backup.py`.

**Verification:** App launches and settings persist across restarts.

### Step 6 — Extract `cli/base.py` and `cli/claude.py`

**What moves:** subprocess helpers, npm/winget wrappers, permission mode functions, PATH manipulation.

**Depends on:** `settings.py`, `constants.py`, `security.py`.

### Step 7 — Extract `updater.py`

**What moves:** GitHub release check, EXE download and self-replace logic.

**Depends on:** `constants.py`, `security.py`.

### Step 8 — Progressively split UI

Move dialogs one at a time: `dlg_fix_claude.py`, `dlg_status_line.py`, `dlg_install.py`, `dlg_permission_mode.py`.

Then tabs. Then widgets.

---

## Rules

- Each module MUST NOT exceed 500 lines
- No circular imports (see dependency graph in ARCHITECTURE.md)
- No `from app.ui import ...` from business logic modules
- Each extracted module gets its own test file in `tests/unit/`

---

## Acceptance Criteria

- [ ] `app/constants.py` exists, imports cleanly, 0 app deps
- [ ] `app/settings.py` exists, all settings functions moved
- [ ] `app/security.py` exists, all key/ssl functions moved
- [ ] `app/cli/claude.py` exists with permission mode functions
- [ ] No module exceeds 500 lines (`wc -l app/**/*.py | sort -n`)
- [ ] `pytest tests/unit/` passes after each step
- [ ] App still builds to working EXE
