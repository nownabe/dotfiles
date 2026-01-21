gitwt() {
  # Show help directly
  if [[ $1 == "-h" || $1 == "--help" ]]; then
    git-wt-helper -h
    return
  fi

  # if -b is the first argument, back to the main worktree
  if [[ $1 == "-b" ]]; then
    shift
    local git_common_dir
    if git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null); then
      cd "$git_common_dir/.."
    else
      echo "Not in a git repository" >&2
      return 1
    fi
    return
  fi

  # Check if current directory exists
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
  # Check if the first argument is 'wt'
  if [[ $1 == "wt" ]]; then
    shift  # Remove 'wt' from the arguments
    gitwt "$@"
  elif [[ $1 == "root" ]]; then
    gitroot
  else
    command git "$@"
  fi
}
