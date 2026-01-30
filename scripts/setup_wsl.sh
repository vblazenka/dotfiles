#!/bin/bash

# WSL Setup Script
# Based on Linux setup with WSL-specific additions
# Uses common functions from setup_common.sh

# Source common functions
source "$DOTFILES_DIR/scripts/setup_common.sh"

install_packages_wsl() {
    log_info "Updating apt and installing packages..."

    sudo apt update

    local packages=(
        "git"
        "neovim"
        "zsh"
        "curl"
        "wget"
        "tree"
        "htop"
        "ripgrep"
        "fd-find"
        "fzf"
        "unzip"
        "build-essential"
    )

    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        sudo apt install -y "$package" || log_warning "Failed to install $package"
    done

    log_success "Package installation completed"
}

install_zellij_wsl() {
    log_info "Checking Zellij..."

    if command -v zellij &> /dev/null; then
        log_success "Zellij is already installed"
        return 0
    fi

    log_info "Installing Zellij..."

    # Version pinned - check https://github.com/zellij-org/zellij/releases for updates
    local version="0.40.1"
    local arch=$(uname -m)
    curl -L "https://github.com/zellij-org/zellij/releases/download/v${version}/zellij-${arch}-unknown-linux-musl.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/zellij /usr/local/bin/
    sudo chmod +x /usr/local/bin/zellij

    log_success "Zellij installed"
}

set_zsh_default() {
    log_info "Setting Zsh as default shell..."

    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "Zsh is already the default shell"
        return 0
    fi

    local zsh_path=$(which zsh)

    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    chsh -s "$zsh_path"
    log_success "Default shell changed to Zsh"
}

main_wsl() {
    log_info "Starting WSL setup..."

    install_packages_wsl
    install_zellij_wsl
    install_oh_my_zsh      # from setup_common.sh
    install_zsh_plugins    # from setup_common.sh
    set_zsh_default
    source "$DOTFILES_DIR/scripts/setup_symlinks.sh"
    setup_symlinks "$DOTFILES_DIR"
    install_uv             # from setup_common.sh
    install_nvm            # from setup_common.sh
    setup_folder_structure # from setup_common.sh

    log_success "WSL setup completed!"
    log_info "Note: Some Windows apps (Cursor, Obsidian) should be installed on Windows side"
}

main_wsl
