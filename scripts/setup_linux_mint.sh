#!/bin/bash

# Linux Mint Setup Script
# Complete development environment setup with modern tools

setup_package_manager() {
    log_info "Updating package manager (apt)..."
    
    # Update package lists
    sudo apt update
    
    # Install essential packages if not present
    local essential_packages=("curl" "wget" "software-properties-common" "apt-transport-https" "ca-certificates" "gnupg" "lsb-release")
    
    for package in "${essential_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            log_info "Installing $package..."
            sudo apt install -y "$package"
        else
            log_success "$package is already installed"
        fi
    done
    
    log_success "Package manager setup completed"
}

setup_git() {
    log_info "Setting up Git..."
    
    # Install git if not present
    if ! command -v git &> /dev/null; then
        log_info "Installing git..."
        sudo apt install -y git
    else
        log_success "Git is already installed"
    fi
    
    # Show current git version
    git_version=$(git --version)
    log_info "Git version: $git_version"
    
    # Configure git
    configure_git
    
    log_success "Git setup completed"
}

configure_git() {
    log_info "Configuring Git..."
    
    # Backup existing gitconfig if it exists
    if [[ -f ~/.gitconfig ]]; then
        log_warning "Backing up existing ~/.gitconfig to ~/.gitconfig.backup"
        cp ~/.gitconfig ~/.gitconfig.backup
    fi
    
    # Create symlink to dotfiles gitconfig
    if [[ -f "$DOTFILES_DIR/dotfiles/.gitconfig" ]]; then
        ln -sf "$DOTFILES_DIR/dotfiles/.gitconfig" ~/.gitconfig
        log_success "Linked .gitconfig from dotfiles"
    else
        log_error "dotfiles/.gitconfig not found!"
        return 1
    fi
    
    # Verify configuration
    log_info "Current Git configuration:"
    echo "  Name: $(git config user.name)"
    echo "  Email: $(git config user.email)"
    
    # Show available aliases
    log_info "Available Git aliases:"
    git config --get-regexp alias || log_info "No aliases configured"
}

install_neovim() {
    log_info "Installing Neovim..."
    
    if command -v nvim &> /dev/null; then
        log_success "Neovim is already installed"
        return 0
    fi
    
    # Install neovim
    log_info "Installing neovim package..."
    sudo apt install -y neovim
    
    # Show installed version
    nvim_version=$(nvim --version | head -1)
    log_info "Installed: $nvim_version"
    
    # Create vim alias to nvim
    setup_vim_alias
    
    log_success "Neovim setup completed"
}

setup_vim_alias() {
    log_info "Setting up vim alias to nvim..."
    
    # For bash users (fallback)
    if [[ -f ~/.bashrc ]]; then
        if ! grep -q "alias vim='nvim'" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Alias vim to nvim" >> ~/.bashrc
            echo "alias vim='nvim'" >> ~/.bashrc
            log_success "Added vim alias to ~/.bashrc"
        else
            log_success "vim alias already exists in ~/.bashrc"
        fi
    fi
    
    # Note: vim alias is already included in our custom .zshrc
    log_info "vim alias is included in the custom .zshrc configuration"
    
    # Create system-wide alternative (optional - more permanent)
    if command -v update-alternatives &> /dev/null; then
        log_info "Setting up system-wide vim alternative..."
        sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
        sudo update-alternatives --config vim
        log_success "System-wide vim alternative configured"
    fi
    
    log_info "vim alias configured in dotfiles. Will be active after zsh setup completes"
}

install_zsh() {
    log_info "Installing Zsh shell..."
    
    if command -v zsh &> /dev/null; then
        log_success "Zsh is already installed"
    else
        log_info "Installing zsh package..."
        sudo apt install -y zsh
        
        # Show installed version
        zsh_version=$(zsh --version)
        log_info "Installed: $zsh_version"
    fi
    
    # Install Oh My Zsh
    install_oh_my_zsh
    
    # Install additional plugins
    install_zsh_plugins
    
    # Set Zsh as default shell
    set_zsh_default_shell
    
    log_success "Zsh setup completed"
}

install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    
    if [[ -d ~/.oh-my-zsh ]]; then
        log_success "Oh My Zsh is already installed"
        return 0
    fi
    
    # Install Oh My Zsh using the official installer
    log_info "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Backup the default .zshrc created by Oh My Zsh
    if [[ -f ~/.zshrc ]]; then
        log_info "Backing up Oh My Zsh default .zshrc..."
        cp ~/.zshrc ~/.zshrc.ohmyzsh.backup
    fi
    
    log_success "Oh My Zsh installed successfully"
}

install_zsh_plugins() {
    log_info "Installing additional Zsh plugins..."
    
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # Install zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed"
    else
        log_success "zsh-autosuggestions is already installed"
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed"
    else
        log_success "zsh-syntax-highlighting is already installed"
    fi
    
    log_success "Zsh plugins installation completed"
}

set_zsh_default_shell() {
    log_info "Setting Zsh as default shell..."
    
    # Check if zsh is already the default shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "Zsh is already the default shell"
        return 0
    fi
    
    # Get the path to zsh
    local zsh_path=$(which zsh)
    
    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    
    # Change default shell to zsh
    log_info "Changing default shell to zsh..."
    chsh -s "$zsh_path"
    
    log_success "Default shell changed to zsh"
    log_warning "You need to log out and log back in (or restart) for the shell change to take effect"
}

configure_zsh() {
    log_info "Configuring Zsh with custom settings..."
    
    # Create or update .zshrc with dotfiles version if it exists
    if [[ -f "$DOTFILES_DIR/dotfiles/.zshrc" ]]; then
        log_info "Linking custom .zshrc from dotfiles..."
        ln -sf "$DOTFILES_DIR/dotfiles/.zshrc" ~/.zshrc
        log_success "Custom .zshrc linked successfully"
    else
        log_info "No custom .zshrc found in dotfiles, keeping Oh My Zsh default"
        
        # Add some basic customizations to the default .zshrc
        if [[ -f ~/.zshrc ]] && ! grep -q "# Custom aliases" ~/.zshrc; then
            log_info "Adding custom aliases to .zshrc..."
            cat >> ~/.zshrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias vim='nvim'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases (if not using the dotfiles .gitconfig)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
EOF
            log_success "Added custom aliases to .zshrc"
        fi
    fi
}

install_uv() {
    log_info "Installing UV (Python package manager)..."
    
    if command -v uv &> /dev/null; then
        log_success "UV is already installed"
        uv_version=$(uv --version)
        log_info "Current version: $uv_version"
        return 0
    fi
    
    # Install UV using the official installer
    log_info "Downloading and installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Source the shell configuration to make uv available
    source ~/.bashrc 2>/dev/null || source ~/.zshrc 2>/dev/null || true
    
    # Add UV to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
    
    # Verify installation
    if command -v uv &> /dev/null; then
        uv_version=$(uv --version)
        log_success "UV installed successfully: $uv_version"
    else
        log_error "UV installation failed"
        return 1
    fi
}

install_python_with_uv() {
    log_info "Installing latest Python version with UV..."
    
    # Install the latest Python version
    log_info "Installing latest Python version..."
    uv python install
    
    # Install with default executables (python, python3)
    log_info "Setting up default Python executables..."
    uv python install --default
    
    # Show installed Python versions
    log_info "Available Python versions:"
    uv python list
    
    # Note: PATH is already configured in our custom .zshrc
    log_success "Python installation with UV completed"
}

# Python development is handled entirely by UV
# No separate function needed

setup_folder_structure() {
    log_info "Setting up basic folder structure..."
    
    # Create Documents/github/vblazenka directory structure
    local github_dir="$HOME/Documents/github"
    local vblazenka_dir="$HOME/Documents/github/vblazenka"
    
    if [[ ! -d "$github_dir" ]]; then
        log_info "Creating $github_dir directory..."
        mkdir -p "$github_dir"
        log_success "Created $github_dir"
    else
        log_success "$github_dir already exists"
    fi
    
    if [[ ! -d "$vblazenka_dir" ]]; then
        log_info "Creating $vblazenka_dir directory..."
        mkdir -p "$vblazenka_dir"
        log_success "Created $vblazenka_dir"
    else
        log_success "$vblazenka_dir already exists"
    fi
    
    # Create some additional useful directories
    local additional_dirs=(
        "$HOME/Documents/projects"
        "$HOME/Documents/scripts"
        "$HOME/Documents/notes"
    )
    
    for dir in "${additional_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "Creating $dir directory..."
            mkdir -p "$dir"
            log_success "Created $dir"
        else
            log_success "$dir already exists"
        fi
    done
    
    log_success "Folder structure setup completed"
}

install_nvm() {
    log_info "Installing NVM (Node Version Manager)..."
    
    if [[ -d "$HOME/.nvm" ]]; then
        log_success "NVM is already installed"
        return 0
    fi
    
    # Download and install NVM
    log_info "Downloading NVM installer..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Source NVM immediately
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # Install latest LTS Node.js
    log_info "Installing latest LTS Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    # Show installed versions
    log_info "Node.js version: $(node --version)"
    log_info "npm version: $(npm --version)"
    
    log_success "NVM and Node.js installation completed"
}

install_zed() {
    log_info "Installing Zed editor..."
    
    if command -v zed &> /dev/null; then
        log_success "Zed is already installed"
        return 0
    fi
    
    # Install Zed using official installer
    log_info "Downloading and installing Zed..."
    curl -f https://zed.dev/install.sh | sh
    
    # Verify installation
    if command -v zed &> /dev/null; then
        log_success "Zed editor installed successfully"
    else
        log_error "Zed installation failed"
        return 1
    fi
}

install_cursor() {
    log_info "Installing Cursor AI editor..."
    
    if [[ -f "$HOME/Applications/cursor.appimage" ]] || command -v cursor &> /dev/null; then
        log_success "Cursor is already installed"
        return 0
    fi
    
    # Install libfuse2 for AppImage support
    if ! dpkg -l | grep -q "^ii  libfuse2 "; then
        log_info "Installing libfuse2 for AppImage support..."
        sudo apt install -y libfuse2
    fi
    
    # Create Applications directory
    mkdir -p "$HOME/Applications"
    
    # Download Cursor AppImage
    log_info "Downloading Cursor AppImage..."
    wget "https://downloader.cursor.sh/linux/appImage/x64" -O "$HOME/Applications/cursor.appimage"
    
    # Make executable
    chmod +x "$HOME/Applications/cursor.appimage"
    
    log_success "Cursor AI editor installed to ~/Applications/cursor.appimage"
    log_info "Run with: ~/Applications/cursor.appimage"
}

install_obsidian() {
    log_info "Installing Obsidian..."
    
    # Check if Obsidian is already installed via Flatpak
    if flatpak list | grep -q "md.obsidian.Obsidian"; then
        log_success "Obsidian is already installed"
        return 0
    fi
    
    # Install Flatpak if not present
    if ! command -v flatpak &> /dev/null; then
        log_info "Installing Flatpak..."
        sudo apt install -y flatpak
        sudo apt install -y gnome-software-plugin-flatpak
    fi
    
    # Add Flathub repository if not already added
    if ! flatpak remotes | grep -q "flathub"; then
        log_info "Adding Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    
    # Install Obsidian
    log_info "Installing Obsidian via Flatpak..."
    sudo flatpak install -y flathub md.obsidian.Obsidian
    
    log_success "Obsidian installed successfully"
    log_info "Launch with: flatpak run md.obsidian.Obsidian"
}

# Main execution for Linux Mint
main() {
    log_info "Starting Linux Mint setup..."
    
    setup_package_manager
    setup_git
    install_neovim
    install_zsh
    configure_zsh
    install_uv
    install_python_with_uv
    install_nvm
    install_zed
    install_cursor
    install_obsidian
    setup_folder_structure
    
    log_success "Linux Mint setup completed! 🎉"
    log_info "Installed applications:"
    log_info "  • Git with your configuration"
    log_info "  • Neovim (with vim alias)"
    log_info "  • Zsh shell with Oh My Zsh"
    log_info "  • UV (Python package manager)"
    log_info "  • Latest Python version via UV"
    log_info "  • NVM + Node.js (latest LTS)"
    log_info "  • Zed code editor"
    log_info "  • Cursor AI editor"
    log_info "  • Obsidian note-taking app"
    log_info "  • Development folder structure"
    log_warning "Please log out and log back in to use Zsh as your default shell"
    log_info "Navigation aliases: cdg (github), cdgv (vblazenka), cdp (projects)"
    log_info "Quick commands: 'uv python list', 'nvm list', 'cursor', 'obsidian'"
}

# Run main function
main
