#!/bin/bash

# Set error handling
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
NON_INTERACTIVE=false
MINIMAL=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -y|--yes|--unattended) NON_INTERACTIVE=true ;;
        -m|--minimal) MINIMAL=true ;;
        -h|--help) 
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -y, --yes, --unattended    Run in non-interactive mode without prompting"
            echo "  -m, --minimal              Minimal install (fish + helix + git only, no GUI apps)"
            echo "  -h, --help                 Show this help message"
            exit 0
            ;;
        *) error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

ask_yes_no() {
    local prompt="$1"
    if [ "$NON_INTERACTIVE" = true ]; then
        info "${prompt} (auto-yes)"
        return 0
    else
        read -p "$prompt " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}

if [ "$MINIMAL" = true ]; then
    info "Starting MINIMAL dotfiles installation (fish + helix + git)..."
else
    info "Starting dotfiles installation..."
fi

if ! command -v brew &> /dev/null; then
    warn "Homebrew not found."
    if ask_yes_no "Install Homebrew from official source? (y/n)"; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        success "Homebrew installed successfully."
    else
        error "Homebrew is required. Please install it manually from https://brew.sh"
        exit 1
    fi
else
    success "Homebrew is already installed."
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$MINIMAL" = true ]; then
    info "Installing minimal dependencies..."
    MINIMAL_DEPS=(stow fish helix git-delta)
    for dep in "${MINIMAL_DEPS[@]}"; do
        if ! brew list "$dep" &>/dev/null; then
            brew install "$dep"
        fi
    done
    success "Minimal dependencies installed."
else
    info "Installing dependencies from Brewfile..."
    if [ -f "$DOTFILES_DIR/Brewfile" ]; then
        if ! brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
            brew bundle install --file="$DOTFILES_DIR/Brewfile"
        else
            success "All Brew dependencies are already satisfied."
        fi
    else
        error "Brewfile not found at $DOTFILES_DIR/Brewfile"
        exit 1
    fi

    info "Installing additional Fonts..."
    if ask_yes_no "Do you want to install additional fonts (Maple Mono, Geist Mono)? (y/n)"; then
        REQUIRED_CASKS=(
            font-maple-mono-nf
            font-geist-mono-nerd-font
        )
        brew install --cask "${REQUIRED_CASKS[@]}"
    fi
fi

info "Linking configuration files with stow..."

mkdir -p "$HOME/.local/bin"

if [ "$MINIMAL" = true ]; then
    STOW_PACKAGES=(fish helix git)
else
    STOW_PACKAGES=(ghostty fish helix zellij mise karabiner btop git)
fi

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

if [ "$MINIMAL" != true ]; then
    info "Stowing bin..."
    stow --restow --target="$HOME/.local/bin" --dir="$DOTFILES_DIR" bin
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

if [[ "$SHELL" != *"fish"* ]]; then
    if ask_yes_no "Do you want to set fish as your default shell? (y/n)"; then
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

if [ -f "$DOTFILES_DIR/fish/dot-config/fish/fish_plugins" ]; then
    if fish -c "type -q fisher" 2>/dev/null; then
        success "Fisher already installed, updating plugins..."
        fish -c "fisher update"
    else
        info "Installing fisher..."
        FISHER_URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
        FISHER_TMP=$(mktemp)

        if curl -fsSL "$FISHER_URL" -o "$FISHER_TMP"; then
            fish -c "source '$FISHER_TMP' && fisher install jorgebucaran/fisher && fisher install (cat $DOTFILES_DIR/fish/dot-config/fish/fish_plugins)"
            rm -f "$FISHER_TMP"
        else
            rm -f "$FISHER_TMP"
            error "Failed to download fisher. Check your network connection."
            exit 1
        fi
    fi
else
    warn "fish_plugins not found at $DOTFILES_DIR/fish/dot-config/fish/fish_plugins, skipping fisher update."
fi

info "Configuring Fish Homebrew PATH..."
fish -c "fish_add_path (brew --prefix)/bin" 2>/dev/null || true

# Migrate PATH from zsh to fish (for users switching from zsh)
if command -v zsh &>/dev/null; then
    info "Migrating PATH from zsh to fish..."

    ZSH_PATHS=$(/bin/zsh -l -c 'echo "$PATH"' 2>/dev/null | tr ':' '\n')
    FISH_PATHS=$(fish -l -c 'string join \n $PATH' 2>/dev/null)

    MIGRATED=0
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        [ ! -d "$p" ] && continue

        # Skip system/default paths (already handled)
        case "$p" in
            /usr/bin|/bin|/usr/sbin|/sbin|/usr/local/bin|/opt/homebrew/bin|/opt/homebrew/sbin) continue ;;
        esac

        # Check if path is already in fish
        if ! echo "$FISH_PATHS" | grep -qxF "$p"; then
            fish -c "fish_add_path --append '$p'" 2>/dev/null
            info "  Added: $p"
            MIGRATED=$((MIGRATED + 1))
        fi
    done <<< "$ZSH_PATHS"

    if [ "$MIGRATED" -gt 0 ]; then
        success "Migrated $MIGRATED PATH entries from zsh to fish."
    else
        success "No additional PATH entries to migrate from zsh."
    fi
else
    info "zsh not found, skipping PATH migration."
fi

if [[ "$(uname)" == "Darwin" ]]; then
    if [ "$NON_INTERACTIVE" = true ]; then
        info "Skipping macOS system preferences in non-interactive mode."
    elif ask_yes_no "Do you want to apply macOS system preferences (macos.sh)? (y/n)"; then
        info "Applying macOS system preferences..."
        bash "$DOTFILES_DIR/macos.sh"
    fi
fi

success "Installation complete!"
info "Next steps:"
echo "1. Run 'exec fish -l' or restart your terminal."
echo "2. Run 'tide configure' to set up your prompt (or use the auto-config as follows):"
echo ""
echo "   tide configure --auto \\"
echo "       --style=Lean \\"
echo "       --prompt_colors='16 colors' \\"
echo "       --show_time='24-hour format' \\"
echo "       --lean_prompt_height='Two lines' \\"
echo "       --prompt_connection=Disconnected \\"
echo "       --prompt_spacing=Sparse \\"
echo "       --icons='Many icons' \\"
echo "       --transient=Yes"
echo ""
echo "3. Edit ~/.config/mise/config.toml to customize your language runtimes if needed, then run 'mise install'."
echo "4. IMPORTANT: Edit ~/.gitconfig.local (and ~/.gitconfig.work if needed) to set your Git Identity."
echo "5. IMPORTANT: Edit ~/.config/fish/config.local.fish to set private ENVs like API keys."
echo "6. IMPORTANT (macOS): Allow Ghostty in 'System Settings > Privacy & Security > Accessibility'."
echo ""
success "Enjoy your new setup!"
