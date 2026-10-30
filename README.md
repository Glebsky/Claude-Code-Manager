# Claude Code Manager

> [!WARNING]
> **Unofficial third-party project.**
> This project is not affiliated with, endorsed, sponsored, or approved by Anthropic, OpenAI, or any other third-party tool provider.
>
> All product names, logos, brands, trademarks, and registered trademarks are the property of their respective owners. Anthropic, Claude, OpenAI, Codex, and related marks are trademarks or registered trademarks of their respective companies.
>
> All company, product, and service names used in this project are for identification purposes only.

Desktop control panel for **[Claude Code](https://github.com/anthropics/claude-code)**, **OpenCode**, and **Codex** on Windows. Switches models and API endpoints, manages multi-model role routing, automatically fetches model catalogs from custom providers, repairs CLIs, and customizes your developer workflow — without touching the terminal or editing JSON files by hand.

**Download:** [ClaudeCodeManager.exe (latest release)](https://github.com/Glebsky/Claude-Code-Manager/releases/latest/download/ClaudeCodeManager.exe)  
*No installation required. Windows 10/11, 64-bit.*

---

## 🚀 Key New Features

### 1. Multi-Model Role Engine & Claude Code CLI `/model` Switching
Claude Code CLI allows switching models during an active interactive session using the `/model` command. Claude Code Manager now configures and distributes your custom models across all Claude Code model tiers via standard environment variables:

- **Haiku Tier**: `ANTHROPIC_DEFAULT_HAIKU_MODEL` & `ANTHROPIC_SMALL_FAST_MODEL` (for fast background operations, summarization, and small tasks)
- **Sonnet Tier**: `ANTHROPIC_DEFAULT_SONNET_MODEL` (main balanced coding engine)
- **Opus Tier**: `ANTHROPIC_DEFAULT_OPUS_MODEL` (complex reasoning and deep architecture tasks)
- **Fable Tier**: `ANTHROPIC_DEFAULT_FABLE_MODEL` (dedicated role mapping for fable-compatible routing)
- **Custom Tier**: `ANTHROPIC_CUSTOM_MODEL_OPTION` (allows adding any arbitrary custom upstream model with custom display name and description)

When you run Claude Code CLI, you can simply type `/model` in the chat to seamlessly switch between your configured Haiku, Sonnet, Opus, Fable, and Custom models on the fly!

### 2. Auto-Discovery & Fetching Models from Base URLs
- **One-Click Model Fetching**: The Base URL manager features an automated **"Get Models" / "Получить модели"** button.
- Automatically queries your provider's `/v1/models` (or `/models`) endpoint using your configured API key.
- Discovers all available models on your custom provider (DeepSeek, Qwen, GLM, Llama, Anthropic proxies, OpenAI-compatible APIs) and automatically populates the model pickers.
- Intelligent auto-role detection: automatically maps fast models (flash, mini, 8b) to Haiku, coding models to Sonnet, reasoners (r1, reasoner, opus) to Opus, and specialty models to Fable/Custom.

### 3. Ambient Particle Background FX
- Subtle, weightless, non-intrusive ambient background animation with floating connected nodes and soft glow effects.
- Fully togglable via an on/off switch in the settings, allowing you to choose between animated atmosphere or minimalist static background.

### 4. Unified Multi-Agent Synchronization
- Synchronizes provider endpoints, authentication keys, and model selections across **Claude Code CLI**, **OpenCode CLI**, and **Codex CLI**.
- Writes persistent environment variables into `~/.claude/settings.json` under `env` and scoped provider files (`opencode-provider.json`) automatically.

---

## 🎛️ Provider Modes

Switch between four distinct provider modes directly from the left sidebar:

- **Anthropic (FreeModel)** — route through FreeModel-compatible proxies and aggregators.
- **Official** — direct Anthropic API connection.
- **OpenAI** — OpenAI-compatible endpoints with model selection and reasoning effort level configuration.
- **Custom URL** — enter any custom compatible base URL (e.g. DeepSeek, OpenRouter, self-hosted vLLM/Ollama, etc.).

---

## 🛠️ Complete Feature Set

- **Model Pickers & Role Assignment** — visual model selection per mode, reasoning-effort level toggles, and dedicated multi-model role assignment.
- **API Key Vaults** — secure local storage and rapid switching of API keys. Each key card displays live usage statistics, limits, and reset times.
- **Base URL Manager** — store, test, and manage custom API endpoints per mode with one-click catalog fetching.
- **opencode Integration** — provider presets, model catalog fetch with reasoning indicators, sound schemes, terminal wallpapers with blur/zoom preview, and Windows toast push notifications.
- **CLI Lifecycle Management** — install, update, and uninstall Claude Code, Codex CLI, and opencode CLI via npm or winget. Compares installed versions against the latest GitHub releases.
- **Environment Diagnostics & Fixes**:
  - Automatically detects missing Node.js on startup and offers automatic installation.
  - **Fix PATH**: adds the Claude binary directory to Windows user PATH.
  - **Fix Claude**: repairs corrupted `~/.claude.json` files with automatic timestamped backups, fixes `installMethod` errors, and pins `DISABLE_UPDATES` to protect stability.
  - **Status Line**: preview, install, and customize the Claude Code status line.
- **Integrated Launchers** — launch Claude Code, Codex, or opencode terminal sessions with active environment variables pre-configured.
- **Bilingual Interface** — complete Russian and English (RU / EN) localization.

---

## 💻 Running from Source

Requirements: Python 3.10+ (64-bit on Windows).

```bash
# Clone the repository
git clone https://github.com/Glebsky/Claude-Code-Manager.git
cd Claude-Code-Manager

# Install dependencies
pip install PySide6

# Run the manager
python claude_code_manager/claude_code_manager.pyw
```

### Building the Executable

To compile a standalone `.exe`:

```bash
pip install pyinstaller
build.bat
```

The resulting `ClaudeCodeManager.exe` will be located in the `claude_code_manager/dist/` directory.

---

## 📄 License

This project is licensed under the [GNU General Public License v3 (GPLv3)](LICENSE).
