# ADR-003 — String ID-based i18n System

> **Status:** Accepted  
> **Date:** 2026-11-15  
> **Deciders:** Project maintainer  
> **Related specs:** I18N-01, I18N-02

---

## Context

The current translation system uses Russian strings as dictionary keys. This causes silent failures when a key has a typo (the Russian text is shown instead of a translated string), and makes it impossible to validate completeness at test time.

## Decision Drivers

- Must detect missing translations at test time (not at runtime in production)
- Must be easy to add a new language in future
- Must not require an external translation library (keep it simple, single EXE)
- Migration from current system must be automatable with a script

## Considered Options

### Option A — Keep Russian-key dicts, improve typo detection *(current improved)*
- ✅ Minimal code change
- ❌ Fundamental fragility remains (key = human-readable string)
- ❌ Adding a 4th language still error-prone

### Option B — Use Qt's QTranslator / .ts files
- ✅ Industry standard for Qt apps
- ✅ `lupdate` can extract strings automatically
- ❌ Requires `.ts` / `.qm` compilation step in build pipeline
- ❌ Overkill for 3 languages and a single developer
- ❌ `.qm` files must be bundled in PyInstaller

### Option C — Single `_STRINGS` dict with string IDs *(chosen)*
- ✅ All languages in one place: easy to see what's missing
- ✅ `validate_translations()` function detects gaps at test time
- ✅ No external tooling or compilation step
- ✅ IDs are stable and versioned (never renamed, only deprecated)
- ❌ Migration effort: replace all `tr("Russian text")` with `tr("namespace.id")`
- ❌ IDs must be chosen thoughtfully (can't change them later)

### Option D — JSON translation files per language
- ✅ Translators can edit without touching Python
- ❌ Adds file I/O on startup
- ❌ Complicates PyInstaller bundling
- ❌ Overkill given the small team size

## Decision

**Option C.** A single `_STRINGS` dict in `app/i18n.py` with dot-namespaced string IDs. The `validate_translations()` function provides testable completeness checking. The migration is a one-time effort that can be semi-automated.

## ID Naming Convention

```
btn.*     button labels
lbl.*     field/form labels
msg.*     dialog bodies (may contain {placeholders})
status.*  status indicator texts
err.*     error messages
tip.*     tooltips
perm.*    permission mode descriptions
title.*   window/dialog titles
```

## Consequences

- All `tr()` call sites updated to use IDs
- `validate_translations()` added to test suite (must return empty list on CI)
- Ukrainian translation completed as part of this change
- Old `TRANSLATIONS_EN` / `TRANSLATIONS_UA` dicts removed
