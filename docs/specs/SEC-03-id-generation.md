# SEC-03 — Secure ID Generation

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** NFR-S03

---

## Problem Statement

Key IDs are generated using the non-cryptographic `random` module:

```python
def _new_key_id():
    return f"k{int(time.time() * 1000)}{random.randint(1000, 9999)}"
```

`random` is seeded deterministically and is **not** suitable for security-sensitive identifiers. An attacker who knows the approximate time of key creation can enumerate possible IDs.

---

## Solution

Use `secrets` module from the standard library:

```python
# app/security.py
import secrets

def new_key_id() -> str:
    """Generate a cryptographically secure, URL-safe key identifier."""
    return f"k{secrets.token_hex(8)}"  # 16 hex chars = 64 bits of entropy
```

`secrets.token_hex(8)` produces 16 hexadecimal characters (64 bits of randomness), which is sufficient for a local identifier namespace.

### Remove `random` import

After this change, audit all usages of `random` in the codebase:

```bash
grep -n "import random\|random\." claude_code_manager.pyw
```

If `random` is only used for ID generation, remove the import entirely. If used for non-security purposes (e.g. particle animation offsets), keep it but add a comment:

```python
import random  # used only for visual/non-security purposes (particle FX)
```

---

## Acceptance Criteria

- [ ] `_new_key_id()` / `new_key_id()` uses `secrets.token_hex` or `secrets.token_urlsafe`
- [ ] `import random` is absent or annotated as non-security use
- [ ] `python -c "from app.security import new_key_id; print(new_key_id())"` produces unique values each run
- [ ] No other ID generation in the codebase uses `random.randint`
