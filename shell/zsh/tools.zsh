# CLI tool integrations. Order matters: fzf binds ^R first, atuin re-binds it
# after, so atuin owns ^R and fzf keeps ^T (files) and Alt-C (cd).

# fzf: Catppuccin Mocha theme, preserving existing options
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

# fzf: keybindings + completion
source <(fzf --zsh)

# atuin: shell history (^R). Up-arrow stays native.
eval "$(atuin init zsh --disable-up-arrow)"

# zoxide: smarter cd (`z`, `zi`)
eval "$(zoxide init zsh)"

# nvm: sourced on first use (~0.5s); .zshenv already puts the right node on PATH.
export NVM_DIR="$HOME/.nvm"
nvm() {
  unfunction nvm
  source "$NVM_DIR/nvm.sh" --no-use
  nvm "$@"
}
