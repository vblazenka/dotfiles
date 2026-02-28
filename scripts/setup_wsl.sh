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

install_neovim() {
    log_info "Checking Neovim..."

    # LazyVim requires Neovim >= 0.11.2, apt version is too old
    local required_version="0.11.0"

    if command -v nvim &> /dev/null; then
        local current_version=$(nvim --version | head -1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
        if [[ "$(printf '%s\n' "$required_version" "$current_version" | sort -V | head -1)" == "$required_version" ]]; then
            log_success "Neovim $current_version is already installed"
            return 0
        fi
        log_info "Neovim $current_version is too old, upgrading..."
    fi

    log_info "Installing Neovim from GitHub releases..."

    # Version pinned - check https://github.com/neovim/neovim/releases for updates
    local version="0.11.6"
    local arch=$(uname -m)
    local tmp_dir=$(mktemp -d)

    curl -L "https://github.com/neovim/neovim/releases/download/v${version}/nvim-linux-${arch}.tar.gz" | tar xz -C "$tmp_dir"
    sudo rm -rf /opt/nvim
    sudo mv "$tmp_dir/nvim-linux-${arch}" /opt/nvim
    rm -rf "$tmp_dir"

    # Add to path via symlink
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

    log_success "Neovim $version installed"
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

configure_locale() {
    log_info "Configuring locale..."

    if locale -a 2>/dev/null | grep -q "en_US.utf8"; then
        log_success "Locale en_US.UTF-8 is already configured"
        return 0
    fi

    sudo locale-gen en_US.UTF-8
    log_success "Locale configured"
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

    configure_locale
    install_packages_wsl
    install_neovim
    install_zellij_wsl
    install_oh_my_zsh      # from setup_common.sh
    install_zsh_plugins    # from setup_common.sh
    set_zsh_default
    source "$DOTFILES_DIR/scripts/setup_symlinks.sh"
    setup_symlinks "$DOTFILES_DIR"
    install_uv             # from setup_common.sh
    install_bun            # from setup_common.sh
    install_nvm            # from setup_common.sh
    setup_folder_structure # from setup_common.sh

    log_success "WSL setup completed!"
    log_info "Note: Some Windows apps (Cursor, Obsidian) should be installed on Windows side"
}

main_wsl
