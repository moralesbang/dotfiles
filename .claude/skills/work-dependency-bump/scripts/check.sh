#!/usr/bin/env bash
# Dependency-pin rule for humand-backoffice and humand-web — its single source. A branch keeps the
# `@humanddev/hu-translations` and `@humanddev/material-hu` entries of `bun.lock` and `package.json`
# at its fork point (merge-base with the nearest of origin/develop and the two newest
# origin/release-*); only the automated bump PR moves them.
#   check.sh          exit 0 when HEAD keeps the fork point's entries, 1 otherwise.
#   check.sh --hook   PreToolUse(Bash): exit 2 on a `git commit` that moves them anywhere else.
entry='"@humanddev/(hu-translations|material-hu)":'
repos='HumandDev/(humand-backoffice|humand-web)(\.git)?$'
files='bun.lock package.json'

# entries <dir> <rev> <file>: the file's pin lines at <rev>: `HEAD:`, `:` (index), `wt` (working tree).
entries() {
  if [[ $2 == wt ]]; then
    grep -E "$entry" "$(git -C "$1" rev-parse --show-toplevel)/$3"
  else
    git -C "$1" show "$2$3" 2>/dev/null | grep -E "$entry"
  fi
}

# fork <dir>: the merge-base with the nearest base.
fork() {
  local ref mb n min='' best=''
  for ref in $(
    git -C "$1" for-each-ref --format='%(refname:short)' refs/remotes/origin/develop
    git -C "$1" for-each-ref --format='%(refname:short)' 'refs/remotes/origin/release-*' |
      grep -E '/release-[0-9]{4}\.[0-9]{2}\.[0-9]{2}$' | sort | tail -2
  ); do
    mb=$(git -C "$1" merge-base HEAD "$ref") || continue
    n=$(git -C "$1" rev-list --count "$mb..HEAD")
    if [[ -z $min ]] || ((n < min)); then min=$n best=$mb; fi
  done
  echo "$best"
}

if [[ $1 != --hook ]]; then
  base=$(fork .)
  [[ -n $base ]] || { echo "No origin/develop or origin/release-* to compare against: fetch origin." >&2; exit 1; }
  for f in $files; do
    [[ "$(entries . HEAD: "$f")" == "$(entries . "$base:" "$f")" ]] && continue
    echo "HEAD moves the @humanddev entries of $f away from the fork point $(git rev-parse --short "$base")." >&2
    exit 1
  done
  exit 0
fi

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
[[ $cmd == *commit* ]] || exit 0
dir=$(jq -r '.cwd // empty' <<<"$input")
[[ -n $dir ]] || dir=$PWD
staged=' ' # "<toplevel>/<file>" entries a `git add` earlier in the command stages from the working tree

path() { local p=${1/#\~/$HOME}; [[ $p == /* ]] && echo "$p" || echo "$dir/$p"; }

consumer() { git -C "$1" remote get-url origin 2>/dev/null | grep -qE "$repos"; }

# touched <dir> <all> [pathspec...]: the files of $files the pathspecs (or <all>) reach.
touched() {
  local d=$1 all=$2
  shift 2
  if (($#)); then
    git -C "$d" ls-files --full-name -- "$@" 2>/dev/null | grep -xE "${files// /|}"
  elif [[ -n $all ]]; then
    tr ' ' '\n' <<<"$files"
  fi
}

git_add() {
  local d=$1 all='' specs=() a top f
  shift
  while (($#)); do
    a=$1; shift
    case $a in
      --) specs+=("$@"); break ;;
      -A | --all | -u | --update) all=1 ;;
      --*) ;;
      -*) [[ $a =~ ^-[a-zA-Z]*[Au] ]] && all=1 ;;
      *) specs+=("$a") ;;
    esac
  done
  consumer "$d" || return 0
  top=$(git -C "$d" rev-parse --show-toplevel)
  for f in $(touched "$d" "$all" "${specs[@]}"); do staged+="$top/$f "; done
}

git_commit() {
  local d=$1 all='' specs=() a top f rev base=''
  shift
  while (($#)); do
    a=$1; shift
    case $a in
      --) specs+=("$@"); break ;;
      -a | --all) all=1 ;;
      -m | -F | -C | -c | -t | --message | --file | --reuse-message | --reedit-message | --template | \
        --author | --date | --fixup | --squash | --trailer | --cleanup) shift ;;
      --*) ;;
      -*)
        [[ $a =~ ^-[a-zA-Z]*a ]] && all=1
        [[ $a =~ ^-[a-zA-Z]*[mFCct]$ ]] && shift ;;
      *) specs+=("$a") ;;
    esac
  done
  consumer "$d" || return 0
  git -C "$d" rev-parse -q --verify MERGE_HEAD >/dev/null && return 0
  top=$(git -C "$d" rev-parse --show-toplevel)
  local wt=" $(touched "$d" "$all" "${specs[@]}" | tr '\n' ' ') "
  for f in $files; do
    rev=:
    [[ $wt == *" $f "* || $staged == *" $top/$f "* ]] && rev=wt
    [[ "$(entries "$d" "$rev" "$f")" == "$(entries "$d" HEAD: "$f")" ]] && continue
    [[ -n $base ]] || base=$(fork "$d")
    [[ -n $base && "$(entries "$d" "$rev" "$f")" == "$(entries "$d" "$base:" "$f")" ]] && continue
    echo "Blocked: this commit moves the @humanddev/hu-translations or @humanddev/material-hu entry of $f; only the automated bump PR moves it. Leave $f out of the commit (git restore --staged $f, explicit paths) and absorb the dependency through the work-dependency-bump skill." >&2
    exit 2
  done
}

# words <segment>: one word per line, quotes stripped, a quoted run kept as one word.
words() {
  local w q='' acc=''
  for w in $1; do
    if [[ -n $q ]]; then
      acc+=" $w"
      [[ $w == *"$q" ]] || continue
      printf '%s\n' "${acc//$q/}"
      q='' acc=''
    elif [[ $w == *[\"\']* ]]; then
      q=${w//[^\"\']/} && q=${q:0:1}
      if [[ ${w#*"$q"} == *"$q"* ]]; then printf '%s\n' "${w//$q/}"; q=''; else acc=$w; fi
    else
      printf '%s\n' "$w"
    fi
  done
  [[ -z $acc ]] || printf '%s\n' "${acc//$q/}"
}

set -f
cmd=${cmd//&&/$'\n'} cmd=${cmd//||/$'\n'} cmd=${cmd//;/$'\n'} cmd=${cmd//|/$'\n'}
while IFS= read -r seg; do
  w=()
  while IFS= read -r x; do w+=("$x"); done < <(words "$seg")
  ((${#w[@]})) || continue
  if [[ ${w[0]} == cd && -n ${w[1]} ]]; then dir=$(path "${w[1]}"); continue; fi
  for ((i = 0; i < ${#w[@]}; i++)); do
    [[ ${w[i]} == git ]] || continue
    d=$dir
    for ((j = i + 1; j < ${#w[@]}; j++)); do
      case ${w[j]} in
        -C) d=$(path "${w[j + 1]}"); ((j++)) ;;
        -c) ((j++)) ;;
        -*) ;;
        add) git_add "$d" "${w[@]:j+1}"; break ;;
        commit) git_commit "$d" "${w[@]:j+1}"; break ;;
        *) break ;;
      esac
    done
    break
  done
done <<<"$cmd"
exit 0
