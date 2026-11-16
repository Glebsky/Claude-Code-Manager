# ARCH-04 — Unify Build: bat + spec

> **Status:** Proposed  
> **Priority:** MUST  
> **Requirement:** NFR-M04

---

## Problem Statement

`build.bat` generates its own PyInstaller configuration via CLI flags, while `ClaudeCodeManager.spec` exists separately. They are not in sync: changes to `.spec` are silently ignored when building via `build.bat`.

---

## Solution

`build.bat` becomes a thin wrapper that only calls the `.spec` file:

```bat
@echo off
echo ========================================
echo  Claude Code Manager - Build Script
echo ========================================
echo.

echo [1/3] Cleaning old build files...
if exist "build" rmdir /s /q "build"
if exist "dist"  rmdir /s /q "dist"
echo Done!
echo.

echo [2/3] Building with PyInstaller spec...
cd /d "%~dp0"
python -m PyInstaller ClaudeCodeManager.spec --clean
echo.

if exist "dist\ClaudeCodeManager.exe" (
    echo [3/3] Build successful!
    echo ========================================
    echo  ClaudeCodeManager.exe created!
    echo  Location: dist\ClaudeCodeManager.exe
    echo ========================================
    explorer dist
) else (
    echo [3/3] Build FAILED - exe not found!
    exit /b 1
)
pause
```

### `ClaudeCodeManager.spec` — canonical build config

All build parameters live here. Update when adding new dependencies:

```python
# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_all

datas    = [('icon.ico', '.'), ('icon.png', '.'),
            ('icon-download-blue.svg', '.'), ('updates.json', '.')]
binaries = []
hiddenimports = []

# Pillow
tmp = collect_all('Pillow')
datas += tmp[0]; binaries += tmp[1]; hiddenimports += tmp[2]

# keyring (for SEC-02)
tmp = collect_all('keyring')
datas += tmp[0]; binaries += tmp[1]; hiddenimports += tmp[2]
hiddenimports += ['keyring.backends.Windows', 'keyring.backends._fail']

a = Analysis(
    ['main.pyw'],            # entry point after ARCH-01 split
    pathex=[],
    binaries=binaries,
    datas=datas,
    hiddenimports=hiddenimports,
    excludes=[
        'PySide6.QtWebEngineWidgets', 'PySide6.QtWebEngineCore',
        'PySide6.QtWebEngine', 'PySide6.QtWebChannel',
        'PySide6.QtQuick', 'PySide6.QtQml',
    ],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz, a.scripts, a.binaries, a.datas, [],
    name='ClaudeCodeManager',
    debug=False,
    strip=False,
    upx=True,
    console=False,
    icon=['icon.ico'],
)
```

---

## Acceptance Criteria

- [ ] `build.bat` contains no `--onefile`, `--windowed`, `--add-data`, or other PyInstaller flags
- [ ] `build.bat` calls only `python -m PyInstaller ClaudeCodeManager.spec --clean`
- [ ] Adding `keyring` to spec produces working EXE (verify SM-02)
- [ ] Build fails fast with `exit /b 1` if EXE not produced
- [ ] Old auto-generated `.spec` file not committed to repo (`.gitignore` updated)
