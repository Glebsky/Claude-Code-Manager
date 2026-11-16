# ARCH-03 — Single Version Constant

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** NFR-M03

---

## Problem Statement

Two version constants exist and have diverged:

```python
APP_VERSION = "6.0.8"       # used for update comparison
APP_DISPLAY_VERSION = "1.0" # shown in UI
```

Git tags show `v6.1.3` — neither constant matches. This causes incorrect update notifications and confuses users.

---

## Solution

### One constant in `app/constants.py`

```python
# app/constants.py
APP_VERSION = "6.1.3"  # MUST match git tag vX.Y.Z exactly
APP_NAME    = "Claude Code Manager"
```

Remove `APP_DISPLAY_VERSION` entirely. Use `APP_VERSION` everywhere.

### Version format

Semantic versioning: `MAJOR.MINOR.PATCH`

| Part  | Bump when                                      |
|-------|------------------------------------------------|
| MAJOR | Breaking change to settings format or workflow |
| MINOR | New feature added                              |
| PATCH | Bug fix, translation update, build change      |

### Release checklist (manual until CI added)

```
1. Update APP_VERSION in app/constants.py
2. Update RELEASE_NOTES.md with changelog entry
3. Update version in updates.json ("version" field)
4. Commit: git commit -m "release: v{VERSION}"
5. Tag:    git tag v{VERSION}
6. Push:   git push origin main --tags
7. Build:  build.bat
8. Upload dist/ClaudeCodeManager.exe to GitHub Release
```

### Auto-extract version in `build.bat`

```bat
:: Read version from constants.py for display/verification
for /f "tokens=2 delims=='" %%v in ('findstr /r "APP_VERSION" app\constants.py') do set VER=%%v
set VER=%VER: =%
echo Building ClaudeCodeManager v%VER%...
```

---

## Acceptance Criteria

- [ ] `grep -rn "APP_DISPLAY_VERSION" .` returns 0 results
- [ ] `grep -rn "APP_VERSION" app/constants.py` shows single definition
- [ ] `APP_VERSION` value matches latest git tag (`git describe --tags`)
- [ ] `updates.json["version"]` matches `APP_VERSION`
- [ ] UI shows correct version string in About section
