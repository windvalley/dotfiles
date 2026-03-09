#!/bin/bash
# dotfiles bootstrap script
# curl -fsSL https://raw.githubusercontent.com/windvalley/dotfiles/main/bootstrap.sh | bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

if [ "$(uname -s)" != "Darwin" ]; then
    error "This dotfiles setup is only supported on macOS."
    exit 1
fi

DEFAULT_DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/windvalley/dotfiles.git"

if ! command -v git &> /dev/null; then
    info "Git is not installed. Installing Command Line Tools for Xcode..."
    xcode-select --install
    
    info "Waiting for Git installation to complete..."
    wait_count=0
    until command -v git &> /dev/null; do
        sleep 5
        wait_count=$((wait_count + 1))
        if [ $((wait_count % 6)) -eq 0 ]; then
            info "Still waiting for Xcode Command Line Tools. Please click 'Install' on the macOS popup..."
        fi
        if [ $wait_count -ge 180 ]; then
            error "Git installation took too long or was cancelled. Please install manually: xcode-select --install"
            exit 1
        fi
    done
    success "Git installed successfully."
fi

# Allow user to specify a custom target directory via DOTFILES_DIR environment variable
TARGET_DIR="${DOTFILES_DIR:-$DEFAULT_DOTFILES_DIR}"

if [ -d "$TARGET_DIR" ]; then
    error "Target directory already exists at $TARGET_DIR."
    error "The bootstrap script is designed for first-time installation only."
    echo -e "${YELLOW}[WARN]${NC} If you want to reinstall, please backup or remove the existing directory:"
    echo "       mv $TARGET_DIR ${TARGET_DIR}.bak"
    echo -e "${YELLOW}[WARN]${NC} Or specify a different location by running:"
    echo "       export DOTFILES_DIR=~/some_other_path; curl ... | bash"
    exit 1
fi

info "Cloning dotfiles repository to $TARGET_DIR..."
git clone "$REPO_URL" "$TARGET_DIR"

cd "$TARGET_DIR"

info "Executing install.sh..."
bash install.sh "$@"

success "Bootstrap completed successfully!"
