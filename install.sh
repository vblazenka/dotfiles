#!/bin/bash

# Dotfiles Installation Script
# Author: Vedran Blazenka
# Description: Cross-platform development environment setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export DOTFILES_DIR

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Export logging functions for child scripts
export -f log_info log_success log_warning log_error

# Header
echo -e "${BLUE}"
echo "======================================="
echo "  Dotfiles Installation Script"
echo "======================================="
echo -e "${NC}"

log_info "Starting installation from: $DOTFILES_DIR"

# Source OS detection
source "$DOTFILES_DIR/scripts/detect_os.sh"

# Detect operating system
detect_os

log_info "Detected OS: $OS_TYPE"

# Run OS-specific setup
case "$OS_TYPE" in
    "macos")
        log_info "Running macOS setup..."
        source "$DOTFILES_DIR/scripts/setup_macos.sh"
        ;;
    "linux")
        log_info "Running Linux setup..."
        source "$DOTFILES_DIR/scripts/setup_linux.sh"
        ;;
    "wsl")
        log_info "Running WSL setup..."
        source "$DOTFILES_DIR/scripts/setup_wsl.sh"
        ;;
    *)
        log_error "Unsupported operating system: $OS_TYPE"
        exit 1
        ;;
esac

log_success "Installation completed!"
log_info "Please restart your terminal to apply all changes."
