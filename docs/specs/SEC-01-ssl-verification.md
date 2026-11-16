# SEC-01 — Enable SSL Certificate Verification

> **Status:** Proposed  
> **Priority:** MUST (Critical Security)  
> **Requirement:** NFR-S02, FR-42  
> **ADR:** [ADR-001](../adr/ADR-001-keyring-storage.md)

---

## Problem Statement

The application globally disables TLS certificate verification:

```python
_ssl_context.check_hostname = False
_ssl_context.verify_mode = ssl.CERT_NONE
```

This makes every HTTPS request (update check, model fetch, API calls) vulnerable to Man-in-the-Middle attacks. An attacker on the same network could intercept the update check and serve a malicious EXE.

---

## Solution

### Two SSL contexts, used by scope

```python
# app/security.py
import ssl

def make_verified_ssl_context() -> ssl.SSLContext:
    """For all official endpoints: GitHub, Anthropic, OpenAI."""
    return ssl.create_default_context()

def make_unverified_ssl_context() -> ssl.SSLContext:
    """
    For user-specified custom Base URLs only.
    MUST only be used after user has acknowledged the risk.
    """
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx
```

### Usage rules

| Call site                        | Context to use              |
|----------------------------------|-----------------------------|
| GitHub release check             | `make_verified_ssl_context()` |
| Anthropic / OpenAI official API  | `make_verified_ssl_context()` |
| Custom Base URL fetch (models)   | Based on user setting `verify_ssl` |
| Self-update EXE download         | `make_verified_ssl_context()` |

### UI opt-out for custom Base URLs

Add a checkbox **"Skip SSL verification (unsafe, for self-signed certs)"** in the Custom URL settings panel. Default: **off** (verified).

Store as `settings["custom_url_skip_ssl"] = False` (bool).

When `True`, show a one-time warning dialog before first use:
> "Warning: SSL verification is disabled for this URL. Your API key and responses are not protected from interception. Only use this for local or trusted self-hosted servers."

---

## Acceptance Criteria

- [ ] `grep -rn "CERT_NONE" app/` returns 0 results outside `security.py`
- [ ] `make_verified_ssl_context()` is used in `updater.py` and all official API calls
- [ ] Custom URL path uses `make_unverified_ssl_context()` only when `custom_url_skip_ssl=True`
- [ ] Warning dialog shown first time user enables `skip_ssl`
- [ ] SM-07 (update check) passes with certificate validation

---

## Migration Notes

Search for all `urllib.request.urlopen` / `http.client` / `requests.get` calls and replace the ssl context argument. Likely 3–6 call sites.
