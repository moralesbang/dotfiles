export ZDOTDIR="${${(%):-%x}:A:h}"  # this file's real directory, wherever the repo lives
path=("$HOME/.local/bin" ${path:#$HOME/.local/bin})
path=("$HOME/.bun/bin" ${path:#$HOME/.bun/bin})
path=("$HOME/Projects/Work/_workspace/scripts" ${path:#$HOME/Projects/Work/_workspace/scripts})


# deja overrides
export DEJA_ACCEPT_KEY=
export DEJA_CYCLE_KEY=^N
export DEJA_CYCLE_FUZZY_KEY=
export DEJA_CYCLE_FUZZY_BACK_KEY=
export DEJA_TOGGLE_EMPTY_KEY=

# --- gh CLI: auto-select work account inside ~/Projects/Work ---
# Lives in .zshenv (not .zshrc) so non-interactive shells — e.g. Claude Code's Bash
# tool — pick it up too. gh honors GH_TOKEN over the active account; the token is read
# from the keyring, not stored. PATH may lack Homebrew here, hence the absolute fallback.
# Outside Work the active account applies: keep it on the personal one (moralesbang).
# The chpwd hook is registered for every shell, so a `cd` inside a Claude Code Bash
# command switches accounts too.
_gh_auto_account() {
  if [[ "$PWD" == "$HOME/Projects/Work"* ]]; then
    local gh_bin="${commands[gh]}"
    [[ -n "$gh_bin" ]] || gh_bin=/opt/homebrew/bin/gh
    if [[ -x "$gh_bin" ]]; then
      export GH_TOKEN="$("$gh_bin" auth token --user jmorales-hu 2>/dev/null)"
    else
      unset GH_TOKEN
    fi
  else
    unset GH_TOKEN
  fi
}
_gh_auto_account
autoload -U add-zsh-hook
add-zsh-hook chpwd _gh_auto_account

# --- nvim: default file-picker scope inside ~/Projects/Work ---
# Relative to the repo root; nvim falls back to the whole repo if it doesn't exist there.
_nvim_pick_scope() {
  if [[ "$PWD" == "$HOME/Projects/Work"* ]]; then
    export NVIM_PICK_SCOPE="src/pages/dashboard/PeopleExperience"
  else
    unset NVIM_PICK_SCOPE
  fi
}
_nvim_pick_scope
if [[ -o interactive ]]; then
  add-zsh-hook chpwd _nvim_pick_scope
fi

# --- node: use the version pinned by the nearest .nvmrc ---
# Prepends that nvm-installed version's bin to PATH, without sourcing nvm.sh (~0.5s).
# Outside a pinned project, or if the version isn't installed, Homebrew's node stays;
# without any other node (Linux), the newest nvm-installed version is used instead.
# Registered for every shell, not just interactive ones, so Claude Code's Bash tool
# runs the project's node too. .zprofile calls it again after `brew shellenv`.
_node_auto_version() {
  # Glob qualifiers below need zsh defaults; host shells (e.g. Claude Code) may differ.
  emulate -L zsh
  path=(${path:#$HOME/.nvm/versions/node/*})
  local dir="$PWD" bin
  while [[ -n "$dir" && ! -f "$dir/.nvmrc" ]]; do dir="${dir%/*}"; done
  if [[ -f "$dir/.nvmrc" ]]; then
    local version="$(<"$dir/.nvmrc")"
    version="v${${version//[[:space:]]/}#v}"
    bin="$HOME/.nvm/versions/node/$version/bin"
  fi
  if [[ ! -d "$bin" ]] && (( ! $+commands[node] )); then
    bin=($HOME/.nvm/versions/node/v*/bin(N/nOn[1]))
  fi
  [[ -d "$bin" ]] && path=("$bin" $path)
}
_node_auto_version
autoload -U add-zsh-hook
add-zsh-hook chpwd _node_auto_version
