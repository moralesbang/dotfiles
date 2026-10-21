
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif (( $+commands[brew] )); then
  eval "$(brew shellenv)"
fi
_node_auto_version
