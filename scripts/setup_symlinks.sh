#!/bin/bash

# Symlink Setup Script
# Creates symlinks from home directory to dotfiles

setup_symlinks() {
    log_info "Setting up symlinks..."

    local dotfiles_dir="$1"

    # Backup function
    backup_if_exists() {
        local target="$1"
        if [[ -e "$target" && ! -L "$target" ]]; then
            log_warning "Backing up existing $target to ${target}.backup"
            mv "$target" "${target}.backup"
        fi
    }

    # Shell config
    backup_if_exists "$HOME/.zshrc"
    ln -sf "$dotfiles_dir/shell/zshrc" "$HOME/.zshrc"
    log_success "Linked ~/.zshrc"

    # Hushlogin (suppress "Last login" message)
    backup_if_exists "$HOME/.hushlogin"
    ln -sf "$dotfiles_dir/shell/hushlogin" "$HOME/.hushlogin"
    log_success "Linked ~/.hushlogin"

    # Git config
    backup_if_exists "$HOME/.gitconfig"
    ln -sf "$dotfiles_dir/git/gitconfig" "$HOME/.gitconfig"
    log_success "Linked ~/.gitconfig"

    # Zellij config
    mkdir -p "$HOME/.config/zellij"
    backup_if_exists "$HOME/.config/zellij/config.kdl"
    ln -sf "$dotfiles_dir/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
    log_success "Linked ~/.config/zellij/config.kdl"

    # Neovim config (link entire directory)
    # -n flag: treat symlink to directory as file, preventing nested links on re-run
    backup_if_exists "$HOME/.config/nvim"
    ln -sfn "$dotfiles_dir/nvim" "$HOME/.config/nvim"
    log_success "Linked ~/.config/nvim"

    log_success "All symlinks created"
}
