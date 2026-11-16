# ADR-004 — Permission Mode Control for Proxy Users

> **Status:** Accepted  
> **Date:** 2026-11-15  
> **Deciders:** Project maintainer  
> **Related specs:** LAUNCH-01

---

## Context

Users routing Claude Code through third-party proxies (api.samp.team, etc.) receive repeated approval prompts because the proxy does not forward Claude Code's server-side safety classifier. The error message reads:

> "Auto mode can't check actions in this session..."

Users need a way to suppress these prompts from within Claude Code Manager, without needing to manually edit JSON files or use Shift+Tab during each session.

## Decision Drivers

- Must work for all proxy setups (not just api.samp.team)
- Must not require Claude Code CLI changes (we control only the manager)
- Solution must be reversible (user can restore default mode)
- Must show clear warning about security implications

## Considered Options

### Option A — Set env var `CLAUDE_CODE_AUTO_MODE_SERVER=0`
- **Why rejected:** This env var does not exist in Claude Code. It has no effect. Setting it would give users false confidence without actually solving the problem.

### Option B — Pass `--dangerously-skip-permissions` flag at launch
- ✅ Works: suppresses all permission prompts for the session
- ✅ Does not modify settings files
- ✅ Scoped to single session
- ❌ User must re-select every launch (non-persistent)
- ❌ Name "dangerously" may alarm users unnecessarily

### Option C — Write `permissions.mode` to `~/.claude/settings.json` *(chosen as primary)*
- ✅ Persistent across sessions (set once, works every time)
- ✅ Supported official API surface of Claude Code
- ✅ Reversible: manager can restore `mode: auto`
- ✅ User sees explicit mode selection in UI
- ❌ Modifies Claude's settings file (acceptable, manager already does this for model roles)

### Option D — Instruct user to press Shift+Tab
- ✅ Zero code changes
- ❌ Manual step each session; users already know this from the error message
- ❌ Does not solve the problem for less technical users

## Decision

**Option C (primary) + Option B (secondary toggle).**

The UI offers a Permission Mode selector that writes to `~/.claude/settings.json`. When a custom proxy is detected, a contextual hint suggests switching to `bypassPermissions`. Option B (`--dangerously-skip-permissions`) is available as a per-launch override without changing persistent settings.

## Security Note

`bypassPermissions` mode disables Claude Code's action confirmation system entirely. This is appropriate for:
- Local development machines
- Trusted private networks
- Users who understand the implications

It is **not** appropriate for shared machines or production environments. The UI must display a clear one-time warning before the first use.

## Consequences

- `set_permission_mode()` function added to `app/cli/claude.py`
- Permission Mode combo added to launch panel in main window
- Mode persisted in app settings (`launch_permission_mode` key)
- Proxy auto-detection added for contextual hint
- Warning dialog shown before first use of `bypassPermissions`
- SM-05 smoke test added for validation
