source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/tools.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# wt shell integration
[ -s "$HOME/Projects/wt/shell/wt.zsh" ] && source "$HOME/Projects/wt/shell/wt.zsh"
