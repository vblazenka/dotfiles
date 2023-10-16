# Aliases
alias source="source ~/.zshrc"
alias ezsh="vim ~/.zshrc"

alias ..="cd .. && pwd"

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

alias cdgo="cd /usr/local/go"

# Prompt
function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

setopt PROMPT_SUBST
PROMPT='%F{cyan}$%f $(parse_git_branch): '

# NVM
export NVM_DIR=~/.nvm
 [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Go
export PATH=$PATH:/usr/local/go/bin  
