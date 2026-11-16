# SEC-02 — API Key Encryption via OS Keyring

> **Status:** Proposed  
> **Priority:** MUST (Critical Security)  
> **Requirement:** NFR-S01, FR-02  
> **ADR:** [ADR-001](../adr/ADR-001-keyring-storage.md)

---

## Problem Statement

API keys are stored as plaintext strings in `%APPDATA%\ClaudeManager\settings.json`. Any process, script, or malware with read access to AppData can extract all keys without authentication.

---

## Solution

Store key **values** in Windows Credential Manager via the `keyring` library. Store only key **IDs** in `settings.json`.

### New settings.json shape (keys section)

```json
{
  "keys": [
    { "id": "k1a2b3c4d5e6f7a8", "label": "Anthropic Main",  "active": true,  "provider": "anthropic" },
    { "id": "k9b8c7d6e5f4a3b2", "label": "OpenRouter Key", "active": false, "provider": "custom" }
  ]
}
```

No `"value"` field in JSON — ever.

### `app/security.py` — keyring API

```python
import keyring
import secrets
from keyring.errors import PasswordDeleteError

KEYRING_SERVICE = "ClaudeCodeManager"

def new_key_id() -> str:
    """Generate a cryptographically random key ID."""
    return f"k{secrets.token_hex(8)}"

def save_api_key(key_id: str, raw_value: str) -> None:
    """Persist raw API key in OS credential store."""
    keyring.set_password(KEYRING_SERVICE, key_id, raw_value)

def load_api_key(key_id: str) -> str | None:
    """Retrieve raw API key from OS credential store."""
    return keyring.get_password(KEYRING_SERVICE, key_id)

def delete_api_key(key_id: str) -> None:
    """Remove API key from OS credential store."""
    try:
        keyring.delete_password(KEYRING_SERVICE, key_id)
    except PasswordDeleteError:
        pass  # already gone
```

### PyInstaller packaging

Add to `ClaudeCodeManager.spec`:

```python
tmp_ret = collect_all('keyring')
datas    += tmp_ret[0]
binaries += tmp_ret[1]
hiddenimports += tmp_ret[2]
hiddenimports += [
    'keyring.backends.Windows',
    'keyring.backends._fail',
]
```

### Migration path for existing users

On first launch after update, detect old-format keys (`settings["keys"][i]["value"]` exists):

```python
def migrate_plaintext_keys(settings: dict) -> dict:
    for key_entry in settings.get("keys", []):
        if "value" in key_entry:
            save_api_key(key_entry["id"], key_entry.pop("value"))
    return settings
```

Call `migrate_plaintext_keys` in `load_settings()` before returning. Run once; old `"value"` field removed.

---

## Acceptance Criteria

- [ ] `settings.json` contains no field named `"value"` or `"api_key"` or `"key"` with a string resembling a key
- [ ] `load_api_key(key_id)` returns correct value after app restart
- [ ] `delete_api_key` removes from Credential Manager (verify in Windows Credential Manager UI)
- [ ] Old plaintext keys migrated automatically on first launch
- [ ] SM-02 manual smoke test passes

---

## Dependencies

- `pip install keyring` (add to build requirements)
- Windows 10+ (uses `WinVaultKeyring` backend automatically)
