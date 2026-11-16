# Claude Code Manager — Project Overview

> **Status:** Active Development  
> **Version:** 6.1.3  
> **Last Updated:** 2026-11-15

## Purpose

Claude Code Manager is a Windows GUI control panel for **Claude Code CLI**, **OpenCode CLI**, and **Codex CLI**. It lets users:

- Switch AI models and API endpoints without manually editing JSON files
- Manage multiple API keys with quick switching
- Install, update, and uninstall CLI tools via npm/winget
- Repair broken CLI configurations (`~/.claude.json`, `~/.claude/settings.json`)
- Configure launch environments (permission modes, model roles, status line)

## Target Users

- Developers on Windows using Claude Code with multiple API providers
- Teams needing quick model switching during sessions
- Power users managing custom endpoints (DeepSeek, OpenRouter, vLLM, Ollama)

## Technology Stack

| Component      | Technology                          |
|----------------|-------------------------------------|
| Language       | Python 3.10+                        |
| UI Framework   | PySide6 (Qt6)                       |
| Packaging      | PyInstaller (single-file EXE)       |
| OS Target      | Windows 10/11 x64                   |
| Distribution   | GitHub Releases (no installer)      |

## Supported Provider Modes

| Mode                   | Description                                      |
|------------------------|--------------------------------------------------|
| Anthropic (FreeModel)  | Proxy/aggregator-compatible endpoints            |
| Official               | Direct Anthropic API with active subscription    |
| OpenAI                 | OpenAI-compatible endpoints (GPT, Codex)         |
| Custom URL             | Any OpenAI-compatible base URL                   |

## Key Constraints

- **Single-file distribution**: must compile to one `.exe`, no installer
- **Zero external runtime**: no Python required on target machine
- **Windows-only**: leverages Windows APIs (registry, DPAPI, winget)
- **Offline-capable**: core features work without internet

## Repository Structure

```
claude_code_manager/
├── claude_code_manager/
│   ├── claude_code_manager.pyw   # Main application
│   ├── ClaudeCodeManager.spec    # PyInstaller spec
│   ├── build.bat                 # Build script
│   ├── updates.json              # Version manifest & default URLs
│   └── icon.ico / icon.png
├── docs/                         # Spec-driven documentation
│   ├── OVERVIEW.md               # This file
│   ├── REQUIREMENTS.md
│   ├── ARCHITECTURE.md
│   ├── TESTING.md
│   ├── specs/                    # Feature specifications
│   └── adr/                      # Architecture Decision Records
├── README.md
├── RELEASE_NOTES.md
└── LICENSE
```

## Related Documents

- [REQUIREMENTS.md](./REQUIREMENTS.md) — What the system must do
- [ARCHITECTURE.md](./ARCHITECTURE.md) — How the system is built
- [TESTING.md](./TESTING.md) — How correctness is verified
- [specs/](./specs/) — Per-feature implementation specifications
- [adr/](./adr/) — Architecture decisions with rationale
