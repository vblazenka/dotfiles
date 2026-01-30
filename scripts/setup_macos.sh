#!/bin/bash

# macOS Setup Script
# Uses common functions from setup_common.sh

# Source common functions
source "$DOTFILES_DIR/scripts/setup_common.sh"

install_homebrew() {
    log_info "Checking Homebrew..."

    if command -v brew &> /dev/null; then
        log_success "Homebrew is already installed"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for current session
    if [[ -d "/opt/homebrew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

install_packages_macos() {
    log_info "Installing packages via Homebrew..."

    local packages=(
        "git"
        "neovim"
        "zellij"
        "zsh"
        "curl"
        "wget"
        "tree"
        "htop"
        "ripgrep"
        "fd"
        "fzf"
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            log_success "$package is already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    log_success "Package installation completed"
}

main_macos() {
    log_info "Starting macOS setup..."

    install_homebrew
    install_packages_macos
    install_oh_my_zsh      # from setup_common.sh
    install_zsh_plugins    # from setup_common.sh
    source "$DOTFILES_DIR/scripts/setup_symlinks.sh"
    setup_symlinks "$DOTFILES_DIR"
    install_uv             # from setup_common.sh
    install_nvm            # from setup_common.sh
    setup_folder_structure # from setup_common.sh

    log_success "macOS setup completed!"
}

main_macos
