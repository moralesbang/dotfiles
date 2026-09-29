export ZDOTDIR="$HOME/Projects/dotfiles/zsh"
path=("$HOME/.local/bin" ${path:#$HOME/.local/bin})
path=("$HOME/.bun/bin" ${path:#$HOME/.bun/bin})


# deja overrides
export DEJA_ACCEPT_KEY=
export DEJA_CYCLE_KEY=^N
export DEJA_CYCLE_FUZZY_KEY=
export DEJA_CYCLE_FUZZY_BACK_KEY=
export DEJA_TOGGLE_EMPTY_KEY=

# --- gh CLI: auto-select work account inside ~/Projects/Humand ---
# Lives in .zshenv (not .zshrc) so non-interactive shells — e.g. Claude Code's Bash
# tool — pick it up too. gh honors GH_TOKEN over the active account; the token is read
# from the keyring, not stored. Absolute gh path: PATH is not set up yet at this point.
_gh_auto_account() {
  if [[ "$PWD" == "$HOME/Projects/Humand"* ]]; then
    export GH_TOKEN="$(/opt/homebrew/bin/gh auth token --user jmorales-hu 2>/dev/null)"
  else
    unset GH_TOKEN
  fi
}
_gh_auto_account
if [[ -o interactive ]]; then
  autoload -U add-zsh-hook
  add-zsh-hook chpwd _gh_auto_account
fi

# --- nvim: default file-picker scope inside ~/Projects/Humand ---
# Relative to the repo root; nvim falls back to the whole repo if it doesn't exist there.
_nvim_pick_scope() {
  if [[ "$PWD" == "$HOME/Projects/Humand"* ]]; then
    export NVIM_PICK_SCOPE="src/pages/dashboard/PeopleExperience"
  else
    unset NVIM_PICK_SCOPE
  fi
}
_nvim_pick_scope
if [[ -o interactive ]]; then
  add-zsh-hook chpwd _nvim_pick_scope
fi
