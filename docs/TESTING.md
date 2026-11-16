# Test Strategy

> **Last Updated:** 2026-11-15

---

## 1. Scope

This document defines how correctness is verified for Claude Code Manager.
Since the app is a Windows-only desktop GUI with no backend server, testing focuses on:
- Unit tests for pure logic (settings, i18n, security, backup)
- Integration tests for file I/O and subprocess calls
- Manual smoke tests for UI flows

---

## 2. Test Layers

### 2.1 Unit Tests (`tests/unit/`)

Run with `pytest tests/unit/` — no network, no disk I/O, no Qt.

| File                          | Covers                                      |
|-------------------------------|---------------------------------------------|
| `test_settings.py`            | load/save/migrate, thread safety            |
| `test_security.py`            | ssl context factory, ID generation          |
| `test_i18n.py`                | tr() lookup, fallback, missing key warning  |
| `test_backup.py`              | rotation: max 5 baks, oldest deleted first  |
| `test_updater.py`             | version comparison (semver)                 |
| `test_launch.py`              | permission mode flag/settings composition   |

### 2.2 Integration Tests (`tests/integration/`)

Run with `pytest tests/integration/` — real temp files, mocked network.

| File                          | Covers                                      |
|-------------------------------|---------------------------------------------|
| `test_settings_io.py`         | round-trip JSON read/write, corrupt file    |
| `test_keyring.py`             | save/load/delete via keyring (mocked)       |
| `test_cli_runner.py`          | subprocess args built for npm/winget        |
| `test_permission_mode.py`     | settings.json written correctly per mode   |

### 2.3 Manual Smoke Tests

Run before each release on a clean Windows 10/11 VM.

| ID     | Scenario                                                   | Expected |
|--------|------------------------------------------------------------|----------|
| SM-01  | First launch: app starts, shows provider tabs              | Pass     |
| SM-02  | Add API key: saved to keyring, not in settings.json        | Pass     |
| SM-03  | Switch provider: env vars written to claude/settings.json  | Pass     |
| SM-04  | Launch Claude Code: terminal opens with correct env        | Pass     |
| SM-05  | Launch with bypassPermissions: no auto-mode prompts        | Pass     |
| SM-06  | Fix Claude: .claude.json backed up, fresh one created      | Pass     |
| SM-07  | Update check: banner shown when new version available      | Pass     |
| SM-08  | Language switch RU/EN/UA: all visible strings change       | Pass     |
| SM-09  | Build: EXE runs on machine without Python                  | Pass     |

---

## 3. Acceptance Criteria Checklist (pre-release)

```
[ ] pytest tests/unit/      -- 0 failures
[ ] pytest tests/integration/ -- 0 failures
[ ] ruff check app/ --select F401,E  -- 0 warnings
[ ] grep -rn "except:" app/ -- 0 results
[ ] grep -rn "CERT_NONE" app/ -- 0 results (or only in custom-url path)
[ ] grep -n "APP_VERSION" app/constants.py -- matches latest git tag
[ ] All SM-01 through SM-09 manual tests pass
[ ] EXE size < 150 MB
[ ] Startup time < 3s on clean Windows 10
```

---

## 4. Test Fixtures

```python
# tests/conftest.py
import pytest, tempfile, pathlib

@pytest.fixture
def tmp_appdata(monkeypatch, tmp_path):
    """Redirect APPDATA to a temp directory for settings tests."""
    monkeypatch.setenv("APPDATA", str(tmp_path))
    return tmp_path

@pytest.fixture
def tmp_userprofile(monkeypatch, tmp_path):
    """Redirect USERPROFILE/HOME for Claude config tests."""
    monkeypatch.setenv("USERPROFILE", str(tmp_path))
    monkeypatch.setenv("HOME", str(tmp_path))
    return tmp_path
```

---

## 5. CI (Future)

If GitHub Actions is added:

```yaml
jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.12' }
      - run: pip install pytest ruff PySide6 keyring
      - run: pytest tests/unit/ tests/integration/ -v
      - run: ruff check app/ --select F401,E
```
