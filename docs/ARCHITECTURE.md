# Architecture Specification

> **Status:** Current State + Target State  
> **Last Updated:** 2026-11-15

---

## 1. Current State (As-Is)

The entire application is a single monolithic file `claude_code_manager.pyw` (~2.6 MB, ~60 000 lines). All concerns — UI, business logic, settings, CLI management, networking, i18n — are co-located.

**Known issues with current architecture:**
- No unit testability (everything tightly coupled)
- Race conditions in settings (no thread locks)
- SSL verification disabled globally (MITM risk)
- API keys stored in plaintext on disk
- Two diverging version constants

---

## 2. Target State (To-Be)

### 2.1 Module Map

```
claude_code_manager/
├── main.pyw                    # Entry: QApplication, MainWindow
└── app/
    ├── constants.py            # APP_VERSION, URLs, paths — zero side-effects
    ├── settings.py             # load/save/migrate — thread-safe (RLock)
    ├── security.py             # keyring wrappers, ssl context factory
    ├── i18n.py                 # tr(key) lookup, language switching
    ├── updater.py              # GitHub version check, EXE self-replace
    ├── backup.py               # Backup rotation
    ├── cli/
    │   ├── base.py             # Abstract: npm, winget, PATH ops
    │   ├── claude.py           # Claude Code specific ops
    │   ├── codex.py            # Codex CLI specific ops
    │   └── opencode.py         # opencode specific ops
    └── ui/
        ├── main_window.py
        ├── tabs/
        │   ├── tab_anthropic.py
        │   ├── tab_official.py
        │   ├── tab_openai.py
        │   └── tab_custom.py
        ├── dialogs/
        │   ├── dlg_fix_claude.py
        │   ├── dlg_status_line.py
        │   ├── dlg_install.py
        │   └── dlg_permission_mode.py
        └── widgets/
            ├── key_card.py
            ├── model_picker.py
            └── particle_bg.py
```

### 2.2 Dependency Graph (strict — no upward deps)

```
main.pyw
  └── ui/main_window
        ├── ui/tabs/*        → settings, i18n, cli/*
        ├── ui/dialogs/*     → settings, cli/*
        └── ui/widgets/*     → i18n
cli/*                        → settings, constants, security
updater                      → constants, security
security                     → constants
settings                     → constants, security(keyring)
i18n                         → constants
constants                    → (none)
```

### 2.3 Settings Data Flow

```
Disk (settings.json) <────────────────────────────────────────────────┐
        │                                                              │
        ▼                                                              │
  load_settings() ──► _migrate() ──► _ensure_default_urls()           │
        │                                                              │
        ▼                                                              │
  Global dict  [protected by threading.RLock]                         │
        │                                                              │
        ├──► UI reads  (get_setting)                                  │
        └──► UI writes (set_setting) ──► save_settings() ────────────►┘
```

### 2.4 Security Architecture

```
  settings.json (on disk)
  { keys: [{id, label, active}] }   ← IDs only, NO raw secrets
          │  id lookup
          ▼
  Windows Credential Manager
  (keyring, backed by DPAPI)
  Service:  "ClaudeCodeManager"
  Username: key_id
  Password: raw_api_key            ← encrypted by OS
```

### 2.5 SSL Context Strategy

| Use case                        | Context                        | Verify cert |
|---------------------------------|--------------------------------|-------------|
| GitHub API (update check)       | `ssl.create_default_context()` | YES         |
| Anthropic official API          | `ssl.create_default_context()` | YES         |
| User custom Base URL (default)  | `ssl.create_default_context()` | YES         |
| User custom Base URL (opt-out)  | custom ctx with `CERT_NONE`    | NO (user ack'd) |

---

## 3. Data Storage Map

| Data            | Location                                             | Protection        |
|-----------------|------------------------------------------------------|-------------------|
| App settings    | `%APPDATA%\ClaudeManager\settings.json`              | None (non-secret) |
| API keys        | Windows Credential Manager                          | DPAPI             |
| Claude settings | `~/.claude/settings.json`                            | None (Claude's)   |
| Claude identity | `~/.claude.json`                                     | None (Claude's)   |
| Backups         | `%APPDATA%\ClaudeManager\settings.json.bakN`         | None              |
| Logs            | `%APPDATA%\ClaudeManager\app.log`                    | None              |

---

## 4. Build Pipeline

```
source (.pyw + resources)
        │
        ▼
  ClaudeCodeManager.spec   ← SINGLE source of truth for build config
        │
        ▼
  python -m PyInstaller ClaudeCodeManager.spec --clean
        │
        ▼
  dist/ClaudeCodeManager.exe  (~80–120 MB, one-file)
        │
        ▼
  GitHub Release (tag vX.Y.Z == APP_VERSION)
```

`build.bat` calls only: `python -m PyInstaller ClaudeCodeManager.spec --clean`

---

## 5. Threading Model

| Thread          | Purpose                     | Communication with UI   |
|-----------------|-----------------------------|-------------------------|
| Main (Qt)       | UI rendering, user events   | —                       |
| UpdaterThread   | GitHub version check        | Qt signals/slots        |
| ModelFetchThread| `/v1/models` HTTP fetch     | Qt signals/slots        |
| CLIRunnerThread | npm/winget subprocess       | Qt signals/slots        |

Rule: **workers never mutate UI directly** — only emit signals. Settings always accessed under `_settings_lock`.
