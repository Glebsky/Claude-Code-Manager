# I18N-01 — Translation System Redesign

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** FR-50, FR-51, FR-53  
> **ADR:** [ADR-003](../adr/ADR-003-i18n-approach.md)

---

## Problem Statement

The current system uses Russian strings as dictionary keys:

```python
TRANSLATIONS_EN = {
    "Получить модели": "Get Models",
    ...
}

def tr(text: str) -> str:
    if lang == "en":
        return TRANSLATIONS_EN.get(text, text)
    ...
```

**Problems:**
- One typo in a Russian key = silent missing translation (falls back to Russian)
- Translations for 3 languages are split across 2+ dicts
- No way to detect missing keys at build/test time
- Multi-line strings as keys are extremely fragile

---

## Solution: String ID system

### File: `app/i18n.py`

```python
import logging
from app.constants import DEFAULT_LANG

logger = logging.getLogger(__name__)

# All strings indexed by a stable dot-separated ID.
# Format: "namespace.identifier"
# IDs are permanent; never rename a key once shipped (use deprecation).
_STRINGS: dict[str, dict[str, str]] = {
    # --- Buttons ---
    "btn.get_models":          {"ru": "Получить модели",   "en": "Get Models",           "ua": "Отримати моделі"},
    "btn.launch":              {"ru": "Запустить",         "en": "Launch",               "ua": "Запустити"},
    "btn.fix_claude":          {"ru": "Исправить",         "en": "Fix",                  "ua": "Виправити"},
    "btn.install":             {"ru": "Установить",        "en": "Install",              "ua": "Встановити"},
    "btn.update":              {"ru": "Обновить",          "en": "Update",               "ua": "Оновити"},
    "btn.delete":              {"ru": "Удалить",           "en": "Delete",               "ua": "Видалити"},
    "btn.cancel":              {"ru": "Отмена",            "en": "Cancel",               "ua": "Скасувати"},
    "btn.ok":                  {"ru": "ОК",                "en": "OK",                   "ua": "ОК"},
    "btn.save":                {"ru": "Сохранить",         "en": "Save",                 "ua": "Зберегти"},
    "btn.add_to_path":         {"ru": "Добавить в PATH",   "en": "Add to PATH",          "ua": "Додати до PATH"},
    # --- Status ---
    "status.session_active":   {"ru": "Сессия активна",   "en": "Session active",       "ua": "Сесія активна"},
    "status.session_inactive": {"ru": "Сессия не активна","en": "Session inactive",     "ua": "Сесія не активна"},
    "status.update_available": {"ru": "Доступно обновление","en": "Update available",   "ua": "Доступне оновлення"},
    "status.installed":        {"ru": "Установлена",       "en": "Installed",            "ua": "Встановлено"},
    # --- Errors ---
    "err.unknown":             {"ru": "Неизвестная ошибка","en": "Unknown error",        "ua": "Невідома помилка"},
    "err.no_api_key":          {"ru": "Нет активного API ключа","en": "No active API key","ua": "Немає активного API ключа"},
    # --- Permission modes ---
    "perm.auto":               {"ru": "Авто (по умолчанию)","en": "Auto (default)",      "ua": "Авто (за замовчуванням)"},
    "perm.bypass":             {"ru": "Без подтверждений", "en": "Bypass all checks",   "ua": "Без підтверджень"},
    "perm.auto_edit":          {"ru": "Авто-правки",       "en": "Auto-approve edits",  "ua": "Авто-правки"},
    "perm.default":            {"ru": "Всё спрашивать",   "en": "Ask for everything",   "ua": "Питати про все"},
    # ... (complete list in translation table spreadsheet)
}

_current_lang: str = DEFAULT_LANG  # "ru" | "en" | "ua"

def set_lang(lang: str) -> None:
    global _current_lang
    assert lang in ("ru", "en", "ua"), f"Unsupported language: {lang}"
    _current_lang = lang

def get_lang() -> str:
    return _current_lang

def tr(key: str) -> str:
    """
    Look up translation for key in current language.
    Falls back to Russian, then to the key itself.
    Missing keys are logged as warnings.
    """
    entry = _STRINGS.get(key)
    if entry is None:
        logger.warning("Missing i18n key: %r (lang=%s)", key, _current_lang)
        return key
    result = entry.get(_current_lang) or entry.get("ru") or key
    if result is None:
        logger.warning("Empty translation for key %r in lang %s", key, _current_lang)
        return key
    return result

def validate_translations() -> list[str]:
    """Return list of keys missing in any language. Run in tests."""
    missing = []
    for key, langs in _STRINGS.items():
        for lang in ("ru", "en", "ua"):
            if not langs.get(lang):
                missing.append(f"{key}[{lang}]")
    return missing
```

### Migration

Replace all `tr("Russian string")` calls with `tr("namespace.id")` calls. Steps:

1. Build the full `_STRINGS` dict from both `TRANSLATIONS_EN` and `TRANSLATIONS_UA`
2. Assign each string a stable ID (see naming convention below)
3. Replace call sites using regex: `tr\("([^"]+)"\)` → map old string to new ID
4. Remove old `TRANSLATIONS_EN` and `TRANSLATIONS_UA` dicts

### ID naming convention

```
btn.*      — button labels
lbl.*      — form labels, field names
msg.*      — dialog messages (multi-line)
status.*   — status indicator strings
err.*      — error messages
tip.*      — tooltips
perm.*     — permission mode descriptions
title.*    — window/dialog titles
```

---

## Acceptance Criteria

- [ ] `validate_translations()` returns empty list (no missing keys)
- [ ] `tr("nonexistent.key")` logs a WARNING and returns `"nonexistent.key"`
- [ ] Language switching updates all visible strings without restart
- [ ] `test_i18n.py::test_all_keys_present` passes
- [ ] `test_i18n.py::test_fallback_to_russian` passes
- [ ] No `TRANSLATIONS_EN` or `TRANSLATIONS_UA` dicts remain in codebase
