# Specs Index

> All feature specifications for Claude Code Manager.  
> Each spec follows the format: **Problem → Solution → Acceptance Criteria**.

---

## Security Specs

| ID     | Title                        | Priority | Status   |
|--------|------------------------------|----------|----------|
| [SEC-01](./SEC-01-ssl-verification.md) | Enable SSL Certificate Verification | MUST | Proposed |
| [SEC-02](./SEC-02-api-key-encryption.md) | API Key Encryption via OS Keyring | MUST | Proposed |
| [SEC-03](./SEC-03-id-generation.md) | Secure ID Generation (`secrets` module) | MUST | Proposed |

## Architecture Specs

| ID     | Title                        | Priority | Status   |
|--------|------------------------------|----------|----------|
| [ARCH-01](./ARCH-01-modularization.md) | Modularization of Monolithic Source | SHOULD | Proposed |
| [ARCH-02](./ARCH-02-settings-thread-safety.md) | Thread-Safe Settings Access | MUST | Proposed |
| [ARCH-03](./ARCH-03-version-management.md) | Single Version Constant | MUST | Proposed |
| [ARCH-04](./ARCH-04-build-unification.md) | Unify build.bat + spec file | MUST | Proposed |

## Launch & Environment Specs

| ID     | Title                        | Priority | Status   |
|--------|------------------------------|----------|----------|
| [LAUNCH-01](./LAUNCH-01-permission-mode.md) | Permission Mode Control at Launch | MUST | Proposed |

## Internationalisation Specs

| ID     | Title                        | Priority | Status   |
|--------|------------------------------|----------|----------|
| [I18N-01](./I18N-01-translation-system.md) | Translation System Redesign | MUST | Proposed |
| [I18N-02](./I18N-02-ua-completion.md) | Complete Ukrainian Translation | SHOULD | Proposed |

## Quality Specs

| ID     | Title                        | Priority | Status   |
|--------|------------------------------|----------|----------|
| [QUAL-01](./QUAL-01-exception-handling.md) | Exception Handling Standard | MUST | Proposed |
| [QUAL-02](./QUAL-02-url-dedup.md) | Eliminate URL Migration Duplication | SHOULD | Proposed |
| [QUAL-03](./QUAL-03-backup-rotation.md) | Backup File Rotation Cap | SHOULD | Proposed |
| [QUAL-04](./QUAL-04-line-endings.md) | Normalize Line Endings (CRLF → LF) | SHOULD | Proposed |

---

## Sprint Plan

| Sprint | Specs | Goal |
|--------|-------|------|
| **1** | SEC-01, SEC-02, SEC-03 | Eliminate critical security vulnerabilities |
| **2** | ARCH-02, ARCH-03, ARCH-04, LAUNCH-01 | Stabilize settings, build, and launch UX |
| **3** | QUAL-01, QUAL-02, QUAL-03, QUAL-04 | Improve code quality and reliability |
| **4** | ARCH-01 | Refactor monolith into modules |
| **5** | I18N-01, I18N-02 | Complete i18n overhaul |

> ⚠️ ARCH-01 runs **after** all other specs so module boundaries are clear before the split.

---

## Spec Lifecycle

```
Proposed  →  In Progress  →  Done  →  (Deprecated)
```

Update the **Status** field in each spec file and in this index as work progresses.
