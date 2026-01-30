# Cross-Platform Dotfiles Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure dotfiles to work across macOS, Linux (Omarchy), and Windows (WSL2) with shared configs and OS-specific overlays.

**Architecture:** Layered configuration approach - a common base sourced by all systems, then OS-specific overlays loaded based on detection. Single `install.sh` entry point that auto-detects OS and runs the appropriate setup.

**Tech Stack:** Bash scripts, zsh, Neovim (LazyVim), Zellij, Git

---

## Task 1: Restructure Directory Layout

**Files:**
- Create: `shell/` directory
- Create: `git/` directory
- Create: `zellij/` directory
- Create: `nvim/` directory
- Move: `dotfiles/.zshrc` → `shell/zshrc.common` (rename + modify)
- Move: `dotfiles/.gitconfig` → `git/gitconfig`
- Delete: `dotfiles/` directory (after migration)

**Step 1: Create new directory structure**

```bash
cd /Users/vedran/Documents/github/vblazenka/dotfiles
mkdir -p shell git zellij nvim
```

**Step 2: Move gitconfig (unchanged - it's universal)**

```bash
mv dotfiles/.gitconfig git/gitconfig
```

**Step 3: Verify moves**

Run: `ls -la shell/ git/`
Expected: gitconfig in git/, shell/ empty (will be populated in Task 2)

**Step 4: Commit structure change**

```bash
git add -A
git commit -m "refactor: create new directory structure for cross-platform support"
```

---

## Task 2: Split zshrc into Layers

**Files:**
- Create: `shell/zshrc` (loader)
- Create: `shell/zshrc.common` (shared config)
- Create: `shell/zshrc.macos` (macOS-specific)
- Create: `shell/zshrc.linux` (Linux-specific)
- Create: `shell/zshrc.wsl` (WSL-specific)
- Create: `shell/hushlogin` (suppress login messages)
- Delete: `dotfiles/.zshrc`

**Step 1: Create the loader file `shell/zshrc`**

```bash
# Vedran's Zsh Configuration Loader
# Detects OS and sources appropriate config files

DOTFILES_SHELL="${0:A:h}"

# Source common configuration (works on all platforms)
source "$DOTFILES_SHELL/zshrc.common"

# Detect OS and source platform-specific config
case "$(uname -s)" in
    Darwin)
        source "$DOTFILES_SHELL/zshrc.macos"
        ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            source "$DOTFILES_SHELL/zshrc.wsl"
        else
            source "$DOTFILES_SHELL/zshrc.linux"
        fi
        ;;
esac
```

**Step 2: Create `shell/zshrc.common` with shared config**

Extract from current `.zshrc` - everything except OS-specific parts:

```bash
# Vedran's Zsh Configuration - Common Settings
# Shared across macOS, Linux, and WSL

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Plugins (installed by setup script)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
)

# Load Oh My Zsh if installed
[[ -d "$ZSH" ]] && source "$ZSH/oh-my-zsh.sh"

# Environment
export LANG=en_US.UTF-8
export EDITOR='nvim'

# Shell aliases
alias reload="source ~/.zshrc"
alias ezsh="$EDITOR ~/.zshrc"
alias vim='nvim'

# Directory navigation
alias ..="cd .. && pwd"
alias ...="cd ../.."
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Project navigation
alias cdg='cd ~/Documents/github'
alias cdgv='cd ~/Documents/github/vblazenka'
alias cdp='cd ~/Documents/projects'
alias cds='cd ~/Documents/scripts'
alias cdn='cd ~/Documents/notes'

# Git shortcuts
alias g="git"
alias gp="g pull"
alias gs="g status"
alias gb="g branch"
alias gaa="g add ."
alias gc="g commit -m"
alias gr="g rebase master"
alias grc="g add . && git rebase --continue"
alias gch="git checkout"
alias gl="git log"
alias glog="git log --oneline --graph --decorate"

# Python/UV aliases
alias py='python3'
alias pip='pip3'
alias uvi='uv init'
alias uva='uv add'
alias uvr='uv run'
alias uvs='uv sync'
alias uvl='uv lock'
alias uvt='uv tool install'
alias uvp='uv python install'

# Custom prompt
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

setopt PROMPT_SUBST
PROMPT='%F{cyan}$%f $(parse_git_branch): '

# Common PATH additions
export PATH="$HOME/.local/bin:$PATH"

# NVM configuration (location is same on all platforms)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
```

**Step 3: Create `shell/zshrc.macos`**

```bash
# Vedran's Zsh Configuration - macOS Specific

# Homebrew paths (Apple Silicon)
if [[ -d "/opt/homebrew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew paths (Intel)
if [[ -d "/usr/local/Homebrew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# macOS-specific aliases
alias update='brew update && brew upgrade'
alias install='brew install'
alias search='brew search'

# Clipboard (native on macOS)
alias clip='pbcopy'
alias paste='pbpaste'

# Open Finder
alias o='open .'

# Application shortcuts (macOS style)
alias cursor='open -a "Cursor"'
alias obsidian='open -a "Obsidian"'

# Go configuration (Homebrew location)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
if [[ -d "/opt/homebrew/opt/go/libexec" ]]; then
    export GOROOT="/opt/homebrew/opt/go/libexec"
    export PATH="$GOROOT/bin:$PATH"
fi
```

**Step 4: Create `shell/zshrc.linux`**

```bash
# Vedran's Zsh Configuration - Linux Specific

# System aliases (apt-based - adjust if using different distro)
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'

# Clipboard (requires xclip)
alias clip='xclip -selection clipboard'
alias paste='xclip -selection clipboard -o'

# Application shortcuts (Linux style)
alias cursor='~/Applications/cursor.appimage &>/dev/null &'
alias obsidian='flatpak run md.obsidian.Obsidian &>/dev/null &'

# Go configuration (standard Linux location)
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
```

**Step 5: Create `shell/zshrc.wsl`**

```bash
# Vedran's Zsh Configuration - WSL Specific

# System aliases (apt-based in WSL)
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'

# Clipboard (use Windows clip.exe)
alias clip='clip.exe'
alias paste='powershell.exe -command "Get-Clipboard"'

# Open Windows Explorer
alias explorer='explorer.exe .'
alias o='explorer.exe .'

# Application shortcuts (launch Windows apps)
alias cursor='cmd.exe /c start cursor'
alias obsidian='cmd.exe /c start obsidian'

# Go configuration
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# WSL-specific: Access Windows home
alias cdwin='cd /mnt/c/Users/$USER'
```

**Step 6: Create `shell/hushlogin`**

```bash
# Empty file - its presence suppresses the "Last login" message
touch shell/hushlogin
```

**Step 7: Remove old zshrc and dotfiles directory**

```bash
rm dotfiles/.zshrc
rmdir dotfiles 2>/dev/null || rm -r dotfiles  # Remove if empty or has only hidden files
```

**Step 8: Verify all files exist**

Run: `ls -la shell/`
Expected: zshrc, zshrc.common, zshrc.macos, zshrc.linux, zshrc.wsl, hushlogin

**Step 9: Commit shell restructure**

```bash
git add -A
git commit -m "refactor: split zshrc into common + OS-specific layers"
```

---

## Task 3: Add Zellij Config

**Files:**
- Copy: `~/.config/zellij/config.kdl` → `zellij/config.kdl`

**Step 1: Copy existing Zellij config**

```bash
cp ~/.config/zellij/config.kdl zellij/config.kdl
```

**Step 2: Verify copy**

Run: `head -20 zellij/config.kdl`
Expected: Should see keybinds configuration

**Step 3: Commit Zellij config**

```bash
git add zellij/config.kdl
git commit -m "feat: add zellij configuration"
```

---

## Task 4: Add Neovim Config

**Files:**
- Copy: `~/.config/nvim/*` → `nvim/` (excluding .git)

**Step 1: Copy Neovim config (excluding .git)**

```bash
rsync -av --exclude='.git' ~/.config/nvim/ nvim/
```

**Step 2: Verify copy**

Run: `ls -la nvim/`
Expected: init.lua, lua/, lazy-lock.json, etc. (NO .git directory)

**Step 3: Commit Neovim config**

```bash
git add nvim/
git commit -m "feat: add neovim (lazyvim) configuration"
```

---

## Task 5: Update OS Detection Script

**Files:**
- Modify: `scripts/detect_os.sh`

**Step 1: Update detect_os.sh with WSL detection**

Replace contents with:

```bash
#!/bin/bash

# OS Detection Script
# Returns: macos, linux, wsl, or unknown

detect_os() {
    OS_TYPE=""

    case "$(uname -s)" in
        Darwin)
            OS_TYPE="macos"
            ;;
        Linux)
            # Check for WSL
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS_TYPE="wsl"
            elif [[ -f /etc/os-release ]]; then
                source /etc/os-release
                # Normalize to just "linux" - distro-specific handled in setup
                OS_TYPE="linux"
                LINUX_DISTRO="$ID"  # Available for setup scripts if needed
            else
                OS_TYPE="linux"
            fi
            ;;
        *)
            OS_TYPE="unknown"
            ;;
    esac

    export OS_TYPE
    export LINUX_DISTRO
}
```

**Step 2: Verify script syntax**

Run: `bash -n scripts/detect_os.sh`
Expected: No output (no syntax errors)

**Step 3: Commit detection update**

```bash
git add scripts/detect_os.sh
git commit -m "refactor: simplify OS detection, add WSL support"
```

---

## Task 6: Create Symlink Setup Script

**Files:**
- Create: `scripts/setup_symlinks.sh`

**Step 1: Create symlink script**

```bash
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
```

**Step 2: Verify script syntax**

Run: `bash -n scripts/setup_symlinks.sh`
Expected: No output (no syntax errors)

**Step 3: Commit symlink script**

```bash
git add scripts/setup_symlinks.sh
git commit -m "feat: add symlink setup script"
```

---

## Task 7: Create Common Setup Functions

**Files:**
- Create: `scripts/setup_common.sh`

**Step 1: Create shared functions used by all platforms**

```bash
#!/bin/bash

# Common Setup Functions
# Shared across macOS, Linux, and WSL setup scripts

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

    # zsh-autosuggestions
    if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom/plugins/zsh-autosuggestions"
        log_success "Installed zsh-autosuggestions"
    else
        log_success "zsh-autosuggestions already installed"
    fi

    # zsh-syntax-highlighting
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
```

**Step 2: Verify script syntax**

Run: `bash -n scripts/setup_common.sh`
Expected: No output (no syntax errors)

**Step 3: Commit common functions**

```bash
git add scripts/setup_common.sh
git commit -m "feat: extract common setup functions to shared script"
```

---

## Task 8: Create macOS Setup Script

**Files:**
- Create: `scripts/setup_macos.sh`

**Step 1: Create macOS setup script**

```bash
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
```

**Step 2: Verify script syntax**

Run: `bash -n scripts/setup_macos.sh`
Expected: No output (no syntax errors)

**Step 3: Commit macOS script**

```bash
git add scripts/setup_macos.sh
git commit -m "feat: add macOS setup script"
```

---

## Task 9: Create Linux Setup Script

**Files:**
- Create: `scripts/setup_linux.sh`
- Delete: `scripts/setup_linux_mint.sh` (replaced)

**Step 1: Create Linux setup script**

```bash
#!/bin/bash

# Linux Setup Script
# Works for Debian/Ubuntu-based distros (apt)
# Omarchy uses apt
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
        PKG_UPDATE="sudo dnf check-update"
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
        "xclip"
        "unzip"
    )

    for package in "${packages[@]}"; do
        log_info "Installing $package..."
        $PKG_INSTALL "$package" || log_warning "Failed to install $package"
    done

    log_success "Package installation completed"
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

    chsh -s "$zsh_path"
    log_success "Default shell changed to Zsh"
}

main_linux() {
    log_info "Starting Linux setup..."

    detect_package_manager
    install_packages_linux
    install_zellij_linux
    install_oh_my_zsh      # from setup_common.sh
    install_zsh_plugins    # from setup_common.sh
    set_zsh_default
    source "$DOTFILES_DIR/scripts/setup_symlinks.sh"
    setup_symlinks "$DOTFILES_DIR"
    install_uv             # from setup_common.sh
    install_nvm            # from setup_common.sh
    setup_folder_structure # from setup_common.sh

    log_success "Linux setup completed!"
}

main_linux
```

**Step 2: Remove old Linux Mint script**

```bash
rm scripts/setup_linux_mint.sh
```

**Step 3: Verify script syntax**

Run: `bash -n scripts/setup_linux.sh`
Expected: No output (no syntax errors)

**Step 4: Commit Linux script**

```bash
git add scripts/setup_linux.sh
git rm scripts/setup_linux_mint.sh
git commit -m "feat: replace linux_mint script with generic linux setup"
```

---

## Task 10: Create WSL Setup Script

**Files:**
- Create: `scripts/setup_wsl.sh`

**Step 1: Create WSL setup script**

```bash
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
```

**Step 2: Verify script syntax**

Run: `bash -n scripts/setup_wsl.sh`
Expected: No output (no syntax errors)

**Step 3: Commit WSL script**

```bash
git add scripts/setup_wsl.sh
git commit -m "feat: add WSL setup script"
```

---

## Task 11: Update Main Install Script

**Files:**
- Modify: `install.sh`

**Step 1: Update install.sh with new OS routing**

Replace contents with:

```bash
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
```

**Step 2: Verify script syntax**

Run: `bash -n install.sh`
Expected: No output (no syntax errors)

**Step 3: Commit install.sh update**

```bash
git add install.sh
git commit -m "refactor: update install.sh for cross-platform support"
```

---

## Task 12: Clean Up and Update Packages

**Files:**
- Delete: `packages/packages_linux_mint.txt`
- Delete: `packages/` directory
- Delete: `scripts/setup_ubuntu.sh` (if exists, referenced but not created)

**Step 1: Remove packages directory (packages are now inline in scripts)**

```bash
rm -rf packages/
```

**Step 2: Remove any orphaned scripts**

```bash
rm -f scripts/setup_ubuntu.sh 2>/dev/null || true
```

**Step 3: Verify clean structure**

Run: `ls -la`
Expected: install.sh, scripts/, shell/, git/, zellij/, nvim/, docs/, README.md

**Step 4: Commit cleanup**

```bash
git add -A
git commit -m "chore: remove packages directory, inline package lists in setup scripts"
```

---

## Task 13: Test on Current Machine (macOS)

**Step 1: Run a dry-run test of the install script structure**

```bash
# Just verify syntax of all scripts
for script in install.sh scripts/*.sh; do
    bash -n "$script" && echo "OK: $script" || echo "FAIL: $script"
done
```

Expected: All scripts should show "OK"

**Step 2: Test OS detection**

```bash
source scripts/detect_os.sh && detect_os && echo "Detected: $OS_TYPE"
```

Expected: `Detected: macos`

**Step 3: Test symlink creation manually**

```bash
# Source helper functions
source install.sh 2>/dev/null || true
source scripts/setup_symlinks.sh
setup_symlinks "$PWD"
```

Verify: `ls -la ~/.zshrc ~/.gitconfig ~/.config/zellij/config.kdl ~/.config/nvim`
Expected: All should be symlinks pointing to dotfiles repo

**Step 4: Test zsh config loads correctly**

```bash
zsh -c "source ~/.zshrc && echo 'Zsh config loaded successfully'"
```

Expected: "Zsh config loaded successfully" (may show some warnings about missing things, that's OK)

---

## Task 14: Update README

**Files:**
- Modify: `README.md`

**Step 1: Update README with new structure and usage**

```markdown
# Dotfiles

Cross-platform dotfiles for macOS, Linux, and Windows (WSL2).

## Quick Start

```bash
git clone https://github.com/vblazenka/dotfiles.git ~/Documents/github/vblazenka/dotfiles
cd ~/Documents/github/vblazenka/dotfiles
./install.sh
```

The install script automatically detects your OS and:
- Installs required packages (zsh, neovim, zellij, etc.)
- Sets up Oh My Zsh with plugins
- Creates symlinks for all configs
- Installs development tools (UV, NVM)

## Supported Systems

- **macOS** - Uses Homebrew
- **Linux** - Uses apt (Debian/Ubuntu-based, including Omarchy)
- **WSL2** - Windows Subsystem for Linux

## Structure

```
dotfiles/
├── install.sh           # Main entry point
├── scripts/
│   ├── detect_os.sh     # OS detection
│   ├── setup_common.sh  # Shared functions
│   ├── setup_symlinks.sh
│   ├── setup_macos.sh
│   ├── setup_linux.sh
│   └── setup_wsl.sh
├── shell/
│   ├── zshrc            # Loader (sources others)
│   ├── zshrc.common     # Shared config
│   ├── zshrc.macos      # macOS-specific
│   ├── zshrc.linux      # Linux-specific
│   ├── zshrc.wsl        # WSL-specific
│   └── hushlogin        # Suppress login message
├── git/
│   └── gitconfig
├── zellij/
│   └── config.kdl
└── nvim/
    └── (LazyVim config)
```

## What Gets Installed

- **Shell**: Zsh + Oh My Zsh + plugins (autosuggestions, syntax highlighting)
- **Editor**: Neovim with LazyVim
- **Terminal**: Zellij
- **Python**: UV package manager
- **Node.js**: NVM + LTS version
- **Packages**: git, curl, wget, ripgrep, tree, htop, etc.

## Manual Steps After Install

1. Restart your terminal (or run `zsh`)
2. Open Neovim - plugins will auto-install on first launch
3. Configure any additional tools as needed

## Customization

- Add aliases to `shell/zshrc.common` (shared) or OS-specific files
- Edit `git/gitconfig` for git settings
- Modify `zellij/config.kdl` for terminal multiplexer
- Neovim config is in `nvim/` (LazyVim-based)
```

**Step 2: Commit README**

```bash
git add README.md
git commit -m "docs: update README for cross-platform setup"
```

---

## Summary

After completing all 14 tasks, the dotfiles structure will be:

```
dotfiles/
├── install.sh              # Entry point - detects OS, runs setup
├── README.md               # Updated documentation
├── scripts/
│   ├── detect_os.sh        # Returns: macos, linux, wsl
│   ├── setup_common.sh     # Shared functions (oh-my-zsh, nvm, uv, etc.)
│   ├── setup_symlinks.sh   # Creates all symlinks
│   ├── setup_macos.sh      # Homebrew-based setup
│   ├── setup_linux.sh      # apt-based setup (generic)
│   └── setup_wsl.sh        # WSL-specific setup
├── shell/
│   ├── zshrc               # Loader - sources common + OS-specific
│   ├── zshrc.common        # Shared aliases, plugins, prompt
│   ├── zshrc.macos         # brew aliases, pbcopy, Go paths
│   ├── zshrc.linux         # apt aliases, xclip, Linux paths
│   ├── zshrc.wsl           # Windows interop, clip.exe
│   └── hushlogin           # Suppress "Last login" message
├── git/
│   └── gitconfig           # Universal git config
├── zellij/
│   └── config.kdl          # Terminal multiplexer config
├── nvim/
│   ├── init.lua
│   ├── lua/
│   └── ...                 # LazyVim config
└── docs/
    └── plans/
        └── 2026-01-30-cross-platform-dotfiles.md
```

Usage on any machine:
```bash
git clone https://github.com/vblazenka/dotfiles.git ~/Documents/github/vblazenka/dotfiles
cd ~/Documents/github/vblazenka/dotfiles
./install.sh
```
