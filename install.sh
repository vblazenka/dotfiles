#!/bin/bash

# Dotfiles Installation Script (macOS)
# Author: Vedran Blazenka

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Logging functions
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
    log_error "These dotfiles support macOS only."
    exit 1
fi

# Header
echo -e "${BLUE}"
echo "======================================="
echo "  Dotfiles Installation Script (macOS)"
echo "======================================="
echo -e "${NC}"

log_info "Starting installation from: $DOTFILES_DIR"

source "$DOTFILES_DIR/scripts/setup_tools.sh"
source "$DOTFILES_DIR/scripts/setup_symlinks.sh"

install_homebrew
install_packages
install_oh_my_zsh
install_zsh_plugins
setup_symlinks "$DOTFILES_DIR"
install_uv
install_bun
install_nvm
setup_folder_structure

log_success "Installation completed!"
log_info "Please restart your terminal to apply all changes."
