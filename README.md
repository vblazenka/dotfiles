# Dotfiles

Personal macOS development environment: Zsh, Neovim (LazyVim), Zellij, Git.

## Quick Start

```bash
git clone https://github.com/vblazenka/dotfiles.git ~/Documents/github/vblazenka/dotfiles
cd ~/Documents/github/vblazenka/dotfiles
./install.sh
```

The install script:
- Installs Homebrew (if missing) and required packages
- Sets up Oh My Zsh with plugins
- Symlinks all configs into place (existing files are backed up with a `.backup` suffix)
- Installs development tools (UV, Bun, NVM + Node LTS)
- Creates the `~/Documents/{github/vblazenka,projects,scripts,notes}` folders

## Structure

```
dotfiles/
├── install.sh                 # Entry point (macOS only)
├── scripts/
│   ├── setup_tools.sh         # Homebrew, packages, Oh My Zsh, UV, Bun, NVM
│   └── setup_symlinks.sh      # Links configs into $HOME
├── shell/
│   ├── zshrc                  # -> ~/.zshrc
│   └── hushlogin              # -> ~/.hushlogin (suppress "Last login" banner)
├── git/
│   └── gitconfig              # -> ~/.gitconfig
├── zellij/
│   └── config.kdl             # -> ~/.config/zellij/config.kdl
└── nvim/                      # -> ~/.config/nvim (LazyVim)
```

## What Gets Installed

- **Shell**: Zsh + Oh My Zsh + plugins (autosuggestions, syntax highlighting)
- **Editor**: Neovim with LazyVim
- **Terminal multiplexer**: Zellij
- **Python**: UV
- **JavaScript**: NVM + Node LTS, Bun
- **CLI tools**: git, curl, wget, ripgrep, fd, fzf, tree, htop, direnv, hunk (git pager)

Optional tools referenced by the shell config but not installed by the script:
Go and OpenJDK (via Homebrew), pnpm, opencode, Maestro. Their PATH entries are harmless when absent.

## Manual Steps After Install

1. Restart your terminal (or run `zsh`)
2. Open Neovim; plugins install automatically on first launch
3. Put secrets (private registry tokens, etc.) in `~/.zshenv`, which is not part of this repo

## Customization

- Aliases and functions: `shell/zshrc`
- Git settings and aliases: `git/gitconfig`
- Zellij keybindings: `zellij/config.kdl`
- Neovim: `nvim/lua/config/` and `nvim/lua/plugins/`
