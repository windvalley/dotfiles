#!/bin/bash

# Set error handling
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
export RED GREEN BLUE YELLOW NC

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
export -f info success warn error

show_help() {
  cat <<EOF
Usage:
  $0 [options]

Options:
  -y, --yes, --unattended    Run in non-interactive mode without prompting
  --with-ollama              Install Ollama and start its background service
  -h, --help                 Show this help message
EOF
}

show_next_steps() {
  cat <<'EOF'
Next steps:
  1. Run 'exec fish -l' or restart your terminal.
  2. Run 'tide configure' to set up your prompt, or use:
     tide configure --auto \
         --style=Lean \
         --prompt_colors='16 colors' \
         --show_time='24-hour format' \
         --lean_prompt_height='Two lines' \
         --prompt_connection=Disconnected \
         --prompt_spacing=Sparse \
         --icons='Many icons' \
         --transient=Yes
  3. All language runtimes, LSPs, and CLI tools have been auto-installed via mise.
     (Check 'mise ls' to see the managed tools).
EOF

  if [ "${SHOW_OLLAMA_NEXT_STEPS:-false}" = true ]; then
    cat <<'EOF'

Optional local LLM:
  - Pull at least one Ollama model, for example: ollama pull llama3.2
  - Set ~/.config/fish/config.local.fish:
      set -gx AICHAT_MODEL "local-llm:llama3.2"
EOF
  fi

  cat <<'EOF'

Manual follow-up:
  - Edit ~/.config/fish/config.local.fish for private ENVs and API keys.
  - Edit ~/.config/ghostty/config.local for machine-specific shortcuts or overrides.
  - Edit ~/.gitconfig.local and ~/.gitconfig.work for Git identity.
  - macOS: Allow Ghostty in 'System Settings > Privacy & Security > Accessibility'.
EOF
}

fish_plugins_args() {
  local fish_plugins_file="$1"
  local plugins=()
  local line=""

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    plugins+=("$line")
  done <"$fish_plugins_file"

  [ "${#plugins[@]}" -eq 0 ] && return 0
  printf '%s\n' "${plugins[@]}"
}

# Parse arguments
NON_INTERACTIVE=false
INSTALL_OLLAMA=false
START_OLLAMA_SERVICE=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -y | --yes | --unattended) NON_INTERACTIVE=true ;;
  --with-ollama)
    INSTALL_OLLAMA=true
    START_OLLAMA_SERVICE=true
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *)
    error "Unknown parameter: $1"
    exit 1
    ;;
  esac
  shift
done

ask_yes_no() {
  local prompt="$1"
  local default_answer="${2:-n}"
  local prompt_suffix=""
  local reply=""

  case "$default_answer" in
  y | Y)
    default_answer="y"
    prompt_suffix="[Y/n]"
    ;;
  n | N)
    default_answer="n"
    prompt_suffix="[y/N]"
    ;;
  *)
    error "ask_yes_no received invalid default answer: $default_answer"
    exit 1
    ;;
  esac

  if [ "$NON_INTERACTIVE" = true ]; then
    info "${prompt} ${prompt_suffix} (auto-yes)"
    return 0
  fi

  while true; do
    # 从 /dev/tty 直接读取终端输入，避免上一步命令（brew/zsh/fish 等）
    # 向 stdin 写入残留字节导致 read 跳过用户输入的问题。
    read -r -p "$prompt $prompt_suffix " reply </dev/tty

    if [ -z "$reply" ]; then
      reply="$default_answer"
    fi

    case "$reply" in
    [Yy]) return 0 ;;
    [Nn]) return 1 ;;
    *)
      warn "Please answer y or n."
      ;;
    esac
  done
}

resolve_ollama_install_plan() {
  if [ "$INSTALL_OLLAMA" = true ]; then
    info "Ollama optional install enabled via CLI flag."
    return 0
  fi

  if [ "$NON_INTERACTIVE" = true ]; then
    info "Non-interactive mode detected, skipping optional Ollama installation by default."
    return 0
  fi

  # Ollama 体积和后续模型下载成本都明显高于普通 CLI，因此仅在交互安装时按需启用。
  if ask_yes_no "Do you want to install Ollama for local models?" "n"; then
    INSTALL_OLLAMA=true
    if ask_yes_no "Do you want to start Ollama service now?" "y"; then
      START_OLLAMA_SERVICE=true
    else
      info "Skipping Ollama service startup. You can run 'brew services start ollama' later."
    fi
  fi
}

install_optional_ollama() {
  local ollama_available=false
  local ollama_managed_by_brew=false

  [ "$INSTALL_OLLAMA" = true ] || return 0

  if command -v ollama &>/dev/null; then
    success "Ollama is already available."
    ollama_available=true
  else
    info "Installing Ollama..."
    if brew install ollama; then
      success "Ollama installed."
      ollama_available=true
    else
      warn "Ollama installation had issues. You can rerun manually: brew install ollama"
      return 0
    fi
  fi

  if brew list --formula ollama >/dev/null 2>&1; then
    ollama_managed_by_brew=true
  fi

  if [ "$START_OLLAMA_SERVICE" = true ]; then
    if [ "$ollama_managed_by_brew" = true ]; then
      info "Starting Ollama service..."
      if brew services start ollama; then
        success "Ollama service started."
      else
        warn "Failed to start Ollama service automatically. You can rerun manually: brew services start ollama"
      fi
    else
      warn "Ollama is not managed by Homebrew on this machine. Please start it manually with 'ollama serve' if needed."
    fi
  else
    info "Skipping Ollama service startup. Run 'brew services start ollama' when you need local models."
  fi

  if [ "$ollama_available" = true ]; then
    SHOW_OLLAMA_NEXT_STEPS=true
  fi
}

if [ "$(uname -s)" != "Darwin" ]; then
  error "This dotfiles setup is only supported on macOS."
  exit 1
fi

info "Starting dotfiles installation..."

if ! command -v brew &>/dev/null; then
  warn "Homebrew not found."
  if ask_yes_no "Install Homebrew from official source?" "y"; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
    success "Homebrew installed successfully."
  else
    error "Homebrew is required. Please install it manually from https://brew.sh"
    exit 1
  fi
else
  success "Homebrew is already installed."
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREW_BUNDLE_CASK_SKIP=""
SKIPPED_PRIVILEGED_CASKS=""

info "Checking current status..."
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  # `karabiner-elements` 通过 pkg 安装，Homebrew 可能触发 sudo。
  # 在 -y / --unattended 模式下，如果当前没有可复用的 sudo 凭证，就跳过它，
  # 避免整个安装流程卡死在密码提示。
  if [ "$NON_INTERACTIVE" = true ] && ! sudo -n true >/dev/null 2>&1; then
    SKIPPED_PRIVILEGED_CASKS="karabiner-elements"
    BREW_BUNDLE_CASK_SKIP="$SKIPPED_PRIVILEGED_CASKS"
    warn "Non-interactive mode detected without cached sudo credentials."
    warn "Skipping privileged casks for now: $SKIPPED_PRIVILEGED_CASKS"
  fi

  if [ -n "$BREW_BUNDLE_CASK_SKIP" ]; then
    BREW_BUNDLE_CHECK_CMD=(env "HOMEBREW_BUNDLE_CASK_SKIP=$BREW_BUNDLE_CASK_SKIP" brew bundle check --file="$DOTFILES_DIR/Brewfile")
    BREW_BUNDLE_INSTALL_CMD=(env "HOMEBREW_BUNDLE_CASK_SKIP=$BREW_BUNDLE_CASK_SKIP" brew bundle install --file="$DOTFILES_DIR/Brewfile")
  else
    BREW_BUNDLE_CHECK_CMD=(brew bundle check --file="$DOTFILES_DIR/Brewfile")
    BREW_BUNDLE_INSTALL_CMD=(brew bundle install --file="$DOTFILES_DIR/Brewfile")
  fi

  if ! "${BREW_BUNDLE_CHECK_CMD[@]}" >/dev/null 2>&1; then
    info "Installing/Updating dependencies..."
    if "${BREW_BUNDLE_INSTALL_CMD[@]}"; then
      success "Brew dependencies installed."
    else
      error "Brew bundle install failed."
      exit 1
    fi
  else
    if [ -n "$SKIPPED_PRIVILEGED_CASKS" ]; then
      success "All non-privileged Brew dependencies are already satisfied."
    else
      success "All Brew dependencies are already satisfied."
    fi
  fi
else
  error "Brewfile not found at $DOTFILES_DIR/Brewfile"
  exit 1
fi

info "Installing additional Fonts..."
if ask_yes_no "Do you want to install additional fonts (Maple Mono, Geist Mono)?" "n"; then
  REQUIRED_CASKS=(
    font-maple-mono-nf
    font-geist-mono-nerd-font
  )
  if brew install --cask --force "${REQUIRED_CASKS[@]}"; then
    success "Fonts installed."
  else
    warn "Font installation had issues."
  fi
fi

resolve_ollama_install_plan
install_optional_ollama

info "Linking configuration files with stow..."

mkdir -p "$HOME/.local/bin"

STOW_PACKAGES=(ghostty fish helix zellij mise karabiner bat btop git aichat)

# Clean up existing config directories and stow packages
for pkg in "${STOW_PACKAGES[@]}"; do
  DIR="$HOME/.config/$pkg"
  # Ensure any existing directory is either unlinked (if symlink) or backed up (if real dir).
  # This guarantees stow creates a pure directory-level mapping to ~/dotfiles,
  # ensuring locally generated files (like Karabiner/Btop UI saves) are tracked automatically.
  if [ -L "$DIR" ]; then
    warn "$DIR is a symlink, unlinking..."
    unlink "$DIR"
  elif [ -d "$DIR" ]; then
    BACKUP_DIR="${DIR}.bak.$(date +%Y%m%d_%H%M%S)"
    warn "Backing up existing real directory $DIR -> $BACKUP_DIR"
    mv "$DIR" "$BACKUP_DIR"
  fi

  info "Stowing $pkg..."
  stow --restow --target="$HOME" --dir="$DOTFILES_DIR" --dotfiles "$pkg"
done

# Always stow bin for scripts, they are useful in CLI
info "Stowing bin..."
stow --restow --target="$HOME/.local/bin" --dir="$DOTFILES_DIR" bin

info "Synchronizing AIChat model catalog..."
if command -v aichat &>/dev/null; then
  if aichat --sync-models; then
    success "AIChat model catalog synchronized."
  else
    warn "AIChat model sync had issues. You can rerun manually: aichat --sync-models"
  fi
else
  warn "AIChat not found, skipping model sync. You can rerun manually after installation: aichat --sync-models"
fi

info "Installing all runtimes and CLI tools managed by Mise..."
if command -v mise &>/dev/null; then
  # 根据 ~/.config/mise/config.toml 声明，一键全量安装所有运行时、LSP 和 CLI 工具
  if mise install --yes; then
    success "Mise tools and runtimes installed."
  else
    warn "Mise installation had issues. You can rerun manually: mise install"
  fi
else
  warn "Mise not found, skipping tool installation."
fi

info "Setting up local configuration overrides..."

# --- 1. Git Local 基础信息模板 ---
if [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES_DIR/local/dot-gitconfig.local.example" "$HOME/.gitconfig.local"
  info "  -> Created ~/.gitconfig.local (Please update it with your name/email)"
else
  success "  -> ~/.gitconfig.local already exists, skipping."
fi

# --- 2. Git 工作目录信息模板 ---
if [ ! -f "$HOME/.gitconfig.work" ]; then
  cp "$DOTFILES_DIR/local/dot-gitconfig.work.example" "$HOME/.gitconfig.work"
  info "  -> Created ~/.gitconfig.work"
else
  success "  -> ~/.gitconfig.work already exists, skipping."
fi

# --- 3. Fish 私有环境变量模板 ---
FISH_LOCAL_CONF="$HOME/.config/fish/config.local.fish"
if [ ! -f "$FISH_LOCAL_CONF" ]; then
  cp "$DOTFILES_DIR/local/config.local.fish.example" "$FISH_LOCAL_CONF"
  info "  -> Created $FISH_LOCAL_CONF (For private API keys and aliases)"
else
  success "  -> $FISH_LOCAL_CONF already exists, skipping."
fi

# --- 4. Ghostty 私有配置模板 ---
GHOSTTY_LOCAL_CONF="$HOME/.config/ghostty/config.local"
if [ ! -f "$GHOSTTY_LOCAL_CONF" ]; then
  mkdir -p "$HOME/.config/ghostty"
  cp "$DOTFILES_DIR/local/ghostty.config.local.example" "$GHOSTTY_LOCAL_CONF"
  info "  -> Created $GHOSTTY_LOCAL_CONF (For private shortcuts and overrides)"
else
  success "  -> $GHOSTTY_LOCAL_CONF already exists, skipping."
fi

if [[ "$SHELL" != *"fish"* ]]; then
  if [ "$NON_INTERACTIVE" = true ]; then
    info "Skipping default shell change in non-interactive mode."
    info "Please run 'chsh -s $(which fish)' manually later if needed."
  elif ask_yes_no "Do you want to set fish as your default shell?" "y"; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
      info "Adding $FISH_PATH to /etc/shells..."
      echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    info "Changing default shell to fish..."
    chsh -s "$FISH_PATH"
  fi
else
  success "Fish is already the default shell."
fi

info "Installing fisher and plugins..."
# 清理 fisher_path 目录（与 config.fish 中 set -g fisher_path 保持一致）
# 该目录存放第三方插件的 functions/completions/conf.d，残留旧数据可能导致安装冲突
FISHER_DATA_DIR="$HOME/.local/share/fisher"
if [ -d "$FISHER_DATA_DIR" ]; then
  warn "Cleaning existing fisher data: $FISHER_DATA_DIR"
  rm -rf "$FISHER_DATA_DIR"
fi

if fish -c "type -q fisher" 2>/dev/null; then
  success "Fisher already installed."
else
  info "Installing fisher..."
  FISHER_URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
  FISHER_TMP=$(mktemp)

  if curl -fsSL "$FISHER_URL" -o "$FISHER_TMP"; then
    fish -c "source '$FISHER_TMP' && fisher install jorgebucaran/fisher"
    rm -f "$FISHER_TMP"
  else
    rm -f "$FISHER_TMP"
    error "Failed to download fisher. Check your network connection."
    exit 1
  fi
fi

if [ -f "$DOTFILES_DIR/fish/dot-config/fish/fish_plugins" ]; then
  info "Installing plugins from fish_plugins..."
  FISH_PLUGINS=()
  while IFS= read -r plugin; do
    [ -z "$plugin" ] && continue
    FISH_PLUGINS+=("$plugin")
  done < <(fish_plugins_args "$DOTFILES_DIR/fish/dot-config/fish/fish_plugins")
  if [ "${#FISH_PLUGINS[@]}" -eq 0 ]; then
    warn "fish_plugins is empty, skipping plugin installation."
  elif fish -c "fisher install $(printf '%q ' "${FISH_PLUGINS[@]}")"; then
    success "Fisher plugins synchronized."
  else
    warn "Fisher plugin synchronization had issues."
  fi
else
  warn "fish_plugins not found at $DOTFILES_DIR/fish/dot-config/fish/fish_plugins, skipping plugin installation."
fi

info "Configuring Fish Homebrew PATH..."
fish -c "fish_add_path (brew --prefix)/bin" 2>/dev/null || true

# Migrate PATH from zsh to fish (for users switching from zsh)
if command -v zsh &>/dev/null; then
  info "Migrating PATH from zsh to fish (with 5-second timeout protection)..."

  if command -v perl &>/dev/null; then
    ZSH_PATHS=$(perl -e 'alarm 5; exec @ARGV' /bin/zsh -l -c 'echo "$PATH"' 2>/dev/null | tr ':' '\n' || true)
  else
    ZSH_PATHS=$(/bin/zsh -l -c 'echo "$PATH"' 2>/dev/null | tr ':' '\n' || true)
  fi

  if [ -z "$ZSH_PATHS" ]; then
    warn "Could not read legacy zsh PATH or timed out. Skipping migration."
  else
    FISH_PATHS=$(fish -l -c 'string join \n $PATH' 2>/dev/null)

    MIGRATED=0
    while IFS= read -r p; do
      [ -z "$p" ] && continue
      [ ! -d "$p" ] && continue

      # Skip system/default paths (already handled)
      case "$p" in
      /usr/bin | /bin | /usr/sbin | /sbin | /usr/local/bin | /opt/homebrew/bin | /opt/homebrew/sbin) continue ;;
      esac

      # Check if path is already in fish
      if ! echo "$FISH_PATHS" | grep -qxF "$p"; then
        fish -c "fish_add_path --append '$p'" 2>/dev/null || true
        info "  Added: $p"
        MIGRATED=$((MIGRATED + 1))
      fi
    done <<<"$ZSH_PATHS"

    if [ "$MIGRATED" -gt 0 ]; then
      success "Migrated $MIGRATED PATH entries from zsh to fish."
    else
      success "No additional PATH entries to migrate from zsh."
    fi
  fi
else
  info "zsh not found, skipping PATH migration."
fi

if [[ "$(uname)" == "Darwin" ]]; then
  if ask_yes_no "Do you want to apply macOS system preferences (macos.sh)?" "n"; then
    info "Applying macOS system preferences..."
    bash "$DOTFILES_DIR/macos.sh"
  fi

fi

success "Installation complete!"
show_next_steps
if [ -n "$SKIPPED_PRIVILEGED_CASKS" ]; then
  warn "Skipped privileged casks in non-interactive mode: $SKIPPED_PRIVILEGED_CASKS"
  info "Install them later in an interactive shell: brew install --cask $SKIPPED_PRIVILEGED_CASKS"
fi
success "Enjoy your new setup!"
