# Eza
alias ls='eza --icons=always --group-directories-first'
alias la='eza --all --icons=always --group-directories-first'
alias l='eza --long --all --git --icons=always --group-directories-first'
alias tree='eza --tree --icons'

alias cc='claude'
alias reload='source "$ZDOTDIR/.zshrc"'
alias gst='git status'
alias gco='git checkout'
alias gfo='git fetch origin'
alias ggl='git pull origin $(git branch --show-current)'
alias ggp='git push origin $(git branch --show-current)'
alias ggfl='git push --force-with-lease origin $(git branch --show-current)'
alias gsw='git switch'
alias gswd='git switch develop'
alias grbod='git rebase origin/develop'
alias grb='git rebase'
alias grbo='git rebase --onto'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias lg=lazygit
alias v='nvim'
alias ..='cd ..'
alias oc='opencode'

# bat: cat with syntax highlighting
alias cat='bat --paging=never'
