# CLI tool integrations. Order matters: fzf binds ^R first, atuin re-binds it
# after, so atuin owns ^R and fzf keeps ^T (files) and Alt-C (cd).

# fzf: keybindings + completion
source <(fzf --zsh)

# atuin: shell history (^R). Up-arrow stays native.
eval "$(atuin init zsh --disable-up-arrow)"

# zoxide: smarter cd (`z`, `zi`)
eval "$(zoxide init zsh)"

