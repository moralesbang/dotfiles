source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/tools.zsh"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# wt shell integration: work-harness checkout first, standalone clone as fallback
for _wt in "$HOME/Projects/work-harness/global-scripts/wt/shell/wt.zsh" "$HOME/Projects/wt/shell/wt.zsh"; do
  [[ -s "$_wt" ]] && { source "$_wt"; break; }
done
unset _wt
