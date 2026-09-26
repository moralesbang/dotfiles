source "$(brew --prefix zinit)/zinit.zsh"

zinit ice wait"0" lucid depth=1 pick"deja.plugin.zsh"
zinit light Giammarco-Ferranti/deja

# Prompt
zinit ice depth=1
zinit light spaceship-prompt/spaceship-prompt

 # Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting
