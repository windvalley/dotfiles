# dotfiles

![macOS](https://img.shields.io/badge/macOS-000000?style=flat&logo=apple&logoColor=white)
[![Ghostty](https://img.shields.io/badge/Ghostty-212121.svg?logo=ghostty&logoColor=white)](https://ghostty.org/)
[![Zellij](https://img.shields.io/badge/Zellij-FF9800.svg)](https://zellij.dev/)
[![Fish](https://img.shields.io/badge/Fish-4E5B3D.svg?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Helix](https://img.shields.io/badge/Helix-5A5D7A.svg?logo=helix&logoColor=white)](https://helix-editor.com/)
[![Mise](https://img.shields.io/badge/Mise-3e1e5b.svg)](https://mise.jdx.dev/)
[![Stow](https://img.shields.io/badge/Stow-005090.svg?logo=gnu&logoColor=white)](https://www.gnu.org/software/stow/)
[![CI](https://github.com/windvalley/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/windvalley/dotfiles/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/windvalley/dotfiles)](https://github.com/windvalley/dotfiles/blob/main/LICENSE)

[中文](README.md) | [English](README.en.md)

This project is a **modern, efficient, and out-of-the-box** macOS terminal development environment. All configurations are version-controlled centrally and deployed with GNU Stow in one shot.

Core stack: Ghostty (terminal) + Zellij (multiplexer) + Fish (shell) + Helix (editor) + Mise (version manager) + AIChat (terminal AI assistant), with a unified visual and interaction style across the entire stack.

**Core design principles:**
1. **Configuration as Code**: All configs are tracked by Git and managed through Stow symlinks, enabling idempotent one-shot resets.
2. **Terminal as Container**: The terminal is only the rendering container (Ghostty). Session and layout orchestration is unified in the multiplexer (Zellij), while code editing is handled by an out-of-the-box modern editor (Helix), eliminating the mental burden of piecing together plugins.
3. **Environment as Sandbox**: No more global pollution or chaotic multi-version managers. A single foundation declares all language sandboxes in one place (Mise).
4. **Comments as Documentation**: Every config file in this project is the most detailed manual itself, with deep Chinese comments, design trade-offs, and best-practice guidance.
5. **AI-Driven Productivity**: Large-model capabilities are built directly into the CLI and common workflows, making the terminal environment AI-native.

> [!NOTE]
> These dotfiles are macOS-only, incompatible with Linux or Windows (WSL), and there are no plans for cross-platform adaptation.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [0. TL;DR (Quick Start)](#0-tldr-quick-start)
- [1. Project Structure](#1-project-structure)
- [2. AI Capabilities](#2-ai-capabilities)
- [3. Installation](#3-installation)
  - [3.1 One-Shot Install (Recommended)](#31-one-shot-install-recommended)
  - [3.2 Manual Installation (Optional)](#32-manual-installation-optional)
  - [3.3 Uninstallation & Recovery Guide](#33-uninstallation--recovery-guide)
- [4. Configuration Guide](#4-configuration-guide)
  - [4.1 Configure Fish](#41-configure-fish)
  - [4.2 Migrate from Zsh](#42-migrate-from-zsh)
  - [4.3 Local Private Configurations (Not Committed)](#43-local-private-configurations-not-committed)
  - [4.4 Configure Fisher](#44-configure-fisher)
  - [4.5 Configure Tide](#45-configure-tide)
  - [4.6 macOS System Preferences (`macos.sh`) (Optional)](#46-macos-system-preferences-macossh-optional)
  - [4.7 Configure Git](#47-configure-git)
  - [4.8 Configure AIChat](#48-configure-aichat)
- [5. Usage](#5-usage)
  - [5.1 Ghostty Terminal](#51-ghostty-terminal)
  - [5.2 Zellij Terminal Multiplexer](#52-zellij-terminal-multiplexer)
  - [5.3 Fish Shell](#53-fish-shell)
  - [5.4 Helix Editor](#54-helix-editor)
  - [5.5 Mise Tool Version Management](#55-mise-tool-version-management)
  - [5.6 Git Configuration Usage](#56-git-configuration-usage)
  - [5.7 Stow Usage Notes](#57-stow-usage-notes)
  - [5.8 Custom Commands (`bin/`)](#58-custom-commands-bin)
  - [5.9 OrbStack (Optional)](#59-orbstack-optional)
- [6. Key Differences from Official Defaults](#6-key-differences-from-official-defaults)
  - [6.1 Karabiner Global Key Remapping](#61-karabiner-global-key-remapping)
  - [6.2 Ghostty Terminal Behavior and Keybindings](#62-ghostty-terminal-behavior-and-keybindings)
  - [6.3 Zellij Shortcuts and Session Architecture](#63-zellij-shortcuts-and-session-architecture)
  - [6.4 Fish Shell Behavior and Keybindings](#64-fish-shell-behavior-and-keybindings)
  - [6.5 Helix Editor Keybindings and Display](#65-helix-editor-keybindings-and-display)
  - [6.6 Git Workflow Enhancements](#66-git-workflow-enhancements)
- [7. Common Maintenance Commands (Makefile)](#7-common-maintenance-commands-makefile)
- [8. FAQ / Troubleshooting](#8-faq--troubleshooting)
- [9. Acknowledgments](#9-acknowledgments)
- [10. License](#10-license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 0. TL;DR (Quick Start)

The simplest approach is to use the one-shot bootstrap installer, which is **designed specifically for first-time setup**:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/windvalley/dotfiles/main/bootstrap.sh)"
```

> [!NOTE]
> If the target directory `~/dotfiles` already exists, the script exits proactively for safety.
> If you want to reinstall, it is recommended to move the old directory away first as a backup (or delete it if you prefer): `mv ~/dotfiles ~/dotfiles.bak`
> To install into another location, specify an environment variable: `export DOTFILES_DIR=~/custom_path; curl ... | bash`

This script automatically installs Homebrew (if missing), Ghostty, Fish, Zellij, Helix, Mise, and Stow, then links configs and initializes Fish Shell.

> [!TIP]
> If `~/dotfiles` is already cloned locally, you can safely run `./install.sh` inside it multiple times. It is idempotent and commonly used to update dependencies or repair symlinks.
> If you want precise manual control, refer to the detailed steps below.

## 1. Project Structure

This repository contains the following config packages and core files:

- `ghostty/`: [Ghostty](https://ghostty.org/) (/ˈɡoʊs.ti/, Ghost + ty) terminal config (modern, fast, GPU-accelerated)
- `fish/`: [Fish](https://fishshell.com/) (/fɪʃ/, **F**riendly **I**nteractive **SH**ell) shell config (friendly, interactive, ready out of the box)
- `zellij/`: [Zellij](https://zellij.dev/) (/ˈzɛl.ɪdʒ/, from Arabic mosaic tile art) terminal multiplexer config (easy to configure, multi-layout support)
- `helix/`: [Helix](https://helix-editor.com/) (/ˈhiː.lɪks/, helix) modern modal editor config (Rust-based, ultra-responsive, built-in LSP support)
- `karabiner/`: [Karabiner-Elements](https://karabiner-elements.pqrs.org/) (/ˌkær.əˈbiː.nər/, German for carabiner) keyboard mapping (swaps Caps Lock and Left Control)
- `git/`: Git base configuration (includes high-frequency aliases, Delta modern diff styling, global ignores, and a multi-account isolation architecture)
- `mise/`: [Mise](https://mise.jdx.dev/) (/miːz/, from French mise en place) tool version manager config (Unified management of Go, Node, Python, and Rust runtimes along with LSPs)
- `aichat/`: [AIChat](https://github.com/sigoden/aichat) terminal AI client (Integrates multiple models, command generation/troubleshooting, and workflow enhancements)
- `bat/`: [bat](https://github.com/sharkdp/bat) custom theme assets for the syntax-highlighting pager, used by `colorscheme` to keep Bat / Delta syntect themes in sync.
- `btop/`: [btop](https://github.com/aristocratos/btop) modern system resource monitoring config.
- `bin/`: High-frequency custom scripts (includes the `zj` project launcher, `gdoctor` diagnostic tool, `aic/aipr` AI-enhancement tools, etc., automatically linked to `~/.local/bin`)
- `local/`: Private local config templates (for Fish environment variable redaction, Git multi-account isolation, and private Ghostty config)
- `Makefile`: Automation for build and maintenance tasks
- `.editorconfig`: Cross-editor formatting rules. It includes strict formatting controls such as indentation mode, forced LF line endings, and final newline protection to keep the codebase clean and avoid cross-platform/editor formatting issues.

## 2. AI Capabilities

This project consolidates AI large-model capabilities into the **command-line editing area**, **Git workflow**, and **daily productivity tools**, forming a unified entry point and reusable toolchain rather than scattered aliases. The foundation is [AIChat](https://github.com/sigoden/aichat), supporting mainstream models such as OpenAI, Claude, Gemini, Tongyi Qianwen, Zhipu, and Moonshot, and also local models through Ollama.

**Command-line agent:**

| Entry | Function | Description |
|------|------|------|
| `Ctrl+y` | Command explanation | Press after typing a command; explanation is shown through bat pagination and is never executed |
| `# <description>` + `Ctrl+y` | Command generation | Describe intent in natural language, generate multiple candidate commands, pick one with fzf, and write it back to the command line |
| `?` | Quick generation | Send natural language directly to `aichat -e` to generate an executable command |
| `??` | Troubleshooting | Automatically captures the last failed command plus terminal output, sends them to AI for diagnosis, and returns repair suggestions (depends on Zellij dump-screen) |

**Git workflow:**

| Command | Function | Description |
|------|------|------|
| `aic` | Commit message | Analyzes the staged diff and generates Conventional Commits style messages, with rewrite/refine/Chinese-English switching support |
| `aipr` | PR description | Compares branch diffs and generates a structured PR description, which can be copied to the clipboard or used to create a PR directly via `gh` |
| `ait` | Release notes | Analyzes commits since the last tag, generates a version number and `CHANGELOG.md`, commits it, and creates a tag automatically |

**Daily productivity:**

| Command | Function | Description |
|------|------|------|
| `t <text>` | Smart translation | Auto-detects input type: English word → dictionary definition (phonetics + bilingual explanation); Chinese phrase → English candidates; paragraph → two-way translation |
| `aip` | Prompt library | Interactively selects commonly used AI programming prompts, supports multi-select with fzf plus filtering by number/keyword, and copies the result to the clipboard automatically |

**Configuration**: Set your model and API key in `~/.config/fish/config.local.fish`. See [4.8 Configure AIChat](#48-configure-aichat).

## 3. Installation

### 3.1 One-Shot Install (Recommended)

The repository root provides an `install.sh` script that automates almost the entire installation and configuration process.

**The script performs the following:**
1. **Environment preparation**: Checks for and installs **Homebrew** automatically if it is not already installed.
2. **Core dependencies**: Reads `Brewfile` and installs all CLI tools (stow, zellij, fish, helix, mise, fzf, chafa, etc.) and GUI apps (Ghostty, OrbStack, Maccy, JetBrains Mono font, etc.).
3. **Font installation**: JetBrains Mono is installed through Brew by default, and the script **asks whether to install** other extended fonts (Maple Mono, Geist Mono).
4. **Symlink setup**: Detects existing configs, backs them up automatically, then uses `stow` to symlink all configs, including the `bin` scripts, into the correct system locations.
5. **AI model sync**: Automatically runs `aichat --sync-models` to synchronize the default model catalog into the local index.
6. **Local model backend (optional)**: In interactive installs, the script **asks whether to install and start** `Ollama`; in non-interactive mode it is skipped by default unless you pass `--with-ollama`. The script does not pull any local model automatically.
7. **Runtime installation**: Installs core language runtimes via **Mise** (Go, Node, Bun, Python, Rust) along with out-of-the-box CLI tools (gh, bat, eza, fd, ripgrep, glow, shellcheck, etc.). LSP and other toolchains can be installed on demand later.
8. **Privacy template setup**: Automatically creates Git identity templates (`.gitconfig.local` / `.work`), private environment variable templates (`config.local.fish`), and a Ghostty private config template (`config.local`) in the user's home directory.
9. **Shell initialization**: Sets **Fish** as the default shell and **automatically migrates PATH variables from your old Zsh setup** into Fish.
10. **Plugin setup**: Installs the **Fisher** plugin manager and syncs all Fish plugins.
11. **System optimization**: Prompts whether to apply **common macOS system preference tweaks** via `macos.sh`.

**Usage:**
```sh
cd "$HOME/dotfiles"
./install.sh
```

> [!TIP]
> **Non-interactive mode**: In automation environments such as CI/CD, append `-y` or `--unattended` to skip all confirmations and install automatically: `./install.sh -y`
>
> If you also want the local-model backend in non-interactive mode, append `--with-ollama`: `./install.sh -y --with-ollama`
>
> If the current session does not have reusable `sudo` credentials, `karabiner-elements` will be skipped automatically in `-y` mode so Homebrew does not block on a password prompt. You can install it later from an interactive shell with `brew install --cask karabiner-elements`

**Installation notes:**
- If Homebrew is missing, the script **asks whether to install it**.
- If you prefer to install Homebrew manually, visit https://brew.sh
- The script automatically detects and migrates your Zsh PATH setup into Fish.

---

### 3.2 Manual Installation (Optional)

If you prefer to do everything manually, follow this order:

#### 3.2.1 Install Dependencies

```sh
# Symlink manager
brew install stow

# Terminal
brew install --cask ghostty@tip

# Multi-pane/session management
brew install zellij

# Interactive shell
brew install fish

# Text editor (replacing vim/neovim)
brew install helix

# Tool version manager
brew install mise

# Git beautifier (syntax-highlighted diffs)
brew install git-delta

# Terminal AI all-in-one assistant (LLM integration + shell assistance)
brew install aichat

# Modern cross-platform system resource monitor
brew install btop

# Clipboard history manager
brew install --cask maccy

# Global key remapping tool
brew install --cask karabiner-elements

# Fonts
brew install --cask font-jetbrains-mono-nerd-font

# Common tools
brew install fzf zoxide grc gawk gnu-sed grep chafa

# Volume control
brew install switchaudio-osx
```

**Notes:**
- `aichat`: A native terminal client for large language models, supporting multimodal and local/cloud models. This config provides `Ctrl+y` for one-key command explanation/generation. A leading `#` means “describe intent -> generate command”.
- `zoxide`: Smart directory jumping, a modern replacement for `cd`. Usage: `z <keyword>` to jump directly, `zi <keyword>` for interactive selection (requires `fzf`).
- `gnu-sed`: Provides `gsed`, used by scripts such as `colorscheme`, `font-size`, and `opacity`.
- `switchaudio-osx`: Provides `SwitchAudioSource`, used by `audio-volume`.
- `grc`: Generic Colouriser. Combined with Fish plugins, it adds colored output enhancements to commands like `ping`, `ls`, `docker`, and `diff`.
- `chafa`: Terminal character image rendering utility, used for high-res image previews in the `p` (clipboard history) command.

#### 3.2.2 Clone the Repository

```sh
git clone --depth=1 https://github.com/windvalley/dotfiles.git "$HOME/dotfiles"

# Update later
cd "$HOME/dotfiles"
git pull --rebase
```

#### 3.2.3 Link Configurations (`stow`)

> [!TIP]
> If `make` is already installed, you can use `make stow` for routine resyncs. For first-time setup, or when real directories already exist under `~/.config/*`, prefer `install.sh` because its backup and migration safeguards are more complete.

If you still want to link configs manually, and want Stow to create clean **directory-level symlinks** for GUI apps such as Btop and Karabiner as well as tools with extensible config directories, you need to defensively clean the target config directories first:

```sh
# If a target config directory already exists as a real directory (not a symlink),
# you must rename or remove it. Do not keep it in place.
# Goal: make stow see the target directory as “missing”, so it maps the whole
# directory as a pure directory-level symlink.
# Otherwise stow will descend into the real directory and create file-level symlinks,
# causing newly generated local files to drift out of version control.
for pkg in ghostty helix zellij mise karabiner bat btop fish git aichat; do
    if [ -d ~/.config/$pkg ] && [ ! -L ~/.config/$pkg ]; then
        mv ~/.config/$pkg ~/.config/$pkg.bak
    elif [ -L ~/.config/$pkg ]; then
        unlink ~/.config/$pkg
    fi
done
```

Then apply all symlink mappings in one shot:

```sh
cd "$HOME/dotfiles"

# Link all standard config packages that follow XDG and map into ~/.config/
stow --restow --target="$HOME" --dir="$HOME/dotfiles" --dotfiles ghostty helix zellij mise karabiner bat btop fish git aichat

# Link packages that require a special target structure
# (for example, custom commands placed under ~/.local/bin)
mkdir -p "$HOME/.local/bin"
stow --restow --target="$HOME/.local/bin" --dir="$HOME/dotfiles" bin
```

#### 3.2.4 Install Runtimes and CLI Tools (Mise)

Once configurations are linked, use `mise` to automatically fetch all configured toolchains:

```sh
# Automatically reads ~/.config/mise/config.toml and installs all tools
mise install
```

### 3.3 Uninstallation & Recovery Guide

If you find that this configuration doesn't suit your habits after trying it out, you can safely uninstall and explicitly revert your system to its default state through the following steps:

1. **Remove all symlinks**:
   ```sh
   cd ~/dotfiles
   make unstow
   ```
2. **Restore your system default Shell** (e.g., reverting to zsh):
   ```sh
   chsh -s /bin/zsh
   ```
3. **Restore your backed-up configurations**:
   When you initially ran `install.sh`, the script automatically renamed your existing configuration directories to `*.bak` (e.g., `~/.config/fish.bak`). You can locate these directories, remove the `.bak` suffix, and overwrite the symlink to restore them to their original state.

---

## 4. Configuration Guide

### 4.1 Configure Fish

Set Fish as the default shell:

```sh
which fish | sudo tee -a /etc/shells
chsh -s $(which fish)
```

After restarting the terminal (or running `exec fish -l`), execute the following inside Fish:

```fish
# Verify the shell switch
echo $SHELL

# Let Fish discover Homebrew-installed programs
fish_add_path (brew --prefix)/bin

# Generate completions automatically from man pages
fish_update_completions

# Theme (affects syntax highlighting only, not the prompt; Tide controls the prompt)
fish_config theme choose dracula
```

### 4.2 Migrate from Zsh

> [!IMPORTANT]
> After switching from Zsh to Fish, PATH entries from Zsh config files such as `~/.zshrc` and `~/.zprofile` are not inherited automatically. That can make installed commands suddenly disappear from your shell.

**Automatic migration (recommended)**: `install.sh` automatically detects your Zsh PATH entries and adds any missing paths into Fish, so no manual steps are needed.

**Manual migration**: If you want to add paths by hand, use `fish_add_path`:

```fish
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
```

> [!TIP]
> `fish_add_path` is persistent because it writes to universal variables. You only need to run it once.
> Use `printf '%s\n' $PATH` to inspect the current path list.

### 4.3 Local Private Configurations (Not Committed)

In real-world use, we often need environment variables that are **machine-specific** or **sensitive**, such as `OPENAI_API_KEY`, internal company proxies, or aliases for a specific machine.

To prevent those values from being tracked by Git and leaked into a public repository, this dotfiles setup already includes a local isolation mechanism:

#### Fish Shell Local Config

1. Copy the example template from this repository to the target location and remove the `.example` suffix:
   ```fish
   cp ~/dotfiles/local/config.local.fish.example ~/.config/fish/config.local.fish
   ```
2. Put all your private settings into the newly created file. The model name, API key, and command below are placeholders only, so replace them with your own values and never commit real credentials back to the repository:
   ```fish
   # ~/.config/fish/config.local.fish
   # set -gx AICHAT_MODEL "gemini:gemini-3-flash-preview"
   # set -gx OPENAI_API_KEY "sk-xxxxxxxxx"
   # abbr -a -g work-vpn "sudo launchctl restart com.corp.vpn"
   ```

#### Ghostty Local Config

1. Copy the example template from this repository to the target location and remove the `.example` suffix:
   ```bash
   cp ~/dotfiles/local/ghostty.config.local.example ~/.config/ghostty/config.local
   ```
2. Add your private or machine-specific config in the new file, such as keybindings or fonts:
   ```ini
   # ~/.config/ghostty/config.local
   # Example: press ctrl+backspace to auto-type placeholder text and hit Enter
   keybind = ctrl+backspace=text:<your-secret>\r
   ```

#### Git Local multi-account isolation

This project's Git configuration adopts a "base + local override" pattern, supporting multiple identities through the `include` directive without polluting the main repository:

1. **Set your personal global identity**:
   ```bash
   cp ~/dotfiles/local/dot-gitconfig.local.example ~/.gitconfig.local
   # Edit ~/.gitconfig.local and fill in your common Name and Email
   ```
2. **Set a separate work/directory identity** (optional):
   ```bash
   cp ~/dotfiles/local/dot-gitconfig.work.example ~/.gitconfig.work
   # Edit ~/.gitconfig.work and fill in your company email; this config only applies to repositories inside ~/work/
   ```

> [!NOTE]
> `config.local.fish` and all `*.local` files are ignored by `.gitignore`. You can safely use them locally without worrying about accidentally `git push`-ing them after Stow symlinks them into place.

### 4.4 Configure Fisher

Fisher is the Fish plugin manager.
By setting `fisher_path` in `config.fish`, all plugin-related files are **fully isolated** under `~/.local/share/fisher`, preventing `~/.config/fish` from being polluted.

```fish
# Important: clear the fisher_path directory before installation to avoid conflicts
rm -rf ~/.local/share/fisher

# Install Fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

# Install plugins (synced from the dotfiles plugin list)
fisher install (cat ~/.config/fish/fish_plugins)
```

For more, see `fish/dot-config/fish/README.md`.

### 4.5 Configure Tide

Tide is the Fish prompt plugin.

```fish
# One-shot automated configuration
tide configure --auto \
--style=Lean \
--prompt_colors='16 colors' \
--show_time='24-hour format' \
--lean_prompt_height='Two lines' \
--prompt_connection=Disconnected \
--prompt_spacing=Compact \
--icons='Many icons' \
--transient=Yes

# Or configure it interactively according to personal preference
tide configure
```

### 4.6 macOS System Preferences (`macos.sh`) (Optional)

The repository root includes a `macos.sh` script that uses `defaults write` to apply deep system preferences commonly preferred by developers.

- **Keyboard experience**: Sets a very fast key repeat rate and disables “press and hold for special characters”.
- **Finder**: Shows all filename extensions, status bar, and path bar; keeps folders on top when sorting by name; disables `.DS_Store` creation on network and USB drives.
- **Trackpad / mouse**: Enables tap-to-click.
- **Dock**: Enables auto-hide and hides recent applications.

You can apply or reapply these preferences at any time with:

```bash
make macos
# or ./macos.sh
```

> [!WARNING]
> This script reflects strong personal preferences for system settings.
> **It is strongly recommended that you open `macos.sh` and skim the source with its detailed inline comments before executing it**. You can easily comment out any `defaults write` command that does not match your habits.

### 4.7 Configure Git

**1. Configure user identity and multi-account isolation (Local Overrides)**

To prevent mixing personal and work email addresses or leaking identity information accidentally, the repository's `~/.config/git/config` **removes hardcoded user identity** and adopts an `include`-based isolation mechanism.

**Set your personal global identity (required):**
Create a Git-ignored local config file in your home directory. You can copy the template directly and edit it:
```bash
cp ~/dotfiles/local/dot-gitconfig.local.example ~/.gitconfig.local
# Then edit ~/.gitconfig.local and fill in your personal information
```

**Set a separate work identity (optional):**
If one machine also handles company code, and all work repositories live under `~/work/` and its subdirectories, copy the template as a dedicated work config:
```bash
cp ~/dotfiles/local/dot-gitconfig.work.example ~/.gitconfig.work
# Then edit ~/.gitconfig.work and fill in your company email
```
Whenever you `git commit` inside that directory, Git uses the `includeIf "gitdir:~/work/"` condition in the config to switch to your work identity automatically, completely preventing identity mistakes.

**2. Custom global ignore file**

The repository already includes a generic `~/.config/git/ignore` (Git XDG standard location, auto-discovered). If you have your own global ignore rules, such as IDE files or temporary files, edit it directly:

```bash
# Add your own global ignore rule (for example, ignore all .log files)
echo "*.log" >> ~/.config/git/ignore
```

> [!TIP]
> The change above updates `~/dotfiles/git/dot-config/git/ignore` directly. It is recommended to commit those changes into your own dotfiles repository.

### 4.8 Configure AIChat

This project already includes an AIChat config package. After Stow, it maps to `~/.config/aichat/config.yaml`.

**1. Config file locations and responsibilities**

- Repository source: `~/dotfiles/aichat/dot-config/aichat/config.yaml`
- Active path: `~/.config/aichat/config.yaml`
- Responsibility boundary:
  - `config.yaml` controls behavior strategy such as `stream`, `function_calling`, `save_session`, and `keybindings`
  - `install.sh` automatically runs `aichat --sync-models` after Stow, so models referenced by the default config are available in the local catalog and do not fail with “model not found” errors
  - API keys and model overrides should be injected through Fish local private files whenever possible, to avoid storing secrets in the repo

**2. Inject model and secret locally through a private file (recommended)**

```fish
# ~/.config/fish/config.local.fish
# Provider prefix examples: claude: / qianwen: / zhipuai: / moonshot: / openai: / gemini: / local-llm:
set -gx AICHAT_MODEL "gemini:gemini-3-flash-preview"
set -gx GEMINI_API_KEY "YOUR_API_KEY_HERE"
```

> [!IMPORTANT]
> Do not write any API key directly into `aichat/dot-config/aichat/config.yaml` in the repository. Secrets belong only in `~/.config/fish/config.local.fish`.

**3. Use Ollama as the local backend (optional)**

This repository exposes Ollama as the `local-llm:` provider while still routing everything through `aichat`, so workflows such as `?`, `??`, `aic`, `aipr`, and `ait` do not need a separate command path.

```bash
# In interactive installs the script asks whether to enable Ollama;
# for unattended installs, turn it on explicitly:
./install.sh -y --with-ollama

# If you prefer to install it manually instead:
brew install ollama
brew services start ollama

# After installation, pull a local model when you actually need one
ollama pull llama3.2
```

```fish
# ~/.config/fish/config.local.fish
# Local Ollama does not require an API key
set -gx AICHAT_MODEL "local-llm:llama3.2"
```

If you pull a different model, run `ollama list` first to get the exact name. If that model is not included in the repository's built-in `local-llm.models` list, append it to `~/.config/aichat/config.yaml` using the same format.

**4. Verify that the configuration is active**

```fish
# Reload Fish environment variables
exec fish

# Check AIChat directories and data isolation paths
# (set centrally by fish/config.fish)
aichat --info

# Refresh the official model catalog manually
aichat --sync-models

# Inspect the model list
aichat --list-models

# If you use local Ollama, also verify the local service and pulled models
ollama list

# Check whether it works
aichat hi
```

## 5. Usage

### 5.1 Ghostty Terminal

**Config file**: `~/.config/ghostty/config`

**Note**: Native tabs are disabled and managed uniformly by Zellij, while multiple windows remain available.

**Shortcuts**:
| Shortcut | Function |
|--------|------|
| `Cmd + Shift + ,` | Reload config after editing |
| `Cmd + ;` | Open Quick Terminal (custom shortcut) |
| `Cmd + n` | Open a new window (plain Fish terminal, skips Zellij auto-start) |

> [!NOTE]
> It is recommended to use Zellij tabs and panes instead of Ghostty's native tabs and splits, so you get more flexible layout control and cross-session persistence.

---

### 5.2 Zellij Terminal Multiplexer

**Config file**: `~/.config/zellij/config.kdl`

**Auto-start**: This setup integrates Zellij auto-start logic directly in Ghostty (via `initial-command`). Opening the **first** terminal window automatically starts or attaches to a Zellij session. If Zellij is not installed, it automatically falls back to a plain Fish terminal. Any additional terminal windows opened via `Cmd + n` will remain as plain Fish terminals and will not trigger the auto-attach logic again, giving you the flexibility to use a raw shell when needed.

**Mode system**: Zellij has multiple modes. Press `Ctrl + p/t/n/h/s/o/a` to enter the corresponding mode directly. Press `Ctrl + g` to enter locked mode, which disables all shortcuts.

**Common shortcuts**:

| Shortcut | Function |
|--------|------|
| `Ctrl + g` | Enter/exit locked mode (disable all shortcuts) |
| `Ctrl + p` | Enter pane mode |
| `Ctrl + t` | Enter tab mode |
| `Ctrl + n` | Enter resize mode |
| `Ctrl + h` | Enter move mode |
| `Ctrl + s` | Enter scroll mode |
| `Ctrl + o` | Enter session mode |
| `Ctrl + a` | Enter TMUX compatibility mode |

**Pane mode (`Ctrl + p`)**:
| Shortcut | Function |
|--------|------|
| `h/j/k/l` | Switch panes in Vim style |
| `d` | Split pane downward |
| `r` | Split pane right |
| `n` | Create a new pane |
| `x` | Close the current pane |
| `f` | Toggle fullscreen |

**Tab mode (`Ctrl + t`)**:
| Shortcut | Function |
|--------|------|
| `n` | Create a new tab |
| `x` | Close the current tab |
| `1-9` | Switch to a specific tab |
| `h/k` | Previous tab |
| `l/j` | Next tab |

**Resize mode (`Ctrl + n`)**:
| Shortcut | Function |
|--------|------|
| `h/j/k/l` | Increase pane size in the corresponding direction |
| `H/J/K/L` | Decrease pane size in the corresponding direction |
| `+/-` | Scale up/down proportionally |

**Global shortcuts (no need to enter a mode)**:
| Shortcut | Function |
|--------|------|
| `Cmd + 1-9` | Switch to a specific tab |

**Layout**:
- **Default layout**: `dev-workspace` (defined at `~/.config/zellij/layouts/dev-workspace.kdl`)
- **Built-in language-specific layouts**: Includes specialized workspace layouts such as `layout-go`, `layout-rust`, `layout-python`, `layout-node`, `layout-cpp`, and `layout-fullstack`, providing out-of-the-box tailored pane splits and functional tabs.
- **Smart Launcher**: Use the custom `zj` command to launch Zellij from any directory. It auto-detects the project structure and smartly selects a tailored layout. The command is **terminal-aware**: in a **bare terminal**, it starts directly; if run from **inside an active Zellij session**, it automatically **opens a new Ghostty window** via AppleScript to create or reattach to the session, elegantly avoiding nesting restrictions. Multiple Ghostty windows/sessions created this way can be quickly toggled using the `Ctrl + \`` shortcut.
- **Load layout manually**: `zellij --layout <layout_name>` (e.g., `zellij --layout layout-go`)

---

### 5.3 Fish Shell

**Config file**: `~/.config/fish/config.fish`

**Common Fish commands**:
| Command | Function |
|------|------|
| `fish_update_completions` | Update command completions |
| `fish_add_path <path>` | Add a path |
| `fish_config` | Open interactive configuration |

**Custom functions** (type `c` to list functions, `a` to list abbreviations):

| Command | Function |
|------|------|
| `c` | **Meta command**: list all custom Fish functions with descriptions |
| `a` | **Meta command**: list all built-in abbreviations and what they do |
| `d` | Quickly display current date and time |
| `nh <cmd>` | Run a command in the background and discard output (short for `nohup`) |
| `ch <cmd>` | Query cheat.sh for quick command help |
| `wt [city]` | Show a detailed 15-day weather forecast table including PM2.5 / air quality. Supports `all` for parallel summaries of multiple cities |
| `lunar [date]` | Perpetual calendar: Gregorian date + lunar date + zodiac + Heavenly Stems / Earthly Branches (supports specific dates such as `2025-01-29`) |
| `myip` | Show local IP, public IP, and geolocation |
| `port <num>` | Inspect local TCP/UDP listeners and processes for a specific port |
| `ports` | Show all local listening TCP ports and processes |
| `extract <file>` | Universal extractor that auto-detects archive formats (zip, tar, gz, rar, 7z...) |
| `mkcd <dir>` | Create a directory and `cd` into it immediately |
| `proxy` / `unproxy` | Enable/disable global terminal proxy with one command (helpful when pulling code is slow) |
| `gitignore <language>` | Fetch a standard `.gitignore` from GitHub templates (example: `gitignore Node`) |
| `backup <file/dir>` | Create a full backup copy of a sensitive file or directory with an exact timestamp |
| `copy [file]` | Copy a file's contents or the previous command's stdout (`\| copy`) to the macOS clipboard instantly |
| `f [query]` | Search for a file and open it with Helix. Opens directly if the query matches a single result |
| `t <text>` | Smart translation / explanation: Chinese to English; English words return US phonetics plus bilingual definitions; English passages are translated into Chinese |
| `aic` | Auto-generate Git commit messages from code changes. Built on `aichat`, with rewrite/refine support |
| `aipr` | Auto-generate Pull Request descriptions from branch changes. Uses a large model to analyze commits and diff |
| `ait` | Auto-generate a changelog from Git history and create a tag |
| `aip` | Plug-and-play AI prompt library. Interactively pick common development prompts and copy them to the clipboard automatically |
| `b [query]` | Search for a file and preview it with bat. Opens directly if the query matches a single result |
| `p [query]` | Preview and search macOS clipboard history via fzf, with native terminal image and text rendering. Auto-copies if the query matches a single result (depends on Maccy and chafa) |
| `s [query]` | Parse hosts from `~/.ssh/config`, choose one via fzf, then establish the SSH connection |
| `rec [name]` | Minimal terminal screencast tool based on asciinema, supporting record, replay (`rec play`), and web upload (`rec upload`) |
| `gtd <tag>` | Delete a Git tag locally and remotely in one command |
| `gdoctor` | Git repository health diagnostic tool: detects interrupted operations, working tree status, remote sync, stale branches, loose objects, and data integrity, with actionable fix suggestions |
| `lg` | Launch `lazygit` terminal UI |
| `zj` | Smart project-aware Zellij launcher. Unified behavior to "prepare a session for the current directory". Automatically opens a new window if run inside Zellij to avoid nesting conflicts |

> [!TIP]
> **FZF Performance Boost**: This project integrates `fd` as the default search backend for `fzf`. This means interactive commands like `zi` are not only lightning fast but also automatically respect `.gitignore` rules.

> [!TIP]
> In non-terminal environments (e.g., browsers, messaging apps, IDEs), you can use Maccy's global shortcut `Cmd + Shift + C` to open the clipboard selection panel directly, without entering the terminal. The `p` command is an enhanced TUI version designed specifically for terminal power users.

**Built-in Abbreviations**:

Abbreviations **expand automatically** when you press space after typing them.

| Abbreviation | Expands to | Meaning |
|------|--------|----------|
| `mkdir` | `mkdir -p` | Recursively create nested directories, including missing parents |
| `ls` / `ll` | `eza` / `eza -l` | Modern file listing / with detailed permissions and sizes |
| `...` / `....` | `../..` / `../../..` | Jump up two or three parent directories quickly |
| `vi` / `vim` / `h` | `hx` | Always launch the modern Helix editor |
| `cs`... | `colorscheme`... | See the custom commands `colorscheme` / `font-size` / `opacity` / `audio-volume` |
| `?` / `??` | `aichat -e` / `ai_diag_last` | Natural-language to command generation / diagnose the previous failed command (depends on Zellij dump-screen capture) |
| `g` | `git` | Entry point for basic Git commands |
| `lg` | `lazygit` | Launch `lazygit` terminal UI |
| `ga` / `gs` | `git add` / `git_status_stats` | Stage files / show status with staged and unstaged line-count stats |
| `gd` / `gds` | `git diff` / `git diff --staged` | Show unstaged changes / show staged but uncommitted changes |
| `gb` / `gba` / `gbd` | `git branch`... | Show local branches / show all branches including remotes / force-delete a branch |
| `gc` / `gca` | `git commit` / `git commit --amend` | Commit code / amend the last commit |
| `gcm` / `gcam` | `git commit -m` / `git commit -a -m` | Commit with a message / stage tracked files and commit with a message |
| `gp` / `gpl` | `git push` / `git pull` | Push code to remote / pull from remote |
| `gm` / `gms` | `git merge` / `git merge --squash` | Merge branches / squash a whole branch into a single change |
| `grb` / `grbc` / `grbi` | `git rebase`... | Rebase a branch / continue after resolving conflicts / interactive rebase for picking or squashing commits |
| `gco` / `gcl` | `git checkout` / `git clean -fd` | Check out a branch or file (legacy style) / remove untracked files and directories (dangerous, confirm before using) |
| `gsw` / `gswc` | `git switch` / `git switch -c` | Switch branches / create and switch to a new branch (recommended modern workflow) |
| `gr` / `grh` | `git reset` / `git reset HEAD` | Reset index or HEAD / reset only the index (undo `add`) |
| `gro` / `gros` | `git restore`... | Undo working tree changes / undo staged changes (recommended modern reset workflow) |
| `gsta` / `gstp` | `git stash` / `git stash pop` | Stash current uncommitted changes / restore stashed changes |
| `gt` / `gts` | `git tag` / `git tag -s` | Show local tags / create a GPG-signed tag |
| `gg` | `git log` | Show raw Git commit history |
| `gl` | `git log --oneline --decorate --graph` | **High frequency** pretty log with branch graph and colored tree structure |
| `glo` / `gls` | `git log --oneline` / `git log --stat` | Minimal one-line log / log with per-commit file change statistics |

> [!TIP]
> Forgot an abbreviation? Just type **`a`** at any time to list all abbreviations plus their expanded commands and descriptions.

**Vi Mode**:
Fish supports a Vi-style editing mode, and this configuration enables it by default; the shortcuts below are split between normal mode and insert mode.

**Normal Mode**:

Enter Vi normal mode: press `Esc` or `Ctrl+[`.

| Shortcut | Function |
|--------|------|
| `i`/`a` | Enter insert mode (before / after cursor) |
| `h`/`l` | Move cursor left / right |
| `k`/`j` | Previous / next command history item, filtered by current input |
| `w`/`b` | Next / previous word |
| `0`/`$` | Beginning / end of line |
| `d` | Delete with a motion, such as `dw` or `dd` |
| `y` | Yank with a motion, such as `yw` or `yy` |
| `<Space>y` | Explicitly copy the entire current command line to the macOS system clipboard |
| `p` | Paste |
| `u` | Undo |
| `Ctrl+e` | In normal mode, open the current command line in the default editor (`hx`) fullscreen |

**Insert Mode**:

| Shortcut | Function |
|--------|------|
| `Esc` / `Ctrl+[` | Return to Vi normal mode |
| `Ctrl+a` | Jump to the beginning of the line |
| `Ctrl+e` | Jump to the end of the line |
| `Ctrl+f` / `Ctrl+b` | Move cursor right / left |
| `Ctrl+n` / `Ctrl+p` | Next / previous command history item |
| `Ctrl+h` / `Backspace` | Delete the character before the cursor |
| `Ctrl+d` | When the command line has content, deletes the character under the cursor; when empty, triggers a double-tap exit confirmation (press again within 500ms to actually exit, preventing accidental terminal or Zellij pane closure) |
| `Ctrl+u` | Delete from the cursor back to the beginning of the line |
| `Ctrl+k` | Delete from the cursor to the end of the line |
| `Ctrl+w` | Delete the word before the cursor |

---

### 5.4 Helix Editor

**Config file**: `~/.config/helix/config.toml`

**Beginner guide**: [Helix Quick Start Guide (for Neovim users)](helix/dot-config/helix/README.md)

**Modes**: Normal, Insert, Select

**Core shortcuts**:

| Shortcut | Function |
|--------|------|
| `i` | Enter insert mode |
| `Esc` | Return to normal mode |
| `v` | Enter / exit select mode |
| `h/j/k/l` | Left / down / up / right |
| `w/b` | Next / previous word |
| `gg/ge` | Start / end of file |
| `x` | Select current line |
| `y/p` | Copy / paste |
| `u/U` | Undo / redo |
| `/` | Search |
| `n/N` | Next / previous match |
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |

**LSP features**:
| Shortcut | Function |
|--------|------|
| `gd` | Go to definition |
| `gy` | Go to type definition |
| `gr` | Find references |
| `gi` | Go to implementation |
| `Space+k` | Show hover documentation |
| `Space+a` | Code actions |
| `Space+r` | Rename symbol |
| `Space+s` | Document symbol list |
| `Space+S` | Workspace symbol list |
| `Space+d` | Show diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `Space+m` | Markdown preview (Glow) |

**LSP configuration**:
- **Language config**: `~/.config/helix/languages.toml`
- **Health checks**: `hx --health` or `hx --health go`
- **Install LSPs**:
  This project centrally manages language servers through `mise`. See [5.5 Mise Tool Version Management](#55-mise-tool-version-management) for details.
- **Restart LSP**: `:lsp-restart`
- **View config**: `:config-open` opens config, `:config-reload` reloads it

---

### 5.5 Mise Tool Version Management

**Core idea:**
Abandon the traditional mess caused by global installs such as `npm i -g`, `pip install`, and `go install`, which pollute the system and create version conflicts.
This configuration unifies **all runtime stacks (Node/Python/Go)** and **language servers (LSPs)** under Mise management, achieving elegant isolation on two levels:
1. **Global disaster-proof baseline**: The global config (`~/.config/mise/config.toml`) declares **latest (`@latest`) LSP toolchains** for major languages, so opening an editor in any normal directory still gives you strong completion and language intelligence.
2. **Clean project-level sandbox**: Inside a specific project, `mise use` can generate a directory-local `.mise.toml` for precise isolation.
    - **For runtimes**: strongly recommended to pin exact versions such as `node@16` for consistent team builds.
    - **For LSPs**: it is usually recommended to stay on `@latest` for the newest syntax highlighting, hints, and performance optimizations. Only pin older LSP versions when a very old project breaks on the latest release.

**Config file**: `~/.config/mise/config.toml`

> [!NOTE]
> **Special note about certain LSPs**:
> Some lower-level tools have strong platform dependencies or very complex build chains, such as `rust-analyzer` and `clangd`. This configuration **does not manage them via Mise**. Installing them through `brew` is still recommended for the best stability and completion experience:
> - **Rust**: `brew install rust-analyzer`
> - **C/C++**: `brew install llvm` (includes `clangd`)

**Common commands**:
| Command | Function |
|------|------|
| `mise install` | Install all missing tools declared by the current directory's `.mise.toml` or global config |
| `mise ls` | List currently active and installed tool versions |
| `mise ls-remote <tool>` | List all remote versions available for that tool |
| `mise use <tool>@<version>` | **Generate `.mise.toml` in the current project and use a specific version** |
| `mise use -g <tool>@<version>` | Change the global default version |
| `mise current <tool>` | Show the actual active version source (local or global) |
| `mise prune` | Free disk space by removing unused old caches |
| `mise doctor` | Diagnose environment variables and why something may not be taking effect |

**Practical examples**:
```bash
# Query available versions and install
mise ls-remote go
mise use -g go@latest

# Best practice inside a project: pin a runtime, keep the LSP latest
cd my-old-project
mise use node@16
mise use npm:@vtsls/language-server@latest

# Extreme case: the project is so old that the latest LSP breaks parsing,
# so you are forced to pin an older LSP version
cd my-ancient-project
mise use npm:@vtsls/language-server@1.0.0
```

---

### 5.6 Git Configuration Usage

> For Git bootstrap configuration such as user identity and multi-account isolation, see [4.7 Configure Git](#47-configure-git).

**Config files**:
- `~/.config/git/config`: core config (XDG standard location)
- `~/.config/git/ignore`: global ignore file (XDG standard location)

**Core features**:
- **Delta integration**: Uses `git-delta` for syntax-highlighted diffs with line numbers, side-by-side display, and color optimization; `syntax-theme` is managed uniformly by the `colorscheme` script.
- **Smart defaults**:
  - `pull.rebase = true`: keep commit history linear and tidy.
  - `push.autoSetupRemote = true`: associate remote tracking branches automatically.
  - `init.defaultBranch = main`: use `main` as the default branch name.
  - `rerere.enabled = true`: remember conflict resolutions automatically to improve the rebase experience.

**Common aliases**:
| Alias | Command | Description |
|------|------|------|
| `git lg` | `log --graph ...` | Show a pretty commit graph (compact) |
| `git lga` | `log --graph ...` | Show a pretty commit graph (detailed, with time) |
| `git last` | `log -1 HEAD` | Show the latest commit |
| `git cleanup` | `branch --merged \| xargs -n1 branch -d` | Clean up merged local branches |

---

### 5.7 Stow Usage Notes

```sh
# Install or reinstall
#
#  -nv simulate the operation without actually doing it;
#  --restow reinstall by recreating symlinks (delete first, then create);
#  --target specifies the symlink target directory;
#  --dir specifies the dotfiles source directory;
#  --dotfiles converts dot- prefixed package names into hidden files starting with .
#
# Example:
stow -nv --restow --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty

# Uninstall
stow -nv --delete --target=$HOME --dir=$HOME/dotfiles --dotfiles ghostty
```

---

### 5.8 Custom Commands (`bin/`)

These commands appear in `~/.local/bin` after the `bin` package is stowed:

- `colorscheme [name]`: Switch themes for Ghostty, Helix, Zellij, Btop, Bat, and Delta together. Without arguments, it shows the current theme and all available themes. Fourteen presets are built in (`dracula`, `catppuccin`, `catppuccin-latte`, `rose-pine`, `tokyonight`, `gruvbox`, `gruvbox-light`, `kanagawa`, `nord`, `solarized`, `one-dark`, `everforest`, `everforest-light`, `dayfox`); `catppuccin` is mapped consistently to the `Macchiato` variant, `catppuccin-latte` maps to the `Latte` variant, `rose-pine`, `kanagawa`, `one-dark`, `everforest`, `everforest-light`, and `dayfox` all use repo-bundled theme assets for Bat / Delta, `tokyonight` uses a repo-bundled custom syntect theme for Bat plus the official Tokyo Night Delta feature, and the `solarized` preset maps to the corresponding dark Solarized variant for each tool. Additional options include `-i` / `--interactive` (requires `fzf`, starts on the current preset, applies the highlighted theme immediately, and exits on Enter or `Esc`), `--current`, `--list`, and `--help`. **With the Git Clean Filter, switching themes does not dirty the repository.**
- `dot-theme-filter`: **Git internal filter, not for direct execution**. Used with `.gitattributes` to automatically restore theme settings, Ghostty font size, Ghostty background opacity, and other local visual preferences to defaults during `git add`, decoupling those UI choices from tracked config state.
- `font-size <1-200>`: Set Ghostty font size; with the Git Clean Filter this does not dirty the dotfiles repository
- `opacity <0.0-1.0>`: Set Ghostty background opacity; with the Git Clean Filter this does not dirty the dotfiles repository
- `audio-volume`: Volume control and output device switching (requires `switchaudio-osx`)
- `preview-md <file>`: Preview a Markdown file in a floating Zellij pane (requires `glow`)
- `colors-print`: Print the terminal 256-color palette
- `print-256-hex-colors`: Print hexadecimal values for the 256 colors
- `validate-configs [tool|all]`: Validate config syntax and integrity (supports fish/git/zellij/helix/mise/ghostty/karabiner)
- `dot-update`: One-shot aggregated update for all core dependencies, including Homebrew, Mise toolchains, Fisher plugins, and Helix Tree-sitter grammars

> [!TIP]
> **How changes take effect:**
> - `colorscheme`: Zellij updates in real time. If Ghostty is already running, the script now triggers a config reload automatically so the new theme applies immediately; if Ghostty is not running, the theme takes effect the next time Ghostty starts. Helix still requires `:config-reload` for already opened buffers; Btop, Bat, and Delta take effect on the next run. `colorscheme -i` / `--interactive` opens the preset list in `fzf` and switches themes as the cursor focus moves, which is useful for rapid theme previewing. The first switch to a repo-bundled custom syntect theme (currently `tokyonight`, `rose-pine`, `kanagawa`, `one-dark`, `everforest`, `everforest-light`, and `dayfox`) triggers `bat cache --build` automatically; for Delta, `tokyonight` enables the official Tokyo Night feature, while `rose-pine`, `kanagawa`, `one-dark`, `everforest`, `everforest-light`, and `dayfox` enable repo-bundled Delta features. If Ghostty auto-reload fails, press `Cmd + Shift + ,` manually.
> - `font-size` / `opacity`: If Ghostty is already running, the script now triggers a config reload automatically so the new font size or opacity applies immediately; if Ghostty is not running, the change takes effect the next time Ghostty starts. If Ghostty auto-reload fails, press `Cmd + Shift + ,` manually; with the Git Clean Filter, these local visual preferences do not dirty the dotfiles repository.

---

### 5.9 OrbStack (Optional)

**Positioning**: This project installs `OrbStack` through Homebrew and treats it as a lightweight, modern container and Linux development environment on macOS.

**Current boundary**: This repository currently **does not manage** OrbStack GUI preferences, VM parameters, networking, volumes, registry mirrors, or other in-app configuration. It only provides installation and terminal-side compatibility.

**Why it relates to SSH**: A Linux machine inside OrbStack can be treated like a local Linux host that is reachable over SSH. That means its terminal compatibility, connection style, and tooling integration are essentially the same class of problem as ordinary remote servers.

**What is already integrated**:
- Fish automatically adds `~/.orbstack/bin` to `PATH`, so after installation you can use commands like `docker`, `docker compose`, and `orb` directly.
- Fish applies dynamic `TERM=xterm-256color` downgrading to `ssh` / `orb`, preventing `unknown terminal type` issues when connecting from Ghostty into SSH or OrbStack remote environments.
- The `s` command now recursively resolves `Include` entries in `~/.ssh/config`, so it can also discover OrbStack-generated SSH host configs.

**How to integrate it into SSH**:
- After first installation, open OrbStack once manually to ensure the background service has started.
- Add this line to `~/.ssh/config`: `Include ~/.orbstack/ssh/config`
- After that, you can treat OrbStack Linux machines exactly like normal SSH hosts, including selecting them through the repository's `s` command.

**Most common usage patterns**:
- If you mainly run containers, your daily workflow is usually just terminal commands like `docker ps`, `docker compose up -d`, and `docker exec -it <container> /bin/bash`.
- If you need a full Linux development machine, create one in the OrbStack GUI, usually with `Ubuntu`.
- After creation, you can enter it directly with `orb -m <machine_name>` or via SSH, for example `ssh <user>@<machine_name>@orb`.
- Common scenarios include reproducing a more server-like Linux environment locally, isolating legacy project dependencies, or running databases and backend services inside an isolated machine.
- When you need to inspect containers, images, volumes, or Linux machine state, simply open the OrbStack GUI.

---

## 6. Key Differences from Official Defaults

This project makes a series of intentional customizations on top of the default configuration of each tool. The table below summarizes **all key deviations from official defaults**, so you can quickly understand what is opinionated in these dotfiles.

### 6.1 Karabiner Global Key Remapping

| Change | Official default | This project | Why |
|------|----------|--------|------|
| Swap Caps Lock ↔ Left Control | Keep original positions | Swap them (excluding HHKB-layout keyboards) | Caps Lock is in a better position for frequent Ctrl usage; Emacs, Zellij, Helix, and Vim all rely heavily on Ctrl |

### 6.2 Ghostty Terminal Behavior and Keybindings

**Keybinding changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| `Cmd + ;` → Quick Terminal | Unbound | `global:cmd+;=toggle_quick_terminal` | Toggle the terminal globally with one shortcut |
| `Cmd + 1~9` | Switch Ghostty tabs | `unbind` | Frees those keys for Zellij tab switching |
| Copy on select | `copy-on-select = true` | `copy-on-select = clipboard` | Copy to both the primary selection and the system clipboard |

**Behavior changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| Window state restore | `default` | `window-save-state = never` | Avoid conflicts with Zellij session restore |
| Hide mouse while typing | `false` | `mouse-hide-while-typing = true` | Reduce visual distraction |
| Background blur | `false` | `background-blur = 25` | Frosted-glass effect when using transparency |
| Unfocused split opacity | `0.7` | `unfocused-split-opacity = 0.3` | More obvious distinction between focused and unfocused panes |
| Environment variable | None | `env = GHOSTTY_RUNTIME=1` | Lets Fish detect whether it is running inside Ghostty |

### 6.3 Zellij Shortcuts and Session Architecture

**Architecture changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| Keybinding system | Built-in defaults | `keybinds clear-defaults=true` rebuilt from scratch | Streamline and unify Vim-style navigation, remove unused bindings |
| Default layout | `default` | `default_layout "dev-workspace"` | Use a custom development workspace layout |
| Session name | Random | `session_name "main"` | Fixed session name for easy attach |
| Auto attach | `false` | `attach_to_session true` | Opening a new terminal attaches to the existing session automatically |
| Theme | `default` | `theme "dracula-pro"` | Custom Dracula variant that fixes selection color compatibility |

**Keybinding enhancements:**
| Change | Description |
|------|------|
| Global `Cmd + 1~9` tab switching | No need to enter tab mode, enabled by Ghostty unbinding its native keys |
| Add `h/j/k/l` navigation in all modes | Panes, tabs, resize, move, and scroll all support Vim-style navigation |
| `Ctrl + a` enters tmux compatibility mode | Gives tmux users a muscle-memory compatibility layer |

### 6.4 Fish Shell Behavior and Keybindings

**Behavior changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| Greeting | Show version info | `fish_greeting ""` (disabled) | Keep terminal startup clean |
| Editing mode | Emacs mode | Hybrid Vi mode (Vi + Emacs insert) | Vi-first key style while preserving Emacs insert shortcuts such as Ctrl-a/e |
| Default editor | None | `EDITOR=hx` / `VISUAL=hx` | Standardize on Helix |
| Pager | None | `MANPAGER` uses bat syntax highlighting | Makes man pages easier to read |
| Homebrew auto-update | Enabled | `HOMEBREW_NO_AUTO_UPDATE=1` | Avoid waiting on updates during every package install |
| Fisher plugin path | `~/.config/fish` | `~/.local/share/fisher` | Isolate third-party plugins and keep the config directory clean |
| Zellij auto-start | Disabled | Auto-start inside Ghostty | Ghostty handles auto-start natively; no need to manually type `zellij`, and falls back to Fish if uninstalled |

**Keybinding changes:**
| Change | Description |
|------|------|
| `Ctrl + d` (insert/normal) | When the command line is empty, requires a double-tap within 500ms to exit, preventing accidental terminal or Zellij pane closure; when the command line has content, retains the default delete-char behavior |
| `Ctrl + e` (normal mode) | Use Helix to edit the current command line fullscreen |
| `<Space>y` (normal mode) | Explicitly copy the full command line to the macOS system clipboard without changing the default yank semantics |
| Vi cursor shapes | `normal=block`, `insert=line`, `replace=underscore` |
| Tide `vi_mode` indicator | `D` → `N` to align with Vim community usage of `N` for Normal |

### 6.5 Helix Editor Keybindings and Display

**Keybinding changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| `Ctrl + r` | Unbound | `:reload` reload current file | Quickly reload files modified externally |
| `Space + m` | Unbound | Preview Markdown with glow | Render Markdown in a floating window |
| `Space + o/i` | Unbound | `expand_selection` / `shrink_selection` | Replaces `Alt-o/i` to avoid Alt key conflicts |
| Insert mode `Ctrl + f/b/n/p/a/e` | Unbound | Emacs-style cursor movement | Move quickly without leaving insert mode |
| `j` / `k` | Move by visual line | Move by physical line (`move_line_down/up`) | Works better with soft wrapping and line-number jumps, avoiding cases where `6j` land in the wrong place |
| `gj` / `gk` | Move by physical line | Move by visual line (`move_visual_line_down/up`) | Use these when you really want to move line by line visually |

**Display changes:**
| Change | Official default | This project | Why |
|------|----------|--------|------|
| Line numbers | Absolute | `line-number = "relative"` | Works better with Vim motions |
| Cursor line / column highlight | Both disabled | `cursorline = true` / `cursorcolumn = true` | Easier cursor positioning |
| Buffer line | `never` | `bufferline = "multiple"` | Show tabs when multiple files are open |
| Color mode indicator | `false` | `color-modes = true` | Different modes get different colors |
| Inlay hints | `false` | `display-inlay-hints = true` | Show inline type hints and similar info |
| End-of-line diagnostics | `disable` | `end-of-line-diagnostics = "warning"` | Display warnings directly at line end |
| Inline diagnostics | `disable` | `cursor-line = "warning"` / `other-lines = "warning"` | Show diagnostics inline across all lines |
| Cleanup on save | Both disabled | `trim-final-newlines` / `trim-trailing-whitespace = true` | Keep files tidy |
| Soft wrap | Disabled | `soft-wrap.enable = true` | Automatically wrap long lines |

### 6.6 Git Workflow Enhancements

| Change | Official default | This project | Why |
|------|----------|--------|------|
| Default editor | `vim` | `core.editor = hx` | Standardize on Helix |
| Pager | `less` | `core.pager = delta` | Syntax-highlighted diffs |
| Pull strategy | `merge` | `pull.rebase = true` | Keep history linear |
| Push behavior | Upstream must be set manually | `push.autoSetupRemote = true` | No need for `--set-upstream` |
| Conflict style | `merge` | `merge.conflictstyle = diff3` | Show base / ours / theirs simultaneously |
| Default branch name | `master` | `init.defaultBranch = main` | Modern community convention |
| Reuse recorded conflict resolution | Disabled | `rerere.enabled = true` | Remember conflict resolutions automatically |
| User identity | Hardcoded in config | Injected via `include` local files | Prevent sensitive identity data from entering the repo |
| Theme decoupling | Changing themes dirties the repo | Handled through Git Clean Filter automatically | Ensure local theme switches do not produce unstaged changes |

---

## 7. Common Maintenance Commands (Makefile)

This project introduces a `Makefile` to standardize daily maintenance tasks and integrate installation, synchronization, validation, and cleanup.

| Command | Description |
|------|------|
| `make help` | Show the help menu (default) |
| `make install` | Run the `install.sh` installer |
| `make stow` | Create symlinks for all config files |
| `make unstow` | Remove all symlinks (uninstall configs) |
| `make restow` | Repair / rebuild all symlinks |
| `make stow-<package>` | Sync only one package, such as `make stow-fish` or `make stow-ghostty` |
| `make fish` | Set Fish as the default shell |
| `make plugins` | Update Fisher plugins |
| `make macos` | Apply macOS system preferences |
| `make validate` | Run full config validation, including tool checks |
| `make lint` | Run shellcheck on repository Shell scripts, including `bootstrap.sh`, `install.sh`, `macos.sh`, and `bin/*` |
| `make docs` | Generate or update the README TOC |
| `make update` | Pull remote code and update the entire core toolchain stack via `dot-update` |
| `make clean` | Clean temporary files such as `.bak` and `.tmp` |e switches do not produce unstaged changes |

## 8. FAQ / Troubleshooting

If you encounter issues during installation or usage, please first refer to the solutions for these common high-frequency problems:


**Q: How do I copy a command line to the macOS system clipboard without a mouse?**
> **A:** In the Fish interactive environment (which has Vi mode enabled by default), you can use the following precise keyboard-driven methods:
> - Press `Esc` (or `Ctrl+[`) to enter Normal mode, then press `<Space>y` (Space followed by y). The entire current command line will be instantly copied to the system clipboard, and you can paste it anywhere using `Cmd+v`.

**Q: How do I copy specific content from a Zellij pane without using a mouse?**
> **A:** In Zellij, you can achieve precise copying through the following keyboard combo:
> 1. Press `Ctrl + s` to enter Scroll mode.
> 2. Press `e` to open the entire scrollback buffer of the current pane in the Helix editor.
> 3. Inside Helix, press `v` to enter select mode, then use motion keys (or `w/b`, `/` for search) to select the exact text you want.
> 4. Press `<Space>y` to yank the selected text directly to the macOS system clipboard.
> 5. Press `:q` to exit Helix and seamlessly return to your Zellij pane.

**Q: The VS Code integrated terminal fails to display icons properly, showing a bunch of "tofu blocks" / garbled text / question marks. How can I fix this?**
> **A:** This is usually because VS Code is not configured to use a Nerd Font with full icon support and ligatures. You can fix this by running `hx ~/Library/Application\ Support/Code/User/settings.json` in your terminal (or opening User Settings JSON from the Command Palette), and adding the following lines:
> ```json
> {
>   "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', monospace",
>   "editor.fontFamily": "'JetBrainsMono Nerd Font', 'FiraCode Nerd Font', Menlo, Monaco, 'Courier New', monospace",
>   "editor.fontLigatures": true
> }
> ```

**Q: In the VS Code integrated terminal, when using the `zi` command (or any fzf interactive prompt), pressing `Ctrl + j/k/n/p` outputs garbled text instead of navigating up or down. How do I fix this?**
> **A:** This happens because VS Code intercepts these control keys by default instead of passing them directly to the underlying shell applications. You can fix this by opening User Settings JSON from the Command Palette (or by running `hx ~/Library/Application\ Support/Code/User/settings.json`), adding the following configuration, and restarting VS Code:
> ```json
> {
>   "terminal.integrated.sendKeybindingsToShell": false
> }
> ```

**Q: Many shortcuts in the terminal (like split screen, paging) suddenly stopped working?**
> **A:** This often happens because `Ctrl + g` was accidentally pressed, entering Zellij's **Locking Mode**. In locked mode, Zellij intercepts all of its own shortcut bindings to "pass them through" to internal programs without conflicts. Simply press `Ctrl + g` again to unlock and return to normal.

**Q: When using `aichat` shortcuts or commands, it prompts that the model cannot be found or network timeout?**
> **A:** Please check two things:
> 1. Ensure you have correctly configured the model name (e.g., `AICHAT_MODEL`) and the corresponding API Key in `~/.config/fish/config.local.fish`. After configuring, be sure to run `exec fish` to reload the environment or restart the terminal.
> 2. If you are using local Ollama, make sure `ollama serve` is running, the target model has been downloaded with `ollama pull <model>`, and the model name is included in `local-llm.models` inside `~/.config/aichat/config.yaml`.
> 3. If the API of the model you are using is access-restricted (e.g., accessing OpenAI from certain regions), you may need to enable a global proxy in your terminal. This configuration has built-in `proxy` and `unproxy` shortcuts to help you toggle the terminal proxy with one click.

**Q: While writing code in the Helix editor, why is there no syntax hinting or code checking?**
> **A:** Helix relies on Language Servers (LSP) to provide intelligent completion capabilities. This project centrally manages LSPs via `mise`:
> - Make sure you have run `mise install` in the terminal to fetch the latest LSP toolchain.
> - Type `:log` in Helix to read the logs, or run `hx --health` in the terminal to verify if the LSP startup for the corresponding language reported any errors.
> - LSPs for certain languages (like C/C++ or Rust) are recommended to be independently installed using brew for optimal stability (e.g., `brew install llvm` or `brew install rust-analyzer`).

---

## 9. Acknowledgments

This project would not exist without the flourishing modern open-source ecosystem. Special thanks to the following outstanding projects that form the foundation of this workflow:

- [Homebrew](https://brew.sh/) / [GNU Stow](https://www.gnu.org/software/stow/)
- [Ghostty](https://ghostty.org/) / [Zellij](https://zellij.dev/)
- [Fish](https://fishshell.com/) / [Fisher](https://github.com/jorgebucaran/fisher) / [Tide](https://github.com/IlanCosman/tide) / [fzf.fish](https://github.com/PatrickF1/fzf.fish)
- [Helix](https://helix-editor.com/) / [Mise](https://mise.jdx.dev/)
- [AIChat](https://github.com/sigoden/aichat) / [GitHub CLI](https://cli.github.com/)
- [fzf](https://github.com/junegunn/fzf) / [fd](https://github.com/sharkdp/fd) / [zoxide](https://github.com/ajeetdsouza/zoxide) / [ripgrep](https://github.com/BurntSushi/ripgrep)
- [bat](https://github.com/sharkdp/bat) / [eza](https://github.com/eza-community/eza) / [git-delta](https://github.com/dandavison/delta) / [glow](https://github.com/charmbracelet/glow)
- [grc](https://github.com/garabik/grc) / [shellcheck](https://github.com/koalaman/shellcheck) / [btop](https://github.com/aristocratos/btop) / [asciinema](https://github.com/asciinema/asciinema)
- [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) / [Maple Mono](https://github.com/subframe7536/maple-font) / [Geist Mono](https://github.com/vercel/geist-font) / [Nerd Fonts](https://www.nerdfonts.com/)
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/) / [OrbStack](https://orbstack.dev/) / [switchaudio-osx](https://github.com/deweller/switchaudio-osx)

---

## 10. License

This project is released under the [MIT License](LICENSE).

You are free to use, study, modify, and distribute this code as the starting point for building your own personal workflow.
