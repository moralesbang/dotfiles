if (( $+commands[brew] )) && [[ -r "$(brew --prefix zinit 2>/dev/null)/zinit.zsh" ]]; then
  source "$(brew --prefix zinit)/zinit.zsh"
else
  source "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"
fi

zinit ice wait"0" lucid depth=1 pick"deja.plugin.zsh"
zinit light Giammarco-Ferranti/deja

# Prompt
eval "$(starship init zsh)"

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting
