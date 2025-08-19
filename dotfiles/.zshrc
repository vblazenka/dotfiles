# Vedran's Zsh Configuration
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load (using custom prompt instead)
# ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='nvim'

# Shell aliases
alias source="source ~/.zshrc"
alias ezsh="vim ~/.zshrc"
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

# Application shortcuts
alias cursor='~/Applications/cursor.appimage &'
alias obsidian='flatpak run md.obsidian.Obsidian &'

# Git configuration (using your preferred pattern)
alias -g g="git"
alias gp="g pull"
alias gs="g status"
alias gb="g branch"
alias gaa="g add ."
alias gc="g commit -m "
alias gr="g rebase master"
alias grc="g add . && git rebase --continue"
alias gch="git checkout"
alias gl="git log"
alias glog="git log --oneline --graph --decorate"

# Development aliases
alias py='python3'
alias pip='pip3'
alias cdgo="cd /usr/local/go"

# UV (Python package manager) aliases
alias uvi='uv init'
alias uva='uv add'
alias uvr='uv run'
alias uvs='uv sync'
alias uvl='uv lock'
alias uvt='uv tool install'
alias uvp='uv python install'

# System aliases
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'

# Custom prompt (keeping your style)
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

setopt PROMPT_SUBST
PROMPT='%F{cyan}$%f $(parse_git_branch): '

# PATH configuration
export PATH="$HOME/.local/bin:$PATH"

# Go configuration
export PATH=$PATH:/usr/local/go/bin

# NVM configuration
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
