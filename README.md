# Dotfiles 🤘

Automated development environment setup for Linux Mint and other operating systems.

## Quick Start

```bash
git clone https://github.com/vblazenka/dotfiles.git
cd dotfiles
./install.sh
```

## Repository Structure

```
dotfiles/
├── install.sh              # Main installation script
├── scripts/                 # Installation and setup scripts
│   ├── detect_os.sh        # OS detection utilities  
│   └── setup_linux_mint.sh # Linux Mint specific setup
├── dotfiles/               # Configuration files
│   ├── .gitconfig         # Git configuration
│   └── .zshrc             # Zsh shell configuration
├── packages/               # Package lists per OS
│   └── packages_linux_mint.txt
└── configs/                # System preferences
```

## Current Features

- ✅ **OS Detection**: Automatically detects Linux Mint, Ubuntu, macOS
- ✅ **Git Setup**: Installs git and configures with your information  
- ✅ **Package Manager**: Updates apt and installs essential packages
- ✅ **Dotfiles Management**: Symlinks configuration files safely
- ✅ **Modern Shell**: Zsh with Oh My Zsh, custom prompt and aliases
- ✅ **Python Environment**: UV package manager + latest Python version (self-contained)
- ✅ **Node.js Environment**: NVM + latest LTS Node.js
- ✅ **Code Editors**: Neovim, Zed (Rust-based), Cursor (AI-powered)
- ✅ **Note Taking**: Obsidian via Flatpak
- ✅ **Development Tools**: Build tools, modern development workflow
- ✅ **Folder Structure**: Organized development directories with navigation aliases

## Software Checklist

- [x] Git configuration
- [x] **Neovim** - Modern Vim-based editor (with vim alias)
- [x] **Zsh + Oh My Zsh** - Modern shell with plugins and themes
- [x] **UV + Python** - Modern Python package manager + latest Python
- [x] **NVM + Node.js** - Node Version Manager + latest LTS Node.js
- [x] **Zed** - High-performance code editor (Rust-based)
- [x] **Cursor** - AI-powered code editor (simple AppImage)
- [x] **Obsidian** - Note-taking and knowledge management (Flatpak)
- [ ] Discord
- [ ] Slack

## Python Development with UV

After installation, you can use UV for modern Python development:

```bash
# Install latest Python
uv python install

# Create a new project
uv init my-project
cd my-project

# Add dependencies
uv add requests numpy

# Run Python scripts
uv run script.py

# Install tools globally
uv tool install black ruff

# List Python versions
uv python list
```

## Folder Structure & Navigation

The setup automatically creates an organized development directory structure:

```
~/Documents/
├── github/
│   └── vblazenka/        # Your GitHub projects
├── projects/             # General projects
├── scripts/              # Utility scripts
└── notes/                # Documentation and notes
```

### Quick Navigation Aliases

```bash
cdg      # Jump to ~/Documents/github
cdgv     # Jump to ~/Documents/github/vblazenka
cdp      # Jump to ~/Documents/projects
cds      # Jump to ~/Documents/scripts
cdn      # Jump to ~/Documents/notes
```

These aliases are included in your .zshrc and make navigating your development environment super fast!

## Development Applications

### Code Editors
- **Zed**: Installed via official installer - `zed`
- **Cursor**: Simple AppImage download - `cursor` or `~/Applications/cursor.appimage`
- **Neovim**: Package manager installation with vim alias - `vim` or `nvim`

### Node.js Development
- **NVM**: Node Version Manager - `nvm install node`, `nvm use node`
- **Node.js**: Latest LTS installed automatically

### Python Development
- **UV**: Modern Python package manager - see Python section above
- **Python**: Latest version managed by UV

### Note Taking
- **Obsidian**: Installed via Flatpak - `flatpak run md.obsidian.Obsidian` or from app menu
- Works perfectly with the `~/Documents/notes` folder structure