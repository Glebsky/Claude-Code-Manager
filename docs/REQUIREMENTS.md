# Requirements Specification

> **Status:** Baseline v1.0  
> **Last Updated:** 2026-11-15  
> **Linked specs:** See `docs/specs/`

---

## 1. Functional Requirements

### 1.1 Provider & Model Management

| ID    | Requirement                                                                 | Priority | Spec     |
|-------|-----------------------------------------------------------------------------|----------|----------|
| FR-01 | Switch between Anthropic, Official, OpenAI, and Custom URL provider modes   | MUST     | —        |
| FR-02 | Store multiple API keys per provider and switch between them                | MUST     | SEC-02   |
| FR-03 | Fetch available models from `/v1/models` endpoint using stored API key      | SHOULD   | —        |
| FR-04 | Assign models to Haiku/Sonnet/Opus/Fable/Custom roles                      | SHOULD   | —        |
| FR-05 | Write model roles to `~/.claude/settings.json` as env vars before launch   | MUST     | —        |

### 1.2 CLI Lifecycle Management

| ID    | Requirement                                                                 | Priority | Spec |
|-------|-----------------------------------------------------------------------------|----------|------|
| FR-10 | Install Claude Code CLI via npm                                             | MUST     | —    |
| FR-11 | Update Claude Code CLI to latest or pinned version                         | MUST     | —    |
| FR-12 | Uninstall Claude Code CLI                                                  | MUST     | —    |
| FR-13 | Same install/update/uninstall for Codex CLI and opencode CLI               | SHOULD   | —    |
| FR-14 | Detect missing Node.js/npm and offer to install it via winget              | MUST     | —    |

### 1.3 Launch & Permission Mode

| ID    | Requirement                                                                                  | Priority | Spec       |
|-------|----------------------------------------------------------------------------------------------|----------|------------|
| FR-20 | Launch Claude Code in a terminal with pre-configured env vars                               | MUST     | —          |
| FR-21 | User can select working directory before launch                                             | MUST     | —          |
| FR-22 | Support `--dangerously-skip-permissions` flag to bypass auto-mode server check             | MUST     | LAUNCH-01  |
| FR-23 | Write `permissions.mode=bypassPermissions` to settings before launch (UI toggle)           | MUST     | LAUNCH-01  |
| FR-24 | Write `permissions.mode=autoEdit` to restore normal permission mode                        | MUST     | LAUNCH-01  |
| FR-25 | Show user-visible explanation of what each permission mode does before applying it         | SHOULD   | LAUNCH-01  |

### 1.4 Configuration Repair (Fix Claude)

| ID    | Requirement                                                                 | Priority |
|-------|-----------------------------------------------------------------------------|----------|
| FR-30 | Back up and recreate `~/.claude.json` with sane defaults                   | MUST     |
| FR-31 | Back up and recreate `~/.claude/settings.json`                             | MUST     |
| FR-32 | Add/remove Claude Code binary directory to Windows user PATH               | MUST     |
| FR-33 | Install/remove the status line script                                       | SHOULD   |

### 1.5 Auto-Update

| ID    | Requirement                                                                 | Priority | Spec   |
|-------|-----------------------------------------------------------------------------|----------|--------|
| FR-40 | Check GitHub Releases for newer version on startup                         | SHOULD   | —      |
| FR-41 | Download new EXE and replace itself via temporary launcher                 | SHOULD   | —      |
| FR-42 | Auto-update MUST use verified TLS (never disable SSL for official URLs)    | MUST     | SEC-01 |

### 1.6 Localisation

| ID    | Requirement                                                                 | Priority | Spec     |
|-------|-----------------------------------------------------------------------------|----------|----------|
| FR-50 | Fully available in Russian (baseline language)                             | MUST     | —        |
| FR-51 | Fully available in English                                                 | MUST     | I18N-01  |
| FR-52 | Fully available in Ukrainian                                               | SHOULD   | I18N-02  |
| FR-53 | Missing translation key falls back to Russian, never crashes               | MUST     | I18N-01  |

---

## 2. Non-Functional Requirements

### 2.1 Security

| ID        | Requirement                                                               | Priority | Spec   |
|-----------|---------------------------------------------------------------------------|----------|--------|
| NFR-S01   | API keys MUST NOT be stored in plaintext on disk                          | MUST     | SEC-02 |
| NFR-S02   | TLS certificate verification MUST be enabled for all official endpoints   | MUST     | SEC-01 |
| NFR-S03   | Cryptographically secure random MUST be used for ID generation            | MUST     | SEC-03 |
| NFR-S04   | Custom Base URLs MAY use unverified TLS (user-acknowledged risk only)     | MAY      | SEC-01 |

### 2.2 Reliability

| ID        | Requirement                                                               | Priority | Spec     |
|-----------|---------------------------------------------------------------------------|----------|----------|
| NFR-R01   | Settings read/write MUST be thread-safe                                   | MUST     | ARCH-02  |
| NFR-R02   | Settings file corruption MUST be detected and recovered via backup        | MUST     | —        |
| NFR-R03   | Backup files MUST be capped at 5 per settings file                        | SHOULD   | QUAL-03  |
| NFR-R04   | App MUST start even if `~/.claude/settings.json` is missing or corrupted  | MUST     | —        |

### 2.3 Maintainability

| ID        | Requirement                                                               | Priority | Spec     |
|-----------|---------------------------------------------------------------------------|----------|----------|
| NFR-M01   | Each source module MUST NOT exceed 500 lines                              | SHOULD   | ARCH-01  |
| NFR-M02   | No bare `except:` — always `except Exception` with logging               | MUST     | QUAL-01  |
| NFR-M03   | Single version constant aligned with git tag                              | MUST     | ARCH-03  |
| NFR-M04   | Build MUST use `.spec` file as single source of truth                     | MUST     | ARCH-04  |
| NFR-M05   | Python files MUST use LF line endings; `.bat` files use CRLF             | SHOULD   | QUAL-04  |

### 2.4 Performance

| ID        | Requirement                                                               | Priority |
|-----------|---------------------------------------------------------------------------|----------|
| NFR-P01   | App startup time MUST be < 3 seconds on Windows 10                       | MUST     |
| NFR-P02   | Settings save MUST complete in < 200 ms                                   | MUST     |
| NFR-P03   | Model catalog fetch MUST run in background thread, never blocking UI      | MUST     |

### 2.5 Distribution

| ID        | Requirement                                                               | Priority |
|-----------|---------------------------------------------------------------------------|----------|
| NFR-D01   | Packaged EXE MUST run without Python installed                            | MUST     |
| NFR-D02   | EXE MUST be under 150 MB                                                  | SHOULD   |
| NFR-D03   | No installer — single EXE drag-and-drop                                   | MUST     |

---

## 3. Out of Scope

- macOS / Linux support
- Cloud sync of settings
- Multi-user / enterprise deployment
- In-app code editor
- Direct Claude API calls from the manager itself
