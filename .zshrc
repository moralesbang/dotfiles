# ====================
# PATH base (system + Homebrew)
# ====================
# IMPORTANT: Do NOT move or remove these two lines, and keep them at the very top.
#
# - The explicit PATH reset on line below guarantees that core system binaries
#   (mkdir, rm, git, tr, etc. in /bin and /usr/bin) are always reachable, even
#   if this shell inherited a broken/empty PATH from a parent process.
# - `brew shellenv` MUST run after that reset so Homebrew's bin is prepended to
#   a known-good PATH. If you swap the order, `$PATH` may be empty when brew
#   expands it, leaving the shell without /bin or /usr/bin and breaking
#   everything downstream (oh-my-zsh, nvm, atuin, zoxide, aliases, etc.).
# - This must live in .zshrc (not only .zprofile) because tmux and other tools
#   spawn non-login shells that never source .zprofile.
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
eval "$(/opt/homebrew/bin/brew shellenv)"

# ====================
# Oh My Zsh
# ====================
export ZSH="$HOME/.oh-my-zsh"
plugins=(git vi-mode zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# ====================
# Prompt
# ====================
eval "$(starship init zsh)"

# ====================
# Shell tools
# ====================
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"

# ====================
# Node
# ====================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun
[ -s "/Users/moralesbang/.bun/_bun" ] && source "/Users/moralesbang/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ====================
# Git
# ====================
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa_hu -F ~/.ssh/config"

# ====================
# PATH
# ====================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/Users/moralesbang/.antigravity/antigravity/bin:$PATH"


# ====================
# Claude Code
# ====================
# export CLAUDE_CODE_NO_FLICKER=1

# ====================
# Editor
# ====================
export EDITOR='nvim'
alias v='nvim'
alias cc='claude'
alias oc='opencode'
alias lg='lazygit'

# ====================
# hu - Humand dev environment
# ====================
hu() {
  local base="$HOME/Projects/Humand"
  local -A repos=(
    [web]="$base/hu-web"
    [backoffice]="$base/hu-backoffice"
    [translations]="$base/hu-translations"
    [material]="$base/hu-material-ds"
  )

  # Create sessions
  # NOTE: Do NOT name the loop variable `path` — in zsh, $path is a tied array
  # that mirrors $PATH. Assigning to it overwrites PATH and breaks every
  # command in the shell.
  for name repo_path in "${(@kv)repos}"; do
    if ! tmux has-session -t "$name" 2>/dev/null; then
      tmux new-session -d -s "$name" -c "$repo_path"
      tmux split-window -h -t "$name" -c "$repo_path" -l 30%
      tmux send-keys -t "$name":1.1 'nvim' C-m
      tmux send-keys -t "$name":1.2 'claude' C-m
      tmux select-pane -t "$name":1.1
    fi
  done

  # Attach to web (or switch if already inside tmux)
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t web
  else
    tmux attach-session -t web
  fi
}

alias clauded='claude --dangerously-skip-permissions'

# Owlet tracker
export PATH="$HOME/Projects/owlet-tracker/dist:$PATH"

# material-hu visual tests: ssh alias whose key has access to HumandDev repos
export VISUAL_SSH_HOST=github-work

# Rust/cargo binaries
export PATH="$HOME/.cargo/bin:$PATH"
