#!/bin/bash

# dotfiles bootstrap script
# curl -fsSL https://raw.githubusercontent.com/windvalley/dotfiles/main/bootstrap.sh | bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ "$(uname -s)" != "Darwin" ]; then
    error "This dotfiles setup is only supported on macOS."
    exit 1
fi

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/windvalley/dotfiles.git"

if ! command -v git &> /dev/null; then
    info "Git is not installed. Installing Command Line Tools for Xcode..."
    xcode-select --install
    
    info "Waiting for Git installation to complete..."
    until command -v git &> /dev/null; do
        sleep 5
    done
    success "Git installed successfully."
fi

if [ -d "$DOTFILES_DIR" ]; then
    info "Dotfiles directory already exists at $DOTFILES_DIR. Updating..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    info "Cloning dotfiles repository to $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

info "Executing install.sh..."
bash install.sh "$@"

success "Bootstrap completed successfully!"
