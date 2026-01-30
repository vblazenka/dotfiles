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
