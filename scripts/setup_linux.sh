#!/bin/bash

# Linux Setup Script
# Works for Debian/Ubuntu (apt), Fedora (dnf), and Arch (pacman)
# Uses common functions from setup_common.sh

# Source common functions
source "$DOTFILES_DIR/scripts/setup_common.sh"

detect_package_manager() {
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="sudo apt install -y"
        PKG_UPDATE="sudo apt update"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf makecache"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
    else
        log_error "No supported package manager found"
        exit 1
    fi

    log_info "Detected package manager: $PKG_MANAGER"
}

install_packages_linux() {
    log_info "Installing packages..."

    $PKG_UPDATE

    # fd-find is the Debian/Ubuntu name; Fedora and Arch use fd
    local fd_pkg="fd"
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        fd_pkg="fd-find"
    fi

    local packages=(
        "git"
        "zsh"
        "curl"
        "wget"
        "tree"
        "htop"
        "ripgrep"
        "$fd_pkg"
        "fzf"
        "xclip"
        "unzip"
    )

    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        $PKG_INSTALL "$package" || log_warning "Failed to install $package"
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

install_zellij_linux() {
    log_info "Checking Zellij..."

    if command -v zellij &> /dev/null; then
        log_success "Zellij is already installed"
        return 0
    fi

    log_info "Installing Zellij..."

    # Try cargo first (most reliable)
    if command -v cargo &> /dev/null; then
        cargo install --locked zellij
    else
        # Version pinned - check https://github.com/zellij-org/zellij/releases for updates
        local version="0.40.1"
        local arch=$(uname -m)
        curl -L "https://github.com/zellij-org/zellij/releases/download/v${version}/zellij-${arch}-unknown-linux-musl.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/zellij /usr/local/bin/
        sudo chmod +x /usr/local/bin/zellij
    fi

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

    sudo chsh -s "$zsh_path" "$(whoami)"
    log_success "Default shell changed to Zsh"
}

main_linux() {
    log_info "Starting Linux setup..."

    detect_package_manager
    install_packages_linux
    install_neovim
    install_zellij_linux
    install_oh_my_zsh      # from setup_common.sh
    install_zsh_plugins    # from setup_common.sh
    set_zsh_default
    source "$DOTFILES_DIR/scripts/setup_symlinks.sh"
    setup_symlinks "$DOTFILES_DIR"
    install_uv             # from setup_common.sh
    install_bun            # from setup_common.sh
    install_nvm            # from setup_common.sh
    setup_folder_structure # from setup_common.sh

    log_success "Linux setup completed!"
}

main_linux
