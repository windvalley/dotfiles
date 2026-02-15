#!/bin/bash

# Set error handling
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

info "Starting dotfiles installation..."

if ! command -v brew &> /dev/null; then
    info "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    success "Homebrew is already installed."
fi

info "Installing required dependencies..."
REQUIRED_FORMULAE=(
    stow
    zellij
    fish
    helix
    mise
    bat
    eza
    fzf
    grc
    gawk
    gnu-sed
    grep
)

brew install "${REQUIRED_FORMULAE[@]}"

info "Installing Ghostty..."
if ! brew list --cask ghostty@tip &>/dev/null; then
    brew install --cask ghostty@tip
else
    success "Ghostty is already installed."
fi

install_optional() {
    local name=$1
    local formula=$2
    if brew list "$formula" &>/dev/null; then
        success "$name already installed."
        return
    fi
    read -p "Do you want to install $name? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install "$formula"
    fi
}

install_optional "switchaudio-osx (for audio-volume)" "switchaudio-osx"

DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    info "Cloning dotfiles repository..."
    git clone https://github.com/windvalley/dotfiles.git "$DOTFILES_DIR"
else
    success "Dotfiles directory already exists at $DOTFILES_DIR"
fi

info "Linking configuration files with stow..."

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/karabiner"

STANDARD_PACKAGES=(ghostty fish helix zellij mise karabiner)
for pkg in "${STANDARD_PACKAGES[@]}"; do
    info "Stowing $pkg..."
    stow --restow --target="$HOME" --dir="$DOTFILES_DIR" --dotfiles "$pkg"
done

info "Stowing bin..."
stow --restow --target="$HOME/.local/bin" --dir="$DOTFILES_DIR" bin

if [[ "$SHELL" != *"fish"* ]]; then
    read -p "Do you want to set fish as your default shell? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
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
if [ -f "$DOTFILES_DIR/fish/dot-config/fish/fish_plugins" ]; then
    if fish -c "type -q fisher" 2>/dev/null; then
        success "Fisher already installed, updating plugins..."
        fish -c "fisher update"
    else
        info "Installing fisher..."
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher && fisher install (cat $DOTFILES_DIR/fish/dot-config/fish/fish_plugins)"
    fi
else
    warn "fish_plugins not found at $DOTFILES_DIR/fish/dot-config/fish/fish_plugins, skipping fisher update."
fi

info "Configuring Fish Homebrew PATH..."
fish -c "fish_add_path (brew --prefix)/bin" 2>/dev/null || true

success "Installation complete!"
info "Next steps:"
echo "1. Restart your terminal."
echo "2. Run 'mise install' to install language runtimes."
echo "3. Enjoy your new setup!"
