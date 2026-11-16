# QUAL-04 — Normalize Line Endings

> **Status:** Proposed  
> **Priority:** SHOULD  
> **Requirement:** NFR-M05

---

## Problem Statement

The main Python file `claude_code_manager.pyw` uses Windows CRLF (`\r\n`) line endings. Python files should use LF (`\n`). Mixed endings cause:

- `git diff` noise when contributors use different editors
- Issues with `grep`, `wc -l`, and other POSIX tools
- Potential problems with shebang lines on WSL

---

## Solution

### Step 1 — Convert existing files

```bash
# Using dos2unix (available in Git Bash / WSL)
dos2unix claude_code_manager/claude_code_manager.pyw

# Or via Python:
python -c "
import pathlib
p = pathlib.Path('claude_code_manager/claude_code_manager.pyw')
p.write_bytes(p.read_bytes().replace(b'\r\n', b'\n'))
"
```

### Step 2 — Add `.gitattributes` to enforce going forward

Create at repository root: `.gitattributes`

```gitattributes
# Python source: always LF
*.py    text eol=lf
*.pyw   text eol=lf
*.spec  text eol=lf

# Docs: LF
*.md    text eol=lf
*.txt   text eol=lf
*.json  text eol=lf
*.yml   text eol=lf
*.yaml  text eol=lf

# Windows scripts: CRLF (required for cmd.exe)
*.bat   text eol=crlf
*.cmd   text eol=crlf
*.ps1   text eol=crlf

# Binary
*.exe   binary
*.ico   binary
*.png   binary
*.jpg   binary
*.gif   binary
*.zip   binary
*.pyc   binary
```

### Step 3 — Re-checkout existing files to apply attributes

```bash
git rm --cached -r .
git reset --hard HEAD
```

This forces Git to re-checkout all tracked files with the new EOL settings.

### Step 4 — Add `crash_dumps` to `.gitignore`

```gitignore
# Crash dumps (remove bash.exe.stackdump already committed)
*.stackdump
*.dmp

# Build artifacts
claude_code_manager/build/
claude_code_manager/dist/
__pycache__/
*.pyc
*.pyo
*.pyd

# App data
*.log
*.bak*
*.tmp
```

---

## Acceptance Criteria

- [ ] `file claude_code_manager.pyw` returns `ASCII text` (no `CRLF`)
- [ ] `.gitattributes` committed to repository root
- [ ] `git ls-files --eol | grep CRLF | grep -v \.bat | grep -v \.cmd | grep -v \.ps1` returns 0 lines
- [ ] `bash.exe.stackdump` removed from tracked files
- [ ] New contributors' editors auto-use LF for `.py` files via `.editorconfig` (optional bonus)

### Optional: `.editorconfig`

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.bat]
end_of_line = crlf
```
