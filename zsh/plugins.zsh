source "$(brew --prefix zinit)/zinit.zsh"

zinit ice wait"0" lucid depth=1 pick"deja.plugin.zsh"
zinit light Giammarco-Ferranti/deja

# Prompt
eval "$(starship init zsh)"

 # Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting
