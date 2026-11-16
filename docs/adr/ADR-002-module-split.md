# ADR-002 — Split Monolith into Modules

> **Status:** Accepted  
> **Date:** 2026-11-15  
> **Deciders:** Project maintainer  
> **Related specs:** ARCH-01

---

## Context

The application is a single ~2.6 MB Python file. While functional, it is not testable, difficult to review, and slow to navigate in an IDE. As the feature set grows, maintenance cost increases super-linearly.

## Decision Drivers

- Must be able to unit-test settings, security, i18n independently
- Must not break existing functionality during split
- PyInstaller build must continue to work
- Split should be safe to do incrementally (one module at a time)

## Considered Options

### Option A — Keep monolith, add tests with heavy mocking
- ✅ No structural change
- ❌ Tests require mocking entire global state
- ❌ Cannot import individual components for testing
- ❌ Does not address the root cause

### Option B — Rewrite in a framework (e.g., PyQt MVC pattern)
- ✅ Clean architecture from scratch
- ❌ Huge effort, high risk of regressions
- ❌ Breaks all PRs in-flight
- ❌ Overkill for a utility application of this scope

### Option C — Incremental extraction into `app/` subpackage *(chosen)*
- ✅ Low risk: one module extracted at a time, app tested after each step
- ✅ Existing functionality preserved throughout
- ✅ PyInstaller continues to work (just adds `app/` to Analysis pathex)
- ✅ Enables unit tests incrementally
- ❌ Takes multiple PRs/sprints to complete

## Decision

**Option C: incremental extraction.** The dependency graph is well-defined (constants → security/settings/i18n → cli → ui), so extraction can proceed bottom-up without circular imports. Each extracted module is independently testable and verifiable.

## Extraction order

1. `constants.py` (no deps)
2. `i18n.py` (deps: constants)
3. `security.py` (deps: constants)
4. `backup.py` (deps: constants)
5. `settings.py` (deps: constants, security, backup)
6. `cli/` (deps: settings, constants)
7. `updater.py` (deps: constants, security)
8. `ui/` (last, largest)

## Consequences

- Entry point becomes `main.pyw` importing from `app/`
- `ClaudeCodeManager.spec` updated to reference `main.pyw`
- `tests/unit/` created for each extracted module
- Existing `claude_code_manager.pyw` retained until all code migrated
