# Options
setopt share_history
setopt hist_ignore_dups
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_reduce_blanks

# Plugins & Plugin manager
source "$ZDOTDIR/plugins.zsh"

# Tool integrations (fzf, atuin, zoxide, bat)
source "$ZDOTDIR/tools.zsh"

# Aliases
source "$ZDOTDIR/aliases.zsh"

# History
HISTFILE=${ZDOTDIR}/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
bindkey '^K' up-line-or-history
bindkey '^J' down-line-or-history
