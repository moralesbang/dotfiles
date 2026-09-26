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
