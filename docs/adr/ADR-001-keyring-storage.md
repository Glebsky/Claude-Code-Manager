# ADR-001 — Use OS Keyring for API Key Storage

> **Status:** Accepted  
> **Date:** 2026-11-15  
> **Deciders:** Project maintainer  
> **Related specs:** SEC-02

---

## Context

The application stores API keys from multiple providers (Anthropic, OpenAI, custom). These keys grant billing access and must not be exposed to other processes or users. The current approach stores them as plaintext strings in `settings.json`.

## Decision Drivers

- API keys are sensitive secrets; plaintext storage is a security vulnerability
- Solution must work without user installing additional software
- Must survive app updates (keys persist across EXE upgrades)
- PyInstaller single-file build must bundle the solution

## Considered Options

### Option A — Continue with plaintext JSON *(current)*
- ✅ Zero new dependencies
- ❌ Keys visible to any process with read access to AppData
- ❌ Violates NFR-S01

### Option B — Encrypt with a hardcoded password
- ✅ Hides keys from casual inspection
- ❌ Hardcoded key = security theater (attacker can reverse EXE)
- ❌ Increases complexity with no real security gain

### Option C — `keyring` library with Windows Credential Manager *(chosen)*
- ✅ Keys encrypted by Windows DPAPI (tied to logged-in user)
- ✅ Standard library for credential storage on all major OSes
- ✅ Works transparently with PyInstaller when bundled via `collect_all('keyring')`
- ✅ Keys survive EXE updates (stored independently of AppData file)
- ❌ Adds `keyring` as a dependency (~500 KB)
- ❌ On machines where Windows Credential Manager fails (rare), falls back to plaintext; must handle gracefully

### Option D — Windows DPAPI directly (ctypes)
- ✅ No dependency
- ❌ Requires platform-specific ctypes code
- ❌ Breaks on non-Windows (not currently a concern but bad practice)
- ❌ More code to maintain

## Decision

**Option C: `keyring` library.** It is the industry-standard solution for this problem, works on Windows out of the box, is easy to bundle with PyInstaller, and stores keys in Windows Credential Manager which is encrypted by the OS.

## Consequences

- `keyring` added to `requirements.txt` and `ClaudeCodeManager.spec`
- `settings.json` schema change: `keys[].value` removed, only `keys[].id` kept
- Migration code runs on first startup after update (see SEC-02)
- If `keyring` backend unavailable, app warns user and refuses to save key (safe failure)
