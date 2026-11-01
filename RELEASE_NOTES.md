# 🚀 Claude Code Manager v6.1.0

A major release introducing the **Multi-Model Role Engine**, dynamic in-session `/model` switching for Claude Code CLI, one-click automated model discovery from custom Base URLs, ambient particle background animation, and unified multi-agent synchronization.

---

## 🌟 What's New

### 🎭 Multi-Model Role Engine & `/model` Command Support
Seamlessly utilize Claude Code CLI's native `/model` picker during active sessions without restarting or re-authenticating. Custom provider models can now be routed across 5 dedicated roles via standard environment variables:

- **Haiku Tier** (`ANTHROPIC_DEFAULT_HAIKU_MODEL` & `ANTHROPIC_SMALL_FAST_MODEL`): Optimized for background summarization, fast lightweight actions, and context compression.
- **Sonnet Tier** (`ANTHROPIC_DEFAULT_SONNET_MODEL`): Balanced daily driver for core programming and development tasks.
- **Opus Tier** (`ANTHROPIC_DEFAULT_OPUS_MODEL`): High-capacity reasoning, deep architectural design, and complex problem-solving.
- **Fable Tier** (`ANTHROPIC_DEFAULT_FABLE_MODEL`): Dedicated slot for fable-compatible routing and specialized agent tasks.
- **Custom Tier** (`ANTHROPIC_CUSTOM_MODEL_OPTION`): Add any arbitrary model with custom display name and description.

> **Usage:** Simply run `claude` and type `/model` in your interactive terminal to switch between your configured models on the fly without losing conversation context!

---

### ⚡ One-Click Model Auto-Discovery (`/v1/models`)
- Added **"Get Models"** button directly inside the Base URL Manager.
- Automatically connects to your provider's `/v1/models` (or `/models`) endpoint using your configured API key.
- Instantly populates the model dropdowns with all available upstream models (DeepSeek, Qwen, GLM, Llama, OpenAI-compatible APIs, Anthropic proxies).
- **Intelligent Heuristic Mapping**: Automatically categorizes models based on nomenclature (`mini`/`flash` ➔ Haiku, `coder`/`chat` ➔ Sonnet, `reasoner`/`r1`/`opus` ➔ Opus).

---

### ✨ Ambient Particle Background FX
- Added an unobtrusive, elegant floating particle mesh background animation.
- Easily toggleable via an on/off switch in the settings, allowing you to choose between animated atmosphere and a clean static canvas.

---

### 🔄 Cross-Agent Synchronization
- Unified environment synchronization for **Claude Code CLI**, **OpenCode CLI**, and **Codex CLI**.
- Automatically writes and persists environment variables into `~/.claude/settings.json` and scoped OpenCode configuration files without manual JSON editing.

---

### 🛡️ Clean Build & Privacy Guarantee
- The bundled executable is completely clean and stateless: **no personal API keys, base URLs, or session histories are included in the build**.
- New users will start with a fresh default profile in `%APPDATA%\ClaudeManager\settings.json`.

---

## 📦 Downloads

| File | Description | Compatibility |
| :--- | :--- | :--- |
| **[ClaudeCodeManager.exe](https://github.com/Glebsky/Claude-Code-Manager/releases/latest/download/ClaudeCodeManager.exe)** | Standalone Executable (Portable, No Installation Required) | Windows 10 / 11 (64-bit) |

---

## 💻 Running from Source

Requirements: Python 3.10+ (64-bit on Windows).

```bash
# Clone the repository
git clone https://github.com/Glebsky/Claude-Code-Manager.git
cd Claude-Code-Manager

# Install dependencies
pip install PySide6 Pillow

# Run the manager
python claude_code_manager/claude_code_manager.pyw
```
