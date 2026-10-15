#!/bin/bash

# Tool installers for macOS
# Functions only; install.sh sources this file and calls them in order.

install_homebrew() {
    log_info "Checking Homebrew..."

    if command -v brew &> /dev/null; then
        log_success "Homebrew is already installed"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for current session
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

install_packages() {
    log_info "Installing packages via Homebrew..."

    # Third-party formulae use the fully qualified tap/name form.
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
        "direnv"              # hooked in shell/zshrc
        "modem-dev/tap/hunk"  # git pager in git/gitconfig
    )

    for package in "${packages[@]}"; do
        local name="${package##*/}"
        if brew list "$name" &>/dev/null; then
            log_success "$name is already installed"
        else
            log_info "Installing $package..."
            brew install "$package"
        fi
    done

    log_success "Package installation completed"
}

install_oh_my_zsh() {
    log_info "Checking Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    fi

    log_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    log_success "Oh My Zsh installed"
}

install_zsh_plugins() {
    log_info "Installing Zsh plugins..."

    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
        log_success "Installed zsh-autosuggestions"
    else
        log_success "zsh-autosuggestions already installed"
    fi

    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$zsh_custom/plugins/zsh-syntax-highlighting"
        log_success "Installed zsh-syntax-highlighting"
    else
        log_success "zsh-syntax-highlighting already installed"
    fi
}

install_uv() {
    log_info "Checking UV..."

    if command -v uv &> /dev/null; then
        log_success "UV is already installed"
        return 0
    fi

    log_info "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"

    log_success "UV installed"
}

install_bun() {
    log_info "Checking Bun..."

    if command -v bun &> /dev/null; then
        log_success "Bun is already installed"
        return 0
    fi

    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash

    log_success "Bun installed"
}

install_nvm() {
    log_info "Checking NVM..."

    if [[ -d "$HOME/.nvm" ]]; then
        log_success "NVM is already installed"
        return 0
    fi

    # Version pinned - check https://github.com/nvm-sh/nvm/releases for updates
    local nvm_version="0.40.1"

    log_info "Installing NVM v${nvm_version}..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh" | bash

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    log_info "Installing Node.js LTS..."
    nvm install --lts
    nvm alias default node

    log_success "NVM and Node.js installed"
}

setup_folder_structure() {
    log_info "Setting up folder structure..."

    local dirs=(
        "$HOME/Documents/github/vblazenka"
        "$HOME/Documents/projects"
        "$HOME/Documents/scripts"
        "$HOME/Documents/notes"
    )

    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
    done

    log_success "Folder structure created"
}
