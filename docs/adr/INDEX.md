# Architecture Decision Records

ADRs document significant architectural decisions: **Context → Options considered → Decision → Consequences**.

Once accepted, an ADR is immutable (append-only). To reverse a decision, create a new ADR that supersedes it.

---

| ID | Title | Status | Date |
|----|-------|--------|------|
| [ADR-001](./ADR-001-keyring-storage.md) | Use OS Keyring for API Key Storage | Accepted | 2026-11-15 |
| [ADR-002](./ADR-002-module-split.md) | Split Monolith into Modules | Accepted | 2026-11-15 |
| [ADR-003](./ADR-003-i18n-approach.md) | String ID-based i18n System | Accepted | 2026-11-15 |
| [ADR-004](./ADR-004-permission-mode.md) | Permission Mode Control for Proxy Users | Accepted | 2026-11-15 |

---

## ADR Template

```markdown
# ADR-NNN — Title

> **Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN  
> **Date:** YYYY-MM-DD  
> **Deciders:** Name(s)  
> **Related specs:** SPEC-ID

## Context

What situation prompted this decision?

## Decision Drivers

- Bullet list of requirements / constraints

## Considered Options

### Option A — Name
- Pro/Con

### Option B — Name *(chosen)*
- Pro/Con

## Decision

We chose Option B because ...

## Consequences

- What changes as a result
- What new problems this introduces
```
