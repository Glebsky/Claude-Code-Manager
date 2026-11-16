# LAUNCH-01 — Permission Mode Control at Launch

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** FR-22, FR-23, FR-24, FR-25

---

## Problem Statement

Users who route Claude Code through third-party proxies (e.g. `api.samp.team`) see this error:

```
Auto mode can't check actions in this session.
Its safety check runs on the server, and your requests go through api.samp.team,
which doesn't pass it through. Actions that need the check now ask for your approval.
```

This happens because Claude Code's "auto" permission mode relies on a **server-side safety classifier** that must be reachable from the same HTTPS endpoint. Third-party proxies do not relay this classifier, so Claude Code falls back to per-action confirmation prompts, breaking the user experience.

### Why `$env:CLAUDE_CODE_AUTO_MODE_SERVER="0"` does NOT help

This environment variable is **not documented** in Claude Code and has no effect. It is not a supported configuration surface.

---

## Solution

The correct fix is to switch Claude Code's **permission mode** before launch. There are two supported approaches:

### Approach A — Write `permissions.mode` to `~/.claude/settings.json`

This is persistent across terminal sessions.

```python
# app/cli/claude.py
import json, pathlib

CLAUDE_SETTINGS = pathlib.Path.home() / ".claude" / "settings.json"

PERMISSION_MODES = {
    "auto":              "auto",           # default, requires server-side classifier
    "bypassPermissions": "bypassPermissions",  # skips ALL checks (use in trusted env)
    "autoEdit":          "autoEdit",       # auto-approve edits, ask for other actions
    "default":           "default",        # ask for every action
}

def set_permission_mode(mode: str) -> None:
    """
    Write permissions.mode to ~/.claude/settings.json.
    Safe: reads existing file, merges, writes back.
    """
    assert mode in PERMISSION_MODES, f"Unknown mode: {mode}"

    settings = {}
    if CLAUDE_SETTINGS.exists():
        try:
            settings = json.loads(CLAUDE_SETTINGS.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            settings = {}

    settings.setdefault("permissions", {})["mode"] = mode
    CLAUDE_SETTINGS.parent.mkdir(parents=True, exist_ok=True)
    CLAUDE_SETTINGS.write_text(
        json.dumps(settings, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

def get_permission_mode() -> str:
    """Read current permissions.mode from ~/.claude/settings.json."""
    try:
        data = json.loads(CLAUDE_SETTINGS.read_text(encoding="utf-8"))
        return data.get("permissions", {}).get("mode", "auto")
    except Exception:
        return "auto"
```

### Approach B — Launch flag `--dangerously-skip-permissions`

This applies only to the single launched session, without modifying settings files.

```python
def build_launch_command(directory: str, skip_permissions: bool = False) -> list[str]:
    cmd = ["claude"]
    if skip_permissions:
        cmd.append("--dangerously-skip-permissions")
    return cmd
```

---

## UI Design

### New UI element: Permission Mode selector

Location: main window, in the launch section (below the working directory selector).

```
 Permission mode:  [ Auto (default) v ]
                     Auto (default)
                     Bypass all checks  <-- recommended for proxy users
                     Auto-approve edits
                     Ask for everything

 [ Launch Claude Code ]
```

When **"Bypass all checks"** is selected, show a one-time informational banner:

> ⚠️ **bypassPermissions mode**: Claude Code will execute file edits, shell commands, and other actions without asking for confirmation. Only use this in a trusted, isolated environment.

Store last-used mode in app settings: `settings["launch_permission_mode"] = "bypassPermissions"`.

### Quick Fix button for proxy error

If the app detects `api.samp.team` or any custom Base URL in the active provider config, show a hint in the launch section:

```
⚠️ Custom proxy detected. Auto mode may show approval prompts.
   [ Set to Bypass ] to suppress them.
```

---

## Implementation Steps

1. Add `set_permission_mode()` and `get_permission_mode()` to `app/cli/claude.py`
2. Add `PermissionModeCombo` widget to `app/ui/widgets/`
3. Wire combo to `set_permission_mode()` on change
4. When launching: call `set_permission_mode(selected)` then start terminal
5. Add proxy-detection hint logic to launch panel

---

## Mode Reference

| Mode                | Server classifier needed | Auto-approves actions | Recommended for         |
|---------------------|--------------------------|----------------------|-------------------------|
| `auto`              | YES                       | Yes (via server)     | Official Anthropic API  |
| `bypassPermissions` | NO                        | Yes (all)            | Proxy users, local dev  |
| `autoEdit`          | NO                        | Edits only           | Balanced safety         |
| `default`           | NO                        | No                   | Maximum safety          |

---

## Acceptance Criteria

- [ ] Permission mode combo shown in launch panel
- [ ] Selecting `bypassPermissions` writes correct JSON to `~/.claude/settings.json`
- [ ] `get_permission_mode()` reads back the value correctly
- [ ] Warning banner shown when `bypassPermissions` selected for first time
- [ ] Proxy detection hint appears when custom base URL is active
- [ ] Launching with `bypassPermissions` mode: no approval prompts in Claude Code session
- [ ] SM-05 manual smoke test passes
