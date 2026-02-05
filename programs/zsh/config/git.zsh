gitwt() {
  if [[ $1 == "-h" || $1 == "--help" ]]; then
    git-wt-helper -h
    return
  fi

  if [[ $1 == "-b" ]]; then
    shift
    local git_common_dir
    if git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null); then
      if [[ "$(basename "$git_common_dir")" == ".git" ]]; then
        cd "$git_common_dir/.."
      else
        cd "$git_common_dir"
      fi
    else
      echo "Not in a git repository" >&2
      return 1
    fi
    return
  fi

  if [[ ! -d "${PWD:-}" ]]; then
    echo "Current directory does not exist. Use 'cd' to move to a valid directory." >&2
    return 1
  fi

  local dest
  dest=$(git-wt-helper "$@") || return
  [[ -n $dest ]] && cd "$dest"
}

gitroot() {
  cd "$(git rev-parse --show-toplevel)" || return
}

git() {
  if [[ $1 == "wt" ]]; then
    shift
    gitwt "$@"
  elif [[ $1 == "root" ]]; then
    gitroot
  else
    command git "$@"
  fi
}
